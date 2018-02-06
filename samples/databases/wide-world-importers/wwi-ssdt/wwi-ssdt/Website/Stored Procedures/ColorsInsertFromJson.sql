CREATE PROCEDURE [Website].[ColorsInsertFromJson](@ColorsJson NVARCHAR(MAX), @UserID int)
WITH EXECUTE AS OWNER
AS BEGIN
	INSERT INTO Warehouse.Colors(ColorName,LastEditedBy)
			OUTPUT  INSERTED.ColorID
			SELECT ColorName,@UserID
			FROM OPENJSON(@ColorsJson)
				WITH (ColorName nvarchar(50))
END