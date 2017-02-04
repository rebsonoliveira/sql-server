SELECT * FROM Logs

SELECT JSON_VALUE(LogEvent, '$.Properties.RequestPath') as Url, *
FROM Logs
WHERE Level = 'Error'

SELECT
		JSON_VALUE(LogEvent, '$.Properties.RequestPath') as Url,
		AVG( CAST(JSON_VALUE(LogEvent, '$.Properties.ElapsedMilliseconds') as float) ) as milliseconds
FROM Logs
WHERE JSON_VALUE(LogEvent, '$.Properties.RequestPath') IS NOT NULL
--AND Timestamp BETWEEN '2017-01-09' AND '2017-01-10'
GROUP BY JSON_VALUE(LogEvent, '$.Properties.RequestPath')
