------------------------------------------------------------------
--                                                              --
--  File:   usp_GetProductsPriceByPK.SQL                        --
--  Version: 0.0.0-1006                                         --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'usp_GetProductsPriceByPK' )
    DROP PROCEDURE usp_GetProductsPriceByPK
GO

CREATE PROCEDURE dbo.usp_GetProductsPriceByPK
(	@LOWER_PK		bigint,
	@UPPER_PK       bigint)
WITH NATIVE_COMPILATION, EXECUTE AS OWNER, SCHEMABINDING
AS BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
	SELECT  PR_ID,
	        PR_NAME,
	        PR_TYPE,
	        PR_DESC,
	        PR_PRICE
    FROM    dbo.Products
    WHERE   PR_ID BETWEEN @LOWER_PK AND @UPPER_PK
    ORDER   BY PR_PRICE ASC
END

GO
