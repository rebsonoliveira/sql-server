------------------------------------------------------------------
--                                                              --
--  File:   usp_FulfillOrders.SQL                     --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'usp_FulfillOrders' )
    DROP PROCEDURE usp_FulfillOrders
GO

CREATE PROCEDURE dbo.usp_FulfillOrders
WITH NATIVE_COMPILATION, EXECUTE AS OWNER, SCHEMABINDING
AS BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
    DECLARE @OrderID			bigint,
            @OrderCID			bigint,
            @FulfillmentDate	datetime = GETDATE(),
            @OrdersToProcess    int = 10

    WHILE (@OrdersToProcess > 0)
    BEGIN
        SELECT  TOP 1
                @OrderID    = O_ID,
                @OrderCID   = O_C_ID
        FROM    dbo.Orders
        WHERE   O_FM_DTS = '1900-01-01 00:00:00.000'
        ORDER   BY O_DTS ASC

        IF @OrderID IS NOT NULL
        BEGIN
            -- update the order with the fulfilment date
            UPDATE  dbo.Orders
            SET     O_FM_DTS    = @FulfillmentDate
            WHERE   O_ID        = @OrderID

            -- insert the data into the FulFillment table
            INSERT INTO dbo.Fulfillment (FM_O_ID, FM_C_ID, FM_DTS) VALUES (@OrderID, @OrderCID, @FulfillmentDate)
    
            SELECT  @OrderID AS 'OrderID Fulfilled'
        END

        SET @OrdersToProcess = @OrdersToProcess - 1
    END
END
