# Import Localization Data.
Import-LocalizedData -BindingVariable local -FileName PSTenableSCLocal -UICulture en-US

# Import Support Functions.
. "$PSScriptRoot\PSTenableSCSupport.ps1"

#region Set Globally Accessible variables.

# Get PS Window Title.
$DefaultPSWindowTitle = [Console]::Title

# Set Culture Variable to manipulate text later.
$Global:Culture = (Get-Culture).TextInfo

# Regular Expressions.
## IPv4.
[RegEx]$Global:IPv4RegEx = '(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])'
Write-SCLog -LogInfo $($local.LOG_IPV4_REGEX -f $IPv4RegEx)

## FQDN.
[RegEx]$Global:FQDNRegEx = '([\D]{1,2}[\w]{4}.)([\D])*?([\w]){5,9}.([\w]).(com|net)'
Write-SCLog -LogInfo $($local.LOG_FQDN_REGEX -f $FQDNRegEx)

## Single Label Name.
[RegEx]$Global:HostNameRegEx = '[a-zA-Z]{1,2}[0-9]{4,5}'

## CVE.
[RegEx]$Global:CVERegEx = "CVE-(1999|2\d{3})-(0\d{2}[1-9]|[1-9]\d{3,})"
Write-SCLog -LogInfo $($local.LOG_CVE_REGEX -f $CVERegEx)

# Tenable.sc address.
[String]$Global:ServerFQDN = "tenablesc.server.net"

# New Line.
$Global:NewLine = [Environment]::NewLine

# Buffer Height -15 lines just in case.
$Global:BufferHeight = [console]::BufferHeight-15

#endregion Globally Accessible variables.

Function ConvertFrom-SCReportCSV2XLSX {
<#
.SYNOPSIS
Convert Tenable SecurityCenter Reports from CSV to XLSX.
.DESCRIPTION
Convert Report CSV file(s), from Tenable SecurityCenter, to a presentable Excel spreadsheet.
.EXAMPLE
Convert Compliance Report CSV file to XLSX Spreadsheet with the minimum parameter set. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Compliance -ComplianceCSV C:\TEMP\compliance.csv -TargetXLSX C:\TEMP\compliance.xlsx -SourceCSVDelimiter ","
.EXAMPLE
Convert Compliance Report CSV file to XLSX Spreadsheet and show all lines. By default, erronous lines are excluded from the output. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Compliance -ComplianceCSV C:\TEMP\compliance.csv -TargetXLSX C:\TEMP\compliance.xlsx -SourceCSVDelimiter "," -ShowAll
.EXAMPLE
Convert Compliance Report CSV file to XLSX Spreadsheet with tab as delimiter. By default it's semicolon. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Compliance -ComplianceCSV C:\TEMP\compliance.csv -TargetXLSX C:\TEMP\compliance.xlsx -SourceCSVDelimiter "," -TargetCSVDelimiter ";"
.EXAMPLE
Convert Compliance Report CSV file to XLSX Spreadsheet and keep the TEMP files created during the process. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Compliance -ComplianceCSV C:\TEMP\compliance.csv -TargetXLSX C:\TEMP\compliance.xlsx -SourceCSVDelimiter "," -KeepTEMP
.EXAMPLE
Convert Vulnerability Report CSV files to XLSX Spreadsheet with the minimum parameter set, including Summary and Detailed sheets. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Vulnerability -VulnSummaryCSV C:\TEMP\vuln_summary.csv -VulnDetailCSV C:\TEMP\vuln_detailed.csv -SourceCSVDelimiter "," -TargetXLSX C:\TEMP\vulnerabilities.xlsx
.EXAMPLE
Convert Vulnerability Report CSV file to XLSX Spreadsheet without the Summary sheet. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Vulnerability -NoVulnSummary -VulnDetailCSV C:\TEMP\vuln_detailed.csv -SourceCSVDelimiter "," -TargetXLSX C:\TEMP\vulnerabilities.xlsx
.EXAMPLE
Convert Vulnerability Report CSV file to XLSX Spreadsheet and exclude some plugins by entering them into an array. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Vulnerability -VulnSummaryCSV C:\TEMP\vuln_summary.csv -VulnDetailCSV C:\TEMP\vuln_detailed.csv -TargetXLSX C:\TEMP\vulnerabilities.xlsx -SourceCSVDelimiter "," -ExcludePlugins 18405,108757,90433
.EXAMPLE
Convert Vulnerability Report CSV file to XLSX Spreadsheet and exclude some plugins by reading plugins from a file. Plugin numbers have to be in a single list/on separate lines Cannot be a delimited array of Plugins. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Vulnerability -VulnSummaryCSV C:\TEMP\vuln_summary.csv -VulnDetailCSV C:\TEMP\vuln_detailed.csv -TargetXLSX C:\TEMP\vulnerabilities.xlsx -SourceCSVDelimiter "," -ExcludePlugins (Get-Content -Path C:\TEMP\plugins.txt)
.EXAMPLE
Convert Vulnerability Report CSV file to XLSX Spreadsheet and exclude some plugins by reading plugins from a file, and some severities. Also specify the delimiter used in the source CSV files.
ConvertFrom-ReportCSV2XLSX -Vulnerability -VulnSummaryCSV C:\TEMP\vuln_summary.csv -VulnDetailCSV C:\TEMP\vuln_detailed.csv -TargetXLSX C:\TEMP\vulnerabilities.xlsx -SourceCSVDelimiter "," -ExcludePlugins (Get-Content -Path C:\TEMP\plugins.txt) -ExcludeSeverities Info, Low
.PARAMETER Compliance
Compliance switch makes available other parameters in the Compliance parameterset. Compliance and Vulnerability parameterset parameters cannot be used at the same time.
.PARAMETER Vulnerability
Vulnerability switch makes available other parameters in the Vulnerability parameterset. Vulnerability and Compliance parameterset parameters cannot be used at the same time.
.PARAMETER NoVulnSummary
Use this parameter if you want to convert just the detailed part.
.PARAMETER ComplianceCSV
Enter path to Compliance CSV file.
.PARAMETER VulnSummaryCSV
Enter path to Vulnerability Summary CSV file.
.PARAMETER VulnDetailCSV
Enter path to Vulnerability Detailed CSV file.
.PARAMETER SourceCSVDelimiter
Set a custom delimiter for the Source CSV.
.PARAMETER TargetCSVDelimiter
Set a custom delimiter for the Target CSV. Default is semicolon (;).
.PARAMETER TargetXLSX
Set Output Excel file Path.
.PARAMETER ExcludePlugins
Exclude some plugins from the output.
.PARAMETER ExcludeSeverities
Exclude some severities from the output.
.PARAMETER ShowAll
Show all Compliance Report lines from the Source CSV File. By Default erronous items are excluded.
.PARAMETER KeepTEMP
Keep the temp CSV files made during the conversion process.
.INPUTS
None, You can't pipe objects to ConvertFrom-SCReportCSV2XLSX.
.OUTPUTS
Preformatted Excel Pacakge.
.NOTES
This Module needs ImportExcel Module to work.
.ROLE
TenableSC User.
.COMPONENT
ImportExcel
.FUNCTIONALITY
Convert SecurityCenver Compliance or Vulnerability Reports to a nice looking spreadsheet.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'Compliance', HelpMessage = { $local.REPC2X_HELP_REPORT_TYPE })]
    [Switch]$Compliance,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Compliance', HelpMessage = { $local.REPC2X_HELP_COMPLIANCE_SOURCE })]
    [ValidateScript({ Test-Path -Path $PSItem -PathType Leaf })]
    [ValidatePattern('^*.csv$')]
    [String]$ComplianceCSV,
    [Parameter(Position = 2, Mandatory = $True, ParameterSetName = 'VulnerabilitySummary', HelpMessage = { $local.REPC2X_HELP_REPORT_TYPE })]
    [Parameter(ParameterSetName = 'NoVulnerabilitySummary')]
    [Switch]$Vulnerability,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'NoVulnerabilitySummary', HelpMessage = { $local.REPC2X_HELP_VULNERABILITY_NO_SUMMARY })]
    [Switch]$NoVulnSummary,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'VulnerabilitySummary', HelpMessage = { $local.REPC2X_HELP_VULNERABILITY_SUMMARY_SOURCE })]
    [ValidatePattern('^*.csv$')]
    [String]$VulnSummaryCSV,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'VulnerabilitySummary', HelpMessage = { $local.REPC2X_HELP_VULNERABILITY_DETAIL_SOURCE })]
    [Parameter(ParameterSetName = 'NoVulnerabilitySummary')]
    [ValidateScript({ Test-Path -Path $PSItem -PathType Leaf })]
    [ValidatePattern('^*.csv$')]
    [String]$VulnDetailCSV,
    [Parameter(Position = 6, Mandatory = $True, Helpmessage = { $local.REPC2X_HELP_SOURCE_DELIMETER })]
    [ValidateLength(1, 1)]
    [String]$SourceCSVDelimiter,
    [Parameter(Position = 7, Mandatory = $False, Helpmessage = { $local.REPC2X_HELP_TARGET_DELIMETER })]
    [ValidateLength(1, 1)]
    [ValidateScript({
        # Do not allow using delimiters that can cause structural instability in the CSV.
        If ($PSItem -in @(",","`"","'","*","-","+")) {
            Write-SCError -Message $($local.REPC2X_ERROR_UNSUPPORTED_DELIMITER -f $PSItem) -RecommendedAction $local.REPC2X_ERROR_UNSUPPORTED_DELIMITER_FIX
        } # Provided delimiter is not supported, exit.
        Else {
            # Supported delimiter was used.
            $True
        } # Provided delimiter is OK. End of TargetCSVDelimiter check.
    })]
    [String]$TargetCSVDelimiter = ';',
    [Parameter(Position = 8, Mandatory = $True, HelpMessage = { $local.REPC2X_HELP_TARGET })]
    [ValidateScript({
        If (Test-Path -Path $PSItem) {
            # File exists, exit. Can't be bothered to offer to save with another name at this point, exit.
            Write-SCError -Message $local.REPC2X_ERROR_TARGET_FILE_EXISTS -RecommendedAction $local.REPC2X_ERROR_TARGET_FILE_EXISTS_FIX
        } # File check failed, file already exists, exit.
        Else {
            # No existing file with the same name.
            $True
        } # Filename does not already exist. End of TargetXLSX file path check.
    })]
    [ValidatePattern('^*.xlsx$')]
    [String]$TargetXLSX,
    [Parameter(Position = 9, Mandatory = $False, ParameterSetName = 'VulnerabilitySummary', HelpMessage = { $local.REPC2X_HELP_EXCLUDE_PLUGINS })]
    [Parameter(ParameterSetName = 'NoVulnerabilitySummary')]
    [String[]]$ExcludePlugins,
    [Parameter(Position = 10, Mandatory = $False, HelpMessage = { $local.REPC2X_HELP_EXCLUDE_SEVERITIES })]
    [String[]]$ExcludeSeverities,
    [Parameter(Position = 11, Mandatory = $True, ParameterSetName = 'Compliance', HelpMessage = { $local.REPC2X_HELP_SHOWALL })]
    [Switch]$ShowAll,
    [Parameter(Position = 12, Mandatory = $False, HelpMessage = { $local.REPC2X_HELP_KEEPTEMP })]
    [Switch]$KeepTEMP
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)
} # End of Begin.
Process {
    Switch ($PSCmdlet.ParameterSetName) {
        'Compliance' {
            Write-SCLog -LogInfo $local.REPC2X_LOG_COMPLIANCE

            # Put Current Scope Name into a variable.
            $Scope = 'Compliance'
            Write-SCLog -LogInfo $($local.REPC2X_LOG_SET_SCOPE -f $Scope)

            # Create TEMP files for the conversion process.
            $ComplianceTMP1 = [System.IO.Path]::GetTempFileName()
            Write-SCLog -LogInfo $($local.REPC2X_LOG_TEMP_FILE -f $ComplianceTMP1, $Scope)
        
            # Go through TEMP CSV Output and remove NULL or White Spaces and make new Output CSV file.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_MODIFY_CSV_STRUCTURE -f $ComplianceTMP1, $SourceCSVDelimiter, $TargetCSVDelimiter, $VulnSummaryCSV)
            (Get-Content -Path $ComplianceCSV -Raw) | Where-Object { ![String]::IsNullOrWhiteSpace($PSItem).Replace('"' + $SourceCSVDelimiter + '"',"$TargetCSVDelimiter") } | Out-File -FilePath $ComplianceTMP1

            # Take the CSV contents and Export them to Excel.
            $WSName = $local.REPC2X_VULNERABILITY_SUMMARY_WORKSHEET
            Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_VARIABLE -f $WSName)
            $TBLName = $local.REPC2X_VULNERABILITY_SUMMARY_TABLE
            Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_TABLE_VARIABLE -f $WSName, $TBLName)

            # Check whether ExcludeSeverities Parameter was used.
            Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUSION_PARAMETERS_CHECK
            If ($ExcludeSeverities) {
                Write-SCLog -LogInfo $($local.REPC2X_LOG_EXCLUDESEVERITIES_USED -f $ExcludeSeverities)

                # Import the modified CSV and export it to Spreadsheet.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $ComplianceTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                $ExportToXLSX = Import-Csv -Path $ComplianceTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object Severity -NotIn $ExcludeSeverities | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
            } # ExcludeSeverities: True.
            Else {
                Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUSION_PARAMETERS_NOT_USED

                # Import the modified CSV and export it to Spreadsheet.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $ComplianceTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                $ExportToXLSX = Import-Csv -Path $ComplianceTMP1 -Delimiter "$TargetCSVDelimiter" | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
            } # ExcludeSeverities: False. End of ExcludeSeverities Parameter check.

            # Save the Excel Package.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_SAVE_EXCEL_PACKAGE -f $Scope)
            $ExportToXLSX.Save()

            # Dispose of the Excel Package.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_DISPOSE_OF_PACKAGE -f $Scope)
            $ExportToXLSX.Dispose()

            # Checking if KeepTEMP Parameter was used.
            If (!$KeepTEMP) {
                # Remove temp file.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_REMOVE_TEMP_FILE -f $ComplianceTMP1)
                Remove-Item -Path $ComplianceTMP1
            } # KeepTEMP: False
            Else {
                # Or don't remove the temp file.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_DONT_REMOVE_TEMP_FILE -f $ComplianceTMP1)
            } # KeepTEMP: True. End of KeepTEMP Parameter check.
            
            # Tell Garbage Collector to dump unnecessary stuff.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_DUMP_GARBAGE -f $Scope)
            [GC]::Collect()

            Write-SCLog -LogInfo $($local.REPC2X_LOG_SECTION_END  -f $Scope)
        } # End of Compliance Parameter check.
        'Vulnerability' {
            If (!$NoVulnSummary) {
                #region Summary
                Write-SCLog -LogInfo $local.REPC2X_LOG_VULNERABILITY

                # Put Current Scope Name into a variable.
                $Scope = 'Vulnerability Summary'
                Write-SCLog -LogInfo $($local.REPC2X_LOG_SET_SCOPE -f $Scope)

                # Create TEMP file for the conversion process.
                $SummaryTMP1 = [System.IO.Path]::GetTempFileName()
                Write-SCLog -LogInfo $($local.REPC2X_LOG_TEMP_FILE -f $SummaryTMP1, $Scope)

                # Convert comma seprarator in CSV to $TargetCSVDelimiter provided delimiter instead. Also remove NULL or White Spaces.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_MODIFY_CSV_STRUCTURE -f $SummaryTMP1, $SourceCSVDelimiter, $TargetCSVDelimiter, $VulnSummaryCSV)
                (Get-Content -Path $VulnSummaryCSV -Raw | Where-Object { ![String]::IsNullOrWhiteSpace($PSItem) }).Replace('"' + $SourceCSVDelimiter + '"','"' + $TargetCSVDelimiter + '"').Replace('Vulnerability Priority Rating','VPR') | Out-File -FilePath $SummaryTMP1

                # Take the CSV contents and Export them to Excel.
                $WSName = $local.REPC2X_VULNERABILITY_SUMMARY_WORKSHEET
                Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_VARIABLE -f $WSName)
                $TBLName = $local.REPC2X_VULNERABILITY_SUMMARY_TABLE
                Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_TABLE_VARIABLE -f $WSName, $TBLName)

                # Check whether ExcludeSeverities or ExcludePlugins Parameters were used.
                Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUSION_PARAMETERS_CHECK
                If ($ExcludePlugins -or $ExcludeSeverity) {
                    # Import the modified CSV and export it to spreadsheet.
                    Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $SummaryTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                    If ($ExcludePlugins -and $ExcludeSeverities) {
                        Write-SCLog -LogInfo $($local.REPC2X_LOG_EXCLUDEPLUGINS_EXCLUDESEVERITIES_USED -f $ExcludePlugins, $ExcludeSeverities)

                        $ExportToXLSX = Import-Csv -Path $SummaryTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object { $PSItem.Plugin -NotIn $ExcludePlugins -and $PSItem.Severity -NotIn $ExcludeSeverities } | Select-Object *, 'Last Month?','Owner(s)','Actions','Ticket Number(s)','Status','Comments','Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                    } # End of ExcludePlugins and ExcludeSeverity Parameters check.
                    ElseIf ($ExcludePlugins) {
                        Write-SCLog -LogInfo $($local.REPC2X_LOG_EXCLUDEPLUGINS_USED -f $ExcludePlugins)

                        $ExportToXLSX = Import-Csv -Path $SummaryTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object Plugin -NotIn $ExcludePlugins | Select-Object *, 'Last Month?','Owner(s)','Actions','Ticket Number(s)','Status','Comments','Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                    } # End of ExcludePlugins Parameter check.
                    ElseIf ($ExcludeSeverities) {
                        Write-SCLog -LogInfo $($local.REPC2X_LOG_EXCLUDESEVERITIES_USED -f $ExcludeSeverities)

                        $ExportToXLSX = Import-Csv -Path $SummaryTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object Severity -NotIn $ExcludeSeverities | Select-Object *, 'Last Month?','Owner(s)','Actions','Ticket Number(s)','Status','Comments','Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                    } # End of ExcludeSeverities Parameter check.
                } # ExcludePlugins or ExcludeSeverity: True.
                Else {
                    Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUSION_PARAMETERS_NOT_USED

                    # Import the modified CSV and export it to Spreadsheet.
                    Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $DetailedTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                    $ExportToXLSX = Import-Csv -Path $SummaryTMP1 -Delimiter "$TargetCSVDelimiter" | Select-Object *, 'Last Month?','Owner(s)','Actions','Ticket Number(s)','Status','Comments','Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                } # ExcludePlugins and ExcludeSeverity: False. End of ExcludePlugins and/or ExcludeSeverity Parameter(s) check.

                # Save the Excel Package.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_SAVE_EXCEL_PACKAGE -f $Scope)
                $ExportToXLSX.Save()
            
                # Dispose of the Excel Package.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_DISPOSE_OF_PACKAGE -f $Scope)
                $ExportToXLSX.Dispose()

                # Checking if KeepTEMP Parameter was used.
                If (!$KeepTEMP) {
                    # Remove temp file.
                    Write-SCLog -LogInfo $($local.REPC2X_LOG_REMOVE_TEMP_FILE -f $SummaryTMP1)
                    Remove-Item -Path $SummaryTMP1
                } # KeepTEMP: False
                Else {
                    # Or don't remove the temp file.
                    Write-SCLog -LogInfo $($local.REPC2X_LOG_DONT_REMOVE_TEMP_FILE -f $SummaryTMP1)
                } # KeepTEMP: True. End of KeepTEMP Parameter check.
            
                # Tell Garbage Collector to dump unnecessary stuff.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_DUMP_GARBAGE -f $Scope)
                [GC]::Collect()

                Write-SCLog -LogInfo $($local.REPC2X_LOG_SECTION_END  -f $Scope)
            } # End of NoVulnSummary Parameter check.
            #endregion

            #region Detailed
        
            # Put Current Scope Name into a variable.
            $Scope = 'Vulnerability Detailed'
            Write-SCLog -LogInfo $($local.REPC2X_LOG_SET_SCOPE -f $Scope)
        
            # Create TEMP file for the conversion process.
            $DetailedTMP1 = [System.IO.Path]::GetTempFileName()
            Write-SCLog -LogInfo $($local.REPC2X_LOG_TEMP_FILE -f $DetailedTMP1, $Scope)

            # Convert comma seprarator in CSV to $TargetCSVDelimiter provided delimiter instead. Remove NULL or White Spaces.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_MODIFY_CSV_STRUCTURE -f $SummaryTMP1, $SourceCSVDelimiter, $TargetCSVDelimiter, $VulnSummaryCSV)
            (Get-Content -Path $VulnDetailCSV -Raw | Where-Object {-not [String]::IsNullOrWhiteSpace($PSItem)}).Replace('"' + $SourceCSVDelimiter + '"','"' + $TargetCSVDelimiter + '"').Replace('Vulnerability Priority Rating','VPR') | Out-File -FilePath $DetailedTMP1

            # Take the CSV contents and Export them to Excel.
            $WSName = $local.REPC2X_VULNERABILITY_DETAIL_WORKSHEET
            Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_VARIABLE -f $WSName)
            $TBLName = $local.REPC2X_VULNERABILITY_DETAIL_TABLE
            Write-SCLog -LogInfo $($local.REPC2X_LOG_WORKSHEET_TABLE_VARIABLE -f $WSName, $TBLName)

            # Check whether ExcludeSeverities or ExcludePlugins Parameters were used.
            Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUSION_PARAMETERS_CHECK
            If ($ExcludePlugins -or $ExcludeSeverity) {
                # Import the modified CSV and export it to Spreadsheet.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $DetailedTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                If ($ExcludePlugins -and $ExcludeSeverities) {
                    Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUDEPLUGINS_EXCLUDESEVERITIES_USED

                    $ExportToXLSX = Import-Csv -Path $DetailedTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object { $PSItem.Plugin -NotIn $ExcludePlugins -and $PSItem.Severity -NotIn $ExcludeSeverities } | Select-Object *, 'Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                } # End of ExcludePlugins and ExcludeSeverity parameters check.
                ElseIf ($ExcludePlugins) {
                    Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUDEPLUGINS_USED

                    $ExportToXLSX = Import-Csv -Path $DetailedTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object Plugin -NotIn $ExcludePlugins | Select-Object *, 'Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                } # End of ExcludePlugins parameter check.
                ElseIf ($ExcludeSeverities) {
                    Write-SCLog -LogInfo $local.REPC2X_LOG_EXCLUDESEVERITIES_USED

                    $ExportToXLSX = Import-Csv -Path $DetailedTMP1 -Delimiter "$TargetCSVDelimiter" | Where-Object Severity -NotIn $ExcludeSeverities | Select-Object *, 'Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
                } # End of ExcludeSeverities parameter check.
            } # ExcludePlugins or ExcludeSeverity: True.
            Else {
                $local.REPC2X_LOG_EXCLUSION_PARAMETERS_NOT_USED

                # Import the modified CSV and export it to Spreadsheet.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_IN_CSV_OUT_XLSX -f $DetailedTMP1, $TargetCSVDelimiter, $TargetXLSX, $TBLName, $WSName)
                $ExportToXLSX = Import-Csv -Path $DetailedTMP1 -Delimiter "$TargetCSVDelimiter" | Select-Object *, 'Excluded' | Export-Excel -Path $TargetXLSX -WorkSheetname $WSName -TableName $TBLName -TableStyle Medium2 -FreezeTopRow -AutoSize -PassThru
            } # ExcludePlugins and ExcludeSeverity: False. End of ExcludePlugins and/or ExcludeSeverity Parameter(s) check.

            # Save the Excel Package.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_SAVE_EXCEL_PACKAGE -f $Scope)
            $ExportToXLSX.Save()
        
            # Dispose of the Excel Package.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_DISPOSE_OF_PACKAGE -f $Scope)
            $ExportToXLSX.Dispose()

            # Checking if KeepTEMP Parameter was used.
            If (!$KeepTEMP) {
                # Remove temp file.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_REMOVE_TEMP_FILE -f $DetailedTMP1)
                Remove-Item -Path $DetailedTMP1
            } # KeepTEMP: False
            Else {
                # Or don't remove the temp file.
                Write-SCLog -LogInfo $($local.REPC2X_LOG_DONT_REMOVE_TEMP_FILE -f $DetailedTMP1)
            } # KeepTEMP: True. End of KeepTEMP Parameter check.
            
            # Tell Garbage Collector to dump unnecessary stuff.
            Write-SCLog -LogInfo $($local.REPC2X_LOG_DUMP_GARBAGE -f $Scope)
            [GC]::Collect()

            Write-SCLog -LogInfo $($local.REPC2X_LOG_SECTION_END  -f $Scope)
            #endregion
        } # End of Vulnerability parameter check.
    } # End of Parameter Switch.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function ConvertFrom-SCReportCSV2XLSX.
 
Function Initialize-SCConnection {
<#
.SYNOPSIS
API Connection Support Function.
Mean to be used only within the module!
.DESCRIPTION
Connects to SecurityCenter API using a username/password pair or username/encrypted file/key file combo.
Password is unencrypted!
.EXAMPLE
Use Username and Password:
Initialize-SCConnection -Username "SCUser" -Password "SCP@55w0rd."
.EXAMPLE
Use Username, Password file and Key File:
Initialize-SCConnection -Username "SCUser" -EncryptedPasswordPath "C:\Protected\Path\password.file" -KeyPath "C:\Protected\Path\key.file"
.EXAMPLE
Use Username, Passowrd and turn Certificate Validation Check off in case self signed, or otherwise invalid, but internally trusted, certificate is used in SecurityCenter.
Initialize-SCConnection -Username "SCUser" -Password "SCP@55w0rd." -DisableCertificateCheck
.PARAMETER Username
Enter SecurityCenter Username.
.PARAMETER Password
Enter SecurityCenter User Password.
.PARAMETER EncryptedPasswordPath
Enter SecurityCenter User Encrypted Password File Path.
.PARAMETER KeyPath
Enter SecurityCenter User Encrypted Password File Key Path.
.PARAMETER DisableCertificateCheck
Turn off Certificate Validation Check.
.NOTES
Tenable.sc API does not support encrypted passwords, nor API keys.
.FUNCTIONALITY
Creates a connection to Tenable.sc's API.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $False, HelpMessage = { $local.INITCONN_HELP_USERNAME })]
    [String]$Username,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Interactive', HelpMessage = { $local.INITCONN_HELP_PASSWORD })]
    [String]$Password,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'EncryptedPasswordFile', HelpMessage = { $local.INITCONN_HELP_ENCRYPTED_PASSWORD_FILE })]
    [ValidateScript({ Test-Path -Path $PSItem -PathType Leaf })]
    [String]$EncryptedPasswordPath,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'EncryptedPasswordFile', HelpMessage = { $local.INITCONN_HELP_ENCRYPTED_PASSWORD_KEY_FILE })]
    [ValidateScript({ Test-Path -Path $PSItem -PathType Leaf })]
    [String]$KeyPath,
    [Parameter(Position = 4, Mandatory = $false, HelpMessage = { $local.INITCONN_HELP_DISABLE_CERTIFICATE_CHECK })]
    [Switch]$DisableCertificateCheck
)

Begin {
    # Check if DisableCertificateCheck Parameter was used.
    If ($DisableCertificateCheck) {
        # Disable SSL certificate validation. Necessary if Server Certificate is invalid, that includes self-signed certificates.
        Write-SCLog -LogInfo $local.INITCONN_LOG_DISABLING_CERTIFICATE_CHECK
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    } # End of DisableCertificateCheck check.

    # Set TLS version.
    Write-SCLog -LogInfo $local.INITCONN_LOG_SET_TLS12
    [System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Server, make it globally available.
    $Global:Server = "https://$ServerFQDN/rest"
    Write-SCLog -LogInfo $($local.INITCONN_LOG_SERVER_ADDRESS -f $Server)
} # End of Begin
Process {
    # Checking if Password Parameter was used.
    If ($Password) {
        # Credentials with interactively entered password.
        $Private:Credentials = '{
            "username"       : "' + $Username + '",
            "password"       : "' + $Password + '",
            "releaseSession" : "FALSE"
        }'
        
        Write-SCLog -LogInfo $($local.INITCONN_LOG_SET_CREDENTIALS -f ($Credentials | ConvertFrom-Json).releaseSession)
    } # Username and Password: True, logging in using interactively entered credentials.
    Else {
        # Decrypt password from a file specified in EncryptedPasswordPath parameter.
        Write-SCLog -LogInfo $($local.INITCONN_LOG_LOAD_ENCRYPTED_PASSWORD -f $EncryptedPasswordPath, $KeyPath)
        $Private:LoadPassword = ConvertTo-SecureString -String (Get-Content -Path "$EncryptedPasswordPath") -Key (Get-Content -Path "$KeyPath")
        Write-SCLog -LogInfo $local.INITCONN_LOG_DECRYPT_PASSWORD
        $Private:Binary = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($LoadPassword)
        $Private:Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($Binary)

        # Build JSON structured Credential.
        $Private:Credentials = '{
            "username"       : "' + $Username + '",
            "password"       : "' + $Password + '",
            "releaseSession" : "FALSE"
        }'

        Write-SCLog -LogInfo $($local.INITCONN_LOG_SET_CREDENTIALS -f ($Credentials | ConvertFrom-Json).releaseSession)

        # Check if the files are encrypted, pass the ACL checks, if yes.
        Write-SCLog -LogInfo $($local.INITCONN_LOG_FILE_ENCRYPTION -f $EncryptedPasswordPath, $KeyPath)
        $Private:Encryption = Get-ItemProperty -Path $EncryptedPasswordPath, $KeyPath | Select-Object -ExpandProperty Attributes
        If ($Encryption[0] -notlike "*Encrypted*" -and $Encryption[1] -notlike "*Encrypted*") {
            Write-SCLog -LogInfo ($local.INITCONN_LOG_FILES_NOT_ENCRYPTED -f $EncryptedPasswordPath, $KeyPath)
            
            # Check if password encryption key is overprivileged.
            Write-SCLog -LogInfo $($local.INITCONN_LOG_ENCRYPTED_FILE_VARIABLE -f $KeyPath)
            $Private:KeyACL = Get-Acl -Path $KeyPath
            Write-SCLog -LogInfo $($local.INITCONN_LOG_CHECK_ENCRYPTED_FILE_ACL -f $KeyPath)
            If ($KeyACL.AccessToString.Contains('BUILTIN\Users') -or $KeyACL.AccessToString.Contains('NT AUTHORITY\Authenticated Users') -or $KeyACL.AccessToString.Contains('BUILTIN\Administrators')) {
                Write-SCLog -LogInfo $($local.INITCONN_LOG_ENCRYPTED_FILE_ACL_WARNING -f $KeyPath)
                Write-Warning -Message $($local.INITCONN_LOG_OVER_PRIVILEGED_PASSWORD_FILES -f $KeyPath)
            } # End of KeyACL ACL check.

            # Check if password file is overprivileged.
            Write-SCLog -LogInfo $($local.INITCONN_LOG_ENCRYPTED_FILE_VARIABLE -f $EncryptedPasswordPath)
            $Private:PWDFileACL = Get-Acl -Path $EncryptedPasswordPath
            Write-SCLog -LogInfo $($local.INITCONN_LOG_CHECK_ENCRYPTED_FILE_ACL -f $EncryptedPasswordPath)
            If ($PWDFileACL.AccessToString.Contains('BUILTIN\Users') -or $PWDFileACL.AccessToString.Contains('NT AUTHORITY\Authenticated Users') -or $PWDFileACL.AccessToString.Contains('BUILTIN\Administrators')) {
                Write-SCLog -LogInfo $($local.INITCONN_LOG_ENCRYPTED_FILE_ACL_WARNING -f $EncryptedPasswordPath)
                Write-Warning -Message $($local.INITCONN_LOG_OVER_PRIVILEGED_PASSWORD_FILES -f $EncryptedPasswordPath)
            } # End of PWDFileACL ACL check.
        } # Password and key files are not encrypted.
        Else {
            Write-SCLog -LogInfo ($local.INITCONN_LOG_FILES_ENCRYPTED -f $EncryptedPasswordPath, $KeyPath)
        } # Password and key files are encrypted. End of files Encryption check.
    } # Username and Password: False, logging in using password file.

    # Start Session and make it Globally Available.
    $Global:StartSession = Invoke-RestMethod -Method POST -Uri "$Server/token" -SessionVariable SCSession -Body $Credentials -ContentType 'application/json' -Headers @{ 'HTTP' = 'X-SecurityCenter' }
    Write-SCLog -LogInfo $($local.INITCONN_LOG_NEW_CONNECTION -f $Server, $StartSession.response.token)

    # Make Session Variable Globally Available.
    Write-SCLog -LogInfo $local.INITCONN_LOG_SESSION_VARIABLE
    $Global:SCSession = $SCSession
}
End {
    # If Password variable was not set, destroy Binary String and Password variables.
    If (!$Password) {
        Write-SCLog -LogInfo $local.INITCONN_LOG_OVERWRITE_DECRYPTED_PASSWORD
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($Binary)
        Write-SCLog -LogInfo $local.INITCONN_LOG_REMOVE_PASSWORD_VARIABLE
        Remove-Variable -Name Password
    } # End of Password variable check.

    # Destroy Credentials variables in any case.
    Write-SCLog -LogInfo $local.INITCONN_LOG_REMOVE_CREDENTIALS_VARIABLE
    Remove-Variable -Name Credentials -ErrorAction SilentlyContinue
    Write-SCLog -LogInfo $local.INITCONN_LOG_REMOVE_USERNAME_VARIABLE
    Remove-Variable -Name Username -ErrorAction SilentlyContinue
}

} # End of Function Initialize-SCConnection.

Function Get-SCCurrentUser {
<#
.SYNOPSIS
Currently Logged In User.
.DESCRIPTION
Shows Currently Logged in Username.
.FUNCTIONALITY
Show Currently Logged in Username.
#>

# Get Current User.
$Method = 'GET'
$URI    = "$Server/currentUser?fields=username"
Write-SCLog -LogInfo $($local.GETCURRENT_USER_LOG_USERNAME_GET_DATA -f $Method, $URI)

$User = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

# Output Current username.
Write-SCLog -LogInfo $local.GETCURRENT_USER_LOG_OUTPUT_USERNAME
Write-Output -InputObject $User.response.username

} # End of Function Get-SCCurrentUser.

Function Get-SCActivePluginFeedStatus {
<#
.SYNOPSIS
Show Active Plugin Feed Status.
.DESCRIPTION
Shows Active type Plugin's Feed Status.
.NOTES
Output is formatted as Table with AutoSize parameter.
.FUNCTIONALITY
Shows Current Active Plugin Feed Status.
#>
[CmdletBinding()]
Param()

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    $Method = 'GET'
    $URI    = "$Server/feed/active"
    Write-SCLog -LogInfo $($local.GETACTIVEPLUGINFEED_LOG_STATUS_GET_DATA -f $Method, $URI)

    # Get Feed Update Status.
    $FeedStatus = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Create a custom table of Active Plugin Feed Status contents.
    Write-SCLog -LogInfo $($local.LOG_CUSTOM_OUTPUT_TABLE -f 'Active Plugin Feed Status')

    $FeedTable = New-Object PSObject
    Add-Member -InputObject $FeedTable -MemberType NoteProperty -Name $local.GETACTIVEPLUGINFEED_STATUS_UPTIME         -Value (ConvertFrom-EpochToNormal -InputEpoch $FeedStatus.response.updateTime)
    Add-Member -InputObject $FeedTable -MemberType NoteProperty -Name $local.GETACTIVEPLUGINFEED_STATUS_STALE          -Value $Culture.ToTitleCase($FeedStatus.response.stale)
    Add-Member -InputObject $FeedTable -MemberType NoteProperty -Name $local.GETACTIVEPLUGINFEED_STATUS_UPDATE_RUNNING -Value $Culture.ToTitleCase($FeedStatus.response.updateRunning)

    # Output Active Plugin Feed Status Data.
    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Active Plugin Feed Status')

    Write-Output -InputObject $FeedTable
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCActivePluginFeedStatus.

Function Initialize-SCActivePluginFeedUpdate {
<#
.SYNOPSIS
Start Active Plugin Feed Update.
.DESCRIPTION
Initializes Active type Plugin's Feed Update.
.FUNCTIONALITY
Forces Active type Plugin Feed Update. This happens once a day by default.
#>
[CmdletBinding()]
Param()

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    $Method = 'POST'
    $URI    = "$Server/feed/active/update"
    Write-SCLog -LogInfo $($local.INIT_APFEED_UPDATE_LOG -f $Method, $URI)

    # Start Active Feed Update.
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    Write-Output -InputObject $local.INIT_APFEED_UPDATE_INFO_UPDATE_INITIATED
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Initialize-SCActivePluginFeedUpdate.

Function Get-SCPlugin {
<#
.SYNOPSIS
Get Plugin Info.
.DESCRIPTION
Gets a specific Plugin Info.
.EXAMPLE
Get Kubernetes Web API Detection, which has an ID of 121471:
Get-SCPlugin -ID 121471
.EXAMPLE
Same as above, but a bit more detailed output:
Get-SCPlugin -ID 121471 -Detailed
.PARAMETER ID
Enter Plugin ID
.PARAMETER Detailed
Show more detailed output of the specified plugin.
.EXAMPLE
Show Scans in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCPlugin -RAW
.PARAMETER ID
ID of the Plugin.
.PARAMETER Detailed
Shows more detailed view of the Plugin.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Plugin Info.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $True, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGIN_HELP_PLUGIN_ID }, ValueFromPipelineByPropertyName)]
    [Int]$ID, 
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_DETAILED })]
    [Switch]$Detailed,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Plugin Data.
    $Method = 'GET'
    $URI    = "$Server/plugin/$ID"
    Write-SCLog -LogInfo $($local.GETPLUGIN_LOG_GET_DATA -f $ID, $Method, $URI)

    $Plugin = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Store Output table into variable.
    If ($Detailed) {
        Write-SCLog -LogInfo $local.GETPLUGIN_LOG_DETAILED_SWITCH

        $OutputTable = $Plugin.response | Select-Object -Property `
            @{ Name = $local.GETPLUGIN_TBL_ID;                                Expression = { $PSItem.id }},
            @{ Name = $local.GETPLUGIN_TBL_NAME;                              Expression = { $PSItem.name }},
            @{ Name = $local.GETPLUGIN_TBL_DESCRIPTION;                       Expression = { $PSItem.description }},
            @{ Name = $local.GETPLUGIN_TBL_SOLUTION;                          Expression = { $PSItem.solution }},
            @{ Name = $local.GETPLUGIN_TBL_SYNOPSIS;                          Expression = { $PSItem.synopsis }},
            @{ Name = $local.GETPLUGIN_TBL_TCP_PORTS;                         Expression = { $PSItem.requiredPorts }},
            @{ Name = $local.GETPLUGIN_TBL_UDP_PORTS;                         Expression = { $PSItem.requiredUDPPorts }},
            @{ Name = $local.GETPLUGIN_TBL_PLUGIN_FILE;                       Expression = { $PSItem.sourceFile }},
            @{ Name = $local.GETPLUGIN_TBL_DEPENDENCIES;                      Expression = { $PSItem.dependencies }},
            @{ Name = $local.GETPLUGIN_TBL_RISK_FACTOR;                       Expression = { $PSItem.riskFactor }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_SCORE;                         Expression = { $PSItem.vprScore }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_VULNERABILITY_AGE;     Expression = { $PSItem.vprContext.value[0] }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_CVSSV3_IMPACT_SCORE;   Expression = { ([math]::Round($PSItem.vprContext.value[1],1)) }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_EXPLOIT_CODE_MATURITY; Expression = { $PSItem.vprContext.value[2] }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_PRODUCT_COVERAGE;      Expression = { $PSItem.vprContext.value[3] }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_THREAT_INTENSITY;      Expression = { $PSItem.vprContext.value[4] }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_THREAT_RECENCY;        Expression = { $PSItem.vprContext.value[5] }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_CONTEXT_THREAT_SOURCES;        Expression = { $PSItem.vprContext.value[6] }},
            @{ Name = $local.GETPLUGIN_TBL_CVSSV3BASE;                        Expression = { $PSItem.cvssV3BaseScore }},
            @{ Name = $local.GETPLUGIN_TBL_CVSSV3TEMPORAL;                    Expression = { $PSItem.cvssV3TemporalScore }},
            @{ Name = $local.GETPLUGIN_TBL_CHECK_TYPE;                        Expression = { $Culture.ToTitleCase($PSItem.checkType) }},
            @{ Name = $local.GETPLUGIN_TBL_EXPLOIT_AVAILABLE;                 Expression = { $Culture.ToTitleCase($PSItem.exploitAvailable) }},
            @{ Name = $local.GETPLUGIN_TBL_PLUGIN_PUBLICATION_DATE;           Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.pluginPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_PATCH_PUBLICATION_DATE;            Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.patchPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_VULNERABILITY_PUBLICATION_DATE;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.vulnPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_REFERENCES;                        Expression = { ($PSItem.xrefs -replace ',', $NewLine -replace '.*CVE:','') }},
            @{ Name = $local.GETPLUGIN_TBL_FAMILY;                            Expression = { $PSItem.family.name }},
            @{ Name = $local.GETPLUGIN_TBL_HASH;                              Expression = { $PSItem.md5 }}
    } # Detailed check: True.
    Else {
        # Shorter output (Default).
        Write-SCLog -LogInfo $local.LOG_DEFAULT

        $OutputTable = $Plugin.response | Select-Object -Property `
            @{ Name = $local.GETPLUGIN_TBL_ID;                                Expression = { $PSItem.id }},
            @{ Name = $local.GETPLUGIN_TBL_NAME;                              Expression = { $PSItem.name }},
            @{ Name = $local.GETPLUGIN_TBL_RISK_FACTOR;                       Expression = { $PSItem.riskFactor }},
            @{ Name = $local.GETPLUGIN_TBL_VPR_SCORE;                         Expression = { $PSItem.vprScore }},
            @{ Name = $local.GETPLUGIN_TBL_EXPLOIT_AVAILABLE;                 Expression = { $Culture.ToTitleCase($PSItem.exploitAvailable) }},
            @{ Name = $local.GETPLUGIN_TBL_PLUGIN_PUBLICATION_DATE;           Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.pluginPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_PATCH_PUBLICATION_DATE;            Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.patchPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_VULNERABILITY_PUBLICATION_DATE;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.vulnPubDate }},
            @{ Name = $local.GETPLUGIN_TBL_REFERENCES;                        Expression = { ($PSItem.xrefs -replace ',', $NewLine -replace '.*CVE:','') }},
            @{ Name = $local.GETPLUGIN_TBL_FAMILY;                            Expression = { $PSItem.family.name }}
    } # Detailed check: False. End of Detailed parameter check.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Plugin')

    # Check if RAW Parameter was used.
    If ($RAW) {
        # Display unformatted, unchanged raw data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $Plugin.response
    } # RAW Parameter was used.
    Else {
        # Output Plugin Data.
        Write-Output -InputObject $OutputTable
    } # Showing Default View. End of RAW parameter check.

}
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
}

} # End of Function Get-SCPlugin.

Function Get-SCPlugins {
<#
.SYNOPSIS
Get Plugins Listing.
.DESCRIPTION
Retrieves a list of Plugins.
.EXAMPLE
Show Plugins with names like "rootkit".
Get-SCPlugins -PluginName "rootkit"
.EXAMPLE
Show Plugins with Plugin Family Name like "IoT".
Get-SCPlugins -FamilyName "IoT"
.EXAMPLE
Show Plugins that have CVEs like "CVE-2019-7061".
Get-SCPlugins -CVE "CVE-2018-18500"
.EXAMPLE
Show certain types of Plugins. We have mostly Active Plugins, so to list those:
Type parameter takes only Active, Passive, or Compliance values. Use tab, to switch between them.
Get-SCPlugins -Type active
.EXAMPLE
Show Plugins with specified Severity.
Severity parameter takes only Critical, High, Info, Low, Medium values. Use tab, to switch between them.
Get-SCPlugins -Severity Critical
.EXAMPLE
Show Plugins with exploits.
Exploitability parameter takes only True and False values. Use tab, to switch between them.
Get-SCPlugins -Exploitable True
.EXAPLE
Limit the Output.
Default Output of 10000 has been set so because it is somewhat reasonable time to wait. But that means that some of the data can and most probably will be left out.
By turning up the limit, the amount of time you have to wait and the amount of data you get, will be inversely proportional.
At the moment, there's not point going over 2.000.000. But by turning it to the max, you will have to wait quite a long time, regardless of how many actual matches you will get. In turn you will get all the data.
Get-SCPlugins -PluginName VLC -Limit 20000
.EXAMPLE
Combining Parameters to get more specific Output.
Find Plugins for Adobe Flash, with Critical severity, existing exploits and belong to one of the Windows Plugin Families.
Get-SCPlugins -PluginName flash -Severity Critical -Exploitable True -FamilyName Windows
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCPlugins -PluginName Adobe -NoFormat
.EXAMPLE
Show Plugins in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted, such as a Table.
This can also be used if you want to export the output, or send it to pipeline.
Get-SCPlugins -RAW
.PARAMETER PluginName
Filter Output by Plugin Name.
.PARAMETER FamilyName
Filter Output by Plugin Family Name.
.PARAMETER CVE
Filter Output by Plugin CVE's.
.PARAMETER Type
Filter Output by Plugin Type.
.PARAMETER Severity
Filter Output by Severity of the Plugins.
.PARAMETER Exploitable
Filter Output by (non-)exploitable Plugins.
.PARAMETER Limit
Limit Output Length.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Plugins Listings.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_PLUGIN_NAME })]
    [String]$PluginName,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_PLUGIN_FAMILY_NAME })]
    [String]$FamilyName,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_CVE })]
    [String]$CVE,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_PLUGIN_TYPE })]
    [ValidateSet('active','all','compliance','custom','lce','notPassive','passive')]
    [String]$Type = 'active',
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_SEVERITY })]
    [ValidateSet('critical','high','info','low','medium')]
    [String]$Severity,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_EXPLOITABLE })]
    [ValidateSet('false','true')]
    [String]$Exploitable,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINS_HELP_OUTPUTLIMIT })]
    [Int]$Limit,
    [Parameter(Position = 7, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 8, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Checking if Limit Parameter was used.
    If (!$Limit) {
        # By Default, only as many as your current Buffer Height permits, will be displayed. Either change the value in PS Properties, or use the Limit Parameter,
        # but then the ones that go beyond the Buffer limit, will be clipped (first ones). Send the output to a file then instead, using the -NoFormat Parameter.
        Write-SCLog -LogInfo $local.LOG_BUFFER_HEIGHT_VARIABLE
        $Limit = $BufferHeight
    } # End of Limit parameter check.

    # Get Plugins Data.
    $Method = 'GET'
    $URI    = "$Server/plugin?fields=id,name,family,type,riskFactor,exploitAvailable,xrefs&filterField=type&op=eq&value=$Type&endOffset=$Limit"

    Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_GET_DATA -f $Method, $URI)
    $Plugins = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($PluginName -and $Severity -and $FamilyName -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_FNAME_PNAME_SEVERITY -f $Exploitable, $FamilyName, $PluginName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.family.name -like "*$FamilyName*" -and $PSItem.name -like "*$PluginName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $Severity -and $FamilyName) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_FNAME_PNAME_SEVERITY -f $FamilyName, $PluginName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.family.name -like "*$FamilyName*" -and $PSItem.name -like "*$PluginName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $Severity -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_PNAME_SEVERITY -f $Exploitable, $PluginName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.name -like "*$PluginName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $FamilyName -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_FNAME_PNAME -f $Exploitable, $FamilyName, $PluginName)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.family.name -like "*$FamilyName*" -and $PSItem.name -like "*$PluginName*" }
    }
    ElseIf ($FamilyName -and $Severity -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_FNAME_SEVERITY -f $Exploitable, $FamilyName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.family.name -like "*$FamilyName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($CVE -and $Severity -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_SEVERITY_XREFS -f $CVE, $Exploitable, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.xrefs -like "*$CVE*" -and $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $Severity) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_PNAME_SEVERITY -f $PluginName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.name -like "*$PluginName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $Type) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_PNAME_TYPE -f $PluginName, $Type)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.name -like "*$PluginName*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($CVE -and $Severity) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_SEVERITY_XREFS -f $CVE, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.xrefs -like "*$CVE*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName -and $FamilyName) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_FNAME_PNAME -f $FamilyName, $PluginName)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.family.name -like "*$FamilyName*" -and $PSItem.name -like "*$PluginName*" }
    }
    ElseIf ($Severity -and $Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY_SEVERITY -f $Exploitable, $Severity )
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($FamilyName -and $Severity) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_FNAME_SEVERITY -f $FamilyName, $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.family.name -like "*$FamilyName*" -and $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($PluginName) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_PNAME -f $PluginName)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.name -like "*$PluginName*" }
    }
    ElseIf ($FamilyName) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_FNAME -f $FamilyName)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.family.name -like "*$FamilyName*" }
    }
    ElseIf ($CVE) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_XREFS -f $CVE)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.xrefs -like "*$CVE*" }
    }
    ElseIf ($Severity) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_SEVERITY -f $Severity)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.riskFactor -eq $Severity }
    }
    ElseIf ($Exploitable) {
        Write-SCLog -LogInfo $($local.GETPLUGINS_LOG_EXPLOITABILITY -f $Exploitable)
        $OutputHolder = $Plugins.response | Where-Object { $PSItem.exploitAvailable -eq $Exploitable }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Plugins.response
    }
    #endregion Conditions

    # Checking if output is empty or not. Low Buffer limit may hide data.
    If ($OutputHolder.Length -lt 1) {
        Write-Output -InputObject $($local.GETPLUGINS_INFO_EMPTY_OUTPUT -f $Limit)
    }
    Else {
        # Checking if NoFormat switch is used.
        If ($NoFormat) {
            # Store Output table into variable.
            $OutputTable = $OutputHolder | Select-Object -Property `
                @{ Name = $local.GETPLUGINS_TBL_ID;                Expression = { $PSItem.id }},
                @{ Name = $local.GETPLUGINS_TBL_NAME;              Expression = { $PSItem.name }},
                @{ Name = $local.GETPLUGINS_TBL_TYPE;              Expression = { $Culture.ToTitleCase($PSItem.type) }},
                @{ Name = $local.GETPLUGINS_TBL_SEVERITY;          Expression = { $PSItem.riskFactor }},
                @{ Name = $local.GETPLUGINS_TBL_EXPLOIT_AVAILABLE; Expression = { $Culture.ToTitleCase($PSItem.exploitAvailable) }},
                @{ Name = $local.GETPLUGINS_TBL_PLUGIN_FAMILY;     Expression = { $PSItem.family.name }}
        } # NoFormat Parameter was used.
        Else {
            # This kind of formatting is necessary, because some Plugin Names are extremely long and it will mess up the Table. By creating a custom Table Property, we can limit column widths.
            $OutputTable =
                @{ Expression = { $PSItem.id };                                     Label = $local.GETPLUGINS_TBL_ID;                Width = 10  }, 
                @{ Expression = { $PSItem.name };                                   Label = $local.GETPLUGINS_TBL_NAME;              Width = 150 }, 
                @{ Expression = { $Culture.ToTitleCase($PSItem.type) };             Label = $local.GETPLUGINS_TBL_TYPE;              Width = 10  }, 
                @{ Expression = { $PSItem.riskFactor };                             Label = $local.GETPLUGINS_TBL_SEVERITY;          Width = 10  },
                @{ Expression = { $Culture.ToTitleCase($PSItem.exploitAvailable) }; Label = $local.GETPLUGINS_TBL_EXPLOIT_AVAILABLE; Width = 20  },
                @{ Expression = { $PSItem.family.name };                            Label = $local.GETPLUGINS_TBL_PLUGIN_FAMILY;     Width = 40  }
        } # Storing Default View. End of NoFormat parameter check.
    } # End of OutputHolder check.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Plugins list')
    # Checking for output options.
    If ($NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Output: NoFormat.
    ElseIf ($RAW) {
        # Display unformatted, unchanged raw data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputHolder | Format-Table -Property $OutputTable
    
        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Default View. End of NoFormat, RAW parameters checks.

} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCPlugins.

Function Get-SCPluginFamilies {
<#
.SYNOPSIS
Get Plugin Families.
.DESCRIPTION
Retrieves a list of Plugin Families.
.EXAMPLE
Show default view. Sorted by Plugin Family Name and formatted as Table.
Get-SCPluginFamilies
.EXAMPLE
Show a specific Plugin Family.
Get-SCPluginFamilies -ID 20
.EXAMPLE
Show Plugin Families filtered by Name.
Get-SCPluginFamilies -Name windows
.EXAMPLE
Show Plugin Families filtered by Type.
Get-SCPluginFamilies -Type active
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCPluginFamilies -NoFormat
.EXAMPLE
Show Plugins in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted, such as a Table.
This can also be used if you want to export the output, or send it to pipeline.
Get-SCPluginFamilies -RAW
.PARAMETER ID
Filter output by ID.
.PARAMETER Name
Filter output by Name.
.PARAMETER Type
Filter output by Type.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.NOTES
Output is sorted by Name column and formatted as Table.
.FUNCTIONALITY
Shows Plugin Families.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINFAMILIES_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINFAMILIES_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINFAMILIES_HELP_TYPE })]
    [ValidateSet('active', 'compliance','passive')]
    [String]$Type,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPLUGINFAMILIES_HELP_RELATED_PLUGINS })]
    [Switch]$ListRelatedPlugins,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get a list of Plugin Families.
    $Method  = 'GET'

    # Check whether ID Parameter was used. If yes, query the Plugin Family directly, instead of filtering it out from all the Plugin Families later.
    If ($ID) {
        $URI = "$Server/pluginFamily/$($ID)?fields=name,type,count,plugins"
    } # Getting Plugin Family with a specific ID.
    Else {
        $URI = "$Server/pluginFamily?fields=name,type,count&endOffset=200"
    } # Getting all Plugin Families. End of ID parameter check.
    Write-SCLog -LogInfo $($local.GETPLUGINFAMILIES_LOG_GET_DATA -f $Method, $URI)

    $PluginFamilies = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Name -and $Type) {
        Write-SCLog -LogInfo $($local.GETPLUGINFAMILIES_LOG_NAME_TYPE -f $Name, $Type)
        $OutputHolder = $PluginFamilies.response | Where-Object { $PSItem.name -like "*$Name*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETPLUGINFAMILIES_LOG_ID -f $ID)
        $OutputHolder = $PluginFamilies.response | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETPLUGINFAMILIES_LOG_NAME -f $Name)
        $OutputHolder = $PluginFamilies.response | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($Type) {
        Write-SCLog -LogInfo $($local.GETPLUGINFAMILIES_LOG_TYPE -f $Type)
        $OutputHolder = $PluginFamilies.response | Where-Object { $PSItem.type -eq $Type }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $PluginFamilies.response
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETPLUGINFAMILIES_TBL_ID;      Expression = { $PSItem.id }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_NAME;    Expression = { $PSItem.name }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_TYPE;    Expression = { $Culture.ToTitleCase($PSItem.type) }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_COUNT;   Expression = { $PSItem.count }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_PLUGINS; Expression = {
                # Check whether Plugins Count is below or equal to current Buffer Height, or if ListRelatedPlugins Parameter was used, to show all Plugins.
                If ($PSItem.count -le $BufferHeight -or $ListRelatedPlugins) {
                    $PluginsArray = ForEach ($Item in $PSItem.plugins) {
                        "$($Item.id) $($Item.name)"
                    }

                    # Break up the array of Plugins to a list.
                    $PluginsArray[0..$($PluginsArray.Length)] -join "`n"
                }
                Else {
                    # Notify User that the Plugins count exceeds Buffer Height.
                    Write-Output -InputObject $($local.GETPLUGINFAMILIES_LOG_LARGE_OUTPUT -f $BufferHeight, $PSItem.count, $($PSItem.count-$BufferHeight))
                }

            }}
    } # ID Parameter: True.
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETPLUGINFAMILIES_TBL_ID;    Expression = { $PSItem.id }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_NAME;  Expression = { $PSItem.name }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_TYPE;  Expression = { $Culture.ToTitleCase($PSItem.type) }},
            @{ Name = $local.GETPLUGINFAMILIES_TBL_COUNT; Expression = { $PSItem.count }}
    } # Storing Default View. End of ID parameter check.

    # Output list of Plugin Families.
    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Plugin Family')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable
        
        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # Display unformatted, unchanged raw data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Sort-Object $local.GETPLUGINFAMILIES_TBL_NAME | Format-Table -AutoSize
    
        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCPluginFamilies.

Function Get-SCRepositories {
<#
.SYNOPSIS
Get Repositories.
.DESCRIPTION
Get a list of Repositories.
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCRepositories -NoFormat
.EXAMPLE
Show Plugins in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted, such as a Table.
This can also be used if you want to export the output, or send it to pipeline.
Get-SCRepositories -RAW
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.NOTES
Output for this function is unformatted.
.FUNCTIONALITY
Shows Repositories List.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Repositories.
    $Method = 'GET'
    $URI    = "$Server/repository"
    Write-SCLog -LogInfo $($local.GETREPOSITORIES_LOG_GET_DATA -f $Method, $URI)
    $UpdateFeed = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Store Output table into variable.
    $OutputTable = $UpdateFeed.response | Select-Object -Property `
        @{ Name = $local.GETREPOSITORIES_TBL_ID;          Expression = { $PSItem.id }},
        @{ Name = $local.GETREPOSITORIES_TBL_NAME;        Expression = { $PSItem.name }},
        @{ Name = $local.GETREPOSITORIES_TBL_DESCRIPTION; Expression = { $PSItem.description }},
        @{ Name = $local.GETREPOSITORIES_TBL_FORMAT;      Expression = { $Culture.ToTitleCase($PSItem.dataFormat) }}

    # Output Repositories Data.
    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Repositories list')

    If ($NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    }
    ElseIf ($RAW) {
        # Display Unformatted, Raw Data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $UpdateFeed.response
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($UpdateFeed.response).Count)
    }
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize
    
        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # End of NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCRepositories.

Function Get-SCScanResults {
<#
.SYNOPSIS
Get Scan Results.
.DESCRIPTION
List Scan Results.
.EXAMPLE
Show All The Scan Results, including empty and erroneous ones. Default view shows only Finished/Successful Results.
Get-SCScanResults -ShowAll
.EXAMPLE
Show Only Running Scans.
Get-SCScanResults -ShowRunningScans
.EXAMPLE
Show Only Scan Results from User who started the Scan(s). Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Scan Results where Initiator's First or Last Name contains "gen".
Get-SCScanResults -Initiator gen
.EXAMPLE
Show Only Scan Results from User who own the Scan(s). Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Scan Results where Owner's First or Last Name contains "gen".
Get-SCScanResults -Owner gen
.EXAMPLE
Show older Reports. Default output is showing within 30 days. Use Tab to switch between allowed values.
Get-SCScanResults -StartTime '120 Days'
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCScanResults -Name dblan -NoFormat
.EXAMPLE
Show Scan Results in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCPlugins -RAW
.PARAMETER ShowAll
Show All Scan Results, including failed and ones without data.
.PARAMETER ShowRunningScans
Show only Running Scans.
.PARAMETER Initiator
Filter Output by Initiator First or Last Name.
.PARAMETER Owner
Filter Output by Owner First or Last Name.
.PARAMETER StartTime
Extend the period in which the reports were created.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show Unformatted Output.
.FUNCTIONALITY
Shows Scan Results.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANRESULTS_HELP_SHOW_ALL })]
    [Switch]$ShowAll,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANRESULTS_HELP_SHOW_RUNNING })]
    [Switch]$ShowRunningScans,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANRESULTS_HELP_INITIATOR })]
    [String]$Initiator,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANRESULTS_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANRESULTS_HELP_START_TIME })]
    [ValidateSet('60 Days','120 Days','360 Days','All')]
    [String]$StartTime,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Start Time from $StartTime Parameter and create an epoch string from the chosen timespan.
    Switch ($StartTime) {
        '60 Days'  { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-60) }
        '120 Days' { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-120) }
        '360 Days' { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-360) }
        'All'      { [Int]$AgeLimit = '1388527200' } # From 01.01.2014.
        Default    { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-30) }
    } # End of StartTime switch.

    # Get Reports.
    $Method = 'GET'
    $URI    = "$Server/scanResult?fields=id,name,status,initiator,owner,repository,importStatus,totalIPs,scannedIPs,startTime,finishTime,completedChecks,totalChecks,running&startTime=$AgeLimit"
    Write-SCLog -LogInfo $($local.GETREPORTS_LOG_GET_DATA -f $Method, $URI)

    $ScanResults = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Initiator -and $ShowRunningScans) {
        Write-SCLog -LogInfo $($local.GETSCANRESULTS_LOG_INITIATOR_SHOW_RUNNING_SCANS -f $Initiator)
        $OutputHolder = $ScanResults.response.usable | Where-Object { $PSItem.running -eq 'true' -and ($PSItem.initiator.firstname -like "*$Initiator*" -or $PSItem.initiator.lastname -like "*$Initiator*" -or $PSItem.initiator.username -like "*$Initiator*") }
    }
    ElseIf ($ShowAll -or $RAW) {
        Write-SCLog -LogInfo $local.GETSCANRESULTS_LOG_SHOW_ALL
        $OutputHolder = $ScanResults.response.usable
    }
    ElseIf ($Initiator) {
        Write-SCLog -LogInfo $($local.GETSCANRESULTS_LOG_INITIATOR -f $Initiator)
        $OutputHolder = $ScanResults.response.usable | Where-Object { $PSItem.initiator.firstname -like "*$Initiator*" -or $PSItem.initiator.lastname -like "*$Initiator*" -or $PSItem.initiator.username -like "*$Initiator*" }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETSCANRESULTS_LOG_OWNER -f $Owner)
        $OutputHolder = $ScanResults.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($ShowRunningScans) {
        Write-SCLog -LogInfo $local.GETSCANRESULTS_LOG_SHOW_RUNNING_SCANS
        $OutputHolder = $ScanResults.response.usable | Where-Object { $PSItem.running -eq 'true' }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $ScanResults.response.usable | Where-Object { $PSItem.importStatus -eq 'Finished' }
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($Initiator -and $ShowRunningScans) {
        Write-SCLog -LogInfo $($local.GETSCANRESULTS_LOG_STORE_INITIATOR_RUNNING_SCANS -f $Initiator)

        $OutputTable = $OutputHolder | Select-Object -Property `
                @{ Name = $local.GETSCANRESULTS_TBL_ID;         Expression = { $PSItem.id }},
                @{ Name = $local.GETSCANRESULTS_TBL_NAME;       Expression = { $PSItem.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_RUNNING;    Expression = { $Culture.ToTitleCase($PSItem.running) }},
                @{ Name = $local.GETSCANRESULTS_TBL_INITIATOR;  Expression = { "$($PSItem.initiator.firstname) $($PSItem.initiator.lastname)/$($PSItem.initiator.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_OWNER;      Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_REPOSITORY; Expression = { $PSItem.repository.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_CHECKS;     Expression = { "$($PSItem.completedChecks)/$($PSItem.totalChecks)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_START;      Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime }},
                @{ Name = $local.GETSCANRESULTS_TBL_ELAPSED;    Expression = {
                    $Duration = New-TimeSpan -Start (ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime) -End (Get-Date)
                    "$($Duration.Hours):$($Duration.Minutes):$($Duration.Seconds)"
                }},
                @{ Name = $local.GETSCANRESULTS_TBL_PROGRESS;   Expression = { ($PSItem.completedChecks/$PSItem.totalChecks).ToString('P')
                }}
    } # Initiator and ShowRunningScans: True.
    ElseIf ($ShowRunningScans) {
        Write-SCLog -LogInfo $local.GETSCANRESULTS_LOG_STORE_RUNNING_SCANS

        $OutputTable = $OutputHolder | Select-Object -Property `
                @{ Name = $local.GETSCANRESULTS_TBL_ID;         Expression = { $PSItem.id }},
                @{ Name = $local.GETSCANRESULTS_TBL_NAME;       Expression = { $PSItem.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_RUNNING;    Expression = { $Culture.ToTitleCase($PSItem.running) }},
                @{ Name = $local.GETSCANRESULTS_TBL_INITIATOR;  Expression = { "$($PSItem.initiator.firstname) $($PSItem.initiator.lastname)/$($PSItem.initiator.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_OWNER;      Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_REPOSITORY; Expression = { $PSItem.repository.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_CHECKS;     Expression = { "$($PSItem.completedChecks)/$($PSItem.totalChecks)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_START;      Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime }},
                @{ Name = $local.GETSCANRESULTS_TBL_ELAPSED;    Expression = {
                    $Duration = New-TimeSpan -Start (ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime) -End (Get-Date)
                    "$($Duration.Hours):$($Duration.Minutes):$($Duration.Seconds)"
                }},
                @{ Name = $local.GETSCANRESULTS_TBL_PROGRESS;   Expression = { ($PSItem.completedChecks/$PSItem.totalChecks).ToString('P')
                }}
    } # ShowRunningScans: True.
    Else {
        Write-SCLog -LogInfo $local.GETSCANRESULTS_LOG_DEFAULT

        $OutputTable = $OutputHolder | Select-Object -Property `
                @{ Name = $local.GETSCANRESULTS_TBL_ID;         Expression = { $PSItem.id }},
                @{ Name = $local.GETSCANRESULTS_TBL_NAME;       Expression = { $PSItem.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_INITIATOR;  Expression = { "$($PSItem.initiator.firstname) $($PSItem.initiator.lastname)/$($PSItem.initiator.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_OWNER;      Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
                @{ Name = $local.GETSCANRESULTS_TBL_REPOSITORY; Expression = { $PSItem.repository.name }},
                @{ Name = $local.GETSCANRESULTS_TBL_HOSTS;      Expression = {
                    If ($PSItem.scannedIPs -ne $PSItem.totalIPs) {
                        "$($PSItem.scannedIPs)/$($PSItem.totalIPs) X"
                    }
                    Else {
                        "$($PSItem.scannedIPs)/$($PSItem.totalIPs)"
                    }
                }},
                @{ Name = $local.GETSCANRESULTS_TBL_CHECKS; Expression = {
                    If ($PSItem.completedChecks -ne $PSItem.totalChecks) {
                        "$($PSItem.completedChecks)/$($PSItem.totalChecks) X"
                    }
                    ElseIf ($PSItem.completedChecks -eq $PSItem.totalChecks) {
                        "$($PSItem.completedChecks)/$($PSItem.totalChecks)"
                    }
                }},
                @{ Name = $local.GETSCANRESULTS_TBL_START;     Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime }},
                @{ Name = $local.GETSCANRESULTS_TBL_FINISH;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.finishTime }},
                @{ Name = $local.GETSCANRESULTS_TBL_DURATION;  Expression = {
                    $Duration = New-TimeSpan -Start (ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime) -End (ConvertFrom-EpochToNormal -InputEpoch $PSItem.finishTime)
                    "$($Duration.Hours):$($Duration.Minutes):$($Duration.Seconds)"
                }}
    } # Store Default View. End of Output tables Parameters check.

    # Checking for output options.
    If ($NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Output: NoFormat.
    ElseIf ($RAW) {
        # Display Unformatted, Raw Data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder
    
        # Show Total Entries.
        Write-Output -InputObject $($NewLine + $local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Sort-Object -Property $local.GETSCANRESULTS_TBL_ID -Descending | Format-Table -AutoSize
    
        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of NoFormat, RAW Parameters checks.
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCScanResults.

Function Get-SCLicenseStatus {
<#
.SYNOPSIS
Get License Status.
.DESCRIPTION
Shows Current License Status and Job Daemon Status.
.NOTES
Output for this function is unformatted.
.FUNCTIONALITY
Shows License Information and Job Daemon Status.
#>
[CmdletBinding()]
Param()

Begin{
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get License Data.
    $Method = 'GET'
    $URI = "$Server/status"
    Write-SCLog -LogInfo $($local.GETLICENSESTATUS_LOG_GET_DATA -f $Method, $URI)
    $LicenseInfo = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Output License Status Data.
    Write-SCLog -LogInfo $($local.LOG_CUSTOM_OUTPUT_TABLE -f 'License Status')

    $LicenseTable = New-Object PSObject
    Add-Member -InputObject $LicenseTable -MemberType NoteProperty -Name $local.GETLICENSESTATUS_TBL_JOB_DAEMON            -Value $LicenseInfo.response.jobd
    Add-Member -InputObject $LicenseTable -MemberType NoteProperty -Name $local.GETLICENSESTATUS_TBL_LICENSE_STATUS        -Value $LicenseInfo.response.licenseStatus
    Add-Member -InputObject $LicenseTable -MemberType NoteProperty -Name $local.GETLICENSESTATUS_TBL_PLUGIN_SUB_STATUS     -Value $LicenseInfo.response.PluginSubscriptionStatus
    Add-Member -InputObject $LicenseTable -MemberType NoteProperty -Name $local.GETLICENSESTATUS_TBL_ACTIVE_TOTAL_LICENSES -Value "$($LicenseInfo.response.activeIPs)/$($LicenseInfo.response.licensedIPs)"
    Add-Member -InputObject $LicenseTable -MemberType NoteProperty -Name $local.GETLICENSESTATUS_TBL_IPS_FREE              -Value ($LicenseInfo.response.licensedIPs-$LicenseInfo.response.activeIPs)

    # Output Results.
    Write-SCLog -LogInfo $local.GETLICENSESTATUS_LOG_OUTPUT
    Write-Output -InputObject $LicenseTable
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCLicenseStatus.

Function Get-SCScanZones {
<#
.SYNOPSIS
Get Zones List.
.DESCRIPTION
Show Zones Listing.
.EXAMPLE
Show the list of Scan Zones.
Get-SCScanZones
.EXAMPLE
Show a specific Scan Zone.
Get-SCScanZones -ID 73
.EXAMPLE
Show Scan Zones which have provided IP address in it, can be partial.
Get-SCScanZones -Address "10.132"
.EXAMPLE
Show Scan Zones in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCScanZones -RAW
.PARAMETER ID
Shows a Scan Zone with specific ID.
.PARAMETER RAW
Show Unformatted Output.
.NOTES
Output for this cmdlet is unformatted. This cmdlet requires the Tenable.sc user to have administrative privileges.
.FUNCTIONALITY
Shows Scan Zones Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETSCANZONES_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Address', HelpMessage = { $local.GETSCANZONES_HELP_ADDRESS })]
    [String]$Address,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'admin'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Scan Zone Data.
    $Method = 'GET'
    $URI    = "$Server/zone"
    Write-SCLog -LogInfo $($local.GETSCANZONES_LOG_GET_DATA -f $Method, $URI)

    $Zones = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Get Zone Data.
    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Scan Zone')

    # Checking if Output is empty or not. Empty Output means the Tenable.sc user used does not have Administrative Privileges.
    If (($Zones.response).Count -lt 1) {
        Write-SCError -Message $local.GETSCANZONES_ERROR_NO_PRIVILEGES -RecommendedAction $local.GETSCANZONES_ERROR_NO_PRIVILEGES_FIX
    } # No Output. End of Output Count check.
    Else {
        Switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                Write-SCLog -LogInfo $local.GETSCANZONES_LOG_DEFAULT

                $Zones.response | Select-Object -Property `
                    @{ Name = $local.GETSCANZONES_TBL_ID ;             Expression = { $PSItem.id }},
                    @{ Name = $local.GETSCANZONES_TBL_NAME;            Expression = { $PSItem.name }},
                    @{ Name = $local.GETSCANZONES_TBL_CREATED_TIME;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
                    @{ Name = $local.GETSCANZONES_TBL_MODIFIED_TIME;   Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
                    @{ Name = $local.GETSCANZONES_TBL_SCANNERS;        Expression = {
                        # Check if there are any Scanners.
                        If (($PSItem.scanners.name).Length -gt 1) {
                            $PSItem.scanners.name -join ','
                        }
                        Else {
                            # No Scanners were found.
                            $local.LOG_NA
                        }
                    }},
                    @{ Name = $local.GETSCANZONES_TBL_ACTIVE_SCANNERS; Expression = { $PSItem.activeScanners }},
                    @{ Name = $local.GETSCANZONES_TBL_IP_COUNT;        Expression = { ([regex]::Matches($PSItem.ipList, $IPv4RegEx)).Count }} | Format-Table -AutoSize

                # Show Total Entries.
                $($local.LOG_COUNT_OUTPUT -f ($Zones.response).Count)
            } # End of Default View.
            'ID' {
                Write-SCLog -LogInfo $local.GETSCANZONES_LOG_ID
    
                $Zones.response | Where-Object ID -eq $ID | Select-Object -Property `
                    @{ Name = $local.GETSCANZONES_TBL_ID ;             Expression = { $PSItem.id }},
                    @{ Name = $local.GETSCANZONES_TBL_NAME;            Expression = { $PSItem.name }},
                    @{ Name = $local.GETSCANZONES_TBL_DESCRIPTION;     Expression = { $PSItem.description }},
                    @{ Name = $local.GETSCANZONES_TBL_CREATED_TIME;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
                    @{ Name = $local.GETSCANZONES_TBL_MODIFIED_TIME;   Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
                    @{ Name = $local.GETSCANZONES_TBL_SCANNERS;        Expression = {
                        # Check if there are any Scanners.
                        If (($PSItem.scanners.name).Length -gt 1) {
                            $PSItem.scanners.name -join ','
                        }
                        Else {
                            # No Scanners were found.
                            $local.LOG_NA
                        }
                    }},
                    @{ Name = $local.GETSCANZONES_TBL_ACTIVE_SCANNERS; Expression = { $PSItem.activeScanners }},
                    @{ Name = $local.GETSCANZONES_TBL_IP_LIST;         Expression = { $($PSItem.ipList -replace ',', $NewLine) }}
            } # End of ID parameter check.
            'Address' {
                Write-SCLog -LogInfo $local.GETSCANZONES_LOG_ADDRESS
    
                $Zones.response | Where-Object ipList -like "*$Address*" | Select-Object -Property `
                    @{ Name = $local.GETSCANZONES_TBL_ID ;             Expression = { $PSItem.id }},
                    @{ Name = $local.GETSCANZONES_TBL_NAME;            Expression = { $PSItem.name }},
                    @{ Name = $local.GETSCANZONES_TBL_DESCRIPTION;     Expression = { $PSItem.description }},
                    @{ Name = $local.GETSCANZONES_TBL_CREATED_TIME;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
                    @{ Name = $local.GETSCANZONES_TBL_MODIFIED_TIME;   Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
                    @{ Name = $local.GETSCANZONES_TBL_SCANNERS;        Expression = {
                        # Check if there are any Scanners.
                        If (($PSItem.scanners.name).Length -gt 1) {
                            $PSItem.scanners.name -join ','
                        }
                        Else {
                            # No Scanners were found.
                            $local.LOG_NA
                        }
                    }},
                    @{ Name = $local.GETSCANZONES_TBL_ACTIVE_SCANNERS; Expression = { $PSItem.activeScanners }},
                    @{ Name = $local.GETSCANZONES_TBL_IP_LIST;         Expression = { $($PSItem.ipList -replace ',', $NewLine) }}

                # Show Total Entries.
                Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($Zones.response).Count)
            } # End of Address parameter check.
            'RAW' {
                # Unformatted Scan Zone Data.
                Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
                Write-Output -InputObject $Zones.response

                # Show Total Entries.
                Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($Zones.response).Count)
            } # End of RAW parameter check.
        } # End of Parameter Switch.
    } # End of output length check.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCScanZones.

Function Get-SCReports {
<#
.SYNOPSIS
Get Reports.
.DESCRIPTION
List Available Reports.
.EXAMPLE
Show a Default View. Sorted by ID and formatted as Table.
Get-SCReports
.EXAMPLE
Show a specific Report.
Get-SCReports -ID 5829
.EXAMPLE
Filter Report by Report Name. Can be partial.
Get-SCReports -Name "workstation"
.EXAMPLE
Filter Reports by specified User. Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Reports where Owner's First or Last Name contains "mil".
Get-SCReports -Owner "mil"
.EXAMPLE
Show older Reports. Default output is showing within 30 days. Use Tab to switch between allowed values.
Get-SCReports -StartTime '120 Days'
.EXAMPLE
Show Reports in Default View. Output is still customized, unlike with RAW parameter, but not forced into a table, as is Default for this entire module.
You will have to use it to export the Output.
Get-SCReports -NoFormat
.EXAMPLE
Show Reports in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCReports -RAW
.PARAMETER ID
Filter Reports by ID.
.PARAMETER Name
Filter Reports by Report Name.
.PARAMETER Owner
Filter Output by Owner's First or Last Name.
.PARAMETER StartTime
Extend the period in which the reports were created.
.PARAMETER NoFormat
Customized Data with no Table Formatting.
.PARAMETER RAW
Show Unformatted Output.
.FUNCTIONALITY
Shows Reports Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETREPORTS_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTS_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTS_HELP_START_TIME })]
    [ValidateSet('60 Days','120 Days','360 Days','All')]
    [String]$StartTime,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Start Time from $StartTime Parameter and create an epoch string from the chosen timespan.
    Switch ($StartTime) {
        '60 Days'  { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-60) }
        '120 Days' { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-120) }
        '360 Days' { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-360) }
        'All'      { [Int]$AgeLimit = '1388527200' } # From 01.01.2014.
        Default    { [Int]$AgeLimit = ConvertFrom-NormalToEpoch -Date (Get-Date).AddDays(-30) }
    } # End of StartTime Switch.

    # Get Reports.
    $Method = 'GET'
    $URI    = "$Server/report?fields=id,name,type,status,finishTime,owner&startTime=$AgeLimit"
    Write-SCLog -LogInfo $($local.GETREPORTS_LOG_GET_DATA -f $Method, $URI)
    $Reports = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Name -and $Owner) {
        Write-SCLog -LogInfo $($local.GETREPORTS_LOG_NAME_OWNER -f $Name, $Owner)
        $OutputHolder = $Reports.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETREPORTS_LOG_NAME -f $Name)
        $OutputHolder = $Reports.response.usable | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETREPORTS_LOG_OWNER -f $Owner)
        $OutputHolder = $Reports.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETREPORTS_LOG_ID -f $ID)
        $OutputHolder = $Reports.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Reports.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    $OutputTable = $OutputHolder | Select-Object -Property `
        @{ Name = $local.GETREPORTS_TBL_ID;     Expression = { $PSItem.id }},
        @{ Name = $local.GETREPORTS_TBL_NAME;   Expression = { $PSItem.name }},
        @{ Name = $local.GETREPORTS_TBL_TYPE;   Expression = { $PSItem.type }},
        @{ Name = $local.GETREPORTS_TBL_STATUS; Expression = { $PSItem.status }},
        @{ Name = $local.GETREPORTS_TBL_START;  Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.startTime }},
        @{ Name = $local.GETREPORTS_TBL_FINISH; Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.finishTime }},
        @{ Name = $local.GETREPORTS_TBL_OWNER;  Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }}

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Reports list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # Display Unformatted, Raw Data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted as Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Sort-Object -Descending $local.GETREPORTS_TBL_ID | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCReports.

Function Export-SCReport {
<#
.SYNOPSIS
Download Report.
.DESCRIPTION
Download Specified Report.
.EXAMPLE
Download Report with an ID of 5228. File will be saved as CSV using the name it has in Tenable.sc.
Export-SCReport -ID 5228 -FolderPath C:\TEMP\
.EXAMPLE
Download Report(s) from Get-SCReports pipeline. File will be saved as CSV using the name it has in Tenable.sc.
Get-SCReports -ID 5744 -NoFormat | Export-SCReport -FolderPath C:\TEMP\
.EXAMPLE
Download Report(s) from Get-SCReports pipeline. File(s) will be saved as CSV using the name it has in Tenable.sc.
Get-SCReports -Owner user -Name sharepoint -NoFormat | Export-SCReport -FolderPath C:\TEMP\
.EXAMPLE
Download two newest Reports, that belong to user and have sharepoint in their names, from Get-SCReports pipeline. Files will be saved as CSVs using the name it has in Tenable.sc.
Get-SCReports -Owner user -Name sharepoint -NoFormat | Select-Object -First 2 | Export-SCReport -FolderPath C:\TEMP\
.PARAMETER ID
Specify Report ID.
.PARAMETER FolderPath
Specify Folder where you want the Report(s) to save. File will be saved as CSV using the name it has in Tenable.sc.
.NOTES
Comma (,) delimiter will be changed to semicolon (;), due to Plugin Texts having commas, which will mess up the conversion with ConvertFrom-ReportCSV2XLSX cmdlet.

Cmdlet will not download whole lists of Reports, just one at a time. At this moment, this is intentional.
.FUNCTIONALITY
Downloads Reports from SecurityCenter.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.EXPORTREPORT_HELP_ID }, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Int[]]$ID,
    [Parameter(Position = 1, Mandatory = $True, HelpMessage = { $local.EXPORTREPORT_HELP_PATH })]
    [ValidateScript( { Test-Path -Path $PSItem -PathType Container } )]
    [String]$FolderPath
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Iterate through provided Report IDs.
    ForEach ($Item in $ID) {
        ## Retrive Report Info.
        $getMethod = 'GET'
        $getURI    = "$Server/report?fields=id,name,finishTime"
        
        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_GET_DATA -f $getMethod, $getURI, $Item)
        $getReports = Invoke-RestMethod -Method $getMethod -Uri $getURI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'
        $ReportRecord = $getReports.response.usable | Where-Object id -eq $Item
        
        ## Remove invalid characters from Report Name so it could be used as a file name.
        $SanitizedName = $($($ReportRecord.name).Split([IO.Path]::GetInvalidFileNameChars()) -join '') -replace ' ','_'
        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_SANITIZE_FILE_NAME -f $ReportRecord.name, $SanitizedName)

        ## Get Finish Date from the Report.
        $Finished = Get-Date ($FinishTime = ConvertFrom-EpochToNormal -InputEpoch $ReportRecord.finishTime) -Format 'yyyyMMdd'
        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_REPORT_FINISH_DATE -f $ReportRecord.name, $Finished)
        
        ## Check if file path has extra \ in it and remove it, if yes.
        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_CHECK_PATH)
        If ($FolderPath -match '\\$') {
            $Output = "$FolderPath$($Finished)_$($ReportRecord.id)_$SanitizedName.csv"
            Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_PATH_CHANGED -f $Output)
        }
        Else {
            $Output = "$FolderPath\$($Finished)_$($ReportRecord.id)_$SanitizedName.csv"
            Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_PATH_NOT_CHANGED -f $Output)
        } ## End of File Path check.

        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_OUTPUT -f $Output)

        ## Save Report to Disk.
        ## Get Report and replace comma (,) separator with a semicolon (;) to avoid issues with importing the CSV to Excel later.
        $postMethod = 'POST'
        $postURI    = "$Server/report/$Item/download"

        $postReport = Invoke-RestMethod -Method $postMethod -Uri $postURI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json' | Out-File -FilePath $Output -Append

        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_EXPORT_DATA -f $URI, $Method, $Item, $Output)

        ## Download Finished.
        Write-SCLog -LogInfo $($local.EXPORTREPORT_LOG_DOWNLOAD_FINISHED -f $Output)
        Write-Output -InputObject $($local.EXPORTREPORT_INFO_SAVED_REPORT -f $Item, $Output)
    } # End of IDs loop.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Export-SCReport.

Function Get-SCAssets {
<#
.SYNOPSIS
Get Assets Listing.
.DESCRIPTION
Retrieves a list of Assets.
.EXAMPLE
Default view, with no filtering.
Get-SCAssets
.EXAMPLE
Show an Asset with an ID of 1239.
Get-SCAssets -ID 1239
.EXAMPLE
Show Assets with certain Type.
Type Parameter takes only static, dnsname, combination or watchlist options. Use tab, to switch between them.
Get-SCAssets -Type combination
.EXAMPLE
Show Only Assets by certain User. Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Reports where Owner's First or Last Name contains "vla".
Get-SCAssets -Owner "vla"
.EXAMPLE
Show Assets with specified IP or FQDN addresses. Can also use only parts of the FQDN.
Get-SCAssets -Address "1.1.1.1"
.EXAMPLE
Show Assets with specified Tag.
Get-SCAssets -Tag TEST
.EXAMPLE
Show empty Asset Lists.
Get-SCAssets -Empty
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCAssets -Type static -NoFormat
.EXAMPLE
Show Assets in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCAssets -RAW
.PARAMETER ID
Show an Asset with a specific ID. If ID is not specified, Default Output of all Assets is shown.
.PARAMETER Name
Filter Output by Asset Name.
.PARAMETER Type
Filter Output by Asset Type.
.PARAMETER Owner
Filter Output by Asset Owner First or Last Name.
.PARAMETER Address
Filter Output by IP or FQDN addresses in Asset.
.PARAMETER Tag
Filter Output by Tag.
.PARAMETER Orphaned
Filter Output by Asset Lists that are not used by any scans.
.PARAMETER Empty
Filter Output by Asset Lists that are empty.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Asset Listings.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETASSETS_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_TYPE })]
    [ValidateSet('combination', 'dnsname', 'dnsnameupload', 'dynamic', 'ldapquery', 'static', 'staticeventfilter', 'staticvulnfilter', 'templates', 'upload', 'watchlist', 'watchlisteventfilter', 'watchlistupload')]
    [String]$Type,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_ADDRESS })]
    [String]$Address,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_TAG })]
    [String]$Tag,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_ORPHANED })]
    [Switch]$Orphaned,
    [Parameter(Position = 7, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETASSETS_HELP_EMPTY })]
    [Switch]$Empty,
    [Parameter(Position = 8, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 9, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Assets Data.
    $Method = 'GET'
    $URI = "$Server/asset?fields=id,name,type,owner,tags,typeFields"
    Write-SCLog -LogInfo $($local.GETASSETS_LOG_GET_DATA -f $Method, $URI)
    $Assets = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Get Scan Data.
    $Method = 'GET'
    $URI = "$Server/scan?fields=credentials"
    Write-SCLog -LogInfo $($local.GETSCANS_LOG_GET_DATA -f $Method, $URI)
    $Scans = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Address -and $Name -and $Owner -and $Tag -and $Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_ADDRESS_NAME_OWNER_TAG_TYPE -f $Address, $Name, $Owner, $Tag, $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" -and $PSItem.type -eq $PSItem.type -and ($PSItem.typeFields.definedIPs -like "*$Address*" -or $PSItem.typeFields.definedDNSNames -like "*$Address*") }
    }
    If ($Name -and $Owner -and $Tag -and $Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_OWNER_TAG_TYPE -f $Name, $Owner, $Tag, $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" -and $PSItem.type -eq $PSItem.type }
    }
    ElseIf ($Name -and $Owner -and $Tag) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_OWNER_TAG -f $Name, $Owner, $Tag)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($Name -and $Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_OWNER_TYPE -f $Name, $Owner, $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($Name -and $Owner -and $Address) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_OWNER_ADDRESS -f $Name, $Owner, $Address)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and ($PSItem.typeFields.definedIPs -like "*$Address*" -or $PSItem.typeFields.definedDNSNames -like "*$Address*") }
    }
    ElseIf ($Name -and $Address) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_ADDRESS -f $Name, $Address)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.typeFields.definedIPs -like "*$Address*" -or $PSItem.typeFields.definedDNSNames -like "*$Address*") }
    }
    ElseIf ($Name -and $Owner) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_OWNER -f $Name, $Owner)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($Name -and $Tag) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_TAG -f $Name, $Tag)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($Name -and $Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME_TYPE -f $Name, $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($Owner -and $Tag) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_OWNER_TAG -f $Owner, $Tag)
        $OutputHolder = $Assets.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_OWNER_TYPE -f $Owner, $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($Empty) {
        Write-SCLog -LogInfo $local.GETASSETS_LOG_EMPTY
        $OutputHolder = $Assets.response.usable | Where-Object { ($PSItem.typeFields.definedIPs).Count -eq 0 -and ($PSItem.typeFields.definedDNSNames).Count -eq 0 }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_ID -f $ID)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_NAME -f $Name)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($Orphaned) {
        Write-SCLog -LogInfo $local.GETASSETS_LOG_ORPHANED
        $OutputHolder = $Assets.response.usable | Where-Object { ($PSItem.typeFields.definedIPs -like "*$Address*" -or $PSItem.typeFields.definedDNSNames -like "*$Address*") -notin $Scans.response.assets.name }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_OWNER -f $Owner)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($Tag) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_TAG -f $Tag)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($Type) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_TYPE -f $Type)
        $OutputHolder = $Assets.response.usable | Where-Object { $PSItem.type -eq $Type }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Assets.response.usable
    }

    # Create Hash Table of Asset Types (in 2019).
    [HashTable]$AssetTypes = @{
        'combination'          = 'Combination of Assets';
        'dnsname'              = 'DNS Name List';
        'dnsnameupload'        = 'Uploaded DNS Names List';
        'dynamic'              = 'Dynamic Asset List';
        'ldapquery'            = 'Asset List from LDAP';
        'static'               = 'Static IP List';
        'staticeventfilter'    = 'IPs from an Event';
        'staticvulnfilter'     = 'IPs from Vulnerability';
        'templates'            = 'Asset List Template';
        'upload'               = 'Uploaded Asset List';
        'watchlist'            = 'Watchlist';
        'watchlisteventfilter' = 'Watchlist from an Event';
        'watchlistupload'      = 'Uploaded Watchlist'
    }

    # Store Output table into variable.
    If ($ID) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_ID -f $ID)

        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETASSETS_TBL_ID;        Expression = { $PSItem.id }},
            @{ Name = $local.GETASSETS_TBL_NAME;      Expression = { $PSItem.name }},
            @{ Name = $local.GETASSETS_TBL_TYPE;      Expression = { $AssetTypes[$PSitem.type] }},
            @{ Name = $local.GETASSETS_TBL_OWNER;     Expression = {
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.owner.firstname -eq '' -and $PSItem.owner.lastname -eq '') {
                    $PSItem.owner.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.owner.firstname -eq '') {
                    "$($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.owner.lastname -eq '') {
                    "$($PSItem.owner.firstname)/$($PSItem.owner.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of user names check.
            }},
            @{ Name = $local.GETASSETS_TBL_TOTAL;     Expression = {
                # Check if Asset List is formatted as DNS Names.
                If ($PSItem.type -eq 'dnsname') {
                    $Script:AddressCount = ($PSItem.typeFields.definedDNSNames -split ',').Count
                    $AddressCount
                } # End of DNS Names check.
                # Check if Asset List is formatted as IP Addresses.
                ElseIf ($PSItem.type -eq 'static') {
                    $Script:AddressCount = ($PSItem.typeFields.definedIPs -split ',').Count
                    $AddressCount
                } # End of IP Addresses check.
                # No adddresses were found in the Asset List.
                Else {
                    $local.LOG_NA
                } # End of Asset List checks.
            }},
            @{ Name = $local.GETASSETS_TBL_TAG;       Expression = { $PSItem.tags }},
            @{ Name = $local.GETASSETS_TBL_ADDRESSES; Expression = {
                # Check if there are more address than can fit in current PS Window Buffer.
                If ($AddressCount -gt $BufferHeight) {
                    # Check if Asset List is formatted as DNS Names.
                    If ($PSItem.type -eq 'dnsname') {
                        $Addresses = $PSItem.typeFields.definedDNSNames -split ','
                    } # End of DNS Names check.
                    # Check if Asset List is formatted as IP Addresses.
                    ElseIf ($PSItem.type -eq 'static') {
                        $Addresses = $PSItem.typeFields.definedIPs -split ','
                    } # End of IP Addresses check.
                    
                    # Show only as many addresses that fit into current PS Window Buffer, along with other table entries.
                    (($Addresses | Select-Object -First $BufferHeight) -join ',') -replace ',', $NewLine
                } # AddressCount is greater than $BufferHeight.
                Else {
                    # Check if Asset List is formatted as DNS Names.
                    If ($PSItem.type -eq 'dnsname') {
                        $PSItem.typeFields.definedDNSNames -replace ',', $NewLine
                    } # End of DNS Names check.
                    # Check if Asset List is formatted as IP Addresses.
                    ElseIf ($PSItem.type -eq 'static') {
                        $PSItem.typeFields.definedIPs -replace ',', $NewLine
                    } # AddressCount is less than $BufferHeight. End of IP Addresses check.
                } # End of AddressCount check.
            }},
            @{ Name = $local.GETASSETS_TBL_INFO;      Expression = {
                # Check if there are more address than can fit in current PS Window Buffer. Show information about clipped data, if yes.
                If ($AddressCount -gt $BufferHeight) {
                    Write-Output -InputObject $($local.INFO_EXCEEDING_BUFFER_HEIGHT -f ($AddressCount-$BufferHeight))
                } # AddressCount is greater than $BufferHeight.
                Else {
                    Write-Output -InputObject '-'
                } # End of AddressCount check.
            }}
    } # ID : True.
    # Checking if Address Parameter was used.
    ElseIf ($Address) {
        Write-SCLog -LogInfo $($local.GETASSETS_LOG_ADDRESS -f $Address)

        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETASSETS_TBL_ID;        Expression = { $PSItem.id }},
            @{ Name = $local.GETASSETS_TBL_NAME;      Expression = { $PSItem.name }},
            @{ Name = $local.GETASSETS_TBL_TYPE;      Expression = { $AssetTypes[$PSitem.type] }},
            @{ Name = $local.GETASSETS_TBL_OWNER;     Expression = {
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.owner.firstname -eq '' -and $PSItem.owner.lastname -eq '') {
                    $PSItem.owner.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.owner.firstname -eq '') {
                    "$($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.owner.lastname -eq '') {
                    "$($PSItem.owner.firstname)/$($PSItem.owner.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of user names check.
            }},
            @{ Name = $local.GETASSETS_TBL_TOTAL;     Expression = {
                # Check if Asset List is formatted as DNS Names.
                If ($PSItem.type -eq 'dnsname') {
                    ([RegEx]::Matches($PSItem.typeFields.definedDNSNames,$FQDNRegEx)).Count
                } # End of DNS Names check.
                # Check if Asset List is formatted as IP Addresses.
                ElseIf ($PSItem.type -eq 'static') {
                    ([RegEx]::Matches($PSItem.typeFields.definedIPs,$IPv4RegEx)).Count
                } # End of IP Addresses check.
                # No adddresses were found in the Asset List.
                Else {
                    $local.LOG_NA
                } # End of Asset List checks.
            }},
            @{ Name = $local.GETASSETS_TBL_TAG;       Expression = { $PSItem.tags }},
            @{ Name = $local.GETASSETS_TBL_ADDRESSES; Expression = {
                # Check if Asset List is formatted as DNS Names.
                If ($PSItem.type -eq 'dnsname') {
                    $Script:AddressCount = ($PSItem.typeFields.definedDNSNames -split ',').Count
                    $AddressCount
                } # End of DNS Names check.
                # Check if Asset List is formatted as IP Addresses.
                ElseIf ($PSItem.type -eq 'static') {
                    $Script:AddressCount = ($PSItem.typeFields.definedIPs -split ',').Count
                    $AddressCount
                } # End of IP Addresses check.
                # No adddresses were found in the Asset List.
                Else {
                    $local.LOG_NA
                } # End of Asset List checks.
            }}
    } # Address: True.
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETASSETS_TBL_ID;    Expression = { $PSItem.id }},
            @{ Name = $local.GETASSETS_TBL_NAME;  Expression = { $PSItem.name }},
            @{ Name = $local.GETASSETS_TBL_TYPE;  Expression = { $AssetTypes[$PSitem.type] }},
            @{ Name = $local.GETASSETS_TBL_OWNER; Expression = {
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.owner.firstname -eq '' -and $PSItem.owner.lastname -eq '') {
                    $PSItem.owner.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.owner.firstname -eq '') {
                    "$($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.owner.lastname -eq '') {
                    "$($PSItem.owner.firstname)/$($PSItem.owner.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of user names check.
            }},
            @{ Name = $local.GETASSETS_TBL_TOTAL; Expression = {
                # Check if Asset List is formatted as DNS Names.
                If ($PSItem.type -eq 'dnsname') {
                    ([RegEx]::Matches($PSItem.typeFields.definedDNSNames,$FQDNRegEx)).Count
                } # End of DNS Names check.
                # Check if Asset List is formatted as IP Addresses.
                ElseIf ($PSItem.type -eq 'static') {
                    ([RegEx]::Matches($PSItem.typeFields.definedIPs,$IPv4RegEx)).Count
                } # End of IP Addresses check.
                # No adddresses were found in the Asset List.
                Else {
                    $local.LOG_NA
                } # End of Asset List checks.
            }},
            @{ Name = $local.GETASSETS_TBL_TAG;   Expression = { $PSItem.tags }}
    } # End of Default View.

    # Output Assets.
    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Scans list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entriesd.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    }
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCAssets.

Function Get-SCScans {
<#
.SYNOPSIS
Get Scan Listing.
.DESCRIPTION
Retrieves a list of Scans.
.EXAMPLE
Show a Scan with an ID of 929. ID shows the most information.
Get-SCScans -ID 1239
.EXAMPLE
Filter Output by Scan Name.
Get-SCScans -Name dblan
.EXAMPLE
Filter Output by Scan Policy Name.
Get-SCScans -PolicyName "windows"
.EXAMPLE
Filter Output by Repository.
Get-SCScans -Repository "ipv4-local"
.EXAMPLE
Filter Output by DHCP Tracking Status.
DHCPTracking parameter takes only true or false options. Use tab, to switch between them.
Get-SCScans -DHCPTracking "false"
.EXAMPLE
Show Only Scans by certain User. Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Reports where Owner's First or Last Name contains "laur".
Get-SCScans -Owner "laur"
.EXAMPLE
Show Scans that have assets like "LPTEST".
Get-SCScans -Assets "LPTEST"
.EXAMPLE
Show Scans that have credentials like "CyberArk".
Get-SCScans -CredentialName "CyberArk"
.EXAMPLE
Show Scans that have Schedule enabled.
Get-SCScans -Scheduled
.EXAMPLE
Show Scans that have Reports attached.
Get-SCScans -Reports
.EXAMPLE
Show Invalid Scans, which don't have credentials and/or Assets/IP List configured.
Get-SCScans -FindInvalidScans
.EXAMPLE
Show expanded view of the Scans, showing Asset List and Credential Names. The Asset List Names and Credential Names can be a bit long, so their ID's are shown by default instead.
Get-SCScans -Expand
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCScans -Name dblan -NoFormat
.EXAMPLE
Show Scans in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCScans -RAW
.PARAMETER ID
Show a Scan with a specific ID.
.PARAMETER Name
Filter Output by Scan Name.
.PARAMETER PolicyName
Filter Output by Scan Policy Name.
.PARAMETER Repository
Filter Output by Scan Repository Name.
.PARAMETER DHCPTracking
Filter Output by Scan DHCP Tracking status.
.PARAMETER Owner
Filter Output by Scan Owner First or Last Name.
.PARAMETER Assets
Filter Output by Scan Assets.
.PARAMETER CredentialName
Filter Output by Credential Name.
.PARAMETER Scheduled
Shows Scans that have Schedule enabled.
.PARAMETER Reports
Shows Scans that have Reports attached.
.PARAMETER FindInvalidScans
Shows Scans that don't have Credentials and/or Targets to Scan.
.PARAMETER Expand
Show Asset List and Credential Names, additionally to their IDs.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Scans.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETSCANS_HELP_ID })]
    [ValidateNotNullOrEmpty()]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_POLICY }, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [String]$PolicyName,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_REPOSITORY })]
    [ValidateNotNullOrEmpty()]
    [String]$Repository,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_DHCP })]
    [ValidateSet('true', 'false')]
    [String]$DHCPTracking,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_OWNER })]
    [ValidateNotNullOrEmpty()]
    [String]$Owner,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_ASSETS  })]
    [ValidateNotNullOrEmpty()]
    [String]$Assets,
    [Parameter(Position = 7, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_CREDENTIALS })]
    [ValidateNotNullOrEmpty()]
    [String]$CredentialName,
    [Parameter(Position = 8, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_SCHEDULED })]
    [Switch]$Scheduled,
    [Parameter(Position = 9, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_REPORTS })]
    [Switch]$Reports,
    [Parameter(Position = 10, Mandatory = $False, ParameterSetName = 'InvalidScans', HelpMessage = { $local.GETSCANS_HELP_INVALID_SCANS })]
    [Switch]$FindInvalidScans,
    [Parameter(Position = 11, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANS_HELP_INVALID_SCANS })]
    [Parameter(ParameterSetName = 'ID')]
    [Parameter(ParameterSetName = 'InvalidScans')]
    [Switch]$Expand,
    [Parameter(Position = 12, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Parameter(ParameterSetName = 'ID')]
    [Parameter(ParameterSetName = 'InvalidScans')]
    [Switch]$NoFormat,
    [Parameter(Position = 13, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    $Method = 'GET'
    $URI    = "$Server/scan?fields=id,name,description,type,policy,repository,dhcpTracking,owner,assets,credentials,schedule,ipList,reports,zone,maxScanTime"
    Write-SCLog -LogInfo $($local.GETSCANS_LOG_GET_DATA -f $Method, $URI)

    $Scans = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($CredentialName -and $DHCPTracking -and $Name -and $Owner -and $PolicyName -and $Repository -and $Scheduled) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_CREDENTIAL_DHCPTRACKING_NAME_OWNER_POLICY_REPOSITORY_SCHEDULED -f $CredentialName, $DHCPTracking, $Name, $Owner, $PolicyName, $Repository)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.credentials.name -like "*$CredentialName*" -and $PSItem.dhcpTracking -eq $DHCPTracking -and $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policy.name -like "*$PolicyName*" -and $PSItem.repository.name -like "*$Repository*" -and $PSItem.schedule.type -ne "template" }
    }
    ElseIf ($Assets -and $Name -and $Owner -and $PolicyName -and $Reports -and $Scheduled) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_ASSETS_NAME_OWNER_POLICY_REPORTS_SCHEDULED -f $Assets, $Name, $Owner, $PolicyName)
        $OutputHolder = $Scans.response.usable | Where-Object { ($PSItem.assets.name -like "*$Assets*" -or $PSItem.ipList -like "*$Assets*") -and $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policy.name -like "*$PolicyName*" -and $PSItem.reports.name -ne $null -and $PSItem.schedule.type -ne "template" }
    }
    ElseIf ($Name -and $Owner -and $PolicyName) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_NAME_OWNER_POLICY -f $Name, $Owner, $PolicyName)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policy.name -like "*$PolicyName*" }
    }
    ElseIf ($Name -and $Owner) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_NAME_OWNER -f $Name, $Owner)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*") -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($Owner -and $PolicyName) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_OWNER_POLICY -f $Owner, $PolicyName)
        $OutputHolder = $Scans.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policy.name -like "*$PolicyName*" }
    }
    Elseif ($Name) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_NAME -f $Name)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.name -like "*$Name*" }
    }
    Elseif ($PolicyName) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_POLICY -f $PolicyName)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.policy.name -like "*$PolicyName*" }
    }
    Elseif ($Repository) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_REPOSITORY -f $Repository)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.repository.name -like "*$Repository*" }
    }
    Elseif ($DHCPTracking) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_DHCP_TRACKING -f $DHCPTracking)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.dhcpTracking -eq "*$DHCPTracking*" }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_OWNER -f $Owner)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($Assets) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_ASSETS -f $Assets)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.assets.name -like "*$Assets*" -or $PSItem.ipList -like "*$Assets*" }
    }
    ElseIf ($CredentialName) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_CREDENTIALS -f $CredentialName)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.credentials.name -like "*$CredentialName*" }
    }
    ElseIf ($Scheduled) {
        Write-SCLog -LogInfo $local.GETSCANS_LOG_SCHEDULED
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.schedule.type -ne 'template' }
    }
    ElseIf ($Reports) {
        Write-SCLog -LogInfo $local.GETSCANS_LOG_REPORTS
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.reports.name -ne $null }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETSCANS_LOG_ID -f $ID)
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($FindInvalidScans) {
        Write-SCLog -LogInfo $local.GETSCANS_HELP_INVALID_SCANS
        $OutputHolder = $Scans.response.usable | Where-Object { $PSItem.credentials.name -eq $null -or $PSItem.credentials.id -eq -1 -or ($PSItem.assets.id -lt 1 -and $PSItem.ipList -like '') }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Scans.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        Write-SCLog -LogInfo $local.GETSCANS_TBL_ID_HOLDER

        $OutputTable = $OutputHolder | Select-Object -Property `
        @{ Name = $local.GETSCANS_TBL_ID;            Expression = { $PSItem.id }},
        @{ Name = $local.GETSCANS_TBL_NAME;          Expression = { $PSItem.name }},
        @{ Name = $local.GETSCANS_TBL_DESCRIPTION;   Expression = { $PSItem.description }},
        @{ Name = $local.GETSCANS_TBL_POLICY;        Expression = { "[$($PSItem.policy.id)]$($PSItem.policy.name)" }},
        @{ Name = $local.GETSCANS_TBL_REPOSITORY;    Expression = {
            # Check if Repository ID is a positive number.
            If ($PSItem.repository.id -match '^[1-9]\d*$') {
                # Check if Expand parameter was used.
                If ($Expand) {
                    # Expand Parameter was used. Show ID, additionally to name.
                    "[$($PSItem.repository.id)]$($PSItem.repository.name)"
                } # Exapnd: True.
                Else {
                    # Expand Parameter was not used. Showing name only.
                    $PSItem.repository.name
                } # Exapand: False. End of Expand parameter check.
            } # Repository exists and is OK.
            # Check whether Repository ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
            ElseIf ($PSItem.repository.id -eq -1) {
                $local.ERROR_MISSING_OBJECT
            } # Repository ID = -1.
            Else {
                # No Repository.
                $local.LOG_NA
            } # End of Repository ID check.
        }},
        @{ Name = $local.GETSCANS_TBL_DHCP_TRACKING; Expression = { $Culture.ToTitleCase($PSItem.dhcpTracking) }},
        @{ Name = $local.GETSCANS_TBL_OWNER;         Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
        @{ Name = $local.GETSCANS_TBL_CREDENTIALS;   Expression = {
            # Check Credentials IDs.
            If ($PSItem.credentials.id.Length -ge 1) {
                ForEach ($Credential in $PSItem.credentials) {
                    # Check if Credential ID is a positive number.
                    If ($Credential.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Credential.id)]$($Credential.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand Parameter was not used. Showing name only.
                            $Credential.name
                        } # Exapand: False. End of Expand parameter check.
                    } # Credential exists and is OK.
                    # Check whether Credential ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Credential.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } #  # Credential ID = -1. End of Credential ID check.
                } # End of Credentials loop.
            } # Credentials exist.
            Else {
                # No Credentials.
                $local.LOG_NA
            } # End of Credentials check.
        }},
        @{ Name = $local.GETSCANS_TBL_ASSETS;        Expression = {
            # Check Assets IDs.
            If ($PSItem.assets.id.Length -ge 1) {
                ForEach ($Asset in $PSItem.assets) {
                    # Check if Asset ID is a positive number.
                    If ($Asset.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Asset.id)]$($Asset.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand Parameter was not used. Showing name only.
                            $Asset.name
                        } # Exapand: False. End of Expand parameter check.
                    } # Asset exists and is OK.
                    # Check whether Asset ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Asset.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Asset ID = -1. End of Asset ID check.
                } # End of Assets loop.
            } # Assets exist.
            Else {
                # No Assets.
                $local.LOG_NA
            } # End of Assets check.
        }},
        @{ Name = $local.GETSCANS_TBL_ADDRESSES;     Expression = {
            # Create an empty Array for addresses in ipList.
            [Array]$AddressArray = @()

            # Check if ipList is empty, or not.
            If ($PSItem.ipList.Length -ge 1) {
                # Match IP and FQDN addresses from ipList and store them to AddressArray, created above.
                $PSItem.ipList | Select-String -Pattern $IPv4RegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                $PSItem.ipList | Select-String -Pattern $FQDNRegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                
                # Check if there are more than 1 address in the array.
                If ($AddressArray.Count -lt 1) {
                    # If it looks empty, check whether the ipList contains Single Label Host Names instead of FQDN's.
                    $PSItem.ipList | Select-String -Pattern $HostNameRegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                } # End of AddressArray count check.

                # Join Addresses with commas.
                $AddressArray -join ','
            } # Addresses exist.
            Else {
                # No Addresses.
                $local.LOG_NA
            } # End of Addresses check.
        }},
        @{ Name = $local.GETSCANS_TBL_REPORTS;       Expression = {
            # Check Reports IDs.
            If ($PSItem.reports.id.Length -ge 1) {
                ForEach ($Report in $PSItem.reports) {
                    # Check if Report ID is a positive number.
                    If ($Report.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Report.id)]$($Report.name)"
                            } # Exapnd: True.
                        Else {
                            # Expand Parameter was not used. Showing name only.
                            $Report.name
                        } # Exapand: False. End of Expand parameter check.
                    } # Report exists and is OK.
                    # Check whether Report ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Report.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Report ID = -1. End of Reports ID check.
                } # End of Reports loop.
            } # Reports exist.
            Else {
                # No Reports.
                $local.LOG_NA
            } # End of Reports check.
        }},
        @{ Name = $local.GETSCANS_TBL_MAX_SCAN_TIME; Expression = { "$($PSitem.maxScanTime) $($local.INFO_TIME_HOURS)" }},
        @{ Name = $local.GETSCANS_TBL_SCHEDULE;      Expression = {
            # Check if Schedule Type is not template, then show schedule.
            If ($PSItem.schedule.type -ne 'template') {
                "$($PSItem.schedule.type) $($PSItem.schedule.start) $($PSItem.schedule.repeatRule) $(ConvertFrom-EpochToNormal -InputEpoch $PSItem.schedule.nextRun)"
            } # End of Schedule Type check.
        }}
    } # ID: True.
    ElseIf ($NoFormat) {
        Write-SCLog -LogInfo $local.GETSCANS_TBL_ID_HOLDER

        $OutputTable = $OutputHolder | Select-Object -Property `
        @{ Name = $local.GETSCANS_TBL_ID;            Expression = { $PSItem.id }},
        @{ Name = $local.GETSCANS_TBL_NAME;          Expression = { $PSItem.name }},
        @{ Name = $local.GETSCANS_TBL_DESCRIPTION;   Expression = { $PSItem.description }},
        @{ Name = $local.GETSCANS_TBL_POLICY;        Expression = {
            # Check if Expand parameter was used.
            If ($Expand) {
                # Expand Parameter was used. Show ID, additionally to name.
                "[$($PSItem.policy.id)]$($PSItem.policy.name)"
            } # Exapnd: True.
            Else {
                # Expand Parameter was not used. Showing only name.
                $PSItem.policy.name
            } # Exapand: False. End of Expand parameter check.
        }},
        @{ Name = $local.GETSCANS_TBL_REPOSITORY;    Expression = {
            # Check if Repository ID is a positive number.
            If ($PSItem.repository.id -match '^[1-9]\d*$') {
                # Check if Expand parameter was used.
                If ($Expand) {
                    # Expand Parameter was used. Show ID, additionally to name.
                    "[$($PSItem.repository.id)]$($PSItem.repository.name)"
                } # Exapnd: True.
                Else {
                    # Expand Parameter was not used. Showing name only.
                    $PSItem.repository.name
                } # Exapand: False. End of Expand parameter check.
            } # Repository exists and is OK.
            # Check whether Repository ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
            ElseIf ($PSItem.repository.id -eq -1) {
                $local.ERROR_MISSING_OBJECT
            } # Repository ID = -1.
            Else {
                # No Repository.
                $local.LOG_NA
            } # End of Repository ID check.
        }},
        @{ Name = $local.GETSCANS_TBL_DHCP_TRACKING; Expression = { $Culture.ToTitleCase($PSItem.dhcpTracking) }},
        @{ Name = $local.GETSCANS_TBL_OWNER;         Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
        @{ Name = $local.GETSCANS_TBL_CREDENTIALS;   Expression = {
            # Check Credentials IDs.
            If ($PSItem.credentials.id.Length -ge 1) {
                ForEach ($Credential in $PSItem.credentials) {
                    # Check if Credential ID is a positive number.
                    If ($Credential.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Credential.id)]$($Credential.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Credential names to length specified below.
                            If (($Credential.name).Length -gt 20) {
                                "$(($Credential.name).SubString(0,20))..."
                            } # Credential Name longer than specified above.
                            Else {
                                # Credential name length is shorter than specified above, showing as is.
                                $Credential.name
                            } # End of Credential length check.
                        } # Exapand: False. End of Expand parameter check.
                    } # Credential exists and is OK.
                    # Check whether Credential ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Credential.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Credential ID = -1. End of Credential ID check.
                } # End of Credentials loop.
            } # Credentials exist.
            Else {
                # No Credentials.
                $local.LOG_NA
            } # End of Credentials check.
        }},
        @{ Name = $local.GETSCANS_TBL_ASSETS;        Expression = {
            # Check Assets IDs.
            If ($PSItem.assets.id.Length -ge 1) {
                ForEach ($Asset in $PSItem.assets) {
                    # Check if Asset ID is a positive number.
                    If ($Asset.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Asset.id)]$($Asset.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Asset names to length specified below.
                            If (($Asset.name).Length -gt 20) {
                                "$(($Asset.name).SubString(0,20))..."
                            } # Asset Name longer than specified above.
                            Else {
                                # Asset name length is shorter than specified above, showing as is.
                                $Asset.name
                            } # End of Asset length check.
                        } # Exapand: False. End of Expand parameter check.
                    } # Asset exists and is OK.
                    # Check whether Asset ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Asset.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Asset ID = -1. End of Assets ID check.
                } # End of Assets loop.
            } # Assets exist.
            Else {
                # No Assets.
                $local.LOG_NA
            } # End of Assets check.
        }},
        @{ Name = $local.GETSCANS_TBL_ADDRESSES;     Expression = {
            # Create an empty Array for addresses in ipList.
            [Array]$AddressArray = @()

            # Check if ipList is empty, or not.
            If ($PSItem.ipList.Length -ge 1) {
                # Match IP and FQDN addresses from ipList and store them to AddressArray, created above.
                $PSItem.ipList | Select-String -Pattern $IPv4RegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                $PSItem.ipList | Select-String -Pattern $FQDNRegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                
                # Check if there are more than 1 address in the array.
                If ($AddressArray.Count -lt 1) {
                    # If it looks empty, check whether the ipList contains Single Label Host Names instead of FQDN's.
                    $PSItem.ipList | Select-String -Pattern $HostNameRegEx -AllMatches | ForEach-Object { $PSItem.Matches } | ForEach-Object { $AddressArray += $PSItem.Value }
                } # End of AddressArray count check.

                # Join Addresses with commas.
                $AddressArray -join ','
            } # Addresses exist.
            Else {
                # No Addresses.
                $local.LOG_NA
            } # End of Addresses check.
        }},
        @{ Name = $local.GETSCANS_TBL_REPORTS;       Expression = {
            # Check Reports IDs.
            If (($PSItem.reports.id).Length -ge 1) {
                ForEach ($Report in $PSItem.reports) {
                    # Check if Report ID is a positive number.
                    If ($Report.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Report.id)]$($Report.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Report names to length specified below.
                            If (($Report.name).Length -gt 20) {
                                "$(($Report.name).SubString(0,20))..."
                            } # Report Name longer than specified above.
                            Else {
                                # Report name length is shorter than specified above, so showing as is.
                                $Report.name
                            } # End of Report length check.
                        } # End of Expand parameter check.
                    } # Report exists and is OK.
                    # Check whether Report ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Report.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Reports ID = -1. End of Reports ID check.
                } # End of Reports loop.
            } # Reports exist.
            Else {
                # No Reports.
                $local.LOG_NA
            } # End of Reports check.
        }},
        @{ Name = $local.GETSCANS_TBL_SCHEDULE;      Expression = {
            # Check if Schedule Type is not template, then show schedule.
            If ($PSItem.schedule.type -ne 'template') {
                "$($PSItem.schedule.type) $($PSItem.schedule.start) $($PSItem.schedule.repeatRule) $(ConvertFrom-EpochToNormal -InputEpoch $PSItem.schedule.nextRun)"
            } # End of Schedule Type check.
        }}
    } # NoFormat: True.
    Else {
        Write-SCLog -LogInfo $local.GETSCANS_TBL_DEFAULT_HOLDER

        $OutputTable = @{ Expression = { $PSItem.id };                                                        Label = $local.GETSCANS_TBL_ID; Width = 5 },
        @{ Expression = { $PSItem.name };                                                                     Label = $local.GETSCANS_TBL_NAME; Width = 45 },
        @{ Expression = {
            # Check if Expand parameter was used.
            If ($Expand) {
                # Expand Parameter was used. Show ID, additionally to name.
                "[$($PSItem.policy.id)]$($PSItem.policy.name)"
            } # Exapnd: True.
            Else {
                # Expand Parameter was not used. Showing only name.
                $PSItem.policy.name
            } # Exapand: False. End of Expand parameter check.
        }; Label = $local.GETSCANS_TBL_POLICY; Width = 42 },
        @{ Expression = {
            # Check Repository ID.
            If ($PSItem.repository.id -match '^[1-9]\d*$') {
                # Check if Expand parameter was used.
                If ($Expand) {
                    # Expand Parameter was used. Show ID, additionally to name.
                    "[$($PSItem.repository.id)]$($PSItem.repository.name)"
                } # Exapnd: True.
                Else {
                    # Expand Parameter was not used. Showing only name.
                    $PSItem.repository.name
                } # Exapand: False. End of Expand parameter check.
            } # Repository exists and is OK.
            # Check whether Repository ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
            ElseIf ($PSItem.repository.id -eq -1) {
                $local.ERROR_MISSING_OBJECT
            } # Repository ID = -1.
            Else {
                # No Repository.
                $local.LOG_NA
            } # End of Repository ID check.
        }; Label = $local.GETSCANS_TBL_REPOSITORY; Width = 20 },
        @{ Expression = { $Culture.ToTitleCase($PSItem.dhcpTracking) };                                       Label = $local.GETSCANS_TBL_DHCP_TRACKING; Width = 14 },
        @{ Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }; Label = $local.GETSCANS_TBL_OWNER; Width = 27 },
        @{ Expression = {
            # Check Credentials IDs.
            If ($PSItem.credentials.id.Length -ge 1) {
                ForEach ($Credential in $PSItem.credentials) {
                    # Check if Credential ID is a positive number.
                    If ($Credential.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Credential.id)]$($Credential.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Credential names to length specified below.
                            If (($Credential.name).Length -gt 50) {
                                "$(($Credential.name).SubString(0,50))..."
                            } # Credential Name longer than specified above.
                            Else {
                                # Credential name length is shorter than specified above, showing as is.
                                $Credential.name
                            } # End of Credential length check.
                        } # Exapand: False. End of Expand parameter check.
                    } # Credential exists and is OK.
                    # Check whether Credential ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Credential.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Credential ID = -1. End of Credential ID check.
                } # End of Credentials loop.
            } # Credentials exist.
            Else {
                # No Credentials.
                $local.LOG_NA
            } # End of Credentials check.
        }; Label = $local.GETSCANS_TBL_CREDENTIALS; Width = 55 },
        @{ Expression = {
            # Check Assets IDs.
            If ($PSItem.assets.id.Length -ge 1) {
                ForEach ($Asset in $PSItem.assets) {
                    # Check if Asset ID is a positive number.
                    If ($Asset.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Asset.id)]$($Asset.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Asset names to length specified below.
                            If (($Asset.name).Length -gt 60) {
                                "$(($Asset.name).SubString(0,60))..."
                            } # Asset Name longer than specified above.
                            Else {
                                # Asset name length is shorter than specified above, showing as is.
                                $Asset.name
                            } # End of Asset length check.
                        } # Exapand: False. End of Expand parameter check.
                    } # Asset exists and is OK.
                    # Check whether Asset ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Asset.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Asset ID = -1. End of Assets ID check.
                } # End of Assets loop.
            } # Assets exist.
            Else {
                # No Assets.
                $local.LOG_NA
            } # End of Assets check.
        }; Label = $local.GETSCANS_TBL_ASSETS; Width = 65 },
        @{ Expression = {
            # Check if ipList is empty, or not.
            If ($PSItem.ipList.Length -ge 1) {
                $PSItem.ipList
            } # IP List is not empty.
            Else {
                # No Addresses.
                $local.LOG_NA
            } # End of Addresses check.
        }; Label = $local.GETSCANS_TBL_ADDRESSES; Width = 25 },
        @{ Expression = {
            # Check Reports IDs.
            If (($PSItem.reports.id).Length -ge 1) {
                ForEach ($Report in $PSItem.reports) {
                    # Check if Report ID is a positive number.
                    If ($Report.id -match '^[1-9]\d*$') {
                        # Check if Expand parameter was used.
                        If ($Expand) {
                            # Expand Parameter was used. Show ID, additionally to name.
                            "[$($Report.id)]$($Report.name)"
                        } # Exapnd: True.
                        Else {
                            # Expand parameter was not used. Crop long Report names to length specified below.
                            If (($Report.name).Length -gt 20) {
                                "$(($Report.name).SubString(0,20))..."
                            } # Report Name longer than specified above.
                            Else {
                                # Report name length is shorter than specified above, so showing as is.
                                $Report.name
                            } # End of Report length check.
                        } # Exapand: False. End of Expand parameter check.
                    } # Report exists and is OK.
                    # Check whether Report ID is -1, meaning that the object is missing (deleted), but still attached to the Scan.
                    ElseIf ($Report.id -eq -1) {
                        $local.ERROR_MISSING_OBJECT
                    } # Report ID = -1. End of Reports ID check.
                } # End of Reports loop.
            } # Reports exist.
            Else {
                # No Reports.
                $local.LOG_NA
            } # End of Reports check.
        }; Label = $local.GETSCANS_TBL_REPORTS; Width = 66 },
        @{ Expression = {
            # Check if Schedule Type is not template, then show schedule.
            If ($PSItem.schedule.type -ne 'template') {
                "$($PSItem.schedule.type) $($PSItem.schedule.start) $($PSItem.schedule.repeatRule) $(ConvertFrom-EpochToNormal -InputEpoch $PSItem.schedule.nextRun)"
            } # End of Schedule Type check.
        }; Label = $local.GETSCANS_TBL_SCHEDULE; Width = 30 }
    } # End of Default View.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Scans list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # Display Unformatted, Raw Data.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputHolder | Format-Table -Property $OutputTable

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCScans.

Function Get-SCPolicies {
<#
.SYNOPSIS
Get Policies Listing.
.DESCRIPTION
Retrieves a list of Policies.
.EXAMPLE
Show a Policy with an ID of 1000333.
Get-SCPolicies -ID 1000333
.EXAMPLE
Filter Output by Policy Name.
Get-SCPolicies -PolicyName "rhel"
.EXAMPLE
Filter Output by Audit File Name.
Get-SCPolicies -AuditFile "rhel"
.EXAMPLE
Filter Output by Audit File Type.
AuditType parameter takes only unix, windows, databse or vmware options. Use tab, to switch between them.
Get-SCPolicies -AuditType "windows
.EXAMPLE
Filter Output by Policy Template.
There are many options, use tab to go through them. Or start with a few characters, like Cr and use tab. In this case you will loop though only options that begin with Cr.
Get-SCPolicies -PolicyTemplate "Advanced Scan"
.EXAMPLE
Show Only Policies by certain User. Use First or Last name, not both at once. Can be partial.
Following cmdlet will find Reports where Owner's First or Last Name contains "sab".
Get-SCPolicies -Owner "sab"
.EXAMPLE
Show Policies in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCPolicies -RAW
.PARAMETER ID
Show a Policy with a specific ID.
.PARAMETER Name
Filter Output by Policy Name.
.PARAMETER AuditFile
Filter Output by Policy Audit File Name.
.PARAMETER AuditType
Filter Output by Policy Audit File Type.
.PARAMETER PolicyTemplate
Filter Output by Policy Template Name.
.PARAMETER Owner
Filter Output by Policy Owner First or Last Name.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Policies.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETPOLICIES_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPOLICIES_HELP_NAME })]
    [String]$PolicyName,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPOLICIES_HELP_AUDITFILE })]
    [String]$AuditFile,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPOLICIES_HELP_AUDITTYPE })]
    [ValidateSet('unix', 'windows', 'database', 'vmware')]
    [String]$AuditType,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPOLICIES_HELP_POLICYTEMPLATE })]
    [ValidateSet('Advanced Scan', 'Basic Network Scan', 'Host Discovery', 'Policy Compliance Auditing', 'Credentialed Patch Audit', 'Malware Scan', 'Web Application Tests', 'Internal PCI Network Scan', 'SCAP and OVAL Auditing', 'Bash Shellshock Detection', 'GHOST (glibc) Detection', 'PCI Quarterly External Scan', 'DROWN Detection', 'Badlock Detection', 'Intel AMT Security Bypass Detection', 'WannaCry Ransomware Detection', 'Shadow Brokers Scans', 'Spectre and Meltdown Detection')]
    [String]$PolicyTemplate,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETPOLICIES_HELP_OWNER  })]
    [String]$Owner,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 7, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Assets Data.
    $Method = 'GET'
    $URI    = "$Server/policy?fields=id,name,description,policyTemplate,owner,auditFiles,tags"
    Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_GET_DATA -f $Method, $URI)
    $Policies = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($AuditFile -and $AuditType -and $PolicyName -and $Owner -and $PolicyTemplate) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITFILE_AUDITTYPE_NAME_OWNER_POLICYTEMPLATE -f $AuditFile, $AuditType, $PolicyName, $Owner, $PolicyTemplate)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.name -like "*$AuditFile*" -and $PSItem.auditFiles.type -eq $AuditType -and $PSItem.name -like "*$PolicyName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policyTemplate.name -like "*$PolicyTemplate*" }
    }
    ElseIf ($PolicyName -and $Owner -and $PolicyTemplate) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_NAME_OWNER_POLICYTEMPLATE -f $PolicyName, $Owner, $PolicyTemplate)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.name -like "*$PolicyName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.policyTemplate.name -like "*$PolicyTemplate*" }
    }
    ElseIf ($AuditFile -and $PolicyName) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITFILE_NAME -f $AuditFile, $PolicyName)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.name -like "*$AuditFile*" -and $PSItem.name -like "*$PolicyName*" }
    }
    ElseIf ($AuditType -and $PolicyName) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITTYPE_NAME -f $AuditType, $PolicyName)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.type -eq $AuditType -and $PSItem.name -like "*$PolicyName*" }
    }
    ElseIf ($AuditType -and $Owner) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITTYPE_OWNER -f $AuditType, $Owner)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.type -eq $AuditType -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($PolicyName -and $Owner) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_NAME_OWNER -f $PolicyName, $Owner)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.name -like "*$PolicyName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($AuditFile -and $PolicyTemplate) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITTYPE_POLICYTEMPLATE -f $AuditType, $PolicyTemplate)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.type -eq $AuditType -and $PSItem.policyTemplate.name -like "*$PolicyTemplate*" }
    }
    ElseIf ($AuditFile) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITFILE -f $AuditFile)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.name -like "*$AuditFile*" }
    }
    ElseIf ($AuditType) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_AUDITTYPE -f $AuditType)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.auditFiles.type -eq $AuditType }
    }
    ElseIf ($PolicyName) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_NAME -f $PolicyName)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.name -like "*$PolicyName*" }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_OWNER -f $Owner)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($PolicyTemplate) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_POLICYTEMPLATE -f $PolicyTemplate)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.policyTemplate.name -like "*$PolicyTemplate*" }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_ID -f $ID)
        $OutputHolder = $Policies.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Policies.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        Write-SCLog -LogInfo $($local.GETPOLICIES_LOG_ID -f $ID)

        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETPOLICIES_TBL_ID;             Expression = { $PSItem.id }},
            @{ Name = $local.GETPOLICIES_TBL_NAME;           Expression = { $PSItem.name }},
            @{ Name = $local.GETPOLICIES_TBL_DESCRIPTION;    Expression = { $PSItem.description }},
            @{ Name = $local.GETPOLICIES_TBL_AUDITFILE;      Expression = { $PSItem.auditFiles.name }},
            @{ Name = $local.GETPOLICIES_TBL_AUDITTYPE;      Expression = { $PSItem.auditFiles.type }},
            @{ Name = $local.GETPOLICIES_TBL_POLICYTEMPLATE; Expression = { $PSItem.policyTemplate.name }},
            @{ Name = $local.GETPOLICIES_TBL_TAGS;           Expression = { $PSItem.tags }},
            @{ Name = $local.GETPOLICIES_TBL_OWNER;          Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }}
    } # ID: True.
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETPOLICIES_TBL_ID;             Expression = { $PSItem.id }},
            @{ Name = $local.GETPOLICIES_TBL_NAME;           Expression = { $PSItem.name }},
            @{ Name = $local.GETPOLICIES_TBL_AUDITFILE;      Expression = { $PSItem.auditFiles.name }},
            @{ Name = $local.GETPOLICIES_TBL_AUDITTYPE;      Expression = { $PSItem.auditFiles.type }},
            @{ Name = $local.GETPOLICIES_TBL_POLICYTEMPLATE; Expression = { $PSItem.policyTemplate.name }},
            @{ Name = $local.GETPOLICIES_TBL_OWNER;          Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }}
    } # End of Default View.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Policies list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    }
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCPolicies.

Function Get-SCBlackoutWindows {
<#
.SYNOPSIS
Get Blackout Window Info.
.DESCRIPTION
Shows Blackout Windows list.
.EXAMPLE
Default Output.
Get-SCBlackoutWindows
.EXAMPLE
Show detailed info of the Blackout Windows.
Get-SCBlackoutWindows -Detailed
.PARAMETER Detailed
Shows detailed info of the Blackout Windows.
.NOTES
Output for this cmdlet is unformatted.
.FUNCTIONALITY
Shows License Information.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $False, HelpMessage = { $local.HELP_DETAILED })]
    [Switch]$Detailed
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get License Data.
    $Method = 'GET'
    $URI    = "$Server/blackout?fields=id,name,description,status,assets,repository,owner,ipList,allIPs,repeatRule,start,end,duration,enabled,modifiedTime,active,functional"
    Write-SCLog -LogInfo $($local.GETBLACKOUT_WINDOW_LOG_GET_DATA -f $Method, $URI)
    $BlackoutInfo = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Output License Status Data.
    Write-SCLog -LogInfo $($local.LOG_CUSTOM_OUTPUT_TABLE -f 'Blackout Window')

    # Check if Detailed Parameter was used.
    If ($Detailed) {
        Write-SCLog -LogInfo $local.GETBLACKOUT_WINDOW_LOG_DETAILED_SWITCH

        $BlackoutTable = New-Object PSObject
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ID -Value $BlackoutInfo.response.id
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_NAME -Value $BlackoutInfo.response.name
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_DESCRIPTION -Value $BlackoutInfo.response.description
            If ($BlackoutInfo.response.allIPs -eq 'true') {
                Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ALLIPS -Value $Culture.ToTitleCase($BlackoutInfo.response.allIPs)
            }
            Else {
                Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_IPLIST -Value $BlackoutInfo.response.ipList
                Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ASSETS -Value $BlackoutInfo.response.assets
                Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_REPOSITORY -Value $BlackoutInfo.response.repository.name
            }
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_OWNER -Value "$($BlackoutInfo.response.owner.firstName) $($BlackoutInfo.response.owner.lastName)"
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_MODIFIEDTIME -Value (ConvertFrom-EpochToNormal -InputEpoch $BlackoutInfo.response.modifiedTime)
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_FUNCTIONAL -Value $Culture.ToTitleCase($BlackoutInfo.response.functional)
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ENABLED -Value $Culture.ToTitleCase($BlackoutInfo.response.enabled)
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ACTIVE -Value $Culture.ToTitleCase($BlackoutInfo.response.active)
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_REPEATRULE -Value $BlackoutInfo.response.repeatRule
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_START -Value $BlackoutInfo.response.start
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_END -Value $BlackoutInfo.response.end
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_STATUS -Value $BlackoutInfo.response.status

            # Output Detailed Results.
            Write-SCLog -LogInfo $local.GETBLACKOUT_WINDOW_LOG_OUTPUT
            Write-Output -InputObject $BlackoutTable
    } # Detailed: True.
    Else {
        $BlackoutTable = New-Object PSObject
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ID -Value $BlackoutInfo.response.id
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_NAME -Value $BlackoutInfo.response.name
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_OWNER -Value "$($BlackoutInfo.response.owner.firstName) $($BlackoutInfo.response.owner.lastName)/$($BlackoutInfo.response.owner.username)"
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ENABLED -Value $Culture.ToTitleCase($BlackoutInfo.response.enabled)
            Add-Member -InputObject $BlackoutTable -MemberType NoteProperty -Name $local.GETBLACKOUT_WINDOW_TBL_ACTIVE -Value $Culture.ToTitleCase($BlackoutInfo.response.active)
    
            # Output Results.
            Write-SCLog -LogInfo $local.GETBLACKOUT_WINDOW_LOG_OUTPUT
            Write-Output -InputObject $BlackoutTable | Format-Table
    } # End of Default View. End of Detailed parameter check.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCBlackoutWindows.

Function Set-SCScan {
<#
.SYNOPSIS
Set Scan Configuration.
.DESCRIPTION
Change parameters of a Scan.
.EXAMPLE
Change Scan Name to "New Scan".
Set-SCScan -ID 635 -Name "New Scan"
.EXAMPLE
Change Scan Description to "Description of the New Scan".
Set-SCScan -ID 635 -Description "Description of the New Scan"
.EXAMPLE
Change Scan's Policy to a Policy with and ID of "1000233".
Set-SCScan -ID 635 -PolicyID 1000233
.EXAMPLE
Change Scan Asset(s). This will replace Assets, NOT Append!
Set-SCScan -ID 635 -AssetID 12333
Set-SCScan -ID 635 -AssetID 12333,12334,12335
.EXAMPLE
Change Scan's IP address(es) or FQDN(s). This will replace Assets, NOT Append!
Set-SCScan -ID 635 -FQDNorIP WS0001.domain.net
Set-SCScan -ID 635 -FQDNorIP WS0001.domain.net, WS0002.domain.net
.EXAMPLE
Change Scan's Credential(s). This will replace Assets, NOT Append!
Set-SCScan -ID 635 -CredentialID 12524
Set-SCScan -ID 635 -CredentialID 12524,12525,13443
.EXAMPLE
Change Scan's Report(s). This will replace Assets, NOT Append!
Set-SCScan -ID 635 -ReportID 1255
Set-SCScan -ID 635 -ReportID 1255,1256
.EXAMPLE
Change Scan Reports Report Source to invidivual.
Set-SCScan -ID 635 -ReportSource individual
.EXAMPLE
Change Scan's Repository to a Repository with and ID of "20".
Set-SCScan -ID 635 -RepositoryID 20
.EXAMPLE
Change whether the scan would look for Virtual Hosts, or not. Default is Enabled (true).
Set-SCScan -ID 635 -ScanVirtualHosts false
.EXAMPLE
Change Scan's Maximum Scan Time in hours.
Set-SCScan -ID 635 -MaxScanTime 2
.EXAMPLE
Turn DHCP Tracking off. Default is Enabled (true).
Set-SCScan -ID 635 -DHCPTracking false
.EXAMPLE
Set Scan's Timeout Action to rollover and Rollover Type to next day.
RolloverType is only set when TimeoutAction has a value of rollover.
Set-SCScan -ID 635 -TimeoutAction rollover -RolloverType nextDay
.PARAMETER ID
Specify the Scan ID, which you want to change.
.PARAMETER Name
Specify new name for the Scan.
.PARAMETER Description
Specify new description for the Scan.
.PARAMETER PolicyID
Specify the ID of the Policy you want to set.
.PARAMETER AssetID
Specify the ID of the Asset you want to set.
.PARAMETER FQDNOrIP
Specify IP or FQDN address(es).
.PARAMETER CredentialID
Specify the ID of the Credential you want to set.
.PARAMETER ReportID
Specify the ID of the Report you want to set.
.PARAMETER ReportSource
Specify the Report Source for the Reports.
.PARAMETER RepositoryID
Specify the ID of the Repository you want to set.
.PARAMETER ScanVirtualHosts
Specify if you want to scan Virtual Hosts. Since Tenable recommends this to be enabled. Default is Enabled (true).
.PARAMETER MaxScanTime
Specify Maximum Scan Time in hours.
.PARAMETER DHCPTracking
Specify whether you wan DHCP Tracking to be Enabled (true), or Disabled (false). Default is Enabled (true).
.PARAMETER TimeoutAction
Specify action if scan times out.
.PARAMETER RolloverType
If Timeoutaction is set to rollover, you would have to pick Rollover Type. Either nextDay, where the Rollover Scan will be run next day, or template, where teh Rollover Scan will be run On Demand.
.FUNCTIONALITY
Change Scan configuration.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.SETSCAN_HELP_ID }, ValueFromPipelineByPropertyName)]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_DESCRIPTION })]
    [String]$Description,
    [Parameter(Position = 3, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_POLICY_ID })]
    [Int]$PolicyID,
    [Parameter(Position = 4, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_ASSET_ID })]
    [Int[]]$AssetID,
    [Parameter(Position = 5, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_ADDRESS })]
    [String[]]$FQDNorIP,
    [Parameter(Position = 6, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_CREDENTIAL_ID })]
    [Int[]]$CredentialID,
    [Parameter(Position = 7, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_REPORT_ID })]
    [Int[]]$ReportID,
    [Parameter(Position = 8, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_REPORT_SOURCE })]
    [ValidateSet('cumulative','patched','individual')]
    [String]$ReportSource = 'cumulative',
    [Parameter(Position = 9, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_REPOSITORY_ID })]
    [Int]$RepositoryID,
    [Parameter(Position = 10, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_SCAN_VIRTUAL_HOSTS })]
    [ValidateSet('true','false')]
    [String]$ScanVirtualHosts = 'true',
    [Parameter(Position = 11, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_MAX_SCAN_TIME })]
    [ValidateRange(1,120)]
    [Int]$MaxScanTime,
    [Parameter(Position = 12, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_DHCPTRACKING })]
    [ValidateSet('false','true')]
    [String]$DHCPTracking = 'true',
    [Parameter(Position = 13, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_TIMEOUT_ACTION })]
    [Validateset('discard','import','rollover')]
    [String]$TimeoutAction,
    [Parameter(Position = 14, Mandatory = $False, HelpMessage = { $local.SETSCAN_HELP_ROLLOVER_TYPE })]
    [Validateset('nextDay','template')]
    [String]$RolloverType
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get the scan's existing data to use when no new data is provided and store it into $ExistingScan variable.
    Get-SCScans -RAW | Where-Object id -eq $ID -OutVariable ExistingScan | Out-Null

    # Set Item Count to 0. Used for enumerating provided IDs.
    [Int]$ItemCount = 0

    # Build JSON query.
    ## If new parameters are not provided, old ones will be used from $ExistingScan.
    $JSONBody = '{
        "repository" : {
            "id" : "' + $(If ($RepositoryID) {
                $RepositoryID
            }
            Else { 
                $ExistingScan.repository.id
            }) + '"
        },
        ' + $(If ($DHCPTracking) {
            '"dhcpTracking" : "' + $DHCPTracking + '",'
        }) + '
        ' + $(If ($Name) {
            '"name" : "' + $Name + '",'
        }) + '
        ' + $(If ($Description) {
            '"description" : "' + $Description + '",'
        }) + '
        ' + $(If ($ReportID) {
        '"reports" : ['
            ForEach ($Report in $ReportID) {
            
                [Int]$ItemCount += 1

                If ($ItemCount -lt $ReportID.Length) {
                    '{
                        "id" : "' + $Report + '",
                        "reportSource" : "' + $ReportSource + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Report + '",
                        "reportSource" : "' + $ReportSource + '"
                    }'
                }
            }
        '],'

        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0

        }) + '
        ' + $(If ($AssetID) {
        '"assets" : ['
            ForEach ($Asset in $AssetID) {
            
                [Int]$ItemCount += 1

                If ($ItemCount -lt $AssetID.Length) {
                    '{
                        "id" : "' + $Asset + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Asset + '"
                    }'
                }
            }
        '],'

        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0

        }) + '
        ' + $(If ($FQDNorIP) {
            '"ipList" : "' + $FQDNorIP + '",'
        }) + '
        ' + $(If ($CredentialID) {
        '"credentials" : ['
            ForEach ($Credential in $CredentialID) {

                [Int]$ItemCount += 1
            
                If ($ItemCount -lt $CredentialID.Length) {
                    '{
                        "id" : "' + $Credential + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Credential + '"
                    }'
                }
            }
        '],'
        
        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0
        
        }) + '
        ' + $(If ($TimeoutAction) {
            '"timeoutAction" : "' + $TimeoutAction + '",'
        }) + '
        ' + $(If (($TimeoutAction -eq "rollover") -and $RolloverType) {
            '"rolloverType" : "' + $RolloverType + '",'
        }) + '
        ' + $(If ($ScanVirtualHosts) {
            '"scanningVirtualHosts" : "' + $ScanVirtualHosts + '",'
        }) + '
        ' + $(If ($MaxScanTime) {
            '"maxScanTime" : "' + $MaxScanTime + '",'
        }) + '
        "policy" : {
            "id" : "' + $(If ($PolicyID) {
                $PolicyID
            }
            Else {
                $ExistingScan.policy.id
            }) + '"
        }
    }'

    $Method = 'PATCH'
    $URI    = "$Server/scan/$ID"
    Write-SCLog -LogInfo $($local.SETSCAN_LOG_GET_DATA -f $Method, $URI)
    # Update the Scan.
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Set-SCScan.

Function Remove-SCAsset {
<#
.SYNOPSIS
Remove an Asset.
.DESCRIPTION
Remove specified Asset.
.EXAMPLE
Remove an Asset with an ID of 7336.
Remove-SCAsset -ID 7336
.EXAMPLE
Remove assets from pipeline.
Get-SCAssets -Owner user -Type dnsname -Tag temp | Remove-SCAsset
.PARAMETER ID
ID of an Asset.
.NOTES
Each removal will ask confirmation.
.FUNCTIONALITY
Removes an Asset from Tenable.SC.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.REMOVEASSET_HELP_ID }, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [Int[]]$ID
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Iterate through provided Asset IDs.
    ForEach ($Item in $ID) {
        $Method = 'DELETE'
        $URI = "$Server/asset/$Item"
        Write-SCLog -LogInfo $($local.REMOVEASSET_LOG_SET_DATA -f $Method, $URI)

        # Expect y (yes), enq (exit, no, quit respectively) inputs.
        While (!(Read-Host -Prompt $($local.REMOVEASSET_INFO_CONFIRMATION -f $Item) -OutVariable UserInput) -notmatch '^e|n|q|y$') {
            Switch -Regex ($UserInput) {
                "^y$" {
                    Try {
                        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'
                        Write-Output $($local.REMOVEASSET_INFO_ASSET_DELETED -f $Item)
                    } # Result: Success.
                    Catch {
                        Write-SCError -Message $PSItem.ErrorDetails.Message -RecommendedAction $local.REMOVEASSET_ERROR_FIX
                    } # Result: Fail.
                    return
                } # End of agreement.
                "^e|n|q^" {
                    Write-Output -InputObject $($local.REMOVEASSET_INFO_DELETION_CANCEL -f $Item)
                    return
                } # End of disagreement.
                Default {
                    Write-Output -InputObject $local.INFO_ACCEPTED_INPUTS
                } # Input was invalid. Loop.
            } # End of Input Switch.
        } # End of While Prompt.
    } # End of Asset ID loop.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Remove-SCAsset.

Function New-SCScan {
<#
.SYNOPSIS
Create a new Scan.
.DESCRIPTION
Create a new Scan in Tenable.SC.
.EXAMPLE
Create a bare minimum Scan with a Name and a Policy.
New-SCScan -Name 'New Scan' -PolicyID 1000204
.EXAMPLE
Create a scan where Virtual Host scanning is turned off.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -ScanVirtualHosts false
.EXAMPLE
Create a scan with a description.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -Description 'Test Scan of Windows Clients'
.EXAMPLE
Create a scan with Policy, Asset, IP, Credential, Report.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -AssetID 1098 -FQDNorIP '127.0.0.1,WS2000.domain.net,WS3253.domain.net,127.0.0.2' -CredentialID 1000119 -ReportID 7161
.EXAMPLE
Create a scan with Policy, Asset, IP, Credential, Report, a different Repository and Report Source.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -AssetID 1098 -FQDNorIP '127.0.0.1,WS2000.domain.net,WS3253,127.0.0.2' -CredentialID 1000119 -ReportID 7161 -RepositoryID 29 -ReportSource patched
.EXAMPLE
Create a scan with Name and a Policy and turn DHCP Tracking and Scan Virtual Hosts off.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -DHCPTracking false -ScanVirtualHosts false
.EXAMPLE
Create a bare minimum Scan with a Name and a Policy. Set custom Max Scan Time in hours (1-120).
When this Parameter is not used, Scan Time will be unlimited.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -MaxScanTime 120
.EXAMPLE
Create a scan with timeout action where scan results will be discarded.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -TimeoutAction discard
.EXAMPLE
Create a scan with rollover setting, with next day option.
New-SCScan -Name 'New Scan' -PolicyID 1000204 -TimeoutAction rollover -RolloverType nextDay
.PARAMETER Name
Specify Name for the new Scan.
.PARAMETER Description
Specify Description for the new Scan.
.PARAMETER PolicyID
Specify the ID of the Policy you want to use.
.PARAMETER AssetID
Specify the ID(s) of the Asset(s) you want to use.
.PARAMETER FQDNorIP
Specify custom addresses as Scan Targets. IP addresses, single label names, Fully Qualified Names are supported. When used with AssetID, a mixed Asset Target will be created.
.PARAMETER CredentialID
Specify the ID(s) of the Credential(s) you want to use.
.PARAMETER ReportID
Specify the ID(s) of the Report(s) you want to use.
.PARAMETER ReportSource
Specify from which Report Source will the data be pulled from for the Report.
.PARAMETER RepositoryID
Specify the ID of the Repository you want to use.
.PARAMETER ScanVirtualHosts
Specify if you want to scan Virtual Hosts. Since Tenable recommends this to be enabled, the Default option is true.
.PARAMETER MaxScanTime
Specify Maximum Scan Time in hours.
.PARAMETER DHCPTracking
Specify whether you wan DHCP Tracking to be Enabled, or not. DHCP Tracking is Enabled by Default.
.PARAMETER TimeoutAction
Specify action if scan times out.
.PARAMETER RolloverType
If Timeoutaction is set to rollover, you would have to pick Rollover Type. Either nextDay, where the Rollover Scan will be run next day, or template, where teh Rollover Scan will be run On Demand.
.FUNCTIONALITY
Creates a new Scan in Tenable.sc.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.NEWSCAN_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 1, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_DESCRIPTION })]
    [String]$Description,
    [Parameter(Position = 2, Mandatory = $True, HelpMessage = { $local.NEWSCAN_HELP_POLICY_ID })]
    [Int]$PolicyID,
    [Parameter(Position = 3, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_ASSET_ID })]
    [Int[]]$AssetID,
    [Parameter(Position = 4, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_ADDRESS })]
    [String[]]$FQDNorIP,
    [Parameter(Position = 5, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_CREDENTIAL_ID })]
    [Int[]]$CredentialID,
    [Parameter(Position = 6, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_REPORT_ID })]
    [Int[]]$ReportID,
    [Parameter(Position = 7, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_REPORT_SOURCE })]
    [ValidateSet('cumulative','patched','individual')]
    [String]$ReportSource = 'cumulative',
    [Parameter(Position = 8, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_REPOSITORY_ID })]
    [Int]$RepositoryID = '16',
    [Parameter(Position = 9, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_SCAN_VIRTUAL_HOSTS })]
    [ValidateSet('true','false')]
    [String]$ScanVirtualHosts = 'true',
    [Parameter(Position = 10, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_MAX_SCAN_TIME })]
    [ValidateRange(1,120)]
    [Int]$MaxScanTime,
    [Parameter(Position = 11, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_DHCP_TRACKING })]
    [ValidateSet('true','false')]
    [String]$DHCPTracking = 'true',
    [Parameter(Position = 12, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_TIMEOUT_ACTION })]
    [Validateset('discard','import','rollover')]
    [String]$TimeoutAction = 'import',
    [Parameter(Position = 13, Mandatory = $False, HelpMessage = { $local.NEWSCAN_HELP_ROLLOVER_TYPE })]
    [Validateset('nextDay','template')]
    [String]$RolloverType
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Set Item Count to 0. Used for enumerating provided IDs.
    [Int]$ItemCount = 0

    # Create New Scan JSON structure.
    $JSONBody = '{
        "type" : "policy",
        "name" : "' + $Name  + '",
        "description" : "' + $Description + '",
        "policy" : {
            "id" : "' + $PolicyID  + '"
        },
        "repository" : {
            "id" : "' + $RepositoryID + '"
        },
        ' + $(If ($TimeoutAction) {
            '"timeoutAction" : "' + $TimeoutAction + '",
        '}) + '
        ' + $(If (($TimeoutAction -eq "rollover") -and $RolloverType) {
            '"rolloverType" : "' + $RolloverType + '",
        '}) + '
        "scanningVirtualHosts" : "' + $ScanVirtualHosts + '",
        "dhcpTracking" : "' + $DHCPTracking + '"
        ' + $(If ($ReportID) { ',"reports" : [
        ' + $(ForEach ($Report in $ReportID) {
            
                [Int]$ItemCount += 1

                If ($ItemCount -lt $ReportID.Length) {
                    '{
                        "id" : "' + $Report + '",
                        "reportSource" : "' + $ReportSource + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Report + '",
                        "reportSource" : "' + $ReportSource + '"
                    }'
                }
            }
        
        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0
        
        ) + ']' }) + '
        ' + $(If ($AssetID) { ',"assets" : [
        ' + $(ForEach ($Asset in $AssetID) {
            
                [Int]$ItemCount += 1

                If ($ItemCount -lt $AssetID.Length) {
                    '{
                        "id" : "' + $Asset + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Asset + '"
                    }'
                }
            }
        
        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0
        
        ) + ']' }) + '
        ' + $(If ($FQDNorIP) {
            '"ipList" : "' + $($FQDNorIP -join ',') + '"
        '}) + '
        ' + $(If ($CredentialID) { ',"credentials" : [
        ' + $(ForEach ($Credential in $CredentialID) {
            
                [Int]$ItemCount += 1
            
                If ($ItemCount -lt $CredentialID.Length) {
                    '{
                        "id" : "' + $Credential + '"
                    },'
                }
                Else {
                    '{
                        "id" : "' + $Credential + '"
                    }'
                }
            }
        
        # Reset the Item Count back to 0.
        [Int]$ItemCount = 0
        
        ) + ']' }) + '
        ' + $(If ($MaxScanTime) {
            ',"maxScanTime" : "' + $MaxScanTime + '"
        '})+'
    }'

    # Create New Scan.
    $Method = "POST"
    $URI    = "$Server/scan"
    Write-SCLog -LogInfo $($local.NEWSCAN_LOG_SET_DATA -f $Method, $URI)
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

    Write-SCLog -LogInfo $($local.NEWSCAN_LOG_NEW_SCAN_DATA -f $AssetsID, $CredentialID, $Description, $DHCPTracking, $IPs, $Name, $PolicyID, $ReportID, $ReportSource, $RepositoryID)
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function New-SCScan.

Function Get-SCCredentials {
<#
.SYNOPSIS
Get Credentials.
.DESCRIPTION
List Credentials.
.EXAMPLE
Default view, with no filtration:
Get-SCCredentials
.EXAMPLE
Get a specific Credential: (ID shows the most detailed information about a Credential.)
Get-SCCredentials -ID 1000124
.EXAMPLE
List Credentials with admin in their name:
Get-SCCredentials -CredentialName admin
.EXAMPLE
List Credentials with dblan in their description:
Get-SCCredentials -Description dblan
.EXAMPLE
List Credentials with Windows Type:
Get-SCCredentials -Type windows
.EXAMPLE
List Credentials with cyberark in their tags:
Get-SCCredentials -Tag cyberark
.EXAMPLE
List Credentials with "rol" in either their first or last name. Will not handle Full Names.
Get-SCCredentials -Owner rol
List Credentials which are of CyberArk Type.
Get-SCCredentials -CyberArkEnabled
.EXAMPLE
List Credentials with C001524 in their usernames.
Get-SCCredentials -Username C001524
.EXAMPLE
List Orphaned Credentials.
Get-SCCredentials -Orphaned
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCCredentials -CredentialName admin -NoFormat
.EXAMPLE
Show Credentials in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCCredentials -RAW
.PARAMETER ID
Filter Output by ID.
.PARAMETER CredentialName
Filter Output by Credential Name.
.PARAMETER Description
Filter Output by Description.
.PARAMETER Type
Filter Output by Type.
.PARAMETER Tag
Filter Output by Tag.
.PARAMETER Owner
Filter Output by Owner.
.PARAMETER CyberArkEnabled
Filter Output by showing only CyberArk enabled Credentials.
.PARAMETER Username
Filter Output by Username.
.PARAMETER Orphaned
Filter out Credentials that are Orphaned.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Credential Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param (
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETCREDENTIALS_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_NAME })]
    [String]$CredentialName,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_DESCRIPTION })]
    [String]$Description,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_TYPE })]
    [ValidateSet('database','ssh','windows')]
    [String]$Type,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_TAG })]
    [String]$Tag,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 6, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_CYBERARK })]
    [Switch]$CyberArkEnabled,
    [Parameter(Position = 7, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_USERNAME })]
    [String]$Username,
    [Parameter(Position = 8, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETCREDENTIALS_HELP_ORPHANED })]
    [Switch]$Orphaned,
    [Parameter(Position = 9, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Parameter(ParameterSetName = 'ID')]
    [Switch]$NoFormat,
    [Parameter(Position = 10, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Credential Data.
    $Method = 'GET'
    $URI    = "$Server/credential?fields=id,name,description,type,tags,typeFields,creator,owner"
    Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_GET_DATA -f $Method, $URI)

    $Credentials = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Get Scan Data.
    $Method = 'GET'
    $URI    = "$Server/scan?fields=credentials"
    Write-SCLog -LogInfo $($local.GETSCANS_LOG_GET_DATA -f $Method, $URI)

    $Scans = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($CredentialName -and $Owner -and $Tag -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_OWNER_TAG_TYPE -f $CredentialName, $Owner, $Tag, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($CredentialName -and $Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_OWNER_TYPE -f $CredentialName, $Owner, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($CredentialName -and $Owner -and $Tag) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_OWNER_TAG -f $CredentialName, $Owner, $Tag)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -eq $Tag }
    }
    ElseIf ($CredentialName -and $Tag -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_TAG_TYPE -f $CredentialName, $Tag, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and $PSItem.tags -like "*$Tag*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($Owner -and $Tag -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_OWNER_TAG_TYPE -f $Owner, $Tag, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($CredentialName -and $Owner) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_OWNER -f $CredentialName, $Owner)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($CredentialName -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME_TYPE -f $CredentialName, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_OWNER_TYPE -f $Owner, $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_ID -f $ID)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($CredentialName) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME -f $CredentialName)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -like "*$CredentialName*" }
    }
    ElseIf ($Orphaned) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_NAME -f $Orphaned)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.name -notin $Scans.response.usable.credentials.name }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_OWNER -f $Owner)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($CyberArkEnabled) {
        Write-SCLog -LogInfo $local.GETCREDENTIALS_LOG_CYBERARK
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.typeFields.authType -eq 'cyberark' }
    }
    ElseIf ($Username) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_CYBERARK -f $Username)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.typeFields.username -like "*$Username*" }
    }
    ElseIf ($Tag) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_TAG -f $Tag)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($Type) {
        Write-SCLog -LogInfo $($local.GETCREDENTIALS_LOG_TYPE -f $Type)
        $OutputHolder = $Credentials.response.usable | Where-Object { $PSItem.type -eq $Type }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Credentials.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETCREDENTIALS_TBL_ID;                     Expression = { $PSItem.id }},
            @{ Name = $local.GETCREDENTIALS_TBL_CREDENTIAL_NAME;        Expression = { $PSItem.name }},
            @{ Name = $local.GETCREDENTIALS_TBL_DESCRIPTION;            Expression = { $PSItem.description }},
            @{ Name = $local.GETCREDENTIALS_TBL_TAG;                    Expression = { $PSItem.tags }},
            @{ Name = $local.GETCREDENTIALS_TBL_TYPE;                   Expression = { $PSItem.type }},
            @{ Name = $local.GETCREDENTIALS_TBL_OWNER;                  Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
            @{ Name = $local.GETCREDENTIALS_TBL_AUTH_TYPE;              Expression = { $PSItem.typeFields.authType }},
            @{ Name = $local.GETCREDENTIALS_TBL_USERNAME;               Expression = {
                # Check if Login TypeField exist.
                If (($PSItem.typeFields.login).Length -gt 1) {
                    $PSItem.typeFields.login
                } # Login TypeField: True.
                Else {
                    # If not, show Username TypeField.
                    $PSItem.typeFields.username
                } # Login TypeField: False. End of Login Type Field check.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DOMAIN;                 Expression = {
                # Check if Domain TypeField exist.
                If (($PSItem.typeFields.domain).Length -gt 1) {
                    # Adding a newline to separate the section that comes after it.
                    $($PSItem.typeFields.domain + $NewLine)
                } # Domain TypeField: True.
                Else {
                    # Domain not specified. Adding a newline to separate the section that comes after it.
                    $($local.LOG_NA + $NewLine)
                } # Domain TypeField: False. End of Domain Type Field check.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_SID;                 Expression = {
                # Check if Credential Type is database and if Database SID exists.
                If ($PSItem.type -eq 'database' -and ($PSItem.typeFields.sid).Length -gt 1) {
                    $PSItem.typeFields.sid
                } # SID TypeField: True.
                Else {
                    $local.LOG_NA
                } # SID TypeField: False. End of SID Type Field check.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_PORT;                Expression = {
                # Check if Credential Type is database.
                If ($PSItem.type -eq 'database') {
                    # Show Credential Database Port.
                    $PSItem.typeFields.port
                } # Port TypeField: True.
                Else {
                    $local.LOG_NA
                } # Port TypeField: False. End of Database Type check for Port Type Field.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_TYPE;                Expression = {
                # Check if Credential Type is database.
                If ($PSItem.type -eq 'database') {
                    # Show Credential Database Type. Adding a newline to separate the section that comes after it.
                    $($PSItem.typeFields.dbType + $NewLine)
                } # DBTYPE TypeField: True.
                Else {
                    # Adding a newline to separate the section that comes after it.
                    $($local.LOG_NA+$NewLine)
                } # DBTYPE TypeField: False. End of Database Type check for DBTYPE Type Field.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_ORACLE_AUTH_TYPE;    Expression = {
                # Check if Oracle Auth Type exists.
                If ($PSItem.typeFields.oracleAuthType -ne $null) {
                    $PSItem.typeFields.oracleAuthType
                } # Oracle Auth Type: True.
                Else {
                    $local.LOG_NA
                } # Oracle Auth Type: False. End of Oracle Auth Type check.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_ORACLE_SERVICE_TYPE; Expression = {
                # Check if Oracle Service Type exists.
                If ($PSItem.typeFields.oracle_service_type -ne $null) {
                    $PSItem.typeFields.oracle_service_type
                } # Oracle Service Type: True.
                Else {
                    $local.LOG_NA
                } # Oracle Service Type: False. End of Oracle Service Type check.
            }}
    } # ID: True.
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETCREDENTIALS_TBL_ID;                     Expression = { $PSItem.id }},
            @{ Name = $local.GETCREDENTIALS_TBL_CREDENTIAL_NAME;        Expression = { $PSItem.name }},
            @{ Name = $local.GETCREDENTIALS_TBL_DESCRIPTION;            Expression = { $PSItem.description }},
            @{ Name = $local.GETCREDENTIALS_TBL_TYPE;                   Expression = { $PSItem.type }},
            @{ Name = $local.GETCREDENTIALS_TBL_DB_TYPE;                Expression = {
                # Check if Credential Type is database.
                If ($PSItem.type -eq 'database') {
                    # Show Credential Database Type.
                    $PSItem.typeFields.dbType
                } # DBTYPE TypeField: True.
                Else {
                    $local.LOG_NA
                } # DBTYPE TypeField: False. End of Database Type check for DBTYPE Type Field.
            }},
            @{ Name = $local.GETCREDENTIALS_TBL_TAG;                    Expression = { $PSItem.tags }},
            @{ Name = $local.GETCREDENTIALS_TBL_OWNER;                  Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
            @{ Name = $local.GETCREDENTIALS_TBL_ATTRIBUTES;             Expression = {
                # Check if Credential Type is database.
                If ($PSItem.type -eq 'database') {
                    $PSItem.typeFields.login
                    
                    # Show Database SID, if it exists.
                    If (($PSItem.typeFields.sid).Length -gt 1) {
                        $PSItem.typeFields.sid
                    } # End of SID Type Field check.
                    
                    $PSItem.typeFields.port
                    
                    # Check if Database TypeField Type is Oracle,
                    If ($PSItem.typeFields.dbType -eq 'Oracle') {
                        $PSItem.typeFields.oracleAuthType
                        $PSItem.typeFields.SQLServerAuthType
                        $PSItem.typeFields.authType
                        $PSItem.typeFields.oracle_service_type
                    } # Database TypeField Type: Oracle.
                    # or Microsoft SQL Server,
                    ElseIf ($PSItem.typeFields.dbType -eq 'SQL Server') {
                        $PSItem.typeFields.SQLServerAuthType
                        $PSItem.typeFields.authType
                    } # Database TypeField Type: SQL Server.
                    # or the other ones.
                    Else {
                        $PSItem.typeFields.authType
                    }  # Database TypeField Type: other. End of Database TypeField Type check.
                } # Credential Type: database.
                # If Attribute Type is not database.
                Else {
                    $PSItem.typeFields.authType
                    $PSItem.typeFields.username
                    
                    # Check if Domain TypeField exists.
                    If (($PSItem.typeFields.domain).Length -gt 1) {
                        $PSItem.typeFields.domain
                    } # End of Domain Type Field check.
                } # Credential Type: not database. End of Credential Type check.
            }}
    } # End of Default View.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Credentials list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCCredentials.

Function Get-SCUsers {
<#
.SYNOPSIS
Get Users.
.DESCRIPTION
List Tenable.sc Users.
.EXAMPLE
Default view, with no filtration:
Get-SCUsers
.EXAMPLE
Filter users by their first, last, or username.
Get-SCUsers -Name bc0000
.EXAMPLE
Show Locked Out Users Only.
Get-SCUsers -ShowLockedOnly
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCUsers -NoFormat
.EXAMPLE
Show Credentials in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCCredentials -RAW
.PARAMETER Name
Filter Output by Name.
.PARAMETER ShowLockedOnly
Filter Output by Locked Out Users.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows User Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param (
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETUSERS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETUSERS_HELP_LOCKED })]
    [Switch]$ShowLockedOnly,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETUSERS_HELP_ROLE })]
    [String]$Role,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETUSERS_HELP_AUTH_TYPE })]
    [ValidateSet('ldap','tns')]
    [String]$AuthType,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETUSERS_HELP_FAILED_LOGINS })]
    [Switch]$FailedLogins,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get User Data.
    $Method = 'GET'
    $URI    = "$Server/user?fields=id,username,firstname,lastname,email,role,lastLogin,locked,failedLogins,authType,ldapUsername,responsibleAsset,group,title"
    Write-SCLog -LogInfo $($local.GETUSERS_LOG_GET_DATA -f $Method, $URI)
    $Users = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Name) {
        Write-SCLog -LogInfo $local.GETUSERS_LOG_NAME
        $OutputHolder = $Users.response | Where-Object { $PSItem.firstname -like "*$Name*" -or $PSItem.lastname -like "*$Name*" -or $PSItem.username -like "*$Name*" }
    }
    ElseIf ($Role) {
        Write-SCLog -LogInfo $local.GETUSERS_LOG_ROLE
        $OutputHolder = $Users.response | Where-Object { $PSItem.role.name -like "*$Role*" }
    }
    ElseIf ($AuthType) {
        Write-SCLog -LogInfo $local.GETUSERS_LOG_AUTH_TYPE
        $OutputHolder = $Users.response | Where-Object { $PSItem.authType -like "*$AuthType*" }
    }
    ElseIf ($FailedLogins) {
        Write-SCLog -LogInfo $local.GETUSERS_LOG_FAILED_LOGINS
        $OutputHolder = $Users.response | Where-Object { $PSItem.failedLogins -ge 1 }
    }
    ElseIf ($ShowLockedOnly) {
        Write-SCLog -LogInfo $local.GETUSERS_LOG_LOCKED
        $OutputHolder = $Users.response | Where-Object { $PSItem.locked -eq 'true' }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Users.response
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($NoFormat) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETUSERS_TBL_ID;                Expression = { $PSItem.id }},
            @{ Name = $local.GETUSERS_TBL_NAME;              Expression = {
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.firstname -eq '' -and $PSItem.lastname -eq '') {
                    $PSItem.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.firstname -eq '') {
                    "$($PSItem.lastname)/$($PSItem.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.lastname -eq '') {
                    "$($PSItem.firstname)/$($PSItem.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.firstname) $($PSItem.lastname)/$($PSItem.username)"
                } # End of user names check.
            }},
            @{ Name = $local.GETUSERS_TBL_ROLE;              Expression = { $PSItem.role.name }},
            @{ Name = $local.GETUSERS_TBL_TITLE;             Expression = { $PSItem.title }},
            @{ Name = $local.GETUSERS_TBL_EMAIL;             Expression = { $PSItem.email }},
            @{ Name = $local.GETUSERS_TBL_LASTLOGIN;         Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.lastLogin }},
            @{ Name = $local.GETUSERS_TBL_LOCKED;            Expression = { $Culture.ToTitleCase($PSItem.locked) }},
            @{ Name = $local.GETUSERS_TBL_FAILEDLOGINS;      Expression = { $PSItem.failedLogins }},
            @{ Name = $local.GETUSERS_TBL_AUTHTYPE;          Expression = { $Culture.ToUpper($PSItem.authType) }},
            @{ Name = $local.GETUSERS_TBL_LDAPUSERNAME;      Expression = {
                # Check if LDAP Username exists.
                If (($PSItem.ldapUsername).Length -gt 1) {
                    $PSItem.ldapUsername
                } # LDAP Username: True.
                Else {
                    # Show local User in Tenable.sc.
                    $local.GETUSERS_INFO_LOCAL_USER
                } # LDAP Username: False. End of LDAP Username check.
            }},
            @{ Name = $local.GETUSERS_TBL_RESPONSIBLE_ASSET; Expression = {
                # Check if User is reponsible for an Asset list.
                If ($PSItem.responsibleAsset.id -ne '-1') {
                    "[$($PSItem.responsibleAsset.id)]$($PSItem.responsibleAsset.name)"
                } # Asset Responsibility: True.
                Else {
                    $local.LOG_NA
                } # Asset Responsibility: False. End of Asset Responsibility check.
            }},
            @{ Name = $local.GETUSERS_TBL_GROUP;             Expression = { $PSItem.group.name }}
    }
    Else {
        $OutputTable =
            @{ Expression = { $PSItem.id };                                              Label = $local.GETUSERS_TBL_ID;                Width = 3  },
            @{ Expression = {
                                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.firstname -eq '' -and $PSItem.lastname -eq '') {
                    $PSItem.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.firstname -eq '') {
                    "$($PSItem.lastname)/$($PSItem.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.lastname -eq '') {
                    "$($PSItem.firstname)/$($PSItem.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.firstname) $($PSItem.lastname)/$($PSItem.username)"
                } # End of user names check.
            };                                                                           Label = $local.GETUSERS_TBL_NAME;              Width = 40 },
            @{ Expression = { $PSItem.role.name };                                       Label = $local.GETUSERS_TBL_ROLE;              Width = 18 },
            @{ Expression = { $PSItem.title };                                           Label = $local.GETUSERS_TBL_TITLE;             Width = 40 },
            @{ Expression = { $PSItem.email };                                           Label = $local.GETUSERS_TBL_EMAIL;             Width = 30 },
            @{ Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.lastLogin }; Label = $local.GETUSERS_TBL_LASTLOGIN;         Width = 20 },
            @{ Expression = { $Culture.ToTitleCase($PSItem.locked) };                    Label = $local.GETUSERS_TBL_LOCKED;            Width = 8  },
            @{ Expression = { $PSItem.failedLogins };                                    Label = $local.GETUSERS_TBL_FAILEDLOGINS;      Width = 15 },
            @{ Expression = { $Culture.ToUpper($PSItem.authType) };                      Label = $local.GETUSERS_TBL_AUTHTYPE;          Width = 10 },
            @{ Expression = {
                # Check if LDAP Username exists.
                If (($PSItem.ldapUsername).Length -gt 1) {
                    $PSItem.ldapUsername
                } # LDAP Username: True.
                Else {
                    # Show local User in Tenable.sc.
                    $local.GETUSERS_INFO_LOCAL_USER
                } # LDAP Username: False. End of LDAP Username check.
            };                                                                           Label = $local.GETUSERS_TBL_LDAPUSERNAME;      Width = 15 },
            @{ Expression = {
                # Check if User is reponsible for an Asset list.
                If ($PSItem.responsibleAsset.id -ne '-1') {
                    "[$($PSItem.responsibleAsset.id)]$($PSItem.responsibleAsset.name)"
                } # Asset Responsibility: True.
                Else {
                    $local.LOG_NA
                } # Asset Responsibility: False. End of Asset Responsibility check.
            };                                                                           Label = $local.GETUSERS_TBL_RESPONSIBLE_ASSET; Width = 23 },
            @{ Expression = { $PSItem.group.name };                                      Label = $local.GETUSERS_TBL_GROUP;             Width = 15 }
    }

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Users list')

    # Checking for output options.
    If ($NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Output: NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputHolder | Format-Table -Property $OutputTable

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Default View. End of NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Get-SCUsers.

Function New-SCAsset {
<#
.SYNOPSIS
Create a New Asset List.
.DESCRIPTION
Creates a new Asset List in Tenable.sc.
.EXAMPLE
Create an Asset using manually entered IP addresses.
New-SCAsset -Type IPs -Name 'Test DNS Asset List' -Description 'Testing PSTenableSC module.' -Tag 'TEST' -Addresses '127.0.0.1,127.0.0.2,127.0.0.3'
.EXAMPLE
Create an Asset using manually entered DNS names.
New-SCAsset -Type DNSNames -Name 'Test DNS Asset List' -Description 'Testing PSTenableSC module.' -Tag 'TEST' -Addresses 'WS2453.domain.net,WS2454.domain.net,WS2455.domain.net'
.EXAMPLE
Create an Asset by importing a list of DNS names. Make sure the Assets are written as FQDN, not hostnames and they need to be comma delimited.
New-SCAsset -Type DNSNames -Name 'Test DNS Asset List' -Description 'Testing PSTenableSC module.' -Tag 'TEST' -Import C:\TEMP\1000.txt -Domain domain.net
.EXAMPLE
Create an Asset by importing a list of IP addresses. Make sure the Assets are comma delimited.
New-SCAsset -Type IPs -Name 'Test DNS Asset List' -Description 'Testing PSTenableSC module.' -Tag 'TEST' -Import C:\TEMP\1000.txt
.PARAMETER Type
Set New Asset's Type.
.PARAMETER Name
Set New Asset's Name.
.PARAMETER Description
Set New Asset's Description.
.PARAMETER Tag
Set New Asset's Tag.
.PARAMETER Addresses
Set Addresses for the New Scan.
Can't be used with Import parameter.
.PARAMETER Import
Set file path for Import.
Can't be used with Addresses parameter.
.FUNCTIONALITY
Create new Asset List.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.NEWASSET_HELP_TYPE })]
    [ValidateSet('IPs','DNSNames')]
    [String]$Type,
    [Parameter(Position = 1, Mandatory = $True, HelpMessage = { $local.NEWASSET_HELP_NAME })]
    [ValidateLength(3,80)]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, HelpMessage = { $local.NEWASSET_HELP_DESCRIPTION })]
    [String]$Description,
    [Parameter(Position = 3, Mandatory = $False, HelpMessage = { $local.NEWASSET_HELP_TAG })]
    [String]$Tag,
    [Parameter(Position = 4, Mandatory = $True, ParameterSetName = 'Values', HelpMessage = { $local.NEWASSET_HELP_ADDRESSES })]
    [String]$Addresses,
    [Parameter(Position = 5, Mandatory = $True, ParameterSetName = 'Import', HelpMessage = { $local.NEWASSET_HELP_IMPORT })]
    [ValidateScript( { Test-Path -Path $PSItem -PathType Leaf } )]
    [String]$Import
)

# Create a mandatory Dynamic Parameter when Type equals DNSNames and Import Parameter is not empty.
DynamicParam {
    # Check if Type Parameter is DNSNames and that Import Parameter is not null.
    If (($Type -eq 'DNSNames') -and ($Import -ne $null)) {

        $DynamicParamName = 'Domain'

        $Attributes = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $Attributes.Position = 6
        $Attributes.Mandatory = $True
        $Attributes.ParameterSetName = 'Import'
        $Attributes.HelpMessage = $local.NEWASSET_HELP_IMPORT_DOMAIN
        $AttributeCollection = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]'
        $AttributeCollection.Add($Attributes)

        $ValidateSetAttribute = New-Object -TypeName System.Management.Automation.ValidateSetAttribute('dmz.domain.com','domain.net','mgmnt.domain.net','pci.domain.net')
        $AttributeCollection.Add($ValidateSetAttribute)

        $DynamicParamater = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($DynamicParamName, [String], $AttributeCollection)

        $DynamicParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $DynamicParameterDictionary.Add($DynamicParamName, $DynamicParamater)

        return $DynamicParameterDictionary
    } # End of Type and Import Parameters check.
} # End of Dynamic Parameter.

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Make Dynamic Parameter available for the autocomplete.
    $Domain = $PSBoundParameters[$DynamicParamName]

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Check if an array of Assets are being imported.
    If ($Import) {
        # Store import file into a variable.
        Write-SCLog -LogInfo $local.NEWASSET_LOG_STORE_IMPORTED_FILE
        $AssetsContent = Get-Content -Path $Import

        # Check if Assets are properly formatted.
        Write-SCLog -LogInfo $local.NEWASSET_LOG_IMPORT_FORMAT
        $FormatCheck = ForEach ($Asset in $AssetsContent) {
            # If Asset list contains FQDN and IP addresses, warn user and stop.
            If ($Asset -match $FQDNRegEx -and $Asset -match $IPv4RegEx) {
                Write-SCError -Message $local.NEWASSET_INFO_MIXED_ASSET_TYPES -RecommendedAction $local.NEWASSET_ERROR_RECOMMENDED_ACTION
            } # End of FQDN and IP Address match check.
            # If Assets are only hostnames, change them to FQDN, using the domain the user provided with Domain Parameter.
            If ($Asset -match $FQDNRegEx -and $Asset -notmatch $IPv4RegEx) {
                "$Asset.$Domain"
            } # End of FQDN match and IP Address nomatch check.
            # If all Assets are FQDN addresses, leave them as is.
            If ($Asset -match $FQDNRegEx) {
                $Asset
            } # End of FQDN check.
            # If all Assets are IP addresses, leave them as is.
            If ($Asset -match $IPv4RegEx) {
                $Asset
            } # End of IP Address check.
        } # End of Asset Format check loop.

        # Check if $FormatCheck output is comma delimited. Add delimiters, if necessary.
        Write-SCLog -LogInfo $local.NEWASSET_LOG_IMPORT_CHECK_COMMAS
        If ($FormatCheck -notcontains ',') {
            $ImportContent = $FormatCheck -join ','
        } # Delimiters: False.
        Else {
            $ImportContent = $FormatCheck
        } # Delimiters: True. End of Delimiters check.
    } # Import: True.
    # Check if Addresses are being provided.
    If ($Addresses) {
        ForEach ($Asset in $Addresses) {
            # If Asset list contains FQDN and IP addresses, warn user and stop.
            If ($Asset -match $FQDNRegEx -and $Asset -match $IPv4RegEx) {
                Write-SCError -Message $local.NEWASSET_INFO_MIXED_ASSET_TYPES -RecommendedAction $local.NEWASSET_ERROR_RECOMMENDED_ACTION
            } # End of FQDN and IP Address match check.
            # If Assets are only hostnames, change them to FQDN, using the domain the user provided with Domain Parameter.
            If ($Asset -match $FQDNRegEx -and $Asset -notmatch $IPv4RegEx) {
                "$Asset.$Domain"
            } # End of FQDN match and IP Address nomatch check.
            # If all Assets are FQDN addresses, leave them as is.
            If ($Asset -match $FQDNRegEx) {
                $Asset
            } # End of FQDN check.
            # If all Assets are IP addresses, leave them as is.
            If ($Asset -match $IPv4RegEx) {
                $Asset
            } # End of IP Address check.
        } # End of Addresses check loop.
    } # Addresses: True.
    # Set Variables depending on the Type parameter.
    If ($Type -eq 'IPs') {
        Write-SCLog -LogInfo $($local.NEWASSET_LOG_TYPE -f $Type)
        $AssetType = 'static'
        $AssetDefinition = 'definedIPs'

        # Check if Assets are listed manually, or provided in a file.
        If ($Addresses) {
            # Check if FQDNs and IPs are both used.
            If (([RegEx]::Matches($Addresses,$FQDNRegEx)).Count -ge 1 -and ([regex]::Matches($Addresses,$IPv4RegEx)).Count -ge 1) {
                Write-SCLog $local.NEWASSET_LOG_MIXED_ADDRESSES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_MIXED_ADDRESSES
                return
            } # End of FQDN and IP Address match check.
            # Check if any IPs Addresses were provided.
            ElseIf (([RegEx]::Matches($Addresses,$IPv4RegEx)).Count -eq 0) {
                Write-SCLog $local.NEWASSET_LOG_NO_IPS
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_NO_IPS
                return
            } # End of IP Address check.
            Else {
                # Input was correctly formatted.
                $Values = $Addresses
            } # End of Addresses formatting check.
        } # Addresses: True
        ElseIf ($Import) {
            # Check if FQDNs and IPs are both used.
            If (([RegEx]::Matches($ImportContent,$FQDNRegEx)).Count -ge 1 -and ([regex]::Matches($ImportContent,$IPv4RegEx)).Count -ge 1) {
                Write-SCLog $local.NEWASSET_LOG_MIXED_ADDRESSES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_MIXED_ADDRESSES
                return
            } # End of FQDN and IP Address match check.
            # Check if any IPs Addresses were provided.
            ElseIf (([RegEx]::Matches($ImportContent,$IPv4RegEx)).Count -eq 0) {
                Write-SCLog $local.NEWASSET_LOG_NO_IPS
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_NO_IPS
                return
            } # End of IP Address check.
            # Input was correctly formatted.
            Else {
                $Values = $ImportContent
            } # End of Addresses formatting check.
        } # Import: True.
    } # Type: IPs.
    ElseIf ($Type -eq 'DNSNames') {
        Write-SCLog -LogInfo $($local.NEWASSET_LOG_TYPE -f $Type)
        $AssetType = 'dnsname'
        $AssetDefinition = 'definedDNSNames'

        # Check if Assets are listed manually, or provided in a file.
        If ($Addresses) {
            # Check if FQDNs and IPs are both used.
            If (([RegEx]::Matches($Addresses,$FQDNRegEx)).Count -ge 1 -and ([regex]::Matches($Addresses,$IPv4RegEx)).Count -ge 1) {
                Write-SCLog $local.NEWASSET_LOG_MIXED_ADDRESSES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_MIXED_ADDRESSES
                return
            } # End of FQDN and IP Address match check.
            # Check if any FQDN Addresses were provided.
            ElseIf (([RegEx]::Matches($Addresses,$FQDNRegEx)).Count -eq 0) {
                Write-SCLog $local.NEWASSET_LOG_NO_DNS_NAMES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_NO_DNS_NAMES
                return
            } # End of FQDN check.
            Else {
                # Input was correctly formatted.
                $Values = $Addresses
            } # End of Addresses formatting check.
        } # Addresses: True.
        ElseIf ($Import) {
            # Check if FQDNs and IPs are both used.
            If (([RegEx]::Matches($ImportContent,$FQDNRegEx)).Count -ge 1 -and ([regex]::Matches($ImportContent,$IPv4RegEx)).Count -ge 1) {
                Write-SCLog $local.NEWASSET_LOG_MIXED_ADDRESSES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_MIXED_ADDRESSES
                return
            } # End of FQDN and IP Address match check.
            # Check if any FQDN Addresses were provided.
            ElseIf (([RegEx]::Matches($ImportContent,$FQDNRegEx)).Count -eq 0) {
                Write-SCLog $local.NEWASSET_LOG_NO_DNS_NAMES
                Write-Host -ForegroundColor Red $local.NEWASSET_LOG_NO_DNS_NAMES
                return
            } # End of FQDN check.
            Else {
                # Input was correctly formatted.
                $Values = $ImportContent
            } # End of Addresses formatting check.
        } # Import: True.
    } # Type: DNSNames.

    # Create New Asset JSON structure.
    Write-SCLog $local.LOG_JSON_QUERY

    $JSONBody = '{
        "type"                   : "'+ $AssetType +'",
        "prepare"                : "true",
        "name"                   : "'+ $Name +'",
        "description"            : "'+ $Description +'",
        "tags"                   : "'+ $Tag +'",
        "'+ $AssetDefinition +'" : "'+ $Values +'"
    }'

    # Create New Asset.
    $Method = 'POST'
    $URI    = "$Server/asset"
    Write-SCLog -LogInfo $($local.NEWASSET_LOG_SET_DATA -f $Method, $URI)
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

    Write-SCLog -LogInfo $($local.NEWASSET_LOG_NEW_ASSET_DATA -f $Type, $Name, $Description, $Tag)

} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function New-SCAsset.

Function Start-SCScan {
<#
.SYNOPSIS
Start a Scan.
.DESCRIPTION
Start an existing Scan.
.EXAMPLE
Start a Scan from pipeline.
Get-SCScans -ID 635 | Start-SCScan
.EXAMPLE
Start a Scan using an ID.
Start-SCScan -ID 635
.EXAMPLE
Start a Diagnostic Scan against a single Asset.
Start-SCScan -ID 635 -Diagnostic
.PARAMETER ID
Scan ID which will be started.
.FUNCTIONALITY
Start a Scan.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.STARTSCAN_HELP_ID }, ValueFromPipelineByPropertyName)]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, HelpMessage = { $local.STARTSCAN_HELP_DIAGNOSTIC_TARGET })]
    [String]$DiagnosticTarget
)
# Create a mandatory Dynamic Parameter when DiagnosticTarget is used.
DynamicParam {
    # Check if DiagnosticTarget is not empty.
    If ($DiagnosticTarget -ne $null) {

        $Attributes = New-Object -TypeName System.Management.Automation.ParameterAttribute
        $Attributes.Position = 2
        $Attributes.Mandatory = $True
        $Attributes.HelpMessage = $local.STARTSCAN_HELP_DIAGNOSTIC_PASSWORD
        $AttributeCollection = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]'
        $AttributeCollection.Add($Attributes)

        $DynamicParamater = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter('DiagnosticPassword', [String], $AttributeCollection)

        $DynamicParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $DynamicParameterDictionary.Add('DiagnosticPassword', $DynamicParamater)
        return $DynamicParameterDictionary
    } # End of DiagnosticTarget check.
} # End of Dynamic Parameter.

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)
    
    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Check if DiagnosticTarget Parameter is used.
    If ($DiagnosticTarget) {
        # List Linux/Windows Default Access Ports in an array.
        [Array]$KnownPorts = @(22,139,445)

        # Create a new hashtable for the statuses of the ports.
        $StatusHashTable = @{}

        # Check if targets are accessible. Store statuses into previously created hashtable.
        ForEach ($Port in $KnownPorts) {
            If ($TCPTest = Test-NetConnection -ComputerName $DiagnosticTarget -Port $Port -WarningAction SilentlyContinue) {
                $StatusHashTable += @{ $Port = $TCPTest.TcpTestSucceeded }
            } # End of Target connectivity test.
        } # End of Port Scan loop.

        # Show an Error, if not and exit.
        If ($StatusHashTable.Values -notcontains $True) {
            Write-SCError -Message $($local.STARTSCAN_ERROR_TARGET_OFFLINE -f $DiagnosticTarget) -RecommendedAction $local.STARTSCAN_ERROR_TARGET_OFFLINE_FIX
        } # Connectivity: False.
        Else {
            # Create Diagnostic Target JSON structure.
            Write-SCLog $local.LOG_JSON_QUERY

            $JSONBody = '{
                "diagnosticTarget"   : "' + $DiagnosticTarget + '",
                "diagnosticPassword" : "' + $DiagnosticPassword + '"
            }'
        } # Connectivity: True. End of Target connectivity test.
    } # End of DiagnosticTarget check.

    # Start the Scan.
    $Method = 'POST'
    $URI    = "$Server/scan/$ID/launch"
    Write-SCLog -LogInfo $($local.STARTSCAN_LOG_SET_DATA -f $Method, $URI)

    # Check if DiagnosticTarget Parameter is used.
    If ($DiagnosticTarget) {
        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'
        Write-SCLog -LogInfo $($local.STARTSCAN_LOG_DIAGNOSTIC_DATA -f $DiagnosticTarget, $ID)
    } # DiagnosticTarget: True.
    Else {
        # Regular Scan start.
        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'
        Write-SCLog -LogInfo $($local.STARTSCAN_LOG_DATA -f $ID)
    } # DiagnosticTarget: True. End of DiagnosticTarget check.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Start-SCScan.

Function Get-SCScanners {
<#
.SYNOPSIS
Get Scanners List.
.DESCRIPTION
List connected Scanners.
.EXAMPLE
Default view, with no filtration:
Get-SCScanners
.EXAMPLE
Get a specific Scanner: (ID shows the most detailed information about a Scanner.)
Get-SCScanners -ID 23
.EXAMPLE
List Scanners with az1 in their name:
Get-SCScanners -Name az1
.EXAMPLE
List Enabled Scanners. (Choose false, to show not Enabled Scanners)
Get-SCScanners -Enabled true
.EXAMPLE
List Agent Capable Scanners. (Choose false, to show not Agent Capable Scanners)
Get-SCScanners -AgentCapable true
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
Get-SCScanners -AgentCapable true -NoFormat
.EXAMPLE
Show Credentials in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCScanners -RAW
.PARAMETER ID
Filter Output by ID.
.PARAMETER Name
Filter Output by Name.
.PARAMETER Enabled
Filter Output by Enabled Scanners.
.PARAMETER AgentCapable
Filter Output by Agent Capable Scanners.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Scanners Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETSCANNERS_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANNERS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANNERS_HELP_ENABLED })]
    [ValidateSet('false','true')]
    [String]$Enabled,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETSCANNERS_HELP_AGENT_CAPABLE })]
    [ValidateSet('false','true')]
    [String]$AgentCapable,
    [Parameter(Position = 9, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)
    
    # Connect to Tenable.sc.
    $User         = 'admin'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get License Data.
    $Method = 'GET'
    $URI    = "$Server/scanner?fields=id,name,description,status,ip,port,enabled,authType,username,agentCapable,version,numScans,numHosts,numSessions,numTCPSessions,loadAvg,uptime,zones"
    Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_GET_DATA -f $Method, $URI)

    $Scanners = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Enabled -and $Name) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_ENABLED_NAME -f $Enabled, $Name)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.enabled -eq $Enabled -and $PSItem.name -like "*$Name*" }
    }
    ElseIf ($AgentCapable -and $Enabled) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_AGENT_CAPABLE_ENABLED -f $AgentCapable, $Enabled)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.agentCapable -eq $AgentCapable -and $PSItem.enabled -eq $Enabled }
    }
    ElseIf ($AgentCapable) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_AGENT_CAPABLE -f $AgentCapable)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.agentCapable -eq $AgentCapable }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_NAME -f $Name)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_ID -f $ID)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($Enabled) {
        Write-SCLog -LogInfo $($local.GETSCANNERS_LOG_ENABLED -f $Enabled)
        $OutputHolder = $Scanners.response | Where-Object { $PSItem.enabled -eq $Enabled }
    }
    Else {
        $OutputHolder = $Scanners.response
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETSCANNERS_TBL_ID;               Expression = { $PSItem.id }},
            @{ Name = $local.GETSCANNERS_TBL_NAME;             Expression = { $PSItem.name }},
            @{ Name = $local.GETSCANNERS_TBL_DESCRIPTION;      Expression = { $PSItem.description }},
            @{ Name = $local.GETSCANNERS_TBL_STATUS;           Expression = {
                # Check if scanner is running.
                If ($PSItem.status -eq 1) {
                    Write-Output -InputObject $local.LOG_OK
                } # Scanner: OK.
                Else {
                    Write-Output -InputObject $local.GETSCANNERS_LOG_NOT_RUNNING
                } # Scanner: Stopped.
            }},
            @{ Name = $local.GETSCANNERS_TBL_IP;               Expression = { $PSItem.ip }},
            @{ Name = $local.GETSCANNERS_TBL_PORT;             Expression = { $PSItem.port }},
            @{ Name = $local.GETSCANNERS_TBL_ENABLED;          Expression = { $Culture.ToTitleCase($PSItem.enabled) }},
            @{ Name = $local.GETSCANNERS_TBL_AUTH_TYPE;        Expression = { $PSItem.authType }},
            @{ Name = $local.GETSCANNERS_TBL_USERNAME;         Expression = { $PSItem.username }},
            @{ Name = $local.GETSCANNERS_TBL_AGENT_CAPABLE;    Expression = { $Culture.ToTitleCase($PSItem.agentCapable) }},
            @{ Name = $local.GETSCANNERS_TBL_AVERAGE_LOAD;     Expression = { $PSItem.loadAvg }},
            @{ Name = $local.GETSCANNERS_TBL_VERSION;          Expression = { $PSItem.version }},
            @{ Name = $local.GETSCANNERS_TBL_NUM_SCANS;        Expression = { $PSItem.numScans }},
            @{ Name = $local.GETSCANNERS_TBL_NUM_HOSTS;        Expression = { $PSItem.numHosts }},
            @{ Name = $local.GETSCANNERS_TBL_NUM_SESSIONS;     Expression = { $PSItem.numSessions }},
            @{ Name = $local.GETSCANNERS_TBL_NUM_TCP_SESSIONS; Expression = { $PSItem.numTCPSessions }},
            @{ Name = $local.GETSCANNERS_TBL_UPTIME;           Expression = {
                # Generate correct uptime format, depending on the uptime value.
                If ((New-TimeSpan -Seconds $PSItem.uptime).Days -ge 1) {
                    "$((New-TimeSpan -Seconds $PSItem.uptime).Days) $($local.INFO_TIME_DAYS)"
                } # Uptime in days.
                Else {
                    If ((New-TimeSpan -Seconds $PSItem.uptime).Hours -ge 1) {
                        "$((New-TimeSpan -Seconds $PSItem.uptime).Hours) $($local.INFO_TIME_HOURS)"
                    } # Uptime in hours.
                    Else {
                        If ((New-TimeSpan -Seconds $PSItem.uptime).Minutes -ge 1) {
                            "$((New-TimeSpan -Seconds $PSItem.uptime).Minutes) $($local.INFO_TIME_MINUTES)"
                        } # Uptime in minutes.
                        Else {
                            "$($PSItem.uptime) $($local.INFO_TIME_SECONDS)"
                        } # Uptime in seconds.
                    } # End of less than hours check.
                } # End of less than days check.
            }},
            @{ Name = $local.GETSCANNERS_TBL_ZONES;            Expression = { $PSItem.zones.name }}
    }
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETSCANNERS_TBL_ID;             Expression = { $PSItem.id }},
            @{ Name = $local.GETSCANNERS_TBL_NAME;           Expression = { $PSItem.name }},
            @{ Name = $local.GETSCANNERS_TBL_DESCRIPTION;    Expression = { $PSItem.description }},
            @{ Name = $local.GETSCANNERS_TBL_STATUS;         Expression = {
                # Check if scanner is running.
                If ($PSItem.status -eq 1) {
                    Write-Output -InputObject $local.LOG_OK
                } # Scanner: OK.
                Else {
                    Write-Output -InputObject $local.GETSCANNERS_LOG_NOT_RUNNING
                } # Scanner: Stopped.
            }},
            @{ Name = $local.GETSCANNERS_TBL_IP;             Expression = { $PSItem.ip }},
            @{ Name = $local.GETSCANNERS_TBL_PORT;           Expression = { $PSItem.port }},
            @{ Name = $local.GETSCANNERS_TBL_ENABLED;        Expression = { $Culture.ToTitleCase($PSItem.enabled) }},
            @{ Name = $local.GETSCANNERS_TBL_AGENT_CAPABLE;  Expression = { $Culture.ToTitleCase($PSItem.agentCapable) }},
            @{ Name = $local.GETSCANNERS_TBL_AVERAGE_LOAD;   Expression = { $PSItem.loadAvg }},
            @{ Name = $local.GETSCANNERS_TBL_VERSION;        Expression = { $PSItem.version }},
            @{ Name = $local.GETSCANNERS_TBL_UPTIME;         Expression = { $PSItem.uptime }}
    }

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Scanners list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCScanners.

Function Remove-SCReport {
<#
.SYNOPSIS
Delete Report(s).
.DESCRIPTION
Delete selected Report(s).
.EXAMPLE
Delete a Report.
Remove-SCReport -ID 5829
.EXAMPLE
Delete an array of Reports.
Remove-SCReport -ID 5829, 5830, 5866
.EXAMPLE
Remove Report(s) by taking input from Get-SCReport pipeline.
This example deletes all reports from the user john that have sharepoint in their names.
Get-SCReports -Owner john -Name sharepoint | Remove-SCReport
.PARAMETER ID
Specifiy ID(s) of the Report(s).
.FUNCTIONALITY
Deletes Specified Reports.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.REMOVEREPORT_HELP_ID }, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Int[]]$ID
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''

    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)

    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)
}
Process {
    # Iterate through provided Report IDs.
    ForEach ($Item in $ID) {
        $Method = 'DELETE'
        $URI    = "$Server/report/$Item"
        Write-SCLog -LogInfo $($local.REMOVEREPORT_LOG_SET_DATA -f $Method, $URI)

        # Expect y (yes), enq (exit, no, quit respectively) inputs.
        While (!(Read-Host -Prompt $($local.REMOVEREPORT_INFO_CONFIRMATION -f $Item) -OutVariable UserInput) -notmatch '^e|n|q|y$') {
            Switch -Regex ($UserInput) {
                "^y$" {
                    Try {
                        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'
                        Write-Output $($local.REMOVEREPORT_INFO_REPORT_DELETED -f $Item)
                    } # Result: Success.
                    Catch {
                        Write-SCError -Message $PSItem.Exception.Message -RecommendedAction $local.REMOVEREPORT_ERROR_FIX
                    } # Result: Fail.
                    return
                } # End of agreement.
                "^e|n|q|y$" {
                    Write-Output -InputObject $($local.REMOVEREPORT_INFO_DELETION_CANCEL -f $Item)
                    return
                } # End of disagreement.
                Default {
                    Write-Output -InputObject $local.INFO_ACCEPTED_INPUTS
                } # Input was invalid. Loop.
            } # End of Input Switch.
        } # End of While Prompt.
    } # End of Report ID loop.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Remove-SCReport.

Function Get-SCAuditFiles {
<#
.SYNOPSIS
Get Audit File List.
.DESCRIPTION
List Audit Files.
.EXAMPLE
Default view, with no filtration:
Get-SCAuditFiles
.EXAMPLE
List Audit Files with windows in their name:
Get-SCAuditFiles -Name windows
.EXAMPLE
List Audit Files with windows Type.
Get-SCAuditFiles -Type windows
.EXAMPLE
List Audit Files with bK5ruK in its filename.
Get-SCAuditFiles -FileName bK5ruK
.EXAMPLE
Get Audit Files with sim in their Owner first or last names.
Get-SCAuditFiles -Owner sim
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCAuditFiles -Owner sim -NoFormat
.EXAMPLE
Show Credentials in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCAuditFiles -RAW
.PARAMETER Name
Filter Output by Name.
.PARAMETER Type
Filter Output by Type.
.PARAMETER FileName
Filter Output by Audit File Name.
.PARAMETER Owner
Filter Output by Owner.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Audit File Listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETAUDITFILE_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETAUDITFILE_HELP_TYPE })]
    [ValidateSet('brocade','cisco','database','filecontent','fortigate','netapp_api','unix','vmware','windows')]
    [String]$Type,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETAUDITFILE_HELP_FILENAME })]
    [String]$FileName,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETAUDITFILE_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Audit Files Data.
    $Method = 'GET'
    $URI    = "$Server/auditFile?fields=id,name,type,originalFilename,createdTime,modifiedTime,auditFileTemplate,owner,filename"
    Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_GET_DATA -f $Method, $URI)
    $AuditFiles = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Name -and $Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_NAME_OWNER_TYPE -f $Name, $Owner, $Type)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($Name -and $Owner) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_NAME_OWNER -f $Name, $Owner)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($Name -and $Type) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_NAME_TYPE -f $Name, $Type)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_OWNER_TYPE -f $Owner, $Type)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_NAME -f $Name)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($Type) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_TYPE -f $Type)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.type -eq "*$Type*" }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETAUDITFILE_LOG_OWNER -f $Owner)
        $OutputHolder = $AuditFiles.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*"}
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $AuditFiles.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $AuditFiles.response.usable | Select-Object -Property `
            @{ Name = $local.GETAUDITFILE_TBL_ID;               Expression = { $PSItem.id }},
            @{ Name = $local.GETAUDITFILE_TBL_NAME;             Expression = { $PSItem.name }},
            @{ Name = $local.GETAUDITFILE_TBL_TYPE;             Expression = { $PSItem.type }},
            @{ Name = $local.GETAUDITFILE_TBL_ORIGINALFILENAME; Expression = { $PSItem.originalFilename }},
            @{ Name = $local.GETAUDITFILE_TBL_FILENAME;         Expression = { $PSItem.Filename }},
            @{ Name = $local.GETAUDITFILE_TBL_TIME_CREATED;     Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
            @{ Name = $local.GETAUDITFILE_TBL_TIME_MODIFIED;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
            @{ Name = $local.GETAUDITFILE_TBL_TEMPLATE;         Expression = {
                # Check if Audit File was done using a Template.
                If ($PSItem.auditFiletemplate.id -ne '-1') {
                    $PSItem.auditFiletemplate.name
                } # End of Audit File Template check.
            }},
            @{ Name = $local.GETAUDITFILE_TBL_OWNER;            Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }}
    }
    Else {
        $OutputTable = $AuditFiles.response.usable | Select-Object -Property `
            @{ Name = $local.GETAUDITFILE_TBL_ID;               Expression = { $PSItem.id }},
            @{ Name = $local.GETAUDITFILE_TBL_NAME;             Expression = { $PSItem.name }},
            @{ Name = $local.GETAUDITFILE_TBL_TYPE;             Expression = { $PSItem.type }},
            @{ Name = $local.GETAUDITFILE_TBL_ORIGINALFILENAME; Expression = { $PSItem.originalFilename }},
            @{ Name = $local.GETAUDITFILE_TBL_FILENAME;         Expression = { $PSItem.Filename }},
            @{ Name = $local.GETAUDITFILE_TBL_TIME_CREATED;     Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
            @{ Name = $local.GETAUDITFILE_TBL_TIME_MODIFIED;    Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
            @{ Name = $local.GETAUDITFILE_TBL_TEMPLATE;         Expression = {
                # Check if Audit File was done using a Template.
                If ($PSItem.auditFiletemplate.id -ne '-1') {
                    $PSItem.auditFiletemplate.name
                } # End of Audit File Template check.
            }},
            @{ Name = $local.GETAUDITFILE_TBL_OWNER;            Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }}
    }

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Audit Files')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCAuditFiles.

Function Get-SCReportDefinitions {
<#
.SYNOPSIS
Get Report Definitions List.
.DESCRIPTION
Shows Report Definitions listing.
.EXAMPLE
Filter Report Definitions by Name.
Get-SCReportDefinitions -Name Summary
.EXAMPLE
Filter Report Definitions by Type.
Get-SCReportDefinitions -Type csv
.EXAMPLE
Filter Report Definitions by Owner.
Get-SCReportDefinitions -Owner name
.EXAMPLE
Filter Report Definition by ID. ID shows some additional fields.
Get-SCReportDefinitions -ID 3894
.EXAMPLE
Show data as customized structure, but not formatted as Table. This way the data is still presented nicely, but will be shown as a list, which will not be desired output with larger results.
This Parameter is necessary, if you want to pass the output to a pipeline, or if you want to export the data. By default, in this module, all the output is formatted as Table.
Get-SCReportDefinitions -Owner name -NoFormat
.EXAMPLE
Show Credentials in an unformatted, less readable format. Use this if you want the output to look the way you want it, as you cannot format an output that has been already formatted.
This is also necessary if you want to export the output.
Get-SCReportDefinitions -RAW
.PARAMETER Name
Filter Output by Name.
.PARAMETER Type
Filter Output by Type.
.PARAMETER Owner
Filter Output by Owner.
.PARAMETER ID
Filter Output by ID.
.PARAMETER NoFormat
Allow data to be customized, but don't format the output as Table.
.PARAMETER RAW
Show unformatted Output.
.FUNCTIONALITY
Shows Report Definitions listing.
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param(
    [Parameter(Position = 0, Mandatory = $False, ParameterSetName = 'ID', HelpMessage = { $local.GETREPORTDEFINITIONS_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTDEFINITIONS_HELP_NAME })]
    [String]$Name,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTDEFINITIONS_HELP_TYPE })]
    [ValidateSet('csv','pdf')]
    [String]$Type,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETREPORTDEFINITIONS_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 5, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
    # Show running cmdlet in PS Window Title.
    [Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Get Assets Data.
    $Method = 'GET'
    $URI    = "$Server/reportDefinition?fields=id,name,type,components,creator,owner"
    Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_GET_DATA -f $Method, $URI)
    $ReportDefinitions = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

    # Generate Output, depending on provided input.
    #region Conditions
    If ($Name -and $Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_NAME_OWNER_TYPE -f $Name, $Owner, $Type)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }

    ElseIf ($Name -and $Owner) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_NAME_OWNER -f $Name, $Owner)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") }
    }
    ElseIf ($Name -and $Type) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_NAME_TYPE -f $Name, $Type)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.name -like "*$Name*" -and $PSItem.type -eq $Type }
    }
    ElseIf ($Owner -and $Type) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_OWNER_TYPE -f $Owner, $Type)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.type -eq $Type }
    }
    ElseIf ($Name) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_NAME -f $Name)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.name -like "*$Name*" }
    }
    ElseIf ($Type) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_TYPE -f $Type)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.type -eq $Type }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_OWNER -f $Owner)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETREPORTDEFINITIONS_LOG_ID -f $ID)
        $OutputHolder = $ReportDefinitions.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEAFULT
        $OutputHolder = $ReportDefinitions.response.usable
    }
    #endregion Conditions

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_ID;      Expression = { $PSItem.id }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_NAME;    Expression = { $PSItem.name }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_TYPE;    Expression = { $PSItem.type }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_CREATOR; Expression = { "$($PSItem.creator.firstname) $($PSItem.creator.lastname)/$($PSItem.creator.username)" }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_OWNER; Expression = { 
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.owner.firstname -eq '' -and $PSItem.owner.lastname -eq '') {
                    $PSItem.owner.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.owner.firstname -eq '') {
                    "$($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.owner.lastname -eq '') {
                    "$($PSItem.owner.firstname)/$($PSItem.owner.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of user names check.
            }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_COLUMNS; Expression = {
                # Check if Report Definition Type is PDF.
                If ($PSItem.type -eq 'pdf') {
                    Write-Output -InputObject $local.GETREPORTDEFINITIONS_INFO_NA_FOR_PDF
                } # Report Definition Type: PDF.
                Else {
                    $PSItem.components.columns
                } # Report Definition Type: Not PDF. End of Report Definition Type check.
            }}
    } # ID: True.
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_ID;    Expression = { $PSItem.id }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_NAME;  Expression = { $PSItem.name }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_TYPE;  Expression = { $PSItem.type }},
            @{ Name = $local.GETREPORTDEFINITIONS_TBL_OWNER; Expression = { 
                # Checking if user has no first- and last name specified, show only username.
                If ($PSItem.owner.firstname -eq '' -and $PSItem.owner.lastname -eq '') {
                    $PSItem.owner.username
                } # End of first and last name check.
                # Checking if user is missing first name, show only last name and username.
                ElseIf ($PSItem.owner.firstname -eq '') {
                    "$($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of first name check.
                # Checking if user is missing last name, show only first name and username.
                ElseIf ($PSItem.owner.lastname -eq '') {
                    "$($PSItem.owner.firstname)/$($PSItem.owner.username)"
                } # End of last name check.
                # Show full name with username.
                Else {
                    "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)"
                } # End of user names check.
            }}
    } # Default View.

    Write-SCLog -LogInfo $($local.LOG_OUTPUT_DATA -f 'Report Definition list')

    # Checking for output options.
    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        Write-Output -InputObject $OutputTable

        # Check if NoFormat Parameter was used, show total count, if yes.
        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        } # End of NoFormat Check.
    } # Output: ID or NoFormat.
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        Write-Output -InputObject $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    } # Output: RAW.
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        Write-Output -InputObject $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    } # Default View. End of ID, NoFormat, RAW parameters checks.
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Get-SCReportDefinitions.

Function Remove-SCScan {
<#
.SYNOPSIS
Remove a Scan.
.DESCRIPTION
Remove specified Scan.
.EXAMPLE
Remove a Scan with an ID of 1162.
Remove-SCScan -ID 1162
.EXAMPLE
Remove Scans from pipe.
Get-SCScan -Owner user -Type dnsname -Tag temp | Remove-SCAsset
.PARAMETER ID
ID of an Asset.
.NOTES
Each removal will ask confirmation.
.FUNCTIONALITY
Removes Assets from Tenable.SC.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.REMOVESCAN_HELP_ID }, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [Int[]]$ID
)

Begin {
	# Show running cmdlet in PS Window Title.
	[Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
}
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Iterate through provided Scan IDs.
    ForEach ($Item in $ID) {
        $Method = 'DELETE'
        $URI    = "$Server/scan/$ID"
        Write-SCLog -LogInfo $($local.REMOVESCAN_LOG_SET_DATA -f $Method, $URI)

        # Expect y (yes), enq (exit, no, quit respectively) inputs.
        While (!($UserInput = Read-Host -Prompt $($local.REMOVESCAN_INFO_CONFIRMATION -f $Item)) -notmatch '^e|n|q|y$') {
            Switch -Regex ($UserInput) {
                "^y$" {
                    Try {
                        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'
                        Write-Output $($local.REMOVESCAN_INFO_SCAN_DELETED -f $Item)
                    } # Result: Success.
                    Catch {
                        Write-SCError -Message $PSItem.Exception.Message -RecommendedAction $local.REMOVESCAN_ERROR_FIX
                    } # Result: Fail.
                    return
                } # End of agreement.
                "^n|e|q$" {
                    Write-Output -InputObject $($local.REMOVESCAN_INFO_DELETION_CANCEL -f $Item)
                    return
                } # End of disagreement.
                Default {
                    Write-Output -InputObject $local.INFO_ACCEPTED_INPUTS
                } # Input was invalid. Loop.
            } # End of Input Switch.
        } # End of While Prompt.
    } # End of Scan ID loop.
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Remove-SCScan.

Function Stop-SCScan {
<#
.SYNOPSIS
Stop a Scan.
.DESCRIPTION
Stop a running Scan.
.EXAMPLE
Stop a Scan from pipeline.
Get-SCScans -ID 635 | Stop-SCScan
.EXAMPLE
Stop a Scan using an ID.
Stop-SCScan -ID 635
.PARAMETER ID
ID of a Scan, which will be stopped.
.FUNCTIONALITY
Stop a Scan.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.STOPSCAN_HELP_ID }, ValueFromPipelineByPropertyName)]
    [Int[]]$ID
)

Begin {
	# Show running cmdlet in PS Window Title.
	[Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)
} # End of Begin.
Process {
    ForEach ($Item in $ID) {
        $Method = 'POST'
        $URI    = "$Server/scanResult/$Item/stop"
        Write-SCLog -LogInfo $($local.STOPSCAN_LOG_SET_DATA -f $Method, $URI)

        Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

        Write-SCLog -LogInfo $($local.STOPSCAN_LOG_DATA -f $Item)
    } # End of Scan ID loop.
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Stop-SCScan.

Function Get-SCAnalysis {
<#
INCOMPLETE
#>
[CmdletBinding()]
Param ()

$User         = 'testuser'
$PasswordFile = ''
$KeyFile      = ''
Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

# Show Current User and context.
Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

$JSONBody = '{
    "type"       : "vuln",
    "sourceType" : "cumulative"
}'

$Method = 'POST'
$URI    = "$Server/analysis"
Write-SCLog -LogInfo $($local.GETANALYSIS_LOG_GET_DATA -f $Method, $URI)

# Update Scan.
Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

} # End of Function Get-SCAnalysis.

Function Get-SCQuery {
<#
INCOMPLETE
#>
[CmdletBinding(DefaultParameterSetName = 'Default')]
Param (
    [Parameter(Position = 0, Mandatory = $False, HelpMessage = { $local.GETQUERY_HELP_ID })]
    [Int]$ID,
    [Parameter(Position = 1, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETQUERY_HELP_OWNER })]
    [String]$Owner,
    [Parameter(Position = 2, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.GETQUERY_HELP_TAG })]
    [String]$Tag,
    [Parameter(Position = 3, Mandatory = $False, ParameterSetName = 'Default', HelpMessage = { $local.HELP_NO_FORMAT })]
    [Switch]$NoFormat,
    [Parameter(Position = 4, Mandatory = $False, ParameterSetName = 'RAW', HelpMessage = { $local.HELP_RAW_OUTPUT })]
    [Switch]$RAW
)

Begin {
	# Show running cmdlet in PS Window Title.
	[Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    $Method = 'GET'
    $URI    = "$Server/query?fields=createdTime,description,filters,id,modifiedTime,name,owner,tags,tool,type"
    Write-SCLog -LogInfo $($local.GETQUERY_LOG_GET_DATA -f $Method, $URI)

    # Update Scan.
    $Queries = Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -ContentType 'application/json'

}
Process {
    # Generate Output, depending on provided input.
    #region Conditions
    If ($Owner -and $Tag) {
        Write-SCLog -LogInfo $($local.GETQUERY_LOG_OWNER_TAG -f $Owner, $Tag)
        $OutputHolder = $Queries.response.usable | Where-Object { ($PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*") -and $PSItem.tags -like "*$Tag*" }
    }
    ElseIf ($ID) {
        Write-SCLog -LogInfo $($local.GETQUERY_LOG_ID -f $ID)
        $OutputHolder = $Queries.response.usable | Where-Object { $PSItem.id -eq $ID }
    }
    ElseIf ($Owner) {
        Write-SCLog -LogInfo $($local.GETQUERY_LOG_OWNER -f $Owner)
        $OutputHolder = $Queries.response.usable | Where-Object { $PSItem.owner.firstname -like "*$Owner*" -or $PSItem.owner.lastname -like "*$Owner*" -or $PSItem.owner.username -like "*$Owner*" }
    }
    ElseIf ($Tag) {
        Write-SCLog -LogInfo $($local.GETQUERY_LOG_TAG -f $Tag)
        $OutputHolder = $Queries.response.usable | Where-Object { $PSItem.tags -like "*$Tag*" }
    }
    Else {
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputHolder = $Queries.response.usable
    }
    #endregion Conditions

    # Available Query types.
    $Script:QueryTypes = @{
        'alert'  = 'Alert';
        'all'    = 'All';
        'lce'    = 'LCE (Log Correlation Engine)';
        'mobile' = 'Mobile';
        'ticket' = 'Ticket';
        'user'   = 'User';
        'vuln'   = 'Vulnerability'
    }

    # Query tools used in Vulnerability Analsysis.
    $Script:QueryTools = @{
        'iplist'                = 'IP List';
        'listmailclients'       = 'List Mail Clients';
        'listos'                = 'List OS';
        'listservices'          = 'List Services';
        'listsoftware'          = 'List Software';
        'listsshservers'        = 'List SSH Servers';
        'listvuln'              = 'Vulnerability List';
        'listwebclients'        = 'List Web Clients';
        'listwebservers'        = 'List Web Servers';
        'sumasset'              = 'Asset Summary';
        'sumcce'                = 'CCE Summary';
        'sumclassa'             = 'Class A Summary';
        'sumclassb'             = 'Class B Summary';
        'sumclassc'             = 'Class C Summary';
        'sumcve'                = 'CVE Summary';
        'sumfamily'             = 'Plugin Family Summary';
        'sumdnsname'            = 'DNS Name Summary';
        'sumiavm'               = 'IAVM Summary';
        'sumid'                 = 'ID Summary';
        'sumip'                 = 'IP Summary';
        'summsbulletin'         = 'MS Bulletin Summary';
        'sumport'               = 'Port Summary';
        'sumprotocol'           = 'Protocol Summary';
        'sumremediation'        = 'Remedation Summary';
        'sumseverity'           = 'Severity Summary';
        'sumuserresponsibility' = 'User Responsibility Summary';
        'vulndetails'           = 'Vulnerability Details';
        'vulnipdetail'          = 'Vulnerability Detail List';
        'vulnipsummary'         = 'Vulnerability Summary'
    }

    # Store Output table into variable.
    If ($ID) {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETQUERY_TBL_ID;             Expression = { $PSItem.id }},
            @{ Name = $local.GETQUERY_TBL_NAME;           Expression = { $PSItem.name }},
            @{ Name = $local.GETQUERY_TBL_TAG;            Expression = { $PSItem.tags }},
            @{ Name = $local.GETQUERY_TBL_OWNER;          Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
            @{ Name = $local.GETQUERY_TBL_TYPE;           Expression = { $QueryTypes[$PSItem.type] }},
            @{ Name = $local.GETQUERY_TBL_TOOL;           Expression = { $QueryTools[$PSItem.tool] }},
            @{ Name = $local.GETQUERY_TBL_CREATED_TIME;   Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
            @{ Name = $local.GETQUERY_TBL_MODIEFIED_TIME; Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
            @{ Name = $local.GETQUERY_TBL_FILTERS;        Expression = {
                $FiltersArray = ForEach ($Item in $PSItem.filters) {
                    "$($Item.filterName) $($Item.operator) $(If ($Item.value.id) {
                            '"[' + $($Item.value.id) + ']' + $($Item.value.name) + '"'
                        }
                        Else {
                            '"' + $($Item.value) + '"'
                        }
                    )"
                }

                If ($FiltersArray.GetType().FullName -eq 'System.String') {
                    $FiltersArray
                }
                Else {
                    $FiltersArray[0..$($FiltersArray.Length)] -join "`n"
                }
            }}
    }
    Else {
        $OutputTable = $OutputHolder | Select-Object -Property `
            @{ Name = $local.GETQUERY_TBL_ID;             Expression = { $PSItem.id }},
            @{ Name = $local.GETQUERY_TBL_NAME;           Expression = { $PSItem.name }},
            @{ Name = $local.GETQUERY_TBL_TAG;            Expression = { $PSItem.tags }},
            @{ Name = $local.GETQUERY_TBL_OWNER;          Expression = { "$($PSItem.owner.firstname) $($PSItem.owner.lastname)/$($PSItem.owner.username)" }},
            @{ Name = $local.GETQUERY_TBL_TYPE;           Expression = { $QueryTypes[$PSItem.type] }},
            @{ Name = $local.GETQUERY_TBL_TOOL;           Expression = { $QueryTools[$PSItem.tool] }},
            @{ Name = $local.GETQUERY_TBL_CREATED_TIME;   Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.createdTime }},
            @{ Name = $local.GETQUERY_TBL_MODIEFIED_TIME; Expression = { ConvertFrom-EpochToNormal -InputEpoch $PSItem.modifiedTime }},
            @{ Name = $local.GETQUERY_TBL_FILTERS;        Expression = {
                ForEach ($Item in $PSItem.filters) {
                    "$($Item.filterName) $($Item.operator) $(If ($Item.value.id) {
                            '"[' + $($Item.value.id) + ']' + $($Item.value.name) + '"'
                        }
                        Else {
                            '"' + $($Item.value) + '"'
                        }
                    )"
                }

                #$FiltersArray[0..$($FiltersArray.Length)] -join ";"
            }}
    }

    If ($ID -or $NoFormat) {
        # Output customized table in default, unformatted View.
        Write-SCLog -LogInfo $local.LOG_NO_FILTER
        $OutputTable

        If ($NoFormat) {
            # Show Total Entries.
            Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
        }
    }
    ElseIf ($RAW) {
        # RAW switch was used, output will be unformatted.
        Write-SCLog -LogInfo $local.LOG_RAW_OUTPUT
        $OutputHolder

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputHolder).Count)
    }
    Else {
        # Output formatted Table.
        Write-SCLog -LogInfo $local.LOG_DEFAULT
        $OutputTable | Format-Table -AutoSize

        # Show Total Entries.
        Write-Output -InputObject $($local.LOG_COUNT_OUTPUT -f ($OutputTable).Count)
    }

}
End {
    # Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
}

} # End of Function Get-SCQuery.

Function Copy-SCScan {
<#
.SYNOPSIS
Copy Scan to another user.
.DESCRIPTION
Copies existing Scan to a specified user.
.EXAMPLE
Copy Scan with and ID of 1139 to a user with an ID of 10.
Copy-SCScan -ExistingScanID 1139 -TargetUserID 10
.EXAMPLE
Same as above, but using other cmdlets from the module this time.
Copy-SCScan -ExistingScanID (Get-SCScans -Name test-dblan -PolicyName workstations -Owner bc8164 -NoFormat).id -TargetUserID (Get-SCUsers -Name testuser -NoFormat).id
.EXAMPLE
Change the copied Scan's name.
If this Parameter is not used, the Scan's name will be taken from existing Scan and '-copy' will be appended to the copied Scan's name.
Copy-SCScan -ExistingScanID 1139 -TargetUserID 10 -NewScanName 'test-dblan-new-scan-va'
.PARAMETER ExistingScanID
Specify the Scan ID of which you want to copy.
.PARAMETER TargetUserID
Specify the User ID to whom the Scan will be copied to.
.PARAMETER NewScanName
Specify a new name for the copied Scan.
.FUNCTIONALITY
Copies Scans to other users in Tenable.sc.
#>
[CmdletBinding()]
Param (
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.COPYSCAN_HELP_EXISTING_SCAN_ID }, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Int]$ExistingScanID,
    [Parameter(Position = 1, Mandatory = $True, HelpMessage = { $local.COPYSCAN_HELP_TARGET_USER_ID })]
    [Int]$TargetUserID,
    [Parameter(Position = 2, Mandatory = $False, HelpMessage = { $local.COPYSCAN_HELP_NAME })]
    [String]$NewScanName
)

Begin {
	# Show running cmdlet in PS Window Title.
	[Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'BC8164'
    $PasswordFile = 'C:\Users\BC8164\Documents\rPass.pwd'
    $KeyFile      = 'C:\Users\BC8164\Documents\rPass.key'
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), 'Copy-SCScan')

    # Check NewScanName Parameter was used. No point querying the old Scan, if yes.
    If (!$NewScanName) {
        # Get the existing scans info for later use.
        Get-SCScans -ID $ExistingScanID -NoFormat -OutVariable ExistingScan | Out-Null
    } # End of NewScanName Parameter check.

    # Build JSON query.
    ## If NewScanName Parameter is not used, old name will be used from $ExistingScan and -copy will be appended to the name.
    $JSONBody = '{
        "name"       : ' + $(If ($NewScanName) {
                '"' + $NewScanName + '"'
            }
            Else {
                '"' + $($ExistingScan.name) + '-copy"'
            })+',
        "targetUser" : {
            "id" : ' + $TargetUserID + '
        }
    }'

    $Method = 'POST'
    $URI    = "$Server/scan/$ExistingScanID/copy"
    Write-SCLog -LogInfo $($local.COPYSCAN_LOG_SET_DATA -f $Method, $URI)

    # Copy Scan.
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Copy-SCScan.

Function Suspend-SCScan {
<#
.SYNOPSIS
Suspend a Scan.
.DESCRIPTION
Suspend a running Scan.
.EXAMPLE
Suspend a Scan from pipeline.
Get-SCScans -ID 635 | Suspend-SCScan
.EXAMPLE
Suspend a Scan using an ID.
Suspend-SCScan -ID 635
.PARAMETER ID
ID of a Scan, which will be suspended.
.FUNCTIONALITY
Suspend a Scan.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.SUSPENDSCAN_HELP_ID }, ValueFromPipelineByPropertyName)]
    [Int]$ID
)

Begin {
	# Show running cmdlet in PS Window Title.
	[Console]::Title = $($local.INFO_TITLE_RUNNING_CMDLET -f $MyInvocation.MyCommand)

    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process {
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), $MyInvocation.MyCommand)

    # Create New Asset.
    $Method = 'POST'
    $URI    = "$Server/scanResult/$ID/pause"
    Write-SCLog -LogInfo $($local.SUSPENDSCAN_LOG_SET_DATA -f $Method, $URI)
    
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

    Write-SCLog -LogInfo $($local.SUSPENDSCAN_LOG_DATA -f $ID)
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Suspend-SCScan.

Function Resume-SCScan {
<#
.SYNOPSIS
Resume a Scan.
.DESCRIPTION
Resume a suspended Scan.
.EXAMPLE
Resume a Scan from pipeline.
Get-SCScans -ID 635 | Resume-SCScan
.EXAMPLE
REsume a Scan using an ID.
Resume-SCScan -ID 635
.PARAMETER ID
ID of a Scan, which will be resumed.
.FUNCTIONALITY
Resume a Scan.
#>
[CmdletBinding()]
Param(
    [Parameter(Position = 0, Mandatory = $True, HelpMessage = { $local.RESUMESCAN_HELP_ID }, ValueFromPipelineByPropertyName)]
    [Int]$ID
)

Begin {
    # Connect to Tenable.sc.
    $User         = 'testuser'
    $PasswordFile = ''
    $KeyFile      = ''
    Write-SCLog -LogInfo $($local.LOG_INIT_NEW_CONN -f $Server, $User, $PasswordFile, $KeyFile)
} # End of Begin.
Process{
    Initialize-SCConnection -Username $User -EncryptedPasswordPath $PasswordFile -KeyPath $KeyFile

    # Show Current User and context.
    Write-Host -ForegroundColor Yellow -Object $($local.INFO_LOGGED_IN -f $(Get-SCCurrentUser), 'Resume-SCScan')

    # Create New Asset.
    $Method = 'POST'
    $URI    = "$Server/scanResult/$ID/resume"
    Write-SCLog -LogInfo $($local.RESUMESCAN_LOG_SET_DATA -f $Method, $URI)
    
    Invoke-RestMethod -Method $Method -Uri $URI -WebSession $SCSession -Headers @{ 'X-SecurityCenter' = $StartSession.response.token } -Body $JSONBody -ContentType 'application/json'

    Write-SCLog -LogInfo $($local.RESUMESCAN_LOG_DATA -f $ID)
} # End of Process.
End {
	# Reset PS Window Title.
    [Console]::Title = $DefaultPSWindowTitle
} # End of End.

} # End of Function Resume-SCScan.
