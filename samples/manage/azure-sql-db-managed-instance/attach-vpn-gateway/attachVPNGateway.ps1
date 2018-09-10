$parameters = $args[0]

$subscriptionId = $parameters['subscriptionId']
$resourceGroupName = $parameters['resourceGroupName']
$virtualNetworkName = $parameters['virtualNetworkName']
$certificateNamePrefix = $parameters['certificateNamePrefix']
$force =  $parameters['force']

$scriptUrlBase = $args[1]

function VerifyPSVersion
{
    Write-Host "Verifying PowerShell version, must be 5.0 or higher."
    if($PSVersionTable.PSVersion.Major -ge 5)
    {
        Write-Host "PowerShell version verified." -ForegroundColor Green
    }
    else
    {
        Write-Host "You need to install PowerShell version 5.0 or heigher." -ForegroundColor Red
        Break;
    }
}

function Ensure-Login () 
{
    $context = Get-AzureRmContext
    If($context.Subscription -eq $null)
    {
        Write-Host "Loging in ..."
        If((Login-AzureRmAccount -ErrorAction SilentlyContinue -ErrorVariable Errors) -eq $null)
        {
            Write-Host ("Login failed: {0}" -f $Errors[0].Exception.Message) -ForegroundColor Red
            Break
        }
    }
    Write-Host "User logedin." -ForegroundColor Green
}

function Select-SubscriptionId {
    param (
        $subscriptionId
    )
    Write-Host "Selecting subscription '$subscriptionId'."
    $context = Get-AzureRmContext
    If($context.Subscription.Id -ne $subscriptionId)
    {
        Try
        {
            Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction Stop | Out-null
        }
        Catch
        {
            Write-Host "Subscription selection failed: $_" -ForegroundColor Red
            Break
        }
    }
    Write-Host "Subscription selected." -ForegroundColor Green
}

function Load-VirtualNetwork {
    param (
        $resourceGroupName,
        $virtualNetworkName
    )
        Write-Host("Loading virtual network '{0}' in resource group '{1}'." -f $virtualNetworkName, $resourceGroupName)
        $virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue
        If($virtualNetwork.Id -ne $null)
        {
            Write-Host "Virtual network loaded." -ForegroundColor Green
            return $virtualNetwork
        }
        else
        {
            Write-Host "Virtual network not found." -ForegroundColor Red
            Break
        }
}

function Load-ResourceGroup {
    param (
        $resourceGroupName
    )
    Write-Host("Loading resource group '{0}'." -f $resourceGroupName)
    $resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName
    If($resourceGroup.ResourceId -ne $null)
    {
        Write-Host "Resource group loaded." -ForegroundColor Green
        return $resourceGroup
    }
    else
    {
        Write-Host "Resource group not found." -ForegroundColor Red
        Break
    }
}

function Set-VirtualNetwork
{
    param($virtualNetwork)

    Write-Host "Applying changes to the virtual network."
    Try
    {
        Set-AzureRmVirtualNetwork -VirtualNetwork $virtualNetwork -ErrorAction Stop | Out-Null
    }
    Catch
    {
        Write-Host "Failed: $_" -ForegroundColor Red
    }

}

function ConvertCidrToUint32Array
{
    param($cidrRange)
    $cidrRangeParts = $cidrRange.Split(@(".","/"))
    $ipnum = ([Convert]::ToUInt32($cidrRangeParts[0]) -shl 24) -bor `
             ([Convert]::ToUInt32($cidrRangeParts[1]) -shl 16) -bor `
             ([Convert]::ToUInt32($cidrRangeParts[2]) -shl 8) -bor `
             [Convert]::ToUInt32($cidrRangeParts[3])

    $maskbits = [System.Convert]::ToInt32($cidrRangeParts[4])
    $mask = 0xffffffff
    $mask = $mask -shl (32 -$maskbits)
    $ipstart = $ipnum -band $mask
    $ipend = $ipnum -bor ($mask -bxor 0xffffffff)
    return @($ipstart, $ipend)
}

function ConvertUInt32ToIPAddress
{
    param($uint32IP)
    $v1 = $uint32IP -band 0xff
    $v2 = ($uint32IP -shr 8) -band 0xff
    $v3 = ($uint32IP -shr 16) -band 0xff
    $v4 = ($uint32IP -shr 24)
    return "$v4.$v3.$v2.$v1"
}

function CalculateNextAddressPrefix
{
    param($virtualNetwork, $prefixLength)
    Write-Host "Calculating address prefix."
    $startIPAddress = 0
    ForEach($addressPrefix in $virtualNetwork.AddressSpace.AddressPrefixes)
    {
        $endIPAddress = (ConvertCidrToUint32Array $addressPrefix)[1]
        If($endIPAddress -gt $startIPAddress)
        {
            $startIPAddress = $endIPAddress
        }
    }
    $startIPAddress += 1
    return (ConvertUInt32ToIPAddress $startIPAddress) + "/" + $prefixLength
}

function CalculateVpnClientAddressPoolPrefix
{
    param($gatewaySubnetPrefix)
    Write-Host "Calculating VPN client address pool prefix."
    If($gatewaySubnetPrefix.StartsWith("10."))
    {
        return "192.168.0.0/24"
    }
    else
    {
        return "172.16.0.0/24"
    }

}

VerifyPSVersion
Ensure-Login
Select-SubscriptionId -subscriptionId $subscriptionId

$virtualNetwork = Load-VirtualNetwork -resourceGroupName $resourceGroupName -virtualNetworkName $virtualNetworkName

$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName

$certificate = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"P2SRoot") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

$certificateThumbprint = $certificate.Thumbprint

New-SelfSignedCertificate -Type Custom -DnsName ($certificateNamePrefix+"P2SChild") -KeySpec Signature `
    -Subject ("CN=$certificateNamePrefix"+"P2SChild") -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $certificate -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") | Out-null

$publicRootCertData = [Convert]::ToBase64String((Get-Item cert:\currentuser\my\$certificateThumbprint).RawData)

$gatewaySubnetPrefix = CalculateNextAddressPrefix $virtualNetwork 28

$vpnClientAddressPoolPrefix = CalculateVpnClientAddressPoolPrefix $gatewaySubnetPrefix

$virtualNetwork.AddressSpace.AddressPrefixes.Add($gatewaySubnetPrefix)
Add-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -VirtualNetwork $virtualNetwork -AddressPrefix $gatewaySubnetPrefix | Out-Null

Set-VirtualNetwork $virtualNetwork

Write-Host

# Start the deployment
Write-Host "Starting deployment..."

$templateParameters = @{
    virtualNetworkName = $virtualNetworkName
    gatewaySubnetPrefix  = $gatewaySubnetPrefix
    vpnClientAddressPoolPrefix  = $vpnClientAddressPoolPrefix
    publicRootCertData  = $publicRootCertData
    }

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri ($scriptUrlBase+'/azuredeploy.json?t='+ [DateTime]::Now.Ticks) -TemplateParameterObject $templateParameters
