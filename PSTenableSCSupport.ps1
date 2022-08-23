# Import localization data.
Import-LocalizedData -BindingVariable local -FileName PSTenableSCLocal -UICulture en-US

#region set globally accessible variables.

# Get local dateTime format.
$Global:LocalDatePattern = ((Get-Culture).DateTimeFormat).ShortDatePattern + " " + (((Get-Culture)).DateTimeFormat).LongTimePattern

# New line.
$Global:NewLine = [Environment]::NewLine

#endregion

Function ConvertFrom-EpochToNormal {
<#
.SYNOPSIS
Epoc time conversion support function.
.DESCRIPTION
Convert epoch time to readable format.
.EXAMPLE
Convert epoch time to readable format.
ConvertFrom-EpochToNormal -InputEpoch 1548752112
.EXAMPLE
Convert epoch time to readable format in one of the available locales.
ConvertFrom-EpochToNormal -InputEpoch 1548752112
.PARAMETER InputEpoch
Enter epoch time.
.PARAMETER DateFormat
Choose one of the available locales.
.FUNCTIONALITY
Converts epoch time to readable format.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [Int]$InputEpoch
)

# Convert epoch time to readable format, using local date time format.
Get-Date ([TimeZone]::CurrentTimeZone.ToLocalTime(([DateTime]'1.1.1970').AddSeconds($InputEpoch))) -Format "$LocalDatePattern"

}

Function ConvertFrom-NormalToEpoch {
<#
.SYNOPSIS
Normal time to epoch conversion support function.
.DESCRIPTION
Convert normal time to epoch.
.EXAMPLE
Convert from normal time to epoch with current UTC time.
ConvertFrom-NormalToEpoch
.EXAMPLE
Convert from normal time to epoch with supplied UTC time.
ConvertFrom-NormalToEpoch -Date "01.01.2016"
.PARAMETER InputEpoch
Enter time. It will be automatically converted to UTC.
.FUNCTIONALITY
Converts normal time to epoch.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $False, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [DateTime]$Date = (Get-Date)
)

# Convert normal time to epoch.
([DateTimeOffset](Get-Date $Date -Format "$LocalDatePattern")).ToUnixTimeSeconds()

}

Function Write-SCLog {
<#
.SYNOPSIS
Logging support function.
.DESCRIPTION
Shows verbose info when -Verbose switch is used, showing extensive info on executed cmdlets.
.EXAMPLE
A simple example:
Write-SCLog -LogInfo "This is an important message"
.EXAMPLE
An example with localization:
Write-SCLog -LogInfo $local.GET_IP
.EXAMPLE
An example with localization using a variable:
Write-SCLog -LogInfo $($local.GET_IP $IP)
.PARAMETER LogInfo
Specify log info.
.NOTES
Output will be formatted as: "datetime - LogInfo"
.FUNCTIONALITY
Provides verbose information for debugging purposes.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.SCLOG_HELP_LOGINFO })]
    [String]$LogInfo
)

# Get current datetime and store it into a variable.
$DateStamp = Get-Date -Format "dd.MM.yyyy HH:mm:ss"

# Output verbose log text.
Write-Verbose "$DateStamp - $LogInfo"
}

Function Write-SCError {
<#
.SYNOPSIS
Custom error notification function.
.DESCRIPTION
Shows custom error messages.
.EXAMPLE
A simple example:
Write-SCError -Message "You messed up!" -RecommendedAction "Fix it."
.PARAMETER Message
Let user know what went wrong.
.PARAMETER RecommendedAction
Let user know how to fix the error.
.FUNCTIONALITY
Provides cleaner error information to user.
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
