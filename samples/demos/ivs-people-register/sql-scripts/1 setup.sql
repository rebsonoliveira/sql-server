CREATE TABLE dbo.People(
	id int primary key identity,
	name nvarchar(50),
	surname nvarchar(50),
	address nvarchar(200),
	town nvarchar(50)
)
GO

alter database current set compatibility_level = 130;
go

declare @people nvarchar(max) = 
N'[{"name":"渡邉󠄐","surname":"俊","address":"神奈川県藤沢市辻堂１－１－４１","town":"辻堂"},{"name":"渡邉󠄑","surname":"龍󠄄之介","address":"神奈川県藤沢市辻󠄀堂１－５０３","town":"辻󠄀堂"},{"name":"渡邉󠄒","surname":"博美","address":"兵庫県芦屋市精道町7番6号","town":"芦屋"},{"name":"田辺","surname":"浩一","address":"東京都港区港南２－１６－３","town":"港南"},{"name":"田辺󠄁","surname":"洋子","address":"鹿児島県薩摩川内市神田町3番22号","town":"薩摩"},{"name":"田辺󠄂","surname":"大輔","address":"愛知県名古屋市熱田区川並町２－１","town":"川並"},{"name":"斎藤","surname":"由紀","address":"滋賀県東近江市五個荘川並󠄂町１－１","town":"川並󠄂"},{"name":"齋󠄂藤","surname":"俊󠄁","address":"東京都葛󠄀飾区小岩１－１－１","town":"葛󠄀飾"},{"name":"齋󠄃藤","surname":"龍一","address":"岡山県備前市東片上126番地 ","town":"芦󠄆別市"},{"name":"龍地","surname":"花子","address":"茨城県水戸市備󠄁前町816-2","town":"芦󠄂別市"},{"name":"龍󠄃地","surname":"次郎","address":"奈良県天理市備󠄂前町2-2-2","town":"芦別市"},{"name":"伴","surname":"龍󠄅二","address":"兵庫県芦󠄀屋市精道町7番6号","town":"芦󠄂屋"}]';

insert into people (name, surname, address, town)
select rtrim(name), surname, address, town
from openjson(@people)
with (name nvarchar(50),surname nvarchar(50),address nvarchar(200),town nvarchar(50))