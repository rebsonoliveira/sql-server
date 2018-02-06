CREATE PROCEDURE Website.CitiesDelete(@CityID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Application.Cities
	WHERE CityID = @CityID
END