CREATE PROCEDURE Website.StateProvincesDelete(@StateProvinceID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Application.StateProvinces
	WHERE StateProvinceID = @StateProvinceID;
END