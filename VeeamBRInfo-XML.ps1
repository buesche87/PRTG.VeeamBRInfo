<#
    .SYNOPSIS
    This script checks the license and version of Veeam Backup & Replication.
    It collects detailed information and creates an XML file as output.

    .INPUTS
    None

    .OUTPUTS
    The script creates a XML file formated for PRTG.

    .LINK
    https://raw.githubusercontent.com/tn-ict/Public/master/Disclaimer/DISCLAIMER

    .NOTES
    Author  : Andreas Bucher
    Version : 0.9.1
    Purpose : XML-Part of the PRTG-Sensor VeeamBRInfo

    .EXAMPLE
    Run this script with task scheduler use powershell.exe as program and the following parameters:
    -NoLogo -NonInteractive -ExecutionPolicy Bypass -File "C:\Script\VeeamBRInfo-XML.ps1"
    This will place a file in C:\Temp\VeeamResults where it can be retreived by the PRTG sensor
#>
#----------------------------------------------------------[Declarations]----------------------------------------------------------
# Use TLS1.2 for Invoke-Webrequest
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# General parameters
$UpdatePath       = "https://raw.githubusercontent.com/buesche87/PRTG.VeeamInfo/main/VeeamInfo-XML.ps1"
$nl               = [Environment]::NewLine
$resultFolder     = "C:\Temp\VeeamResults" # Output location for xml files

# PRTG parameters
$ExpWarning = 30 # Warninglevel in days for license expiry
$ExpError   = 14 # Errorlevel in days for license expiry

# Define VeeamInfos object and parameters
$VeeamInfos = [PSCustomObject]@{
    Value             = 0
    Text              = ""
    Warning           = 0
    Error             = 0
    FullVersion       = 0
    Version           = 0
    Build             = 0
    VersionInfo       = ""
    SupportId         = 0
    Edition           = ""
    LicenseStatus     = ""
    ExpirationDate    = 0
    ExpirationDays    = 0
    Licensed          = 0
    LicensedTxt       = ""
    Used              = 0
    UsedTxt           = ""
}

#-----------------------------------------------------------[Functions]------------------------------------------------------------
# Export XML
function Set-XMLContent {
    param(
        $VeeamInfos
    )

    $VeeamInfos.Text = $VeeamInfos.Text + " - Veeam Backup & Replication v." + $VeeamInfos.FullVersion + " - " + $($VeeamInfos.Edition) + " (" + $VeeamInfos.VersionInfo + ")"

    # Create XML-Content
    $result= ""
    $result+= '<?xml version="1.0" encoding="UTF-8" ?>' + $nl
    $result+= "<prtg>" + $nl

    $result+=   "<Error>$($VeeamInfos.Error)</Error>" + $nl
    $result+=   "<Text>$($VeeamInfos.Text)</Text>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Status</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.Value)</value>" + $nl
    $result+=   "  <Warning>$($VeeamInfos.Warning)</Warning>" + $nl
    $result+=   "  <LimitMaxWarning>2</LimitMaxWarning>" + $nl
    $result+=   "  <LimitMaxError>3</LimitMaxError>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Version</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.Version)</value>" + $nl
    $result+=   "  <Float>1</Float>" + $nl
    $result+=   "  <DecimalMode>All</DecimalMode>" + $nl
    $result+=   "  <showChart>0</showChart>" + $nl
    $result+=   "  <showTable>0</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>Build</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.Build)</value>" + $nl
    $result+=   "  <showChart>0</showChart>" + $nl
    $result+=   "  <showTable>0</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>SupportID</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.SupportId)</value>" + $nl
    $result+=   "  <showChart>0</showChart>" + $nl
    $result+=   "  <showTable>0</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>License expiry</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.ExpirationDays)</value>" + $nl
    $result+=   "  <CustomUnit>Days</CustomUnit>" + $nl
    $result+=   "  <LimitMinWarning>$ExpWarning</LimitMinWarning>" + $nl
    $result+=   "  <LimitWarningMsg>Lizenz läuft in $($VeeamInfos.ExpirationDays) Tagen aus</LimitWarningMsg>" + $nl
    $result+=   "  <LimitMinError>$ExpError</LimitMinError>" + $nl
    $result+=   "  <LimitErrorMsg>Lizenz läuft in $($VeeamInfos.ExpirationDays) Tagen aus</LimitErrorMsg>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>$($VeeamInfos.LicensedTxt)</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.Licensed)</value>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+=   "<result>" + $nl
    $result+=   "  <channel>$($VeeamInfos.UsedTxt)</channel>" + $nl
    $result+=   "  <value>$($VeeamInfos.Used)</value>" + $nl
    $result+=   "  <LimitMaxWarning>$($VeeamInfos.Licensed)</LimitMaxWarning>" + $nl
    $result+=   "  <LimitWarningMsg>Anzahl Lizenzen aufgebraucht</LimitWarningMsg>" + $nl
    $result+=   "  <LimitMode>1</LimitMode>" + $nl
    $result+=   "  <showChart>1</showChart>" + $nl
    $result+=   "  <showTable>1</showTable>" + $nl
    $result+=   "</result>" + $nl

    $result+= "</prtg>" + $nl

    # Write XML-File
    if(-not (test-path $resultFolder)){ New-Item -Path $resultFolder -ItemType Directory }
    $xmlFilePath = "$resultFolder\VeeamInfo.xml"
    $result | Out-File $xmlFilePath -Encoding utf8

}
# Get Veeam license info
function Get-LicenseInfo {
    param(
        $License
    )

    # License status
    $VeeamInfos.LicenseStatus  = $License.Status
    $VeeamInfos.ExpirationDate = $License.ExpirationDate
    $VeeamInfos.ExpirationDays = ($License.ExpirationDate - (Get-Date)).Days
    $VeeamInfos.Edition        = $License.Edition
    $VeeamInfos.SupportId      = $License.SupportId

    # Check if socket or instance license is used
    if ($License.SocketLicenseSummary.LicensedSocketsNumber -ne 0) {
        $VeeamInfos.Licensed    = $License.SocketLicenseSummary.LicensedSocketsNumber
        $VeeamInfos.Used        = $License.SocketLicenseSummary.UsedSocketsNumber
        $VeeamInfos.LicensedTxt = "Lizenzierte Sockets"
        $VeeamInfos.UsedTxt     = "Benutzte Sockets"
    }
    elseif ($License.InstanceLicenseSummary.LicensedInstancesNumber -ne 0) {
        $VeeamInfos.Licensed    = $License.InstanceLicenseSummary.LicensedInstancesNumber
        $VeeamInfos.Used        = $License.InstanceLicenseSummary.UsedInstancesNumber
        $VeeamInfos.LicensedTxt = "Lizenzierte Instanzen"
        $VeeamInfos.UsedTxt     = "Benutzte Instanzen"
    }

    Return $VeeamInfos
}
# Get Veeam license status
function Get-LicenseStatus {
    param(
        $VeeamInfos
    )

    # Get license status
    if     ($VeeamInfos.LicenseStatus -eq "Valid")         { $VeeamInfos.Value = 1; $VeeamInfos.Warning = 0; $VeeamInfos.Error = 0; $VeeamInfos.Text = "Lizenz valid" }
    elseif ($VeeamInfos.LicenseStatus -eq "Invalid")       { $VeeamInfos.Value = 3; $VeeamInfos.Warning = 0; $VeeamInfos.Error = 1; $VeeamInfos.Text = "Lizenz invalid" }
    elseif ($VeeamInfos.LicenseStatus -eq "Expired")       { $VeeamInfos.Value = 2; $VeeamInfos.Warning = 1; $VeeamInfos.Error = 0; $VeeamInfos.Text = "Lizenz ausgelaufen" }
    elseif ($VeeamInfos.LicenseStatus -eq "Not Installed") { $VeeamInfos.Value = 2; $VeeamInfos.Warning = 1; $VeeamInfos.Error = 0; $VeeamInfos.Text = "Lizenz nicht installiert" }
    elseif ($VeeamInfos.LicenseStatus -eq "Warning")       { $VeeamInfos.Value = 2; $VeeamInfos.Warning = 1; $VeeamInfos.Error = 0; $VeeamInfos.Text = "Lizenz Warning" }
    elseif ($VeeamInfos.LicenseStatus -eq "Error")         { $VeeamInfos.Value = 3; $VeeamInfos.Warning = 0; $VeeamInfos.Error = 1; $VeeamInfos.Text = "Lizenz Error" }
    else                                                   { $VeeamInfos.Value = 3; $VeeamInfos.Warning = 0; $VeeamInfos.Error = 1; $VeeamInfos.Text = "Lizenz unbekannter Fehler" }

    Return $VeeamInfos
}
# Get Veeam Version Info
function Get-VersionInfo {
    param(
        $VeeamInfos
    )

    # Find installation path in Registry
    $CoreDllPath = (Get-ItemProperty -Path "HKLM:\Software\Veeam\Veeam Backup and Replication\" | Select-Object -ExpandProperty CorePath) + "Veeam.Backup.Core.dll"
    $CoreDll     = Get-Item -Path $CoreDllPath

    # Get version number, build number and Info
    $VeeamInfos.FullVersion = $CoreDll.VersionInfo.ProductVersion
    $Version                = $VeeamInfos.FullVersion.Split(".")
    $VeeamInfos.Version     = $Version[0] + "." + $Version[1]
    $VeeamInfos.Build       = $Version[3]
    $VeeamInfos.VersionInfo = $CoreDll.VersionInfo.Comments

    Return $VeeamInfos
}
# Update Script
function Get-NewScript {

    # Check if Update-Script is reachable
    $StatusCode = Invoke-WebRequest $UpdatePath -UseBasicParsing | ForEach-Object {$_.StatusCode}
    $CurrentScript = $PSCommandPath

    if ($StatusCode -eq 200 ) {

        # Parse version string of script on github
        $UpdateScriptcontent = (Invoke-webrequest -URI $UpdatePath -UseBasicParsing).Content
        $newversionstring    = ($UpdateScriptcontent | Select-String "Version :.*" | Select-Object -First 1).Matches.Value
        $newversion          = $newversionstring -replace '[^0-9"."]',''

        # Parse version string of current script
        $CurrentScriptContent = Get-Content -Path $PSCommandPath -Encoding UTF8 -Raw
        $currentversionstring = ($CurrentScriptContent | Select-String "Version :.*" | Select-Object -First 1).Matches.Value
        $currentversion       = $currentversionstring -replace '[^0-9"."]',''

        # Replace and re-run script if update-script is newer
        if ([version]$newversion -gt [version]$currentversion) {

            # Create temp directory if it does not exists
            $tmpdirectory = "C:\Temp"
            if(-not (test-path $tmpdirectory)){ New-Item -Path $tmpdirectory -ItemType Directory }

            # Create a temporary file with content of the new script
            $tempfile = "$tmpdirectory\update-script.new"
            Invoke-WebRequest -URI $UpdatePath -outfile $tempfile

            # Replace current script
            $content = Get-Content $tempfile -Encoding utf8 -raw
            $content | Set-Content $CurrentScript -encoding UTF8

            # Remove temporary file
            Remove-Item $tempfile

            # Call new script
            &$CurrentScript $script:args
        }
    }
}
#-----------------------------------------------------------[Execute]------------------------------------------------------------
# Autoupdate script
Get-NewScript

# Get license infos
$License    = Get-VBRInstalledLicense
$VeeamInfos = Get-LicenseInfo $License
$VeeamInfos = Get-LicenseStatus $VeeamInfos
$VeeamInfos = Get-VersionInfo $VeeamInfos

# Return XML
Set-XMLContent $VeeamInfos