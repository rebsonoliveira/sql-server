$parameters = $args[0]

$subscriptionId = $parameters['subscriptionId']
$resourceGroupName = $parameters['resourceGroupName']
$virtualNetworkName = $parameters['virtualNetworkName']
$subnetName = $parameters['subnetName']
$force =  $parameters['force']

$NSnetworkModels = "Microsoft.Azure.Commands.Network.Models"
$NScollections = "System.Collections.Generic"

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
        $virtualNetwork = Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroupName -Name $virtualNetworkName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        If($null -ne $virtualNetwork.Id)
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

function LoadVirtualNetworkSubnet {
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
            Break
        }
}

function VerifySubnet {
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
            Break
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
            Break
        }
}

function VerifyDNSServersList {
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

function VerifyServiceEndpoints {
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

function LoadNetworkSecurityGroup {
    param (
        $subnet
    )
        Write-Host("Loading Network security group for subnet '{0}'." -f $subnet.Name)
        If(
            $null -ne $subnet.NetworkSecurityGroup
          )
        {
            $nsgSegments = ($subnet.NetworkSecurityGroup.Id).Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)        
            $nsgName = $nsgSegments[-1].Trim()
            $nsgResourceGroup = $nsgSegments[3].Trim()
            $networkSecurityGroup = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $nsgResourceGroup -Name $nsgName
            Write-Host "Network security group security group loaded." -ForegroundColor Green
            return $networkSecurityGroup
        }
        Else
        {
            return $null
        }
}

function DefineSecurityRules{

        $securityRules = New-Object "$NScollections.List``1[$NSnetworkModels.PSSecurityRule]"
        #begin NSG inbound rules
        $rule = New-AzureRmNetworkSecurityRuleConfig `
            -Name prepare-allow-management-inbound `
            -Description "Allow inbound TCP traffic on ports 9000,9003,1438,1440,1452" `
            -Direction Inbound -Priority 110 -Access Allow -Protocol Tcp `
            -SourceAddressPrefix * -DestinationAddressPrefix * `
            -SourcePortRange * -DestinationPortRange @(9000, 9003, 1438, 1440, 1452)
        $securityRules.Add($rule)
        $rule = New-AzureRmNetworkSecurityRuleConfig `
            -Name prepare-allow-mi_subnet-inbound `
            -Description "Allow inbound inter-node traffic" `
            -Direction Inbound -Priority 160 -Access Allow -Protocol * `
            -SourceAddressPrefix $subnet.AddressPrefix -DestinationAddressPrefix * `
            -SourcePortRange * -DestinationPortRange *
        $securityRules.Add($rule)
        $rule = New-AzureRmNetworkSecurityRuleConfig `
            -Name prepare-allow-health_probe-inbound `
            -Description "Allow health probe inbound" `
            -Direction Inbound -Priority 170 -Access Allow -Protocol * `
            -SourceAddressPrefix AzureLoadBalancer -DestinationAddressPrefix * `
            -SourcePortRange * -DestinationPortRange *
        $securityRules.Add($rule)
        #end NSG inbound rules
        #begin NSG outbound rules
        $rule = New-AzureRmNetworkSecurityRuleConfig `
            -Name prepare-allow-management-outbound `
            -Description "Allow outbound TCP traffic on port 80,443,12000" `
            -Direction Outbound -Priority 110 -Access Allow -Protocol Tcp `
            -SourceAddressPrefix * -DestinationAddressPrefix * `
            -SourcePortRange * -DestinationPortRange @(80, 443, 12000)
        $securityRules.Add($rule)
        $rule = New-AzureRmNetworkSecurityRuleConfig `
            -Name prepare-allow-mi_subnet-outbound `
            -Description "Allow outbound inter-node traffic" `
            -Direction Outbound -Priority 140 -Access Allow -Protocol * `
            -SourceAddressPrefix * -DestinationAddressPrefix $subnet.AddressPrefix `
            -SourcePortRange * -DestinationPortRange *
        $securityRules.Add($rule)
        #end NSG outbound rules

        return $securityRules
}

function ConvertCidrToUint32Array
{
    param(
        $cidrRange
    )
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

function ContainsCidr
{
    param(
        $cidrRangeA, 
        $cidrRangeB
    )
    $a = ConvertCidrToUint32Array $cidrRangeA
    $b = ConvertCidrToUint32Array $cidrRangeB

    return `
        (($a[0] -le $b[0]) -and ($a[1] -ge $b[1]))
}

function HasCidrOverlap
{
    param($cidrRangeA, $cidrRangeB)
    $a = ConvertCidrToUint32Array $cidrRangeA
    $b = ConvertCidrToUint32Array $cidrRangeB

    return `
        (($a[0] -ge $b[0]) -and ($a[0] -lt $b[1])) -or `
        (($a[1] -le $b[1]) -and ($a[1] -gt $b[0])) -or `
        (($a[0] -le $b[0]) -and ($a[1] -ge $b[1]))
}

function VerifyAddressPrefix {
    param (
        $nsgRuleAddressPrefixes,
        $securityRuleAddressPrefix
    )
    
    ForEach($nsgRuleAddressPrefix in $nsgRuleAddressPrefixes) {
        If($nsgRuleAddressPrefix -eq "*"){
            return $true;
        }

        If($nsgRuleAddressPrefix -eq $securityRuleAddressPrefix){
            return $true;
        }

        If(($true -ne $securityRuleAddressPrefix.Contains('/')) -or ($true -ne $nsgRuleAddressPrefix.Contains('/'))) {
            continue;
        }

        return ContainsCidr -cidrRangeA $nsgRuleAddressPrefix -cidrRangeB $securityRuleAddressPrefix
    }

    return $false
}

function VerifyDenyRuleAddressPrefix {
    param (
        $nsgRuleAddressPrefixes,
        $securityRuleAddressPrefix
    )
    
    ForEach($nsgRuleAddressPrefix in $nsgRuleAddressPrefixes) {
        If($nsgRuleAddressPrefix -eq "*"){
            return $true;
        }

        If($nsgRuleAddressPrefix -eq $securityRuleAddressPrefix){
            return $true;
        }

        If(($true -ne $securityRuleAddressPrefix.Contains('/')) -or ($true -ne $nsgRuleAddressPrefix.Contains('/'))) {
            continue;
        }

        return HasCidrOverlap -cidrRangeA $nsgRuleAddressPrefix -cidrRangeB $securityRuleAddressPrefix
    }

    return $false
}

function IsPrivateCidr
{    
    param($cidrRange)
    return `
        (ContainsCidr "10.0.0.0/8" $cidrRange) -or `
        (ContainsCidr "172.16.0.0/12" $cidrRange) -or `
        (ContainsCidr "192.168.0.0/16" $cidrRange)
}


function ContainsPort{
    param(
        $nsgRulePort,
        $securityRulePort
    )

    If($nsgRulePort.Contains('-')){
        $startPort = [Int32]::Parse($nsgRulePort.Split('-')[0])
        $endPort =  [Int32]::Parse($nsgRulePort.Split('-')[1])
        $port = [Int32]::Parse($securityRulePort)
        return $startPort -le $port -and $port -le $endPort
    }
    else{
        return $nsgRulePort -eq $securityRulePort
    }
}

function VerifyPort {
    param (
        $nsgRulePorts,
        $securityRulePort
    )
    
    ForEach($nsgRulePort in $nsgRulePorts) {
        If($true -eq (ContainsPort -nsgRulePort $nsgRulePort -securityRulePort $securityRulePort)) {
            return $true
        }
    }

    return $false
}

function VerifyNSGRule {
    param (
        $securityRule,
        $nsgRule
    )

    If($securityRule.Direction -ne $nsgRule.Direction) {
        return $false
    }

    If($nsgRule.Access -eq "Allow") {
        If(($nsgRule.Protocol -ne "*") -and ($nsgRule.Protocol -ne $securityRule.Protocol)) {
            return $false
        }

        If(($true -ne $nsgRule.SourceAddressPrefix.Contains('*')) -and ($true -ne (VerifyAddressPrefix -nsgRuleAddressPrefixes $nsgRule.SourceAddressPrefix -securityRuleAddressPrefix $securityRule.SourceAddressPrefix[0]))) {
            return $false
        }

        If(($true -ne $nsgRule.DestinationAddressPrefix.Contains('*')) -and ($true -ne (VerifyAddressPrefix  -nsgRuleAddressPrefixes $nsgRule.DestinationAddressPrefix -securityRuleAddressPrefix $securityRule.DestinationAddressPrefix[0]))) {
            return $false
        }


        If(($true -ne $nsgRule.SourcePortRange.Contains('*')) -and ($true -ne (VerifyPort -nsgRulePorts $nsgRule.SourcePortRange -securityRulePort $securityRule.SourcePortRange[0]))) {
            return $false
        }

        If(($true -ne $nsgRule.DestinationPortRange.Contains('*')) -and ($true -ne (VerifyPort -nsgRulePorts $nsgRule.DestinationPortRange -securityRulePort $securityRule.DestinationPortRange[0]))) {
            return $false
        }
    }
    Else {
        If(($securityRule.Protocol -ne "*") -and ($nsgRule.Protocol -ne "*") -and ($nsgRule.Protocol -ne $securityRule.Protocol)) {
            return $false
        }

        If(($true -ne $securityRule.SourceAddressPrefix.Contains('*')) -and ($true -ne $nsgRule.SourceAddressPrefix.Contains('*')) -and ($true -ne (VerifyDenyRuleAddressPrefix -nsgRuleAddressPrefixes $nsgRule.SourceAddressPrefix -securityRuleAddressPrefix $securityRule.SourceAddressPrefix[0]))) {
            return $false
        }

        If(($true -ne $securityRule.DestinationAddressPrefix.Contains('*')) -and ($true -ne $nsgRule.DestinationAddressPrefix.Contains('*')) -and ($true -ne (VerifyDenyRuleAddressPrefix  -nsgRuleAddressPrefixes $nsgRule.DestinationAddressPrefix -securityRuleAddressPrefix $securityRule.DestinationAddressPrefix[0]))) {
            return $false
        }


        If(($true -ne $securityRule.SourcePortRange.Contains('*')) -and ($true -ne $nsgRule.SourcePortRange.Contains('*')) -and ($true -ne (VerifyPort -nsgRulePorts $nsgRule.SourcePortRange -securityRulePort $securityRule.SourcePortRange[0]))) {
            return $false
        }

        If(($true -ne $securityRule.DestinationPortRange.Contains('*')) -and ($true -ne $nsgRule.DestinationPortRange.Contains('*')) -and ($true -ne (VerifyPort -nsgRulePorts $nsgRule.DestinationPortRange -securityRulePort $securityRule.DestinationPortRange[0]))) {
            return $false
        }
    }

    return $true

}

function VerifyNSGRules {
    param (
        $securityRule,
        $nsgRules
    )

    ForEach($nsgRule in $nsgRules){
        If(VerifyNSGRule -securityRule $securityRule -nsgRule $nsgRule){
            return ($nsgRule.Access -eq "Allow")
        }        
    }

    return $false
}


function VerifyNSG {
    param (
        $subnet
    )
        $securityRules = DefineSecurityRules

        $result = @{ 
            nsgSecurityRules = New-Object "$NScollections.List``1[$NSnetworkModels.PSSecurityRule]"
            failedSecurityRules = New-Object "$NScollections.List``1[$NSnetworkModels.PSSecurityRule]"
            success = $false 
        }
        Write-Host("Verifying Network security group for subnet '{0}'."-f $subnet.Name)
        $nsg = LoadNetworkSecurityGroup $subnet
        If(
            $null -ne $nsg
          )
        {
            $result['nsgSecurityRules'] = ($nsg.SecurityRules | Sort-Object -Property Priority)

            ForEach($securityRule in $securityRules){
                If($false -eq (VerifyNSGRules -securityRule $securityRule -nsgRules $result['nsgSecurityRules'])){
                    $result['failedSecurityRules'].Add($securityRule)
                }
            }
            $result['success'] = $result['failedSecurityRules'].Count -eq 0
        }
        Else {
            $result['failedSecurityRules'] = DefineSecurityRules
        }
        If($true -eq $result['success'])
        {
            Write-Host "Passed Validation - Network security group." -ForegroundColor Green
        }
        Else
        {
            Write-Host "Warning - Network security group needs modifications." -ForegroundColor Yellow
        }
        return $result
}

function LoadRouteTable {
    param (
        $subnet
    )
        Write-Host("Loading Route table for subnet '{0}'." -f $subnet.Name)
        If(
            $null -ne $subnet.RouteTable
          )
        {
            $rtSegments = ($subnet.RouteTable.Id).Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)        
            $rtName = $rtSegments[-1].Trim()
            $rtResourceGroup = $rtSegments[3].Trim()
            $routeTable = Get-AzureRmRouteTable -ResourceGroupName $rtResourceGroup -Name $rtName
            Write-Host "Route table loaded." -ForegroundColor Green
            return $routeTable
        }
        return $null
}

function VerifyRouteTable {
    param (
        $subnet
    )
        $result = @{ 
            routes = New-Object "$NScollections.List``1[$NSnetworkModels.PSRoute]"
            hasRouteTable = $false
            hasDefaultRoute = $false
            allowsInterNodeTraffic = $true
            hasNoPublicIPRouting = $true
            success = $false 
        }
        $defaultRoute = New-AzureRmRouteConfig -Name "prepare-default" -AddressPrefix 0.0.0.0/0 -NextHopType Internet
        Write-Host("Verifying RT for subnet '{0}'."-f $subnet.Name)
        $routeTable = LoadRouteTable $subnet
        If(
            $null -ne $routeTable
          )
        {
            $result['hasRouteTable'] = $true
            Write-Host("Verifying Route table '{0}'." -f $routeTable.Name)

            ForEach($route in $routeTable.Routes)
            {
                If(
                    (HasCidrOverlap -cidrRangeA $route.AddressPrefix -cidrRangeB $subnet.AddressPrefix)  -and `
                    $route.NextHopType -ne "VnetLocal"
                  )
                {
                    $result['allowsInterNodeTraffic'] = $false;
                    Continue
                }

                If($false -eq (IsPrivateCidr -cidrRange $route.AddressPrefix)  -and `
                    $route.NextHopType -ne "Internet"
                  )
                {
                    $result['hasNoPublicIPRouting'] = $false;
                    Continue
                }

                If(
                    $route.AddressPrefix -eq "0.0.0.0/0" -and `
                    $route.NextHopType -eq "Internet"
                  )
                {
                    $result['hasDefaultRoute'] = $true;
                }

                $result['routes'].Add($route)
            }


            $result['success'] = $result['hasRouteTable'] -and $result['hasDefaultRoute'] -and $result['allowsInterNodeTraffic'] -and $result['hasNoPublicIPRouting']
        }
        
        If($true -ne $result['hasDefaultRoute'])
        {
            $result['routes'].Insert(0, $defaultRoute)
        }

        If($true -eq $result['success'])
        {
            Write-Host "Passed Validation - Route table." -ForegroundColor Green
        }
        Else
        {
            If($true -eq $result['hasRouteTable'])
            {
                Write-Host "Warning - Route table needs modifications." -ForegroundColor Yellow
            }
            Else
            {
                Write-Host "Warning - There is no route table on the subnet." -ForegroundColor Yellow
            }
        }
        
        return $result
}


function PrepareDNSServerList
{
    param($virtualNetwork)
    Write-Host "Adding 168.63.129.16 to DNS servers list."
    $virtualNetwork.DhcpOptions.DnsServers += "168.63.129.16"
}

function PrepareServiceEndpoints
{
    param($subnet)
    Write-Host "Removing service endpoints."
    $subnet.ServiceEndpoints.Clear()
}

function PrepareNSG
{
    param(
        $nsgVerificationResult,
        $virtualNetwork,   
        $subnet
    )
    Write-Host "Creating Network security group."
    $networkSecurityGroupName = "nsgManagedInstance" + (Get-Random -Maximum 1000)
    $securityRules = $nsgVerificationResult['failedSecurityRules']
    $inboundRulePriority = 0
    $outboundRulePriority = 0

    ForEach($securityRule in $nsgVerificationResult['failedSecurityRules']){
        If($securityRule.Direction -eq "Inbound") {
            $inboundRulePriority = $securityRule.Priority
        }
        Else{
            $outboundRulePriority = $securityRule.Priority
        }
    }

    ForEach($nsgRule in $nsgVerificationResult['nsgSecurityRules']){
        If($nsgRule.Direction -eq "Inbound"){
            if($nsgRule.Priority -lt $inboundRulePriority) {
                $inboundRulePriority += 10
                $nsgRule.Priority = $inboundRulePriority
            }
        }
        Else{
            if($nsgRule.Priority -lt $outboundRulePriority) {
                $outboundRulePriority += 10
                $nsgRule.Priority = $outboundRulePriority
            }
        }
        $securityRules.Add($nsgRule)
    }

    Try
    {
        $networkSecurityGroup = New-AzureRmNetworkSecurityGroup -Name $networkSecurityGroupName -ResourceGroupName $virtualNetwork.ResourceGroupName -Location $virtualNetwork.Location -SecurityRules $securityRules
    }
    Catch
    {
        Write-Host "Failed: $_" -ForegroundColor Red
    }

    Write-Host "Associating Network security group."
    $subnet.NetworkSecurityGroup = $networkSecurityGroup
}

function PrepareRouteTable
{
    param(
        $routeTableVerificationResult,
        $virtualNetwork,   
        $subnet
    )
    Write-Host "Creating Route table."
    $routeTableName = "rtManagedInstance" + (Get-Random -Maximum 1000)
    $routes = $routeTableVerificationResult['routes']

    Try
    {
        $routeTable = New-AzureRmRouteTable -Name $routeTableName -ResourceGroupName $virtualNetwork.ResourceGroupName -Location $virtualNetwork.Location -Route $routes
    }
    Catch
    {
        Write-Host "Failed: $_" -ForegroundColor Red
    }

    Write-Host "Associating Route table."
    $subnet.RouteTable = $routeTable
}

function SetVirtualNetwork
{
    param($virtualNetwork)

    Write-Host "Applying changes to the virtual network."
    Try
    {
        Set-AzureRmVirtualNetwork -VirtualNetwork $virtualNetwork -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
    }
    Catch
    {
        Write-Host "Failed: $_" -ForegroundColor Red
    }

}

EnsureLogin
SelectSubscriptionId -subscriptionId $subscriptionId

$virtualNetwork = LoadVirtualNetwork -resourceGroupName $resourceGroupName -virtualNetworkName $virtualNetworkName
$subnet = LoadVirtualNetworkSubnet -virtualNetwork $virtualNetwork -subnetName $subnetName

Write-Host

VerifySubnet $subnet
$isOkDnsServersList = VerifyDNSServersList $virtualNetwork
$isOkServiceEndpoints = VerifyServiceEndpoints $subnet
$nsgVerificationResult = VerifyNSG $subnet
$isOkNSG = $nsgVerificationResult['success']
$routeTableVerificationResult = VerifyRouteTable $subnet
$hasRouteTable = $routeTableVerificationResult['hasRouteTable']
$isOkRouteTable = $routeTableVerificationResult['success']
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
        Write-Host "[NSG] Create a copy of assoicated Network security group and add security rules to:" -ForegroundColor Yellow
        ForEach($rule in $nsgVerificationResult['failedSecurityRules']){
            Write-Host ("[NSG] -"+$rule.Description) -ForegroundColor Yellow
        }
        Write-Host "[NSG] Associate newly created Network security group to subnet." -ForegroundColor Yellow
    }  
    If($isOkRouteTable -ne $true)
    {
        If($hasRouteTable -eq $true)
        {
            Write-Host "[UDR] Create a copy of associated Route table." -ForegroundColor Yellow

            If($false -eq $routeTableVerificationResult['hasDefaultRoute'])
            {
                Write-Host "[UDR] Add 0.0.0.0/0 -> Internet route." -ForegroundColor Yellow
            }

            If($false -eq $routeTableVerificationResult['allowsInterNodeTraffic'])
            {
                Write-Host "[UDR] Remove route(s) that interfere with intercluster traffic." -ForegroundColor Yellow
            }

            If($false -eq $routeTableVerificationResult['hasNoPublicIPRouting'])
            {
                Write-Host "[UDR] Remove route(s) that interfere with direct traffic to public IP addresses." -ForegroundColor Yellow
            }
        }
        Else
        {
            Write-Host "[UDR] Create Route table with single 0.0.0.0/0 -> Internet route." -ForegroundColor Yellow
        }
        Write-Host "[UDR] Associate newly created Route table to subnet." -ForegroundColor Yellow
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
            PrepareDNSServerList $virtualNetwork
        }    

        If($isOkServiceEndpoints -ne $true)
        {
            PrepareServiceEndpoints $subnet
        }
            
        If($isOkNSG -ne $true)
        {
            PrepareNSG $nsgVerificationResult $virtualNetwork $subnet
        }  

        If($isOkRouteTable -ne $true)
        {
            PrepareRouteTable $routeTableVerificationResult $virtualNetwork $subnet
        }   

        SetVirtualNetwork $virtualNetwork

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

