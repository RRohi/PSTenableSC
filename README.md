Support functions and stuff
=========================

Text capitalization
-------------------

`$testVar = 'lower case text'`

Changing cases in a string to **title case**, **upper case**, or **lower case**:  

`$Culture.ToTitleCase($testVar)`  || Output: `Lower Case Text`  
`$Culture.ToUpper($testVar)` || Output: `LOWER CASE TEXT`  
`$Culture.ToLower($testVar)` || Output: `lower case text`  

Epoch time conversion
---------------------

`$epochTime = '1575376470'`  
`$regularTime = Get-Date`  

Convert epoch time to normal date:  
`ConvertFrom-EpochToNormal -InputEpoch $epochTime` || Output: `03.12.2019 14:34:30` (date format depends on your locale settings)  

Convert normal date to epoch:  
`ConvertFrom-NormalToEpoch -Date $regularTime` || Output: `1552397119`
