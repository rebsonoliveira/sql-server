declare @source xml = '<place source XML result here>';
declare @target xml = '<place target xml result here>';

with 
src as(
select property = x.v.value('name[1]', 'nvarchar(300)'),
		value = x.v.value('value[1]', 'nvarchar(300)')
from @source.nodes('//row') x(v)
UNION ALL
select property = 'DB-CONFIG:'+y.v.value('local-name(.)', 'nvarchar(300)'),
		value = y.v.value('.[1]', 'nvarchar(300)')
from @source.nodes('//db') x(v)
cross apply x.v.nodes('*') y(v)
UNION ALL
select property = 'TEMPDB:'+y.v.value('local-name(.)', 'nvarchar(300)'),
		value = y.v.value('.[1]', 'nvarchar(300)')
from @source.nodes('//tempdb') x(v)
cross apply x.v.nodes('*') y(v)
),
tgt as(
select property = x.v.value('name[1]', 'nvarchar(300)'),
		value = x.v.value('value[1]', 'nvarchar(300)')
from @target.nodes('//row') x(v)
UNION ALL
select property = 'DB-CONFIG:'+y.v.value('local-name(.)', 'nvarchar(300)'),
		value = y.v.value('.[1]', 'nvarchar(300)')
from @target.nodes('//db') x(v)
cross apply x.v.nodes('*') y(v)
UNION ALL
select property = 'TEMPDB:'+y.v.value('local-name(.)', 'nvarchar(300)'),
		value = y.v.value('.[1]', 'nvarchar(300)')
from @target.nodes('//tempdb') x(v)
cross apply x.v.nodes('*') y(v)
)
select property = isnull(src.property, tgt.property),
		source = src.value, target = tgt.value
from src full outer join tgt on src.property = tgt.property
where (src.value <> tgt.value
or src.value is null and tgt.value is not null
or src.value is not null and tgt.value is null)
order by isnull(src.property, tgt.property)
