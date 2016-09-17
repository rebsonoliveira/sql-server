use insert_is_faster_in_2016
go
drop table watchinsertsfly
go
create table watchinsertsfly (col1 int, col2 char(2000) not null)
go
set nocount on
go
begin tran
declare @x int
set @x = 0
while (@x < 2500000)
begin
	set @x = @x + 1
	insert into watchinsertsfly values (@x, 'x')
end
commit tran
go
set nocount off
go
-- Build an empty table to use for INSERT...SELECT
--
drop table parallelinserts
go
select * into parallelinserts from watchinsertsfly where 1 = 2
go
checkpoint
go