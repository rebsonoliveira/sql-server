------------------------------------------------------------------
--                                                              --
--  File:   Create_TVPs.SQL                                     --
--  Version: 0.0.0-1003                                         --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO


IF EXISTS ( SELECT name FROM sysobjects WHERE xtype = 'TT' AND name LIKE 'TT_InMemDBTVPOrders%' )
    DROP TYPE dbo.InMemDBTVPOrders
GO

CREATE TYPE dbo.InMemDBTVPOrders AS TABLE(
    SEQ     int         NOT NULL,
	PR_ID   bigint      NOT NULL,
    PR_QTY  int

    INDEX PK_IMDBTVPOrders NONCLUSTERED HASH ( SEQ )
		WITH (BUCKET_COUNT =  10)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO


CREATE TYPE dbo.InMemDBTVPTypes AS TABLE(
	REQ_TYPE	tinyint		NOT NULL

	INDEX PK_IMDBTVPTypes NONCLUSTERED HASH ( REQ_TYPE )
		WITH (BUCKET_COUNT = 10)
)
WITH ( MEMORY_OPTIMIZED = ON )
GO
