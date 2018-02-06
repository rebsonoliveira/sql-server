
CREATE PROCEDURE [Website].[ColorsDelete](@ColorID int)
WITH EXECUTE AS OWNER
AS BEGIN
	DELETE Warehouse.Colors
	WHERE ColorID = @ColorID
END