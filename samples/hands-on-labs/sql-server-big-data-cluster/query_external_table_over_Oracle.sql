/*
For all items whose price was changed on a given date, compute the percentage change in inventory between the 30day period BEFORE the price change 
and the 30day period AFTER the change. Group this information by warehouse.
*/

--Replace <yourTableNameHere> with your external table name that you created pointing to Oracle table

DECLARE @q22_date VARCHAR(10);
DECLARE @q22_current_price_min DECIMAL(18, 6);
DECLARE @q22_current_price_max DECIMAL(18, 6);

SET @q22_date = '2001-05-08'; 
SET @q22_current_price_min = 0.98;
SET @q22_current_price_max = 1.5;

SELECT TOP (100) *
FROM 
(
	SELECT
		w_warehouse_name,
		i_item_id,
		SUM
		(
			CASE WHEN DATEDIFF(dd, d_date, CAST(@q22_date AS DATETIME)) >= 0
				THEN inv_quantity_on_hand
				ELSE 0 END
		) AS inv_after,
		SUM
		(
			CASE WHEN DATEDIFF(dd, d_date, CAST(@q22_date AS DATETIME)) < 0
				THEN inv_quantity_on_hand
				ELSE 0 END
		) AS inv_before
	FROM
		<yourTableNameHere> inv, --UPDATE WITH THE NAME OF YOUR EXTERNAL TABLE
		item i,
		warehouse w,
		date_dim d
	WHERE
		i_current_price BETWEEN @q22_current_price_min AND @q22_current_price_max
		AND i_item_sk = inv_item
		AND inv_warehouse = w_warehouse_sk
		AND inv_date = d_date_sk
		AND DATEDIFF(dd, d_date,  @q22_date) >= -30
		AND DATEDIFF(dd, d_date,  @q22_date) <= 30
	GROUP BY w_warehouse_name, i_item_id
) T
WHERE
	inv_before > 0
	-- CAST is required, otherwise the division is computed as an integer
	AND CAST(inv_after AS DECIMAL) / CAST(inv_before AS DECIMAL) >= 2.0 / 3.0
	AND CAST(inv_after AS DECIMAL) / CAST(inv_before AS DECIMAL) <= 3.0 / 2.0
ORDER BY w_warehouse_name, i_item_id
;

--Cleanup
--
DROP EXTERNAL TABLE [<yourTableNameHere>]
DROP EXTERNAL DATA SOURCE [<yourDataSourceNameHere>] 
DROP DATABASE SCOPED CREDENTIAL [<yourCredentialNameHere>] 