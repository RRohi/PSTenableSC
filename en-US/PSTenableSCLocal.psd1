# English localization file.

ConvertFrom-StringData @'
ERROR_MISSING_OBJECT                                                        = Missing Object!

HELP_DETAILED                                                               = Specify if detailed information is shown.
HELP_NO_FORMAT                                                              = Specify customized table, which will be unformatted default view.
HELP_RAW_OUTPUT                                                             = Specify if you want RAW Output, with unformatted data. Dates will remain in Epoch. You will need to use this switch to export to CSV or if you want to filter the output. Preformatted table cannot be modified.

INFO_ACCEPTED_INPUTS                                                        = Accepted inputs are y or n. Additionally to n, e and q can also be used to exit script.
INFO_EXCEEDING_BUFFER_HEIGHT                                                = Output exceeds current buffer height. "{0}" lines were not shown.\nIncrease buffer height, or preferrable way would be to redirect the output to a CSV by using -NoFormat Parameter and Export-CSV cmdlet.
INFO_LOGGED_IN                                                              = Logged in as: "{0}" [{1}]
INFO_NO_RESULTS                                                             = No Results.
INFO_TIME_DAYS                                                              = Days
INFO_TIME_HOURS                                                             = Hours
INFO_TIME_MINUTES                                                           = Minutes
INFO_TIME_SECONDS                                                           = Seconds
INFO_TITLE_RUNNING_CMDLET                                                   = Windows PowerShell - Running: "{0}".

LOG_BUFFER_HEIGHT_VARIABLE                                                  = Storing Buffer Height into a variable for later use.
LOG_COUNT_OUTPUT                                                            = Showing {0} entries.
LOG_CUSTOM_OUTPUT_TABLE                                                     = Creating a custom table for "{0}" Data.
LOG_CVE_REGEX                                                               = Storing CVE RegEx in a variable: "{0}"
LOG_DEFAULT                                                                 = No Parameters were used, showing default output.
LOG_FQDN_REGEX                                                              = Storing FQDN RegEx in a variable: "{0}"
LOG_HOSTNAME_REGEX                                                          = Storing Single Label Host Names RegEx in a variable: "{0}"
LOG_INIT_NEW_CONN                                                           = Initiating a connection to Tenable.sc server "{0}" as "{1}", with Password File "{2}" and Key File "{3}".
LOG_IPV4_REGEX                                                              = Storing IPv4 RegEx in a variable: {0}
LOG_JSON_QUERY                                                              = Building JSON structure for Invoke-RestMethod.
LOG_NA                                                                      = N/A
LOG_NO_FILTER                                                               = No Filtering Parameters was used, showing customized output, with no Table Formatting.
LOG_OK                                                                      = OK
LOG_OUTPUT_DATA                                                             = Displaying {0} Data.
LOG_RAW_OUTPUT                                                              = RAW switch was used, outputting unformatted data.


SCLOG_HELP_LOGINFO                                                          = Specify Log Info Message.


SCERROR_HELP_MESSAGE                                                        = Specify Error Message.
SCERROR_HELP_RECOMMENDED_ACTION                                             = Specify Recommended action to fix the error.

REPC2X_ERROR_TARGET_FILE_EXISTS                                             = File already exists. Exiting!
REPC2X_ERROR_TARGET_FILE_EXISTS_FIX                                         = Choose a target file name, which doesn't already exist.
REPC2X_ERROR_UNSUPPORTED_DELIMITER                                          = Do not use {0} as a delimiter! Exiting!
REPC2X_ERROR_UNSUPPORTED_DELIMITER_FIX                                      = Don't use these characters as delimiters: , " ' * - +

REPC2X_HELP_COMPLIANCE_SOURCE                                               = Specify Compliance Source CSV File Path.
REPC2X_HELP_EXCLUDE_PLUGINS                                                 = Specify Plugin IDs that will be excluded from the output.
REPC2X_HELP_EXCLUDE_SEVERITIES                                              = Specify Severities that will be excluded from the output.
REPC2X_HELP_KEEPTEMP                                                        = Specify if you want to keep the temporary CSV files made during the process. Default is No.
REPC2X_HELP_REPORT_TYPE                                                     = Specify Source Report Type.
REPC2X_HELP_SHOWALL                                                         = Specify if you want to see the erroneous lines from the Source CSV as well. Default is No.
REPC2X_HELP_SOURCE_DELIMETER                                                = Specify a delimiter for the input CSV file. Default is comma (,).
REPC2X_HELP_TARGET                                                          = Specify Excel file location and filename, with the extension of xlsx.
REPC2X_HELP_TARGET_DELIMETER                                                = Specify a delimiter for target CSV file.
REPC2X_HELP_VULNERABILITY_DETAIL_SOURCE                                     = Specify Vulnerability Detail List Source CSV File Path.
REPC2X_HELP_VULNERABILITY_NO_SUMMARY                                        = Specify if you don't want to create the Summary Page.
REPC2X_HELP_VULNERABILITY_SUMMARY_SOURCE                                    = Specify Vulnerability Summary Source CSV File Path.

REPC2X_LOG_COMPLIANCE                                                       = Compliance Parameter switch was used.
REPC2X_LOG_DISPOSE_OF_PACKAGE                                               = Dispose of "{0}" Excel Package after saving it.
REPC2X_LOG_DONT_REMOVE_TEMP_FILE                                            = Temporary file "{0}" was not removed.
REPC2X_LOG_DUMP_GARBAGE                                                     = Dumping "{0}" Garbage.
REPC2X_LOG_SECTION_END                                                      = End of "{0}".
REPC2X_LOG_EXCLUSION_PARAMETERS_CHECK                                       = Checking if ExcludePlugins, or ExcludeSeverities parameters were used.
REPC2X_LOG_EXCLUSION_PARAMETERS_NOT_USED                                    = ExcludePlugins and/or ExcludeSeverities parameters were not used. Default Option.
REPC2X_LOG_EXCLUDEPLUGINS_USED                                              = ExcludePlugins parameter was used.\nFollowing Plugins were excluded: "{0}"
REPC2X_LOG_EXCLUDEPLUGINS_EXCLUDESEVERITIES_USED                            = ExcludePlugins and ExcludeSeverities parameters were used.\nFollowing Plugins were excluded: "{0}"\nFollowing Severities were excluded: "{1}".
REPC2X_LOG_EXCLUDESEVERITIES_USED                                           = ExcludeSeverities parameter was used.\nFollowing Severities were excluded: "{0}".
REPC2X_LOG_IN_CSV_OUT_XLSX                                                  = Import temporary file "{0}" with the delimiter "{1}" and export it into an Excel Package: "{2}" [WorksheetName: "{4}", Table Name: "{3}"].
REPC2X_LOG_MODIFY_CSV_STRUCTURE                                             = Going through "{0}" - Removing NULL and White Spaces, replacing source delimiter "{1}" with target delimiter "{2}", renaming Vulnerability Priority Rating header to VPR and outputting the modifications to: "{3}".
REPC2X_LOG_REMOVE_TEMP_FILE                                                 = Removing temporary file: "{0}".
REPC2X_LOG_SAVE_EXCEL_PACKAGE                                               = Save "{0}" Excel Package.
REPC2X_LOG_SET_SCOPE                                                        = Setting Scope to "{0}".
REPC2X_LOG_TEMP_FILE                                                        = Creating temporary file "{0}" for "{1}".
REPC2X_LOG_VULNERABILITY                                                    = Vulnerability Parameter switch was used. Performing Vulnerability Report Conversion.
REPC2X_LOG_WORKSHEET_VARIABLE                                               = Storing Worksheet Name into a variable: "{0}".
REPC2X_LOG_WORKSHEET_TABLE_VARIABLE                                         = Storing Table Name in Worksheet "{0}" as: "{1}".

REPC2X_COMPLIANCE_TABLE                                                     = ComplianceTable
REPC2X_COMPLIANCE_WORKSHEET                                                 = Compliance
REPC2X_VULNERABILITY_DETAIL_TABLE                                           = DetailedTable
REPC2X_VULNERABILITY_DETAIL_WORKSHEET                                       = Vulnerability Detailed List
REPC2X_VULNERABILITY_SUMMARY_TABLE                                          = SummaryTable
REPC2X_VULNERABILITY_SUMMARY_WORKSHEET                                      = Vulnerability Summary


INITCONN_HELP_DISABLE_CERTIFICATE_CHECK                                     = Specify if Certificate Check needs to be Disabled.
INITCONN_HELP_ENCRYPTED_PASSWORD_FILE                                       = Specify the path of the encrypted password file.
INITCONN_HELP_ENCRYPTED_PASSWORD_KEY_FILE                                   = Specify the path of the encrypted password key file.
INITCONN_HELP_PASSWORD                                                      = Specify Tenable.sc Password.
INITCONN_HELP_USERNAME                                                      = Specify Tenable.sc Username.

INITCONN_LOG_CHECK_ENCRYPTED_FILE_ACL                                       = Checking if "{0}" ACL is over privileged. Authenticated Users and Built In Users and Administrators should not be in the list.
INITCONN_LOG_DECRYPT_PASSWORD                                               = Decrypting password to use it in HTTP POST query for login.
INITCONN_LOG_DISABLING_CERTIFICATE_CHECK                                    = Disabling Certificate Check.
INITCONN_LOG_ENCRYPTED_FILE_VARIABLE                                        = Storing "{0}" into a variable.
INITCONN_LOG_ENCRYPTED_FILE_ACL_WARNING                                     = Show warning to user that "{0}" ACL has users that should not be there.
INITCONN_LOG_FILE_ENCRYPTION                                                = Checking if "{0}" and "{1}" files are encrypted. If yes, pass the ACL checks.
INITCONN_LOG_FILES_ENCRYPTED                                                = "{0}" and "{1}" files are encrypted. Skipping ACL checks.
INITCONN_LOG_FILES_NOT_ENCRYPTED                                            = "{0}" and "{1}" files are not encrypted. Checking file ACLs for excessive privileges.
INITCONN_LOG_LOAD_ENCRYPTED_PASSWORD                                        = Loading encrypted password into variable using password file "{0}" with the key file "{1}".
INITCONN_LOG_NEW_CONNECTION                                                 = Starting a new connection to Tenable.sc server "{0}" and creating a token for later use. Connection will be stored in "{1}" token.
INITCONN_LOG_OVER_PRIVILEGED_PASSWORD_FILES                                 = "{0}" file is over privileged, remove all non-necessary accounts from ACL. Authenticated Users and Built In Users and Administrators should not be in the list. Leave only the actual user.
INITCONN_LOG_OVERWRITE_DECRYPTED_PASSWORD                                   = Overwriting decrypted password in memory and releasing the basic string.
INITCONN_LOG_REMOVE_CREDENTIALS_VARIABLE                                    = Removing Credentials Variable.
INITCONN_LOG_REMOVE_PASSWORD_VARIABLE                                       = Removing Password Variable.
INITCONN_LOG_REMOVE_USERNAME_VARIABLE                                       = Removing Username Variable.
INITCONN_LOG_SERVER_ADDRESS                                                 = Setting Tenable.sc server as: {0}
INITCONN_LOG_SESSION_VARIABLE                                               = Making Session Variable $SCSession Globally Available.
INITCONN_LOG_SET_CREDENTIALS                                                = Setting Credentials for Tenable.sc API Login. releaseSession is set to {0}
INITCONN_LOG_SET_TLS12                                                      = Setting TLS version to 1.2.


GETCURRENT_USER_LOG_OUTPUT_USERNAME                                         = Outputting Current User Name.
GETCURRENT_USER_LOG_USERNAME_GET_DATA                                       = [SCSession] Retrieving Username, using "{0}" method on "{1}".


GETACTIVEPLUGINFEED_LOG_STATUS_GET_DATA                                     = [SCSession] Getting Active Plugin Feed Data, using "{0}" method on "{1}".

GETACTIVEPLUGINFEED_STATUS_STALE                                            = Stale
GETACTIVEPLUGINFEED_STATUS_SUBSCRIPTION_STATUS                              = Subscription Status
GETACTIVEPLUGINFEED_STATUS_UPDATE_RUNNING                                   = Update Running
GETACTIVEPLUGINFEED_STATUS_UPTIME                                           = Active Feed Update Time


INIT_APFEED_UPDATE_INFO_UPDATE_INITIATED                                    = Active Plugin Feed Update Initiated.

INIT_APFEED_UPDATE_LOG                                                      = [SCSession] Initiating Active Plugin Feed Update, using "{0}" method on "{1}".


GETPLUGIN_HELP_PLUGIN_ID                                                    = Specify Plugin ID.

GETPLUGIN_LOG_DETAILED_SWITCH                                               = Detailed Switch was used.
GETPLUGIN_LOG_GET_DATA                                                      = [SCSession] Getting Plugin with an ID of "{0}", using "{1}" method on "{2}".

GETPLUGIN_TBL_CHECK_TYPE                                                    = Check Type
GETPLUGIN_TBL_CVSSV3BASE                                                    = CVSSv3 Base Score
GETPLUGIN_TBL_CVSSV3TEMPORAL                                                = CVSSv3 Temporal Score
GETPLUGIN_TBL_DEPENDENCIES                                                  = Dependencies
GETPLUGIN_TBL_DESCRIPTION                                                   = Description
GETPLUGIN_TBL_EXPLOIT_AVAILABLE                                             = Exploit Available?
GETPLUGIN_TBL_FAMILY                                                        = Family Name
GETPLUGIN_TBL_HASH                                                          = MD5 Hash
GETPLUGIN_TBL_ID                                                            = ID
GETPLUGIN_TBL_NAME                                                          = Name
GETPLUGIN_TBL_PATCH_PUBLICATION_DATE                                        = Patch Publication Date
GETPLUGIN_TBL_PLUGIN_FILE                                                   = Plugin File
GETPLUGIN_TBL_PLUGIN_PUBLICATION_DATE                                       = Plugin Publication Date
GETPLUGIN_TBL_REFERENCES                                                    = References
GETPLUGIN_TBL_RISK_FACTOR                                                   = Risk Factor
GETPLUGIN_TBL_SOLUTION                                                      = Solution
GETPLUGIN_TBL_SYNOPSIS                                                      = Synopsis
GETPLUGIN_TBL_TCP_PORTS                                                     = Required TCP Port(s)
GETPLUGIN_TBL_UDP_PORTS                                                     = Required UDP Port(s)
GETPLUGIN_TBL_VPR_CONTEXT_CVSSV3_IMPACT_SCORE                               = VPR Context - CVSS v3 Impact Score
GETPLUGIN_TBL_VPR_CONTEXT_EXPLOIT_CODE_MATURITY                             = VPR Context - Exploit Code Maturity
GETPLUGIN_TBL_VPR_CONTEXT_PRODUCT_COVERAGE                                  = VPR Context - Product Coverage
GETPLUGIN_TBL_VPR_CONTEXT_THREAT_INTENSITY                                  = VPR Context - Threat Intensity (Last 28 days)
GETPLUGIN_TBL_VPR_CONTEXT_THREAT_RECENCY                                    = VPR Context - Threat Recency
GETPLUGIN_TBL_VPR_CONTEXT_THREAT_SOURCES                                    = VPR Context - Threat Sources (Last 28 days)
GETPLUGIN_TBL_VPR_CONTEXT_VULNERABILITY_AGE                                 = VPR Context - Vulnerability Age
GETPLUGIN_TBL_VPR_SCORE                                                     = VPR Score
GETPLUGIN_TBL_VULNERABILITY_PUBLICATION_DATE                                = Vulnerability Publication Date


GETPLUGINS_HELP_CVE                                                         = Specify CVE ID, can be partial.
GETPLUGINS_HELP_EXPLOITABLE                                                 = Specify if you want to see exploitable plugins, or not.
GETPLUGINS_HELP_OUTPUTLIMIT                                                 = Specify the amount of lines you want to output. 2000000 is safe maximum, but the query will take a long time!
GETPLUGINS_HELP_PLUGIN_FAMILY_NAME                                          = Specify Plugin Family Name, can be partial.
GETPLUGINS_HELP_PLUGIN_NAME                                                 = Specify Plugin Name, can be partial.
GETPLUGINS_HELP_PLUGIN_TYPE                                                 = Specify which Plugin Types you want to see.
GETPLUGINS_HELP_SEVERITY                                                    = Specify Severity level of Plugins.

GETPLUGINS_INFO_EMPTY_OUTPUT                                                = Looks like your Output turned out empty, but that doesn't necessarily mean there were no entries. Consider using -Limit parameter to increase current Output limit of {0} lines.\nLimit of tens of thousands will take a bit, hundreds of thousands will take alot of time. No point going over 2 million! Compliance Check IDs start at 1000000.

GETPLUGINS_LOG_EXPLOITABILITY                                               = Exploitable Parameter was used, showing Plugins with Exploitable setting: "{0}".
GETPLUGINS_LOG_EXPLOITABILITY_FNAME_PNAME                                   = Exploitable, FamilyName and PluginName Parameters were used, showing Plugins with "{2}" in their names, Family Name like "{1}" and Exploitable setting: "{0}".
GETPLUGINS_LOG_EXPLOITABILITY_FNAME_PNAME_SEVERITY                          = Exploitable, FamilyName, PluginName and Severity Parameters were used, showing Plugins with "{2}" in their names, Severity equal to: "{3}", Family Name like "{1}" and Exploitable setting: "{0}".
GETPLUGINS_LOG_EXPLOITABILITY_FNAME_SEVERITY                                = Exploitable, FamilyName and Severity Parameters were used, showing Plugins with "{1}" in their Family names, Severity equal to: "{2}" and Exploitable setting: "{0}".
GETPLUGINS_LOG_EXPLOITABILITY_PNAME_SEVERITY                                = Exploitable, PluginName and Severity Parameters were used, showing Plugins with "{1}" in their names, Severity equal to: "{2}" and have Exploitable setting: "{0}".
GETPLUGINS_LOG_EXPLOITABILITY_SEVERITY                                      = Exploitable and Severity Parameter were used, showing Plugins with Exploitable setting: "{0}" and Severity equal to: "{1}".
GETPLUGINS_LOG_EXPLOITABILITY_SEVERITY_XREFS                                = CVE, Exploitable and Severity Parameters were used, showing Plugins with CVE like "{2}", Severity equal to: "{1}" and Exploitable setting: "{0}".
GETPLUGINS_LOG_FNAME                                                        = FamilyName Parameter was used, showing Plugins with Family Name like "{0}".
GETPLUGINS_LOG_FNAME_PNAME                                                  = PluginName and FamilyName Parameters were used, showing Plugins with "{0}" in their names and Family Name like "{1}".
GETPLUGINS_LOG_FNAME_SEVERITY                                               = FamilyName and Severity Parameters were used, showing Plugins with "{0}" in their Family names and Severity equal to: "{1}".
GETPLUGINS_LOG_FNAME_PNAME_SEVERITY                                         = FamilyName, PluginName and Severity Parameters were used, showing Plugins with "{1}" in their names, Severity equal to: "{2}" and Family Name like "{0}".
GETPLUGINS_LOG_GET_DATA                                                     = [SCSession] Getting Plugins Data, using "{0}" method on "{1}".
GETPLUGINS_LOG_PNAME                                                        = PluginName Parameter was used, showing Plugins with Plugin Name like "{0}".
GETPLUGINS_LOG_PNAME_SEVERITY                                               = PluginName and Severity Parameters were used, showing Plugins with "{0}" in their names and Severity equal to: "{1}".
GETPLUGINS_LOG_PNAME_TYPE                                                   = PluginName and Type Parameters were used, showing Plugins with "{0}" in their names and Type equal to: "{1}".
GETPLUGINS_LOG_SEVERITY                                                     = Severity Parameter was used, showing Plugins with Severity equal to: "{0}".
GETPLUGINS_LOG_SEVERITY_XREFS                                               = CVE and Severity Parameters were used, showing Plugins with CVE like "{0}" and Severity equal to: "{1}".
GETPLUGINS_LOG_TYPE                                                         = Type Parameter was used, showing Plugins with Type equal to: "{0}".
GETPLUGINS_LOG_XREFS                                                        = CVE Parameter was used, showing Plugins with CVE like "{0}".


GETPLUGINS_TBL_EXPLOIT_AVAILABLE                                            = Exploit Available
GETPLUGINS_TBL_ID                                                           = ID
GETPLUGINS_TBL_NAME                                                         = Name
GETPLUGINS_TBL_PLUGIN_FAMILY                                                = Family
GETPLUGINS_TBL_SEVERITY                                                     = Severity
GETPLUGINS_TBL_TYPE                                                         = Type


GETPLUGINFAMILIES_HELP_ID                                                   = Specify Plugin Family ID.
GETPLUGINFAMILIES_HELP_RELATED_PLUGINS                                      = Specify whether to show the Plugins of the Plugin Family.
GETPLUGINFAMILIES_HELP_NAME                                                 = Specify Plugin Family Name. Can be partial.
GETPLUGINFAMILIES_HELP_TYPE                                                 = Specify Plugin Family Type.

GETPLUGINFAMILIES_LOG_GET_DATA                                              = [SCSession] Getting Plugin Family Data, using "{0}" method on "{1}".
GETPLUGINFAMILIES_LOG_ID                                                    = ID Parameter was used, showing Plugins Family with an ID of: "{0}".
GETPLUGINFAMILIES_LOG_LARGE_OUTPUT                                          = Your PS Window Buffer Height ("{0}") is smaller than the output of the Plugins Count ("{1}") of this Plugin Family.\nUse ListRelatedPlugins Parameter to see them all and you might want to export the output to a file, since you won't be seeing the first "{2}" lines.
GETPLUGINFAMILIES_LOG_NAME                                                  = Name Parameter was used, showing Plugins Families with Name like: "{0}".
GETPLUGINFAMILIES_LOG_NAME_TYPE                                             = Name and Type Parameters were used, showing Plugins Families with Name like: "{0}" and with the following Type: "{1}".
GETPLUGINFAMILIES_LOG_TYPE                                                  = Type Parameter was used, showing Plugins Families with the following type: "{0}".

GETPLUGINFAMILIES_TBL_COUNT                                                 = Count
GETPLUGINFAMILIES_TBL_ID                                                    = ID
GETPLUGINFAMILIES_TBL_NAME                                                  = Name
GETPLUGINFAMILIES_TBL_PLUGINS                                               = Plugins
GETPLUGINFAMILIES_TBL_TYPE                                                  = Type


GETREPOSITORIES_LOG_GET_DATA                                                = [SCSession] Getting Repository List, using "{0}" method on "{1}".

GETREPOSITORIES_TBL_ID                                                      = ID
GETREPOSITORIES_TBL_NAME                                                    = Name
GETREPOSITORIES_TBL_DESCRIPTION                                             = Description
GETREPOSITORIES_TBL_FORMAT                                                  = Format


GETSCANRESULTS_HELP_INITIATOR                                               = Specify Scan Initiator.
GETSCANRESULTS_HELP_OWNER                                                   = Specify Scan Owner.
GETSCANRESULTS_HELP_SHOW_ALL                                                = Specify if you want to see all Scans, including the ones with no results.
GETSCANRESULTS_HELP_SHOW_RUNNING                                            = Specify if you want to only see Scans currently running.
GETSCANRESULTS_HELP_START_TIME                                              = Specify Scan Result Age. If not specified, 30 days worth of Reports will be shown (Default).

GETSCANRESULTS_LOG_GET_DATA                                                 = [SCSession] Getting Scan Results, using "{0}" method on "{1}".
GETSCANRESULTS_LOG_INITIATOR                                                = Initiator Parameter was used, showing Scan Results with the Scan Initiator like "{0}".
GETSCANRESULTS_LOG_INITIATOR_SHOW_RUNNING_SCANS                             = Initiator and ShowRunningScans Parameters were used, showing only Running Scans with the Scan Initiator like "{0}".
GETSCANRESULTS_LOG_OWNER                                                    = Owner Parameter was used, showing Scan Results with the Owner like "{0}".
GETSCANRESULTS_LOG_SHOW_ALL                                                 = ShowAll or RAW Parameter was used, showing all Scans Results, including invalid and empty ones.
GETSCANRESULTS_LOG_SHOW_RUNNING_SCANS                                       = ShowRunningScans Parameter was used, showing only Currently Running Scans.
GETSCANRESULTS_LOG_DEFAULT                                                  = Creating Default Table.
GETSCANRESULTS_LOG_STORE_INITIATOR_RUNNING_SCANS                            = Creating Table for Running Scans with the Scan Initiator like "{0}".
GETSCANRESULTS_LOG_STORE_RUNNING_SCANS                                      = Creating Table for Running Scans.

GETSCANRESULTS_TBL_CHECKS                                                   = Checks
GETSCANRESULTS_TBL_DURATION                                                 = Duration
GETSCANRESULTS_TBL_ELAPSED                                                  = Elapsed
GETSCANRESULTS_TBL_FINISH                                                   = Finish
GETSCANRESULTS_TBL_HOSTS                                                    = Hosts
GETSCANRESULTS_TBL_ID                                                       = ID
GETSCANRESULTS_TBL_IMPORT_STATUS                                            = Import Status
GETSCANRESULTS_TBL_INITIATOR                                                = Initiator
GETSCANRESULTS_TBL_NAME                                                     = Name
GETSCANRESULTS_TBL_OWNER                                                    = Owner
GETSCANRESULTS_TBL_PROGRESS                                                 = Progress
GETSCANRESULTS_TBL_REPOSITORY                                               = Repository
GETSCANRESULTS_TBL_RUNNING                                                  = Running
GETSCANRESULTS_TBL_START                                                    = Start


GETLICENSESTATUS_TBL_ACTIVE_TOTAL_LICENSES                                  = Active/Total Licenses
GETLICENSESTATUS_TBL_IPS_FREE                                               = IPs free
GETLICENSESTATUS_TBL_JOB_DAEMON                                             = Job Daemon
GETLICENSESTATUS_TBL_LICENSE_STATUS                                         = License Status
GETLICENSESTATUS_TBL_PLUGIN_SUB_STATUS                                      = Plugin Subscription Status

GETLICENSESTATUS_LOG_GET_DATA                                               = [SCSession] Getting License Status Data, using "{0}" method on "{1}".
GETLICENSESTATUS_LOG_OUTPUT                                                 = Outputting License Data


GETSCANZONES_ERROR_NO_PRIVILEGES                                            = No Output was returned, meaning that the user specified does not have Administrative privileges in Tenable.sc!
GETSCANZONES_ERROR_NO_PRIVILEGES_FIX                                        = Run the cmdlet again with Tenable.sc Administrator credentials.

GETSCANZONES_HELP_ADDRESS                                                   = Specify IP Address, can be partial.
GETSCANZONES_HELP_ID                                                        = Specify Scan Zone ID.

GETSCANZONES_LOG_ADDRESS                                                    = Address Parameter was used.
GETSCANZONES_LOG_DEFAULT                                                    = Detailed Switch was not used. Default Option.
GETSCANZONES_LOG_ID                                                         = ID Parameter was used.
GETSCANZONES_LOG_GET_DATA                                                   = [SCSession] Getting Zone Data, using "{0}" method on "{1}".

GETSCANZONES_TBL_ACTIVE_SCANNERS                                            = Active Scanners
GETSCANZONES_TBL_CREATED_TIME                                               = Created
GETSCANZONES_TBL_DESCRIPTION                                                = Description
GETSCANZONES_TBL_ID                                                         = ID
GETSCANZONES_TBL_IP_COUNT                                                   = IP Count
GETSCANZONES_TBL_IP_LIST                                                    = IP List
GETSCANZONES_TBL_MODIFIED_TIME                                              = Modified
GETSCANZONES_TBL_NAME                                                       = Name
GETSCANZONES_TBL_SCANNERS                                                   = Scanners


GETREPORTS_HELP_ID                                                          = Specify Report ID.
GETREPORTS_HELP_NAME                                                        = Specify Report Name, can be partial.
GETREPORTS_HELP_OWNER                                                       = Specify Report Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETREPORTS_HELP_START_TIME                                                  = Specify Report Age. If not specified, 30 day's worth of Reports will be shown (Default).

GETREPORTS_LOG_GET_DATA                                                     = [SCSession] Getting Reports List, using "{0}" method on "{1}".
GETREPORTS_LOG_ID                                                           = Filter by ID.
GETREPORTS_LOG_NAME                                                         = Filter by Reports Name. Showing Reports with "{0}" in their names.
GETREPORTS_LOG_NAME_OWNER                                                   = Filter by Reports Name and Owner. Showing Reports that are owned by "{1}" and have "{0}" in their names.
GETREPORTS_LOG_OWNER                                                        = Filter by Owner. Showing Reports owned by: "{0}".

GETREPORTS_TBL_ID                                                           = ID
GETREPORTS_TBL_NAME                                                         = Name
GETREPORTS_TBL_TYPE                                                         = Type
GETREPORTS_TBL_STATUS                                                       = Status
GETREPORTS_TBL_START                                                        = Start
GETREPORTS_TBL_FINISH                                                       = Finish
GETREPORTS_TBL_OWNER                                                        = Owner


EXPORTREPORT_HELP_ID                                                        = Specify Report ID.
EXPORTREPORT_HELP_PATH                                                      = Specify Report Output Path, with CSV extension.

EXPORTREPORT_INFO_SAVED_REPORT                                              = Downloaded Report with an ID "{0}" to "{1}".

EXPORTREPORT_LOG_CHECK_PATH                                                 = Check if Path has an extra \ in it and remove it if yes.
EXPORTREPORT_LOG_DOWNLOAD_FINISHED                                          = Report was downloaded to: "{0}".
EXPORTREPORT_LOG_EXPORT_DATA                                                = [SCSession] Getting Report from "{0}", using method "{1}", with an ID of "{2}" in a Session named $SCSession to a file specified as "{3}".
EXPORTREPORT_LOG_GET_DATA                                                   = [SCSession] Getting Report from "{0}", using method "{1}", with an ID of "{2}".
EXPORTREPORT_LOG_OUTPUT                                                     = Storing output path to variable: "{0}".
EXPORTREPORT_LOG_PATH_CHANGED                                               = File Path contained an extra \ and it was removed. New File Path: "{0}".
EXPORTREPORT_LOG_PATH_FILENOEXT                                             = Storing File Name without extension to variable: "{0}".
EXPORTREPORT_LOG_PATH_FOLDER                                                = Storing Folder part of the Path to variable: "{0}".
EXPORTREPORT_LOG_PATH_NOT_CHANGED                                           = File Path is OK and was not changed. File Path: "{0}".
EXPORTREPORT_LOG_REPORT_FINISH_DATE                                         = Report "{0}" was finished at "{1}".
EXPORTREPORT_LOG_SANITIZE_FILE_NAME                                         = File Name sanitization process: "{0}" -> "{1}".


GETASSETS_HELP_ADDRESS                                                      = Specify IP or DNS address.
GETASSETS_HELP_EMPTY                                                        = Specify if you want to see empty Asset Lists.
GETASSETS_HELP_ID                                                           = Specify Asset ID.
GETASSETS_HELP_NAME                                                         = Specify Asset Name, can be partial.
GETASSETS_HELP_ORPHANED                                                     = Specify if you want to see Orphaned Asset Lists.
GETASSETS_HELP_OWNER                                                        = Specify Asset Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETASSETS_HELP_TAG                                                          = Specify Tag.
GETASSETS_HELP_TYPE                                                         = Specify Asset Type.

GETASSETS_INFO_OUTPUT_TOO_LONG                                              = Address count exceeds your buffer height and some of the output will be clipped.\nConsider outputting it to CSV by using -NoFormat Parameter and pipe it to Export-CSV cmdlet. Continue (y/n)?

GETASSETS_LOG_ADDRESS                                                       = Address Parameter was used. Address is like "{0}".
GETASSETS_LOG_ADDRESS_NAME_OWNER_TAG_TYPE                                   = Address, Name, Owner, Tag and Type Parameters were used, showing Assets with "{0}" in their names, Owner is like "{1}", have "{2}" Tag and are of type: "{3}", with either IP or DNS addresses like "{4}" in Address collection.
GETASSETS_LOG_EMPTY                                                         = Empty Parameter was used, showing Asset Lists that don't have any addresses inside.
GETASSETS_LOG_GET_DATA                                                      = [SCSession] Getting Asset Data, using "{0}" method on "{1}".
GETASSETS_LOG_ID                                                            = ID Parameter was used: "{0}".
GETASSETS_LOG_NAME                                                          = Name Parameter was used: "{0}".
GETASSETS_LOG_NAME_ADDRESS                                                  = Address and Name Parameters were used, showing Assets with "{0}" in their names, with either IP or DNS addresses like "{1}" in Address collection.
GETASSETS_LOG_NAME_OWNER                                                    = Name and Owner Parameters were used, showing Assets with "{0}" in their names and Owner is like "{1}".
GETASSETS_LOG_NAME_OWNER_ADDRESS                                            = Address, Name and Owner Parameters were used, showing Assets with "{0}" in their names, Owner is like "{1}", with either IP or DNS addresses like "{2}" in Address collection.
GETASSETS_LOG_NAME_OWNER_TAG                                                = Name, Owner and Tag Parameters were used, showing Assets with "{0}" in their names, Owner is like "{1}", have "{2}" Tag.
GETASSETS_LOG_NAME_OWNER_TAG_TYPE                                           = Name, Owner, Tag and Type Parameters were used, showing Assets with "{0}" in their names, Owner is like "{1}", have "{2}" Tag and are of type: "{3}".
GETASSETS_LOG_NAME_OWNER_TYPE                                               = Name, Owner and Type Parameters were used, showing Assets with "{0}" in their names, Owner is like "{1}" and are of type: "{2}".
GETASSETS_LOG_NAME_TAG                                                      = Name and Tag Parameters were used, showing Assets with "{0}" in their names, that have "{1}" Tag.
GETASSETS_LOG_NAME_TYPE                                                     = Name and Type Parameters were used, showing Assets with "{0}" in their names and are of type: "{1}".
GETASSETS_LOG_ORPHANED                                                      = Orphaned Parameter was used, showing Credentials which are not assigned to Scans.
GETASSETS_LOG_OWNER                                                         = Owner Parameter was used, showing Assets where Owner is like: "{0}".
GETASSETS_LOG_OWNER_TAG                                                     = Owner and Tag Parameters were used, showing Assets where Owner is like "{0}" and have "{1}" Tag.
GETASSETS_LOG_OWNER_TYPE                                                    = Owner and Type Parameters were used, showing Assets where Owner is like "{0}" and are of type: "{1}".
GETASSETS_LOG_TAG                                                           = Tag Parameter was used, showing Assets that have "{0}" Tag.
GETASSETS_LOG_TYPE                                                          = Type Parameter was used, showing Assets that are of type: "{0}".

GETASSETS_TBL_ADDRESSES                                                     = Addresses
GETASSETS_TBL_ID                                                            = ID
GETASSETS_TBL_INFO                                                          = Info
GETASSETS_TBL_NAME                                                          = Name
GETASSETS_TBL_OWNER                                                         = Owner
GETASSETS_TBL_TAG                                                           = Tag
GETASSETS_TBL_TOTAL                                                         = Total
GETASSETS_TBL_TYPE                                                          = Type


GETSCANS_HELP_ASSETS                                                        = Specify Asset Name, can be partial.
GETSCANS_HELP_CREDENTIALS                                                   = Specify Credential Name, can be partial.
GETSCANS_HELP_DHCP                                                          = Specify if DHCP Tracking should be enabled (true), or disabled (false).
GETSCANS_HELP_FULL                                                          = Specify if you want to see detailed information.
GETSCANS_HELP_ID                                                            = Specify Scan ID.
GETSCANS_HELP_INVALID_SCANS                                                 = Specify if you want to see Scans that don't have Credentials and/or Assets configured.
GETSCANS_HELP_NAME                                                          = Specify Scan Name, can be partial.
GETSCANS_HELP_OWNER                                                         = Specify Scan Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETSCANS_HELP_POLICY                                                        = Specify Policy Name, can be partial.
GETSCANS_HELP_REPORTS                                                       = Specify Report Name, can be partial.
GETSCANS_HELP_REPOSITORY                                                    = Specify Repository Name, can be partial.
GETSCANS_HELP_SCHEDULED                                                     = Specify if you want to see Scans that have schedules configured.

GETSCANS_LOG_ASSETS                                                         = Assets Parameter was used, showing Scans that have Assets Name like: "{0}".
GETSCANS_LOG_ASSETS_NAME_OWNER_POLICY_REPORTS_SCHEDULED                     = Assets, Name, Owner, Policy, Reports and Scheduled Parameters were used, showing Scans with "{0}" in their names, Policy like: "{1}", Owner is like "{2}", has reports attached, has Assets like "{3}" configured, and are scheduled.
GETSCANS_LOG_CREDENTIALS                                                    = Credentials Parameter was used, showing Scans that have Credential Name like: "{0}".
GETSCANS_LOG_CREDENTIAL_DHCPTRACKING_NAME_OWNER_POLICY_REPOSITORY_SCHEDULED = Credentials, DHCPTracking, Name, Owner, Policy, Repository and Scheduled Parameters were used, showing Scans with "{0}" in their names, Policy like: "{1}", Repository like "{2}", DHCPTracking is set to "{3}", Owner is like "{4}" and are scheduled.
GETSCANS_LOG_GET_DATA                                                       = [SCSession] Getting License Status Data, using "{0}" method on "{1}".
GETSCANS_LOG_DHCP_TRACKING                                                  = DHCPTracking Parameter was used, showing Scans that have DHCPTracking equal to: "{0}".
GETSCANS_LOG_ID                                                             = ID Parameter was used, showing Scan with an ID of "{0}".
GETSCANS_LOG_NAME                                                           = Name Parameter was used, showing Scans that are like: "{0}".
GETSCANS_LOG_NAME_OWNER                                                     = Name and Owner Parameters were used, showing Scans that have Name like: "{0}" and Owner is like "{1}".
GETSCANS_LOG_NAME_OWNER_POLICY                                              = Name, Owner and Policy Parameters were used, showing Scans that have Name like: "{0}", Owner is like "{1}" and Policy is like: "{2}".
GETSCANS_LOG_OWNER                                                          = Owner Parameter was used, showing Scans that have Owner's First or Last Name like: "{0}".
GETSCANS_LOG_OWNER_POLICY                                                   = Owner and Policy Parameters were used, showing Scans where Owner is like "{0}" and Policy is like: "{1}".
GETSCANS_LOG_POLICY                                                         = Policy Parameter was used, showing Scans that have Policy like: "{0}".
GETSCANS_LOG_REPORTS                                                        = Reports Parameter was used, showing Scans that have Reports configured.
GETSCANS_LOG_REPOSITORY                                                     = Repository Parameter was used, showing Scans that have Repository like: "{0}".
GETSCANS_LOG_SCHEDULED                                                      = Scheduled Parameter was used, showing Scans that have Schedules enabled.

GETSCANS_TBL_ADDRESSES                                                      = Address(es)
GETSCANS_TBL_ASSETS                                                         = Asset(s)
GETSCANS_TBL_CREDENTIALS                                                    = Credential(s)
GETSCANS_TBL_DEFAULT_HOLDER                                                 = No Parameter was used, creating custom formatted Output Table.
GETSCANS_TBL_DESCRIPTION                                                    = Description
GETSCANS_TBL_DHCP_TRACKING                                                  = DHCP Tracking
GETSCANS_TBL_ID                                                             = ID
GETSCANS_TBL_ID_HOLDER                                                      = Storing ID Output Holder to an Output Table.
GETSCANS_TBL_MAX_SCAN_TIME                                                  = MaxScanTime
GETSCANS_TBL_NAME                                                           = Name
GETSCANS_TBL_OWNER                                                          = Owner
GETSCANS_TBL_POLICY                                                         = PolicyName
GETSCANS_TBL_REPORTS                                                        = Reports
GETSCANS_TBL_REPOSITORY                                                     = Repository
GETSCANS_TBL_SCHEDULE                                                       = Schedule


GETPOLICIES_HELP_AUDITFILE                                                  = Specify Audit File Name.
GETPOLICIES_HELP_AUDITTYPE                                                  = Specify Audit Type.
GETPOLICIES_HELP_ID                                                         = Specify Scan ID.
GETPOLICIES_HELP_NAME                                                       = Specify Scan Name, can be partial.
GETPOLICIES_HELP_OWNER                                                      = Specify Scan Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETPOLICIES_HELP_POLICYTEMPLATE                                             = Specify Policy Template.

GETPOLICIES_LOG_AUDITFILE                                                   = AuditFile Parameter was used, showing Policies that have Audit File like: "{0}".
GETPOLICIES_LOG_AUDITFILE_AUDITTYPE_NAME_OWNER_POLICYTEMPLATE               = AuditFile, AuditType, Name, Owner and PolicyTemplate Parameters were used, showing Policies that have Audit Files like: "{0}", which are of Type "{1}", with Policy name like: "{2}", owner like: "{3}", using Policy Template: "{4}".
GETPOLICIES_LOG_AUDITFILE_NAME                                              = AuditFile and Name Parameters were used, showing Policies that have Audit Files like: "{0}", with Policy name like: "{1}".
GETPOLICIES_LOG_AUDITTYPE                                                   = AuditType Parameter was used, showing Policies that have Audit Type equal to: "{0}".
GETPOLICIES_LOG_AUDITTYPE_NAME                                              = AuditType and Name Parameters were used, showing Policies that have Audit Files with type of "{0}", with Policy name like: "{1}".
GETPOLICIES_LOG_AUDITTYPE_OWNER                                             = AuditType and Owner Parameters were used, showing Policies that have Audit Type of "{0}", with the owner like: "{1}".
GETPOLICIES_LOG_AUDITTYPE_POLICYTEMPLATE                                    = AuditType and PolicyTemplate Parameters were used, showing Policies that have Audit Type of "{0}", which have the following Policy Template: "{1}".
GETPOLICIES_LOG_GET_DATA                                                    = [SCSession] Getting Policies Data, using "{0}" method on "{1}".
GETPOLICIES_LOG_ID                                                          = ID Parameter was used, showing Policy with an ID of "{0}".
GETPOLICIES_LOG_NAME                                                        = Name Parameter was used, showing Policies that have Name like: "{0}".
GETPOLICIES_LOG_NAME_OWNER                                                  = Name and Owner Parameters were used, showing Policies that have Policy name like: "{0}" and owner like: "{1}".
GETPOLICIES_LOG_NAME_OWNER_POLICYTEMPLATE                                   = Name, Owner and PolicyTemplate Parameters were used, showing Policies that have Policy name like: "{0}", owner like: "{1}", using Policy Template: "{2}".
GETPOLICIES_LOG_OWNER                                                       = Owner Parameter was used, showing Policies that have Owner's First- or Last Name like: "{0}".
GETPOLICIES_LOG_POLICYTEMPLATE                                              = PolicyTemplate Parameter was used, showing Policies that have Policy template equal to: "{0}".

GETPOLICIES_TBL_AUDITFILE                                                   = Audit File
GETPOLICIES_TBL_AUDITTYPE                                                   = Audit Type
GETPOLICIES_TBL_DESCRIPTION                                                 = Description
GETPOLICIES_TBL_ID                                                          = ID
GETPOLICIES_TBL_NAME                                                        = Name
GETPOLICIES_TBL_OWNER                                                       = Owner
GETPOLICIES_TBL_POLICYTEMPLATE                                              = Policy Template
GETPOLICIES_TBL_TAGS                                                        = Tags


GETBLACKOUT_WINDOW_LOG_DETAILED_SWITCH                                      = Detailed Switch was used.
GETBLACKOUT_WINDOW_LOG_GET_DATA                                             = [SCSession] Getting Policies Data, using "{0}" method on "{1}".
GETBLACKOUT_WINDOW_LOG_OUTPUT                                               = Outputting Blackout Window data.

GETBLACKOUT_WINDOW_TBL_ACTIVE                                               = Active
GETBLACKOUT_WINDOW_TBL_ALLIPS                                               = ALL IPs
GETBLACKOUT_WINDOW_TBL_ASSETS                                               = Assets
GETBLACKOUT_WINDOW_TBL_DESCRIPTION                                          = Description
GETBLACKOUT_WINDOW_TBL_ENABLED                                              = Enabled
GETBLACKOUT_WINDOW_TBL_END                                                  = End
GETBLACKOUT_WINDOW_TBL_FUNCTIONAL                                           = Functional
GETBLACKOUT_WINDOW_TBL_ID                                                   = ID
GETBLACKOUT_WINDOW_TBL_IPLIST                                               = IP List
GETBLACKOUT_WINDOW_TBL_MODIFIEDTIME                                         = Modified Time
GETBLACKOUT_WINDOW_TBL_NAME                                                 = Name
GETBLACKOUT_WINDOW_TBL_OWNER                                                = Owner
GETBLACKOUT_WINDOW_TBL_REPEATRULE                                           = Repeat Rule
GETBLACKOUT_WINDOW_TBL_REPOSITORY                                           = Repository  
GETBLACKOUT_WINDOW_TBL_START                                                = Start
GETBLACKOUT_WINDOW_TBL_STATUS                                               = Status


SETSCAN_HELP_ADDRESS                                                        = Specify Asset FQDN or IP Address(es).
SETSCAN_HELP_ASSET_ID                                                       = Specify Asset ID(s).
SETSCAN_HELP_CREDENTIAL_ID                                                  = Specify Credential ID(s).
SETSCAN_HELP_DESCRIPTION                                                    = Specify Scan Description.
SETSCAN_HELP_DHCPTRACKING                                                   = Specify DHCP Tracking state.
SETSCAN_HELP_ID                                                             = Specify Scan ID.
SETSCAN_HELP_MAX_SCAN_TIME                                                  = Specify Max Scan Time in hours.
SETSCAN_HELP_NAME                                                           = Specify Scan Name.
SETSCAN_HELP_POLICY_ID                                                      = Specify Policy ID.
SETSCAN_HELP_REPORT_ID                                                      = Specify Report ID(s).
SETSCAN_HELP_REPORT_SOURCE                                                  = Specify Report Source for the Scan.
SETSCAN_HELP_REPOSITORY_ID                                                  = Specify Repository ID for the Scan.
SETSCAN_HELP_ROLLOVER_TYPE                                                  = Specify Rollover Type.
SETSCAN_HELP_SCAN_VIRTUAL_HOSTS                                             = Specify whether Virtual Hosts will be scanned.
SETSCAN_HELP_TIMEOUT_ACTION                                                 = Specify Timeout Action.

SETSCAN_LOG_GET_DATA                                                        = [SCSession] Setting Scan Data, using "{0}" method on "{1}".


REMOVEASSET_ERROR                                                           = Following error occurred: {0}
REMOVEASSET_ERROR_FIX                                                       = Make sure the ID of the Asset exists and is correct.

REMOVEASSET_HELP_ID                                                         = Specify Asset ID.

REMOVEASSET_INFO_ASSET_DELETED                                              = Asset with an ID of "{0}" is deleted.
REMOVEASSET_INFO_CONFIRMATION                                               = Asset with an ID of "{0}" will be permanently deleted. Are you sure? (y/n)
REMOVEASSET_INFO_DELETION_CANCEL                                            = Deletion of Asset "{0}" cancelled.

REMOVEASSET_LOG_SET_DATA                                                    = [SCSession] Setting Deletion Instruction, using "{0}" method on "{1}".


NEWSCAN_HELP_ASSET_ID                                                       = Specify Asset(s) ID(s) for the New Scan.
NEWSCAN_HELP_CREDENTIAL_ID                                                  = Specify Credential(s) ID(s) for the New Scan.
NEWSCAN_HELP_DESCRIPTION                                                    = Specify New Scan Description.
NEWSCAN_HELP_DHCP_TRACKING                                                  = Specify whether DHCP Tracking should be Enabled or Disabled.
NEWSCAN_HELP_ADDRESS                                                        = Specify FQDN or IP Addresses for the New Scan.
NEWSCAN_HELP_MAX_SCAN_TIME                                                  = Specify Max Scan Time in hours.
NEWSCAN_HELP_NAME                                                           = Specify New Scan Name.
NEWSCAN_HELP_POLICY_ID                                                      = Specify Policy ID for the New Scan.
NEWSCAN_HELP_REPORT_ID                                                      = Specify Report ID for the New Scan.
NEWSCAN_HELP_REPORT_SOURCE                                                  = Specify Report Source for the New Scan.
NEWSCAN_HELP_REPOSITORY_ID                                                  = Specify Repository ID for the New Scan.
NEWSCAN_HELP_ROLLOVER_TYPE                                                  = Specify Rollover Type.
NEWSCAN_HELP_SCAN_VIRTUAL_HOSTS                                             = Specify whether Virtual Hosts will be scanned.
NEWSCAN_HELP_TIMEOUT_ACTION                                                 = Specify Timeout Action.

NEWSCAN_LOG_NEW_SCAN_DATA                                                   = New Scan was created with a name of "{5}", Description "{2}", Policy ID "{6}", Repository ID "{9}", with the Report Source of "{8}", DHCP Tracking "{3}", Asset ID "{0}", IPs "{4}", Credential ID "{1}".
NEWSCAN_LOG_SET_DATA                                                        = [SCSession] Setting New Scan Instruction, using "{0}" method on "{1}".


GETCREDENTIALS_HELP_CYBERARK                                                = Specify if you want to see CyberArk enabled Credentials.
GETCREDENTIALS_HELP_DESCRIPTION                                             = Specify Description, can be partial.
GETCREDENTIALS_HELP_ID                                                      = Specify ID.
GETCREDENTIALS_HELP_NAME                                                    = Specify Name, can be partial.
GETCREDENTIALS_HELP_ORPHANED                                                = Specify if you want to see Orphaned Credentials.
GETCREDENTIALS_HELP_OWNER                                                   = Specify Credential's Owner's Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETCREDENTIALS_HELP_TAG                                                     = Specify Tag Name, can be partial.
GETCREDENTIALS_HELP_TYPE                                                    = Specify Type.
GETCREDENTIALS_HELP_USERNAME                                                = Specify Username used in the credential, can be partial.

GETCREDENTIALS_LOG_CYBERARK                                                 = CyberArk Parameter was used, showing Credentials that are CyberArk integrated.
GETCREDENTIALS_LOG_GET_DATA                                                 = [SCSession] Getting Credential Data, using "{0}" method on "{1}".
GETCREDENTIALS_LOG_ID                                                       = ID Parameter was used, showing Credentials with ID: "{0}".
GETCREDENTIALS_LOG_NAME                                                     = Name Parameter was used, showing Credentials with "{0}" in their names.
GETCREDENTIALS_LOG_NAME_OWNER                                               = Name and Owner Parameters were used, showing Credentials with "{0}" in their names and Owner's first or surname like "{1}".
GETCREDENTIALS_LOG_NAME_OWNER_TAG                                           = Name, Owner and Tag Parameters were used, showing Credentials with "{0}" in their names, Owner's first or surname like "{1}" and tag like: "{2}".
GETCREDENTIALS_LOG_NAME_OWNER_TAG_TYPE                                      = Name, Owner, Tag and Type Parameters were used, showing Credentials with "{0}" in their names, Owner's first or surname like "{1}", tag like "{2}" and are of type: "{3}".
GETCREDENTIALS_LOG_NAME_OWNER_TYPE                                          = Name, Owner and Type Parameters were used, showing Credentials with "{0}" in their names, Owner's first or surname like "{1}" and are of type: "{2}".
GETCREDENTIALS_LOG_NAME_TAG_TYPE                                            = Name, Tag and Type Parameters were used, showing Credentials with "{0}" in their names, tag like "{1}" and are of type: "{2}".
GETCREDENTIALS_LOG_NAME_TYPE                                                = Name and Type Parameters were used, showing Credentials with "{0}" in their names and are of type: "{1}".
GETCREDENTIALS_LOG_OWNER                                                    = Owner Parameter was used, showing Credentials with Owner's first or surname like "{0}".
GETCREDENTIALS_LOG_OWNER_TAG_TYPE                                           = Owner, Tag, Type Parameters were used, showing Credentials with the Owner like "{0}", Tag like: "{1}" and are of type: "{2}".
GETCREDENTIALS_LOG_OWNER_TYPE                                               = Owner and Type Parameters were used, showing Credentials with Owner's first or surname like "{0}" and are of type: "{1}".
GETCREDENTIALS_LOG_TAG                                                      = Tag Parameter was used, showing Credentials where tag is like "{0}".
GETCREDENTIALS_LOG_TYPE                                                     = Type Parameter was used, showing Credentials where type is "{0}".
GETCREDENTIALS_LOG_USERNAME                                                 = Username Parameter was used, showing Credentials where Credential "{0}" is configured.

GETCREDENTIALS_TBL_ATTRIBUTES                                               = Attributes
GETCREDENTIALS_TBL_AUTH_TYPE                                                = Auth Type
GETCREDENTIALS_TBL_CREDENTIAL_NAME                                          = Credential Name
GETCREDENTIALS_TBL_CYBERARK                                                 = Cyberark
GETCREDENTIALS_TBL_DB_ORACLE_AUTH_TYPE                                      = Oracle Auth Type
GETCREDENTIALS_TBL_DB_ORACLE_SERVICE_TYPE                                   = Oracle Service Type
GETCREDENTIALS_TBL_DB_PORT                                                  = DB Port
GETCREDENTIALS_TBL_DB_SID                                                   = DB SID
GETCREDENTIALS_TBL_DB_TYPE                                                  = DB Type
GETCREDENTIALS_TBL_DESCRIPTION                                              = Description
GETCREDENTIALS_TBL_DOMAIN                                                   = Domain
GETCREDENTIALS_TBL_ID                                                       = ID
GETCREDENTIALS_TBL_OWNER                                                    = Owner
GETCREDENTIALS_TBL_TAG                                                      = Tag
GETCREDENTIALS_TBL_TYPE                                                     = Type
GETCREDENTIALS_TBL_USERNAME                                                 = Username


GETUSERS_HELP_AUTH_TYPE                                                     = Specify Auth Type.
GETUSERS_HELP_FAILED_LOGINS                                                 = Show Users with failed logins.
GETUSERS_HELP_LOCKED                                                        = Show Only Locked Users.
GETUSERS_HELP_NAME                                                          = Specify User Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETUSERS_HELP_ROLE                                                          = Specify User Role.

GETUSERS_INFO_LOCAL_USER                                                    = Local User

GETUSERS_LOG_AUTH_TYPE                                                      = AuthType Parameter was used, showing Users with "{0}" Authentication type.
GETUSERS_LOG_FAILED_LOGINS                                                  = FailedLogins Parameter was used, showing Users with failed logins.
GETUSERS_LOG_GET_DATA                                                       = [SCSession] Getting Users Data, using "{0}" method on "{1}".
GETUSERS_LOG_LOCKED                                                         = ShowLockedOnly Parameter was used, showing only Users that are Locked Out.
GETUSERS_LOG_NAME                                                           = Name Parameter was used, showing Users with "{0}" in their names.
GETUSERS_LOG_ROLE                                                           = Role Parameter was used, showing Users with "{0}" in their roles.

GETUSERS_TBL_AUTHTYPE                                                       = Auth Type
GETUSERS_TBL_EMAIL                                                          = E-mail
GETUSERS_TBL_FAILEDLOGINS                                                   = Failed Logins
GETUSERS_TBL_GROUP                                                          = Group
GETUSERS_TBL_ID                                                             = ID
GETUSERS_TBL_LASTLOGIN                                                      = Last Login
GETUSERS_TBL_LDAPUSERNAME                                                   = LDAP Username
GETUSERS_TBL_LOCKED                                                         = Locked
GETUSERS_TBL_NAME                                                           = Name
GETUSERS_TBL_RESPONSIBLE_ASSET                                              = Responsible Asset(s)
GETUSERS_TBL_ROLE                                                           = Role
GETUSERS_TBL_TITLE                                                          = Title


NEWASSET_ERROR_MIXED_ASSET_TYPES                                            = IP Addresses and FQDN's can't be used in the same Asset list!
NEWASSET_ERROR_RECOMMENDED_ACTION                                           = Provide a list of Assets which are either IP Addresses only, or FQDN only.

NEWASSET_HELP_ADDRESSES                                                     = Specify addresses for the new Asset.
NEWASSET_HELP_DESCRIPTION                                                   = Specify new Asset's Description.
NEWASSET_HELP_IMPORT                                                        = Specify if you want to import Asset's from a file.
NEWASSET_HELP_IMPORT_DOMAIN                                                 = Specify which Domain the imported Assets belong to.
NEWASSET_HELP_NAME                                                          = Specify new Asset's Name.
NEWASSET_HELP_TAG                                                           = Specify a Tag for the New Asset.
NEWASSET_HELP_TYPE                                                          = Specify new Asset's Type.

NEWASSET_LOG_IMPORT_CHECK_COMMAS                                            = Checking if Imported Assets are comma delimited. Commas will be added, if not.
NEWASSET_LOG_IMPORT_FORMAT                                                  = Checking if Imported Assets are formatted as FQDN or hostname. FQDN's are required for successful Import.
NEWASSET_LOG_MIXED_ADDRESSES                                                = Asset List contains both IP addresses and DNS Names. This is not supported, exiting.
NEWASSET_LOG_NEW_ASSET_DATA                                                 = New Asset was created with a type of "{0}", Name "{1}", Description "{2}", Tag "{3}".
NEWASSET_LOG_NO_DNS_NAMES                                                   = Asset List does not contain DNS Names, exiting.
NEWASSET_LOG_NO_IPS                                                         = Asset List does not contain IP addresses, exiting.
NEWASSET_LOG_SET_DATA                                                       = [SCSession] Setting New Asset Instruction, using "{0}" method on "{1}".
NEWASSET_LOG_STORE_IMPORTED_FILE                                            = Store Imported file into a variable.
NEWASSET_LOG_TYPE                                                           = Type "{0}" was selected.


STARTSCAN_ERROR_TARGET_OFFLINE                                              = "{0}" is offline.
STARTSCAN_ERROR_TARGET_OFFLINE_FIX                                          = Make sure the target is online, or if the target name/IP address is correct.

STARTSCAN_HELP_ID                                                           = Specify Scan ID.
STARTSCAN_HELP_DIAGNOSTIC_PASSWORD                                          = Specify password for the Diagnostic Scan.
STARTSCAN_HELP_DIAGNOSTIC_TARGET                                            = Specify whether the scan will be a Diagnostic Scan.

STARTSCAN_LOG_DATA                                                          = Started Scan with an ID of "{0}".
STARTSCAN_LOG_DIAGNOSTIC_DATA                                               = Started Diagnostic Scan against "{1}", using the scan with an ID of "{0}".
STARTSCAN_LOG_SET_DATA                                                      = [SCSession] Setting Scan Start Instruction, using "{0}" method on "{1}".


GETSCANNERS_HELP_AGENT_CAPABLE                                              = Specify if Scanners are Agent Capable.
GETSCANNERS_HELP_ENABLED                                                    = Specify if Scanners are Enabled.
GETSCANNERS_HELP_ID                                                         = Specify Scanners ID.
GETSCANNERS_HELP_NAME                                                       = Specify Scanners Name, can be partial.

GETSCANNERS_LOG_AGENT_CAPABLE                                               = AgentCapable Parameter was used, showing Scanners that have Agent Capable status "{0}".
GETSCANNERS_LOG_AGENT_CAPABLE_ENABLED                                       = AgentCapable and Enabled Parameters were used, showing Scanners that have Enabled status "{0}" and Agent Capable status "{1}".
GETSCANNERS_LOG_ENABLED                                                     = Enabled Parameter was used, showing Scanners that have Enabled status "{0}".
GETSCANNERS_LOG_ENABLED_NAME                                                = Enabled and Name Parameters were used, showing Scanners that have Enabled status "{0}" and have a name like "{1}".
GETSCANNERS_LOG_GET_DATA                                                    = [SCSession] Getting Scanners Data, using "{0}" method on "{1}".
GETSCANNERS_LOG_ID                                                          = ID Parameter was used, showing Scanner that has an ID of "{0}".
GETSCANNERS_LOG_NAME                                                        = Name Parameter was used, showing Scanners that have Name like "{0}".
GETSCANNERS_LOG_NOT_RUNNING                                                 = Not Running

GETSCANNERS_TBL_AGENT_CAPABLE                                               = Agent Capable
GETSCANNERS_TBL_AUTH_TYPE                                                   = Auth Type
GETSCANNERS_TBL_AVERAGE_LOAD                                                = Average Load
GETSCANNERS_TBL_DESCRIPTION                                                 = Description
GETSCANNERS_TBL_ENABLED                                                     = Enabled
GETSCANNERS_TBL_ID                                                          = ID
GETSCANNERS_TBL_IP                                                          = IP
GETSCANNERS_TBL_NAME                                                        = Name
GETSCANNERS_TBL_NUM_HOSTS                                                   = Num of Hosts
GETSCANNERS_TBL_NUM_SCANS                                                   = Num of Scans
GETSCANNERS_TBL_NUM_SESSIONS                                                = Num of Sessions
GETSCANNERS_TBL_NUM_TCP_SESSIONS                                            = Num of TCP Sessions
GETSCANNERS_TBL_PORT                                                        = Port
GETSCANNERS_TBL_STATUS                                                      = Status
GETSCANNERS_TBL_UPTIME                                                      = Uptime
GETSCANNERS_TBL_USERNAME                                                    = Username
GETSCANNERS_TBL_VERSION                                                     = Version
GETSCANNERS_TBL_ZONES                                                       = Zones


REMOVEREPORT_ERROR_FIX                                                      = Make sure the Report ID exists or if the connection is working.

REMOVEREPORT_HELP_ID                                                        = Specify Report ID.

REMOVEREPORT_INFO_CONFIRMATION                                              = Asset with an ID of "{0}" will be permanently deleted. Are you sure? (y/n)
REMOVEREPORT_INFO_DELETION_CANCEL                                           = Deletion of report "{0}" cancelled.
REMOVEREPORT_INFO_REPORT_DELETED                                            = Report with an ID of "{0}" is deleted.

REMOVEREPORT_LOG_SET_DATA                                                   = [SCSession] Setting Deletion Instruction, using "{0}" method on "{1}".


GETAUDITFILE_HELP_FILENAME                                                  = Specify Audit File Name, can be partial.
GETAUDITFILE_HELP_NAME                                                      = Specify Audit Name, can be partial.
GETAUDITFILE_HELP_OWNER                                                     = Specify Audit Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETAUDITFILE_HELP_TYPE                                                      = Specify Audit Type.

GETAUDITFILE_LOG_GET_DATA                                                   = [SCSession] Getting Audit File Data, using "{0}" method on "{1}".
GETAUDITFILE_LOG_NAME                                                       = Name Parameter was used, showing Audit Files with "{0}" in their names.
GETAUDITFILE_LOG_NAME_OWNER                                                 = Name and Owner Parameters were used, showing Audit Files with "{0}" in their names and Owner's first or surname like "{1}".
GETAUDITFILE_LOG_NAME_OWNER_TYPE                                            = Name, Owner and Type Parameters were used, showing Audit Files with "{0}" in their names, Owner's first or surname like "{1}" and are of type: "{2}".
GETAUDITFILE_LOG_NAME_TYPE                                                  = Name and Type Parameters were used, showing Audit Files with "{0}" in their names and are of type: "{1}".
GETAUDITFILE_LOG_OWNER                                                      = Owner Parameter was used, showing Audit Files with Owner's first or surname like "{0}".
GETAUDITFILE_LOG_OWNER_TYPE                                                 = Owner and Type Parameters were used, showing Audit Files with Owner's first or surname like "{0}" and are of type: "{1}".
GETAUDITFILE_LOG_TYPE                                                       = Type Parameter was used, showing Audit Files which are of type: "{0}".

GETAUDITFILE_TBL_ID                                                         = ID
GETAUDITFILE_TBL_FILENAME                                                   = Filename
GETAUDITFILE_TBL_NAME                                                       = Name
GETAUDITFILE_TBL_ORIGINALFILENAME                                           = Original Filename
GETAUDITFILE_TBL_OWNER                                                      = Owner
GETAUDITFILE_TBL_TEMPLATE                                                   = Template
GETAUDITFILE_TBL_TIME_CREATED                                               = Created
GETAUDITFILE_TBL_TIME_MODIFIED                                              = Modified
GETAUDITFILE_TBL_TYPE                                                       = Type
GETAUDITFILE_TBL_TYPEFIELDS                                                 = Type Fields


GETREPORTDEFINITIONS_HELP_DETAILED                                          = Specify if you want to see detailed view, which has additional fields.
GETREPORTDEFINITIONS_HELP_ID                                                = Specify Report Definition ID.
GETREPORTDEFINITIONS_HELP_NAME                                              = Specify Report Definition name, can be partial.
GETREPORTDEFINITIONS_HELP_OWNER                                             = Specify Report Definition Owner Name. Either full first, or surname, or parts of first or surname. Full name "Firstname Surname", will not give results.
GETREPORTDEFINITIONS_HELP_TYPE                                              = Specify Report Definition Type.

GETREPORTDEFINITIONS_INFO_NA_FOR_PDF                                        = N/A for PDF.

GETREPORTDEFINITIONS_LOG_ID                                                 = ID Parameter was used, showing Report Definition with an ID of "{0}".
GETREPORTDEFINITIONS_LOG_GET_DATA                                           = [SCSession] Getting Report Definition Data, using "{0}" method on "{1}".
GETREPORTDEFINITIONS_LOG_NAME                                               = Name Parameter was used, showing Report Definitions with Name like: "{0}".
GETREPORTDEFINITIONS_LOG_NAME_OWNER                                         = Owner and Name Parameters were used, showing Report Definitions with name like "{0}" and owner's first or surname like "{1}".
GETREPORTDEFINITIONS_LOG_NAME_OWNER_TYPE                                    = Owner, Name and Type Parameters were used, showing Report Definitions with name like "{0}", owner's first or surname like "{1}" and are Type of: "{2}".
GETREPORTDEFINITIONS_LOG_NAME_TYPE                                          = Name and Type Parameters were used, showing Report Definitions with Name like: "{0}" and are of Type: "{1}".
GETREPORTDEFINITIONS_LOG_OWNER                                              = Owner Parameter was used, showing Report Definitions with Owner's first or surname like "{0}".
GETREPORTDEFINITIONS_LOG_OWNER_TYPE                                         = Owner and Type Parameters were used, showing Report Definitions with Owner's first or surname like "{0}" and are of Type: "{1}".
GETREPORTDEFINITIONS_LOG_TYPE                                               = Type Parameter was used, showing Report Definitions of Type: "{0}".

GETREPORTDEFINITIONS_TBL_COLUMNS                                            = Columns
GETREPORTDEFINITIONS_TBL_CREATOR                                            = Creator
GETREPORTDEFINITIONS_TBL_ID                                                 = ID
GETREPORTDEFINITIONS_TBL_NAME                                               = Name
GETREPORTDEFINITIONS_TBL_OWNER                                              = Owner
GETREPORTDEFINITIONS_TBL_TYPE                                               = Type


REMOVESCAN_ERROR_FIX                                                        = Make sure the Scan ID exists or if the connection is working.

REMOVESCAN_HELP_ID                                                          = Specify Scan ID.

REMOVESCAN_INFO_CONFIRMATION                                                = Scan with an ID of "{0}" will be permanently deleted. Are you sure? (y/n)
REMOVESCAN_INFO_DELETION_CANCEL                                             = Deletion of "{0}" cancelled.
REMOVESCAN_INFO_SCAN_DELETED                                                = Scan with an ID of "{0}" is deleted.

REMOVESCAN_LOG_SET_DATA                                                     = [SCSession] Setting Deletion Instruction, using "{0}" method on "{1}".


STOPSCAN_HELP_ID                                                            = Specify Scan ID.

STOPSCAN_LOG_DATA                                                           = Stopped Scan with an ID of "{0}".
STOPSCAN_LOG_SET_DATA                                                       = [SCSession] Setting Scan Stop Instruction, using "{0}" method on "{1}".


GETANALYSIS_LOG_GET_DATA                                                    = [SCSession] Getting Analysis Data, using "{0}" method on "{1}".


GETQUERY_HELP_ID                                                            = Specify Query ID.
GETQUERY_HELP_OWNER                                                         = Specify Report Definition Owner Name. Full/Partial first/last name, or B-number. Full name "Firstname Surname", will not give results.
GETQUERY_HELP_TAG                                                           = Specify Query Tag.

GETQUERY_LOG_GET_DATA                                                       = [SCSession] Getting Query Data, using "{0}" method on "{1}".
GETQUERY_LOG_ID                                                             = ID Parameter was used, showing Query with an ID of "{0}".
GETQUERY_LOG_OWNER                                                          = Owner Parameter was used, showing Queries with Owner's first or surname like: "{0}".
GETQUERY_LOG_OWNER_TAG                                                      = Owner and Tag Parameters were used, showing Queries with Owner's first or surname like "{0}" and Tag like: "{1}".
GETQUERY_LOG_TAG                                                            = Tag Parameter was used, showing Queries with Tag like: "{0}".

GETQUERY_TBL_CREATED_TIME                                                   = Created
GETQUERY_TBL_FILTERS                                                        = Filters
GETQUERY_TBL_ID                                                             = ID
GETQUERY_TBL_MODIEFIED_TIME                                                 = Modified
GETQUERY_TBL_NAME                                                           = Name
GETQUERY_TBL_OWNER                                                          = Owner
GETQUERY_TBL_TAG                                                            = Tag
GETQUERY_TBL_TOOL                                                           = Tool
GETQUERY_TBL_TYPE                                                           = Type


COPYSCAN_HELP_EXISTING_SCAN_ID                                              = Specify existing Scan ID.
COPYSCAN_HELP_NAME                                                          = Specify new Scan Name.
COPYSCAN_HELP_TARGET_USER_ID                                                = Specify target User ID.

COPYSCAN_LOG_SET_DATA                                                       = [SCSession] Setting Scan Copy instructions, using "{0}" method on "{1}".


SUSPENDSCAN_HELP_ID                                                         = Specify Scan ID.

SUSPENDSCAN_LOG_DATA                                                        = Suspended Scan with an ID of "{0}".
SUSPENDSCAN_LOG_SET_DATA                                                    = [SCSession] Setting Scan Suspension Instruction, using "{0}" method on "{1}".


RESUMESCAN_HELP_ID                                                          = Specify Scan ID.

RESUMESCAN_LOG_DATA                                                         = Resumed Suspended Scan with an ID of "{0}".
RESUMESCAN_LOG_SET_DATA                                                     = [SCSession] Setting Scan Resume Instruction, using "{0}" method on "{1}".
'@
