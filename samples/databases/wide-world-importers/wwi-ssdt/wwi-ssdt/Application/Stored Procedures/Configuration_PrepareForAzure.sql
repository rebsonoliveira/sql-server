CREATE PROCEDURE [Application].[Configuration_PrepareForAzure]
AS

  EXEC [Application].[Configuration_RemoveColumnstoreIndexing]

  EXEC [DataLoadSimulation].[DeactivateTemporalTablesBeforeDataLoad]

  EXEC [Application].[Configuration_DisableInMemory]
  
RETURN 0
