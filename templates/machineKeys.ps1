# Machine Key Script
# File managed by Puppet - DO NOT MAKE MANUAL CHANGES TO THIS FILE
#
# Version 1.1
# 2015-07-08
#
# Robert Ian Hawdon (https://robertianhawdon.me.uk)
#
# Original script by Jeff Graves 2012-05-06
#
#
#param ($readWrite = "read", $allkeys = $true, $version, $validationKey, $decryptionkey, $validation)

param ($readWrite = "<%= scope['dotnetmachinekey::readwrite'] %>", $allkeys = $true, $version, $validationKey = "<%= scope['dotnetmachinekey::validationkey'] %>", $decryptionkey = "<%= scope['dotnetmachinekey::decryptionkey'] %>", $validation = "<%= scope['dotnetmachinekey::validation'] %>")

function GenKey ([int] $keylen) {
        $buff = new-object "System.Byte[]" $keylen
        $rnd = new-object System.Security.Cryptography.RNGCryptoServiceProvider
        $rnd.GetBytes($buff)
        $result =""
        for($i=0; $i -lt $keylen; $i++) {
                $result += [System.String]::Format("{0:X2}",$buff[$i])
        }
        $result
}

function SetKey ([string] $version, [string] $validationKey, [string] $decryptionKey, [string] $validation) {
    write-host "Setting machineKey for $version"
    $currentDate = (get-date).tostring("mm_dd_yyyy-hh_mm_s") # month_day_year - hours_mins_seconds
    
    $machineConfig = $netfx[$version]
        
    if (Test-Path $machineConfig) {
        $xml = [xml](get-content $machineConfig)
        $xml.Save($machineConfig + "_$currentDate")
        $root = $xml.get_DocumentElement()
        $system_web = $root."system.web"
        if ($system_web.machineKey -eq $nul) { 
                $machineKey = $xml.CreateElement("machineKey") 
                $a = $system_web.AppendChild($machineKey)
        }
        $system_web.SelectSingleNode("machineKey").SetAttribute("validationKey","$validationKey")
        $system_web.SelectSingleNode("machineKey").SetAttribute("decryptionKey","$decryptionKey")
        $system_web.SelectSingleNode("machineKey").SetAttribute("validation","$validation")
        $a = $xml.Save($machineConfig)
    }
    else { write-host "$version is not installed on this machine" -fore yellow }
}

function GetKey ([string] $version) { 
    write-host "Getting machineKey for $version"
    $machineConfig = $netfx[$version]
    
    if (Test-Path $machineConfig) { 
        $machineConfig = $netfx.Get_Item($version)
        $xml = [xml](get-content $machineConfig)
        $root = $xml.get_DocumentElement()
        $system_web = $root."system.web"
        if ($system_web.machineKey -eq $nul) { 
                write-host "machineKey is null for $version" -fore red
        }
        else {
            write-host "Validation Key: $($system_web.SelectSingleNode("machineKey").GetAttribute("validationKey"))" -fore green
            write-host "Decryption Key: $($system_web.SelectSingleNode("machineKey").GetAttribute("decryptionKey"))" -fore green
            write-host "Validation: $($system_web.SelectSingleNode("machineKey").GetAttribute("validation"))" -fore green
        }
    }
    else { write-host "$version is not installed on this machine" -fore yellow }
}

$global:netfx = @{"1.1x86" = "C:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\CONFIG\machine.config"; `
           "2.0x86" = "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\CONFIG\machine.config"; `
           "4.0x86" = "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\CONFIG\machine.config"; `
           "2.0x64" = "C:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config"; `
           "4.0x64" = "C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config"}
if(!$allkeys)
{
    while(!$version) {
        $input = read-host "Version (1.1x86, 2.0x86, 4.0x86, 2.0x64, 4.0x64)"
        if ($netfx.ContainsKey($input)) { $version = $input }
    }
}

if ($readWrite -eq "read")
{
    if($allkeys) {
        foreach ($key in $netfx.Keys) { GetKey -version $key }
    }
    else {
        GetKey -version $version
    }
}
elseif ($readWrite -eq "write")
{   
    if (!$validationkey) {
        $validationkey = GenKey -keylen 64
        write-host "Validation Key: $validationKey" -fore green
    }

    if (!$decryptionkey) {
        $decryptionKey = GenKey -keylen 24
        write-host "Decryption Key: $decryptionKey" -fore green
    }

    if (!$validation) {
        $validation = "SHA1"
        write-host "Validation: $validation" -fore green
    }
    
    if($allkeys) {
        foreach ($key in $netfx.Keys) { SetKey -version $key -validationkey $validationkey -decryptionKey $decryptionKey -validation $validation}
    }
    else {
        SetKey -version $version -validationkey $validationkey -decryptionKey $decryptionKey -validation $validation
    }
}

