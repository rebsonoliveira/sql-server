CREATE PROCEDURE [dbo].[InsertMeterMeasurementHistory] 
	@MeterID INT
AS
BEGIN 
	BEGIN TRAN		
		INSERT INTO dbo.MeterMeasurementHistory (MeterID, MeasurementInkWh, PostalCode, MeasurementDate) 
		SELECT TOP 250000 MeterID, MeasurementInkWh, PostalCode, MeasurementDate FROM dbo.MeterMeasurement
		WHERE MeterID = @MeterID

		DELETE TOP (250000) FROM dbo.MeterMeasurement WHERE MeterID = @MeterID
	COMMIT
END;