------------------------------------------------------------------
--                                                              --
--  File:   usp_InsertOrder.SQL                                 --
--  Version: 0.0.0-1006                                         --
--                                                              --
------------------------------------------------------------------
SET QUOTED_IDENTIFIER OFF
GO

SET ANSI_NULLS ON
GO

USE InMemDB
GO

IF EXISTS ( SELECT name FROM sysobjects WHERE name = 'usp_InsertOrder' )
    DROP PROCEDURE usp_InsertOrder
GO

CREATE PROCEDURE [dbo].[usp_InsertOrder]
(	@C_ID               bigint,
	@OL_SEQ_1			tinyint,
	@OL_PR_ID_1			bigint,
	@OL_PR_QTY_1		int,
	@OL_SEQ_2			tinyint,
	@OL_PR_ID_2			bigint,
	@OL_PR_QTY_2		int,
	@OL_SEQ_3			tinyint,
	@OL_PR_ID_3			bigint,
	@OL_PR_QTY_3		int,
	@OL_SEQ_4			tinyint,
	@OL_PR_ID_4			bigint,
	@OL_PR_QTY_4		int,
	@OL_SEQ_5			tinyint,
	@OL_PR_ID_5			bigint,
	@OL_PR_QTY_5		int)
WITH NATIVE_COMPILATION, EXECUTE AS OWNER, SCHEMABINDING
AS BEGIN ATOMIC WITH
(
    TRANSACTION ISOLATION LEVEL = SNAPSHOT,
    LANGUAGE = N'us_english'
)
    DECLARE @Order_Id           bigint,
            @TotalPrice         decimal(12,2) = 0,
			@NullDate			datetime = '1900-01-01',
			@SeqNumber			tinyint = 0,
			@SeqCount			tinyint = 5,
			@SeqID				tinyint,
			@PR_ID				bigint,
			@PR_Qty				int,
            @PR_Price           numeric(9,2),
            @InsertFlag         bit = 0

    --insert an Order record to claim the O_ID
    INSERT INTO dbo.Orders (O_C_ID, O_TOTAL, O_DTS, O_FM_DTS) VALUES (@C_ID, 0, GETDATE(), @NullDate)
    
    -- get the inserted order id
    SELECT  @order_id   = SCOPE_IDENTITY()

    -- now process the order lines
	WHILE (@SeqNumber < @SeqCount)
	BEGIN
		SELECT	@SeqNumber	= @SeqNumber + 1

		IF @SeqNumber = 1
		BEGIN
			SELECT	@SeqID	    = @OL_SEQ_1,
					@PR_ID	    = @OL_PR_ID_1,
					@PR_Qty	    = @OL_PR_QTY_1,
                    @PR_Price   = PR_PRICE
            FROM    dbo.Products
            WHERE   PR_ID       = @OL_PR_ID_1                     

            IF @@ROWCOUNT > 0
            BEGIN
                SET     @InsertFlag = 1
                SET     @TotalPrice = @TotalPrice + (@PR_QTY * @PR_Price)
            END
        END

		IF @SeqNumber = 2
		BEGIN
			SELECT	@SeqID	= @OL_SEQ_2,
					@PR_ID	= @OL_PR_ID_2,
					@PR_Qty	= @OL_PR_QTY_2,
                    @PR_Price   = PR_PRICE
            FROM    dbo.Products
            WHERE   PR_ID       = @OL_PR_ID_2 

            IF @@ROWCOUNT > 0
            BEGIN
                SET     @InsertFlag = 1
                SET     @TotalPrice = @TotalPrice + (@PR_QTY * @PR_Price)
            END
        END

		IF @SeqNumber = 3
		BEGIN
			SELECT	@SeqID	= @OL_SEQ_3,
					@PR_ID	= @OL_PR_ID_3,
					@PR_Qty	= @OL_PR_QTY_3,
                    @PR_Price   = PR_PRICE
            FROM    dbo.Products
            WHERE   PR_ID       = @OL_PR_ID_3 

            IF @@ROWCOUNT > 0
            BEGIN
                SET     @InsertFlag = 1
                SET     @TotalPrice = @TotalPrice + (@PR_QTY * @PR_Price)
            END
        END

		IF @SeqNumber = 4
		BEGIN
			SELECT	@SeqID	= @OL_SEQ_4,
					@PR_ID	= @OL_PR_ID_4,
					@PR_Qty	= @OL_PR_QTY_4,
                    @PR_Price   = PR_PRICE
            FROM    dbo.Products
            WHERE   PR_ID       = @OL_PR_ID_4 

            IF @@ROWCOUNT > 0
            BEGIN
                SET     @InsertFlag = 1
                SET     @TotalPrice = @TotalPrice + (@PR_QTY * @PR_Price)
            END
        END

		IF @SeqNumber = 5
		BEGIN
			SELECT	@SeqID	= @OL_SEQ_5,
					@PR_ID	= @OL_PR_ID_5,
					@PR_Qty	= @OL_PR_QTY_5,
                    @PR_Price   = PR_PRICE
            FROM    dbo.Products
            WHERE   PR_ID       = @OL_PR_ID_5 

            IF @@ROWCOUNT > 0
            BEGIN
                SET     @InsertFlag = 1
                SET     @TotalPrice = @TotalPrice + (@PR_QTY * @PR_Price)
            END
        END
	
		IF (@InsertFlag = 1)
        BEGIN
			INSERT INTO dbo.OrderLines VALUES (@order_id, @SeqID, @PR_ID, @PR_QTY, @PR_Price, GETDATE())
            SET     @InsertFlag = 0
        END
	END

    -- now update the order with the total price
    UPDATE  dbo.Orders
    SET     O_TOTAL = @TotalPrice
	WHERE   O_ID    = @Order_id AND
			O_C_ID  = @C_ID

   SELECT  @order_id,
           @C_ID,
           @TotalPrice

END


GO


