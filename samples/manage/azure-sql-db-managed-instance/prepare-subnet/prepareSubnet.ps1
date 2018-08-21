$parameters = $args[0]

$subscriptionId = $parameters['subscriptionId']
$resourceGroupName = $parameters['resourceGroupName']
$virtualNetworkName = $parameters['virtualNetworkName']
$subnetName = $parameters['subnetName']
$force =  $parameters['force']

function Ensure-Login () 
{
    $context = Get-AzureRmContext
    If($context.Subscription -eq $null)
    {
        Write-Host "Loging in ..."
        If((Login-AzureRmAccount -ErrorAction SilentlyContinue -ErrorVariable Errors) -eq $null)
        {
            Write-Host ("Login failed: {0}" -f $Errors.Message) -ForegroundColor Red
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
            Exit
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
            Exit
        }
}

function Load-VirtualNetworkSubnet {
    param (
        $virtualNetwork,
        $subnetName
    )
        Write-Host("Loading subnet '{0}'." -f $subnetName)
        $subnets = $virtualNetwork.Subnets.Name
        If($true -eq $subnets.Contains($subnetName))
        {
            $subnetIndex = $subnets.IndexOf($subnetName)
            $subnet = $virtualNetwork.Subnets[$subnetIndex]
            Write-Host "Subnet loaded." -ForegroundColor Green
            return $subnet
        }
        else
        {
            Write-Host "Subnet not found." -ForegroundColor Red
            Exit
        }
}

function Verify-Subnet {
    param (
        $subnet
    )
        Write-Host("Verifying subnet '{0}'." -f $subnet.Name)
        If($subnet.AddressPrefix.Split('/')[1] -le 28)
        {
            Write-Host "Passed Validation - Subnet is of enough size." -ForegroundColor Green
        }
        Else
        {
            Write-Host "Failed Validation - Minimum supported subnet size is /28." -ForegroundColor Red
            Exit
        }
        If(
            ($subnet.IpConfigurations.Count -eq 0) -and
            (
                ($subnet.ResourceNavigationLinks.Count -eq 0) -or
                ($subnet.ResourceNavigationLinks[0].LinkedResourceType -eq 'Microsoft.Sql/virtualClusters')
            )
          )
        {
            Write-Host "Passed Validation - There are no conflicting resources inside the subnet." -ForegroundColor Green
        }
        Else
        {
            Write-Host "Failed Validation - Subnet is already in use." -ForegroundColor Red
            Exit
        }
}

function Verify-DNSServersList {
    param (
        $virtualNetwork
    )
        Write-Host("Verifying DNS servers list for virtual network '{0}'." -f $virtualNetwork.Name)
        If(
            $virtualNetwork.DhcpOptions.DnsServers.Count -eq 0 -or
            $virtualNetwork.DhcpOptions.DnsServers.Contains('168.63.129.16')
          )
        {
            Write-Host "Passed Validation - DNS Servers List." -ForegroundColor Green
            return $true
        }
        Else
        {
            Write-Host "Warning - DNS servers list should contain 168.63.129.16." -ForegroundColor Yellow
            return $false
        }
}

function Verify-ServiceEndpoints {
    param (
        $subnet
    )
        Write-Host("Verifying Service endpoints for subnet '{0}'." -f $subnet.Name)
        If(
            $subnet.ServiceEndpoints.Count -eq 0
          )
        {
            Write-Host "Passed Validation - No service endpoints." -ForegroundColor Green
            return $true
        }
        Else
        {
            Write-Host "Warning - Service endpoints are not supported." -ForegroundColor Yellow
            return $false
        }
}


function Verify-NSG {
    param (
        $subnet
    )
        Write-Host("Verifying NSG for subnet '{0}'."-f $subnet.Name)
        If(
            $subnet.NetworkSecurityGroup -eq $null
          )
        {
            Write-Host "Passed Validation - No NSG." -ForegroundColor Green
            return $true
        }
        Else
        {
            Write-Host "Warning - NSG is not supported before provisioning." -ForegroundColor Yellow
            return $false
        }
}

function Load-RouteTable {
    param (
        $subnet
    )
        Write-Host("Loading Route table for subnet '{0}'." -f $subnet.Name)
        If(
            $subnet.RouteTable -ne $null
          )
        {
            $rtSegments = ($subnet.RouteTable.Id).Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)        
            $rtName = $rtSegments[-1].Trim()
            $rtResourceGroup = $rtSegments[3].Trim()
            $routeTable = Get-AzureRmRouteTable -ResourceGroupName $rtResourceGroup -Name $rtName
            Write-Host "Route table loaded." -ForegroundColor Green
            return $routeTable
        }
        Else
        {
            Write-Host "Warning - There is no route table on the subnet." -ForegroundColor Yellow
            return $null
        }
}

function Verify-RouteTable {
    param (
        $subnetAddressPrefix,
        $routeTable
    )
        Write-Host("Verifying Route table '{0}'." -f $routeTable.Name)
        
        $hasDefaultRule = $false
        $hasAnyOtherRule = $false

        ForEach($route in $routeTable.Routes)
        {
            If(
                $route.AddressPrefix -eq "0.0.0.0/0" -and `
                $route.NextHopType -eq "Internet"
              )
            {
                $hasDefaultRule = $true;
            }
            Else
            {
                $hasAnyOtherRule = $true
            }
        }
        
        If($hasDefaultRule -ne $true)
        {
            Write-Host "Warning - 0.0.0.0/0 next hop type Internet rule is missing." -ForegroundColor Yellow
        }

        If($hasAnyOtherRule -eq $true)
        {
            Write-Host "Warning - Route table has rule other then 0.0.0.0/0 next hop type Internet." -ForegroundColor Yellow
        }

        $isValid = $hasDefaultRule -and ($hasAnyOtherRule -ne $true)
                
        If(
            $isValid
          )
        {
            Write-Host "Passed Validation - Route table." -ForegroundColor Green
        }
        return $isValid
}

function Prepare-DNSServerList
{
    param($virtualNetwork)
    Write-Host "Adding 168.63.129.16 to DNS servers list."
    $virtualNetwork.DhcpOptions.DnsServers += "168.63.129.16"
}

function Prepare-ServiceEndpoints
{
    param($subnet)
    Write-Host "Removing service endpoints."
    $subnet.ServiceEndpoints.Clear()
}

function Prepare-NSG
{
    param($subnet)
    Write-Host "Dissasociating NSG."
    $subnet.NetworkSecurityGroup = $null
}

function Prepare-RouteTable
{
    param(
        $existingRouteTable,
        $virtualNetwork,    
        $subnet
    )
    Write-Host "Creating Route table."
    $defaultRoute = New-AzureRmRouteConfig -Name "default" -AddressPrefix 0.0.0.0/0 -NextHopType "Internet"
    $routeTableName = "rtManagedInstance" + (Get-Random -Maximum 1000)
    $routeTable = $null

    Try
    {
        $routeTable = New-AzureRmRouteTable -Name $routeTableName -ResourceGroupName $virtualNetwork.ResourceGroupName -Location $virtualNetwork.Location -Route $defaultRoute
    }
    Catch
    {
        Write-Host "Failed: $_" -ForegroundColor Red
    }

    Write-Host "Associating Route table."
    $subnet.RouteTable = $routeTable
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

Ensure-Login
Select-SubscriptionId -subscriptionId $subscriptionId

$virtualNetwork = Load-VirtualNetwork -resourceGroupName $resourceGroupName -virtualNetworkName $virtualNetworkName
$subnet = Load-VirtualNetworkSubnet -virtualNetwork $virtualNetwork -subnetName $subnetName

Write-Host

Verify-Subnet $subnet
$isOkDnsServersList = Verify-DNSServersList $virtualNetwork
$isOkServiceEndpoints = Verify-ServiceEndpoints $subnet
$isOkNSG = Verify-NSG $subnet
$routeTable = Load-RouteTable $subnet
$hasRouteTable = $routeTable -ne $null
$isOkRouteTable = $false
If($hasRouteTable) 
{ 
    $isOkRouteTable = Verify-RouteTable $subnet.AddressPrefix $routeTable 
}

$isValid = $isOkDnsServersList -and $isOkServiceEndpoints -and $isOkNSG -and $isOkRouteTable

If($isValid -ne $true)
{
    Write-Host
    Write-Host("----------  To prepare the virtual network subnet for Managed Instance this script will: --------------- ")  -ForegroundColor Yellow    
    Write-Host
    If($isOkDnsServersList -ne $true)
    {
        Write-Host "[DNS] Add IP address 168.63.129.16 at the end of DNS servers list." -ForegroundColor Yellow
    }    
    If($isOkServiceEndpoints -ne $true)
    {
        Write-Host "[Endpoints] Remove all service endpoints." -ForegroundColor Yellow
    }    
    If($isOkNSG -ne $true)
    {
        Write-Host "[NSG] Disassociate NSG from the subnet." -ForegroundColor Yellow
    }  
    If($isOkRouteTable -ne $true)
    {
        If($hasRouteTable)
        {
            Write-Host "[UDR] Disassociate existing Route table from the subnet." -ForegroundColor Yellow
        }
        Write-Host "[UDR] Create Route table with single 0.0.0.0/0 -> Internet rule and associate it to the subnet." -ForegroundColor Yellow
    }   
    Write-Host
    Write-Host("-------------------------------------------------------------------------------------------------------- ")  -ForegroundColor Yellow    
    Write-Host


    $applyChanges = $force
    
    If($applyChanges -ne $true)
    {
        $reply = Read-Host -Prompt "Do you want to make these changes? [y/n]"
        $applyChanges = $reply -match "[yY]" 
        Write-Host
    }

    If ($applyChanges) 
    { 
        If($isOkDnsServersList -ne $true)
        {
            Prepare-DNSServerList $virtualNetwork
        }    

        If($isOkServiceEndpoints -ne $true)
        {
            Prepare-ServiceEndpoints $subnet
        }
            
        If($isOkNSG -ne $true)
        {
            Prepare-NSG $subnet
        }  

        If($isOkRouteTable -ne $true)
        {
            Prepare-RouteTable $routeTable $virtualNetwork $subnet
        }   

        Set-VirtualNetwork $virtualNetwork

        Write-Host
        Write-Host "Subnet prepared for the Managed Instance." -ForegroundColor Green        
        Write-Host "https://portal.azure.com/#create/Microsoft.SQLManagedInstance"
    }
    Else
    {
        Write-Host
        Write-Host "Subnet preparation canceled." -ForegroundColor Yellow
    }

}
Else
{
    Write-Host
    Write-Host "Subnet is already prepared." -ForegroundColor Green
    Write-Host "https://portal.azure.com/#create/Microsoft.SQLManagedInstance"
}

