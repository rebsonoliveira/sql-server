------------------------------------------------------------------
--                                                              --
--  File:   usp_GetOrdersByCustomerID.SQL                       --
--  Version: 0.0.0-1006                                         --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'usp_GetOrdersByCustomerID' )
    DROP PROCEDURE usp_GetOrdersByCustomerID
GO

CREATE PROCEDURE dbo.usp_GetOrdersByCustomerID
(	@C_ID           bigint)
WITH NATIVE_COMPILATION, EXECUTE AS OWNER, SCHEMABINDING
AS BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
    DECLARE @c_f_name       varchar(20),
            @c_l_name       varchar(25),
            @c_email        varchar(50),
            @o_id           bigint,
            @o_total        decimal(9,2),
            @o_dts          datetime
          

    SELECT  @c_f_name   = C_F_NAME,
            @c_l_name   = C_L_NAME,
            @c_email    = C_EMAIL
    FROM    dbo.Customer
    WHERE   C_ID        = @C_ID

    SELECT  @o_id       = O_ID,
            @o_total    = O_TOTAL,
            @o_dts      = O_DTS
    FROM    dbo.Orders
    WHERE   O_C_ID      = @c_id
    ORDER   BY O_ID ASC

    SELECT  OL_SEQ,
            OL_PR_ID,
            OL_QTY,
            OL_PRICE
    FROM    dbo.OrderLines
    WHERE   OL_O_ID = @o_id
        
    SELECT  @c_f_name,
            @c_l_name,
            @c_email
END

GO
