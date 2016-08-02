# Order Processing Benchmark using In-Memory OLTP

Sample order processing workload that can be used for benchmarking transactional processing with in-memory technologies. The scripts in this folder leverage the In-Memory OLTP feature in SQL Server 2016.

<a name=about-this-sample></a>

## About this sample

* **Applies to:** SQL Server 2016 (or higher)
* **Key features:** In-Memory OLTP
* **Workload:** OLTP
* **Programming Language:** T-SQL
* **Authors:** Jos de Bruijn, Liang Yang


## Running this sample

1. Create the database, tables, and stored procedures using the T-SQL scripts in the corresponding subfolders. 

  - The hash indexes are sized for large databases, processing billions of orders. They are appropriate for 1TB and larger database size. For smaller database and memory size, adjust the bucket counts accordingly.

2. Run the stored procedures using the following mix.

  - There are plans to make a scalable workload driver available as well. Timeline is TBD.

|Stored Procedure|Weight|Distribution|
|----------|--------|-------|
|GetOrdersByCustomerID|8|25.8%|
|GetProductsByType|6|19.4%|
|GetProductsPriceByPK	|4	|12.9%|
|ProductSelectionCriteria	|2	|6.5%|
|InsertOrder	|10	|32.3%|
|FulfillOrders	|1	|3.2%|



## Workload description

|Transaction	|Type|	Description|
|-----|-----|------|
|GetOrdersByCustomerID	|Read-only	|Select customer info, orders, and order lines for a given customer.|
|GetProductsByType	|Read-only	|Select top 10 products of a given type, ordered by price.|
|GetProductsPriceByPK	|Read-only	|Select all products in a given ID range, ordered by price.|
|ProductSelectionCriteria	|Read-only	|Select top 20 products in a given ID range with the highest computed “closeness” factor against the |PurchaseCriteria|
|InsertOrder	|Read-write	|Insert a new order for a given customer with up to five order lines.|
|FulfillOrders	|Read-write	|Fulfill 10 oldest outstanding orders.|



## More information
- [In-Memory OLTP (In-Memory Optimization)] (https://msdn.microsoft.com/library/dn133186.aspx)
- [OLTP and database management] (https://www.microsoft.com/en-us/server-cloud/solutions/oltp-database-management.aspx)
