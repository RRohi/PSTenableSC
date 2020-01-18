# Import Localization Data.
Import-LocalizedData -BindingVariable local -FileName PSTenableSCLocal -UICulture en-US

#region Set Globally Accessible variables.

# Get Local DateTime Format.
$Global:LocalDatePattern = ((Get-Culture).DateTimeFormat).ShortDatePattern + " " + (((Get-Culture)).DateTimeFormat).LongTimePattern

# New Line.
$Global:NewLine = [Environment]::NewLine

#endregion Globally Accessible variables.

Function ConvertFrom-EpochToNormal {
<#
.SYNOPSIS
Epoc time conversion support function.
.DESCRIPTION
Convert Epoch time to readable format.
.EXAMPLE
Convert Epoch time to readable format.
ConvertFrom-EpochToNormal -InputEpoch 1548752112
.EXAMPLE
Convert Epoch time to readable format in one of the available locales. Default is EE.
ConvertFrom-EpochToNormal -InputEpoch 1548752112 -DateFormat LT
.PARAMETER InputEpoch
Enter Epoch time.
.PARAMETER DateFormat
Choose one of the available locales.
.FUNCTIONALITY
Converts Epoch time to readable format.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [Int]$InputEpoch
)

# Convert Epoch time to readable format, using Local Date Time Format.
Get-Date ([TimeZone]::CurrentTimeZone.ToLocalTime(([DateTime]'1.1.1970').AddSeconds($InputEpoch))) -Format "$LocalDatePattern"

}

Function ConvertFrom-NormalToEpoch {
<#
.SYNOPSIS
Normal time to Epoch conversion support function.
.DESCRIPTION
Convert Normal time to Epoch.
.EXAMPLE
Convert from Normal time to Epoch with current UTC time.
ConvertFrom-NormalToEpoch
.EXAMPLE
Convert from Normal time to Epoch with supplied UTC time.
ConvertFrom-NormalToEpoch -Date "01.01.2016"
.PARAMETER InputEpoch
Enter Time. It will be automatically converted to UTC.
.FUNCTIONALITY
Converts Normal time to Epoch.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $False, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [DateTime]$Date = (Get-Date)
)

# Convert Normal time to Epoch.
([DateTimeOffset](Get-Date $Date -Format "$LocalDatePattern")).ToUnixTimeSeconds()

}

Function Write-SCLog {
<#
.SYNOPSIS
Logging Support Function.
.DESCRIPTION
Shows verbose info when -Verbose switch is used, showing extensive info on executed cmdlets.
.EXAMPLE
A Simple example:
Write-SCLog -LogInfo "This is an important message"
.EXAMPLE
A Sample with localization functionality is use:
Write-SCLog -LogInfo $local.GET_IP
.EXAMPLE
A Sample with localization functionality in use with a variable:
Write-SCLog -LogInfo $($local.GET_IP $IP)
.PARAMETER LogInfo
Specify Log Info.
.NOTES
Output will be formatted as: "datetime - LogInfo"
.FUNCTIONALITY
Provides Verbose Information for debugging purposes.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.SCLOG_HELP_LOGINFO })]
    [String]$LogInfo
)

# Get Current DateTime and store it into a variable.
$DateStamp = Get-Date -Format "dd.MM.yyyy HH:mm:ss"

# Output Verbose Log Text.
Write-Verbose "$DateStamp - $LogInfo"
}

Function Write-SCError {
<#
.SYNOPSIS
Custom Error Notification Function.
.DESCRIPTION
Shows custom Error Messages.
.EXAMPLE
A Simple example:
Write-SCError -Message "You messed up!" -RecommendedAction "Fix it."
.PARAMETER Message
Let user know what went wrong.
.PARAMETER RecommendedAction
Let user know how to fix the error.
.FUNCTIONALITY
Provides cleaner Error Information to user.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.SCERROR_HELP_MESSAGE })]
    [String]$Message,
    [Parameter(Position = 1, Mandatory = $True, HelpMessage = { $local.SCERROR_HELP_RECOMMENDED_ACTION })]
    [String]$RecommendedAction
)

Write-Host -ForegroundColor Red -BackgroundColor Black -Object "Error: $Message$($NewLine)Recommended Action: $RecommendedAction"

Break

}
