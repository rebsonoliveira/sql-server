$parameters = $args[0]

$subscriptionId = $parameters['subscriptionId']
$resourceGroupName = $parameters['resourceGroupName']
$virtualMachineName = $parameters['virtualMachineName']
$virtualNetworkName = $parameters['virtualNetworkName']
$managementSubnetName = $parameters['subnetName']
$administratorLogin  = $parameters['administratorLogin']
$administratorLoginPassword  = $parameters['administratorLoginPassword']

$scriptUrlBase = $args[1]

if($virtualMachineName -eq '' -or $virtualMachineName -eq $null) {
    $virtualMachineName = 'Jumpbox'
    Write-Host "VM Name: 'Jumpbox'." -ForegroundColor Green
}

if($managementSubnetName -eq '' -or $managementSubnetName -eq $null) {
    $managementSubnetName = 'Management'
    Write-Host "Using subnet 'Management'." -ForegroundColor Green
}

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

function EnsureLogin () 
{
    $context = Get-AzureRmContext
    If($null -eq $context.Subscription)
    {
        Write-Host "Loging in ..."
        If($null -eq (Login-AzureRmAccount -ErrorAction SilentlyContinue -ErrorVariable Errors))
        {
            Write-Host ("Login failed: {0}" -f $Errors[0].Exception.Message) -ForegroundColor Red
            Break
        }
    }
    Write-Host "User logedin." -ForegroundColor Green
}

function SelectSubscriptionId {
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

function LoadVirtualNetwork {
    param (
        $resourceGroupName,
        $virtualNetworkName
    )
        Write-Host("Loading virtual network '{0}' in resource group '{1}'." -f $virtualNetworkName, $resourceGroupName)
        $virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue
        If($null -ne $virtualNetwork.Id)
        {
            Write-Host "Virtual network loaded." -ForegroundColor Green
            If($virtualNetwork.VirtualNetworkPeerings.Count -gt 0) {
                Write-Host "Virtual should not have peerings." -ForegroundColor Red
            }

            return $virtualNetwork
        }
        else
        {
            Write-Host "Virtual network not found." -ForegroundColor Red
            Break
        }
}

function SetVirtualNetwork
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
    Write-Host "Calculating address prefix..."
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
    $addressPrefixResult = (ConvertUInt32ToIPAddress $startIPAddress) + "/" + $prefixLength
    Write-Host "Using address prefix $addressPrefixResult." -ForegroundColor Green
    return $addressPrefixResult
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
EnsureLogin
SelectSubscriptionId -subscriptionId $subscriptionId

$virtualNetwork = LoadVirtualNetwork -resourceGroupName $resourceGroupName -virtualNetworkName $virtualNetworkName

$subnets = $virtualNetwork.Subnets.Name

If($false -eq $subnets.Contains($managementSubnetName))
{
    Write-Host "$managementSubnetName is not one of the subnets in $subnets" -ForegroundColor Yellow
    Write-Host "Creating subnet $managementSubnetName ($managementSubnetPrefix) in the VNet..." -ForegroundColor Green
    $managementSubnetPrefix = CalculateNextAddressPrefix $virtualNetwork 28

    $virtualNetwork.AddressSpace.AddressPrefixes.Add($managementSubnetPrefix)
    Add-AzureRmVirtualNetworkSubnetConfig -Name $managementSubnetName -VirtualNetwork $virtualNetwork -AddressPrefix $managementSubnetPrefix | Out-Null

    SetVirtualNetwork $virtualNetwork
    Write-Host "Added subnet $managementSubnetName into VNet." -ForegroundColor Green
} else {
    Write-Host "The subnet $managementSubnetName already exists in the VNet." -ForegroundColor Green
}

Write-Host

# Start the deployment
Write-Host "Starting deployment..."

$templateParameters = @{
    virtualNetworkName = $virtualNetworkName
    managementSubnetName  = $managementSubnetName
    virtualMachineName  = $virtualMachineName
    administratorLogin  = $administratorLogin
    administratorLoginPassword  = $administratorLoginPassword
}

# New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri ($scriptUrlBase+'/azuredeploy.json?t='+ [DateTime]::Now.Ticks) -TemplateParameterObject $templateParameters

Write-Host "Deployment completed"