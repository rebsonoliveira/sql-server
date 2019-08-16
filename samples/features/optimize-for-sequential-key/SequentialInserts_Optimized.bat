ECHO OFF
rd /s /q %temp%\output
"ostress.exe" -E -S.\SQL2019 -dAdventureWorks2016_EXT -Q"EXEC usp_InsertLogRecord @Optimized = 1" -mstress -quiet -n1 -r1 | FINDSTR "Cantfindthisstring"
rd /s /q %temp%\output
"ostress.exe" -E -S.\SQL2019 -dAdventureWorks2016_EXT -Q"EXEC usp_InsertLogRecord @Optimized = 1" -mstress -quiet -n256 -r250 | FINDSTR "QEXEC Starting Creating elapsed"