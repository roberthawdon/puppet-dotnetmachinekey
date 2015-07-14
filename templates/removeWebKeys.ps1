# Remove Web Key Script
# File managed by Puppet - DO NOT MAKE MANUAL CHANGES TO THIS FILE
#
# Version 1.0
# 2015-07-08
#
# Robert Ian Hawdon (https://robertianhawdon.me.uk)
#
# Based on a script by Jeff Graves 2012-05-06
#
#

param ($allkeys = $true)

function RmKey ([string] $version) {
    write-host "Removing machineKey for $version"
    $currentDate = (get-date).tostring("mm_dd_yyyy-hh_mm_s") # month_day_year - hours_mins_seconds

    $machineConfig = $netfx[$version]

    if (Test-Path $machineConfig) {
        $xml = [xml](get-content $machineConfig)
        $xml.Save($machineConfig + "_$currentDate")
        $root = $xml.get_DocumentElement()
        $system_web = $root."system.web"
        $system_web.SelectSingleNode("machineKey").RemoveAll()
        $a = $xml.Save($machineConfig)
    }
    else { write-host "$version is not installed on this machine" -fore yellow }
}

$global:netfx = @{"1.1x86" = "C:\WINDOWS\Microsoft.NET\Framework\v1.1.4322\CONFIG\web.config"; `
           "2.0x86" = "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config"; `
           "4.0x86" = "C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\CONFIG\web.config"; `
           "2.0x64" = "C:\WINDOWS\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config"; `
           "4.0x64" = "C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\CONFIG\web.config"}
if(!$allkeys)
{
    while(!$version) {
        $input = read-host "Version (1.1x86, 2.0x86, 4.0x86, 2.0x64, 4.0x64)"
        if ($netfx.ContainsKey($input)) { $version = $input }
    }
}

if($allkeys) {
        foreach ($key in $netfx.Keys) { RmKey -version $key }
    }
    else {
        RmKey -version $version
    }
