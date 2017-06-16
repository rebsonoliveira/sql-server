CREATE TABLE DataLoadSimulation.[ColdRoomTemperatures_temp] (
    [ColdRoomTemperatureID] BIGINT                                      NOT NULL,
    [ColdRoomSensorNumber]  INT                                         NOT NULL,
    [RecordedWhen]          DATETIME2 (7)                               NOT NULL,
    [Temperature]           DECIMAL (10, 2)                             NOT NULL,
    [ValidFrom]             DATETIME2 (7) NOT NULL,
    [ValidTo]               DATETIME2 (7) NOT NULL,
    INDEX [IX_DataSimulation_ColdRoomTemperatures_ColdRoomSensorNumber] 
		NONCLUSTERED HASH ([ColdRoomSensorNumber]) WITH (BUCKET_COUNT=100000)
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY=SCHEMA_ONLY);

