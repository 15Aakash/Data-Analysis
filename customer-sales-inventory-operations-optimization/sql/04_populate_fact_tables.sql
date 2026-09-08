USE CustomerSalesInventoryOps;
GO

SELECT COUNT(*) AS UnmatchedSalesProducts
FROM staging.Transactions s
LEFT JOIN core.Products p
    ON UPPER(LTRIM(RTRIM(s.StockCode))) = p.StockCode
WHERE s.TransactionType = 'Merchandise Sale'
  AND p.ProductKey IS NULL;

SELECT COUNT(*) AS UnmatchedSalesDates
FROM staging.Transactions s
LEFT JOIN core.Dates d
    ON CAST(s.InvoiceDate AS DATE) = d.FullDate
WHERE s.TransactionType = 'Merchandise Sale'
  AND d.DateKey IS NULL;

SELECT
    SUM(
        CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END
    ) AS UnmatchedCancellationProducts,

    SUM(
        CASE
            WHEN s.CustomerID IS NOT NULL
             AND c.CustomerKey IS NULL
            THEN 1 ELSE 0
        END
    ) AS UnmatchedCancellationCustomers,

    SUM(
        CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END
    ) AS UnmatchedCancellationDates

FROM staging.Transactions s

LEFT JOIN core.Products p
    ON UPPER(LTRIM(RTRIM(s.StockCode))) = p.StockCode

LEFT JOIN core.Customers c
    ON s.CustomerID = c.CustomerID

LEFT JOIN core.Dates d
    ON CAST(s.InvoiceDate AS DATE) = d.FullDate

WHERE s.TransactionType = 'Merchandise Cancellation';

INSERT INTO core.Sales
(
    StagingTransactionID,
    Invoice,
    ProductKey,
    CustomerKey,
    DateKey,
    Quantity,
    UnitPrice,
    GrossRevenue,
    Country,
    InvoiceDate
)

SELECT
    s.StagingTransactionID,
    s.Invoice,
    p.ProductKey,
    c.CustomerKey,
    d.DateKey,
    s.Quantity,
    s.UnitPrice,
    s.TransactionValue,
    s.Country,
    s.InvoiceDate

FROM staging.Transactions s

INNER JOIN core.Products p
    ON UPPER(LTRIM(RTRIM(s.StockCode))) = p.StockCode

LEFT JOIN core.Customers c
    ON s.CustomerID = c.CustomerID

INNER JOIN core.Dates d
    ON CAST(s.InvoiceDate AS DATE) = d.FullDate

WHERE s.TransactionType = 'Merchandise Sale';
GO

SELECT COUNT(*) AS SalesRows
FROM core.Sales;

SELECT
    SUM(GrossRevenue) AS GrossMerchandiseRevenue
FROM core.Sales;

INSERT INTO core.Cancellations
(
    StagingTransactionID,
    CancellationInvoice,
    ProductKey,
    CustomerKey,
    DateKey,
    CancelledQuantity,
    UnitPrice,
    CancellationValue,
    Country,
    CancellationDate
)

SELECT
    s.StagingTransactionID,
    s.Invoice,
    p.ProductKey,
    c.CustomerKey,
    d.DateKey,

    ABS(s.Quantity),

    s.UnitPrice,

    ABS(s.Quantity) * s.UnitPrice,

    s.Country,
    s.InvoiceDate

FROM staging.Transactions s

INNER JOIN core.Products p
    ON UPPER(LTRIM(RTRIM(s.StockCode))) = p.StockCode

LEFT JOIN core.Customers c
    ON s.CustomerID = c.CustomerID

INNER JOIN core.Dates d
    ON CAST(s.InvoiceDate AS DATE) = d.FullDate

WHERE s.TransactionType = 'Merchandise Cancellation';
GO

SELECT COUNT(*) AS CancellationRows
FROM core.Cancellations;

SELECT
    SUM(CancelledQuantity) AS CancelledUnits,
    SUM(CancellationValue) AS CancellationValue
FROM core.Cancellations;

SELECT
    'Sales' AS FactTable,
    COUNT(*) AS RecordCount
FROM core.Sales

UNION ALL

SELECT
    'Cancellations',
    COUNT(*)
FROM core.Cancellations;