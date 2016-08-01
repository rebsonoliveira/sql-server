------------------------------------------------------------------
--                                                              --
--  File:   usp_GetProductsByType.SQL                           --
--  Version: 0.0.0-1006                                         --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'usp_GetProductsByType' )
    DROP PROCEDURE usp_GetProductsByType
GO

CREATE PROCEDURE dbo.usp_GetProductsByType
(	@REQ_TYPE		int )
WITH NATIVE_COMPILATION, EXECUTE AS OWNER, SCHEMABINDING
AS BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
	SELECT  TOP 10
            PR_ID,
	        PR_NAME,
	        PR_TYPE,
	        PR_DESC,
	        PR_PRICE
    FROM    dbo.Products
    WHERE   PR_TYPE = @REQ_TYPE
    ORDER   BY PR_PRICE ASC
   
END

GO
