CREATE PROCEDURE Website.CountriesDelete(@CountryID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Application.Countries
	WHERE CountryID = @CountryID;
END