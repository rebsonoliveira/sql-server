CREATE PROCEDURE [Website].[StateProvincesInsertFromJson](@StateProvinces NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Application.StateProvinces(StateProvinceCode,StateProvinceName,CountryID,SalesTerritory,LatestRecordedPopulation,LastEditedBy)
	OUTPUT  INSERTED.StateProvinceID
	SELECT StateProvinceCode,StateProvinceName,CountryID,SalesTerritory,LatestRecordedPopulation,@UserID
	FROM OPENJSON(@StateProvinces)
		WITH (
			StateProvinceCode nvarchar(5) N'strict $.StateProvinceCode',
			StateProvinceName nvarchar(50) N'strict $.StateProvinceName',
			CountryID int N'strict $.CountryID',
			SalesTerritory nvarchar(50) N'strict $.SalesTerritory',
			LatestRecordedPopulation bigint)
END