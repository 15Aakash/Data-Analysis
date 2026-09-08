USE CustomerSalesInventoryOps;
GO

CREATE OR ALTER VIEW analytics.vw_SalesDetail
AS

SELECT
    s.SalesKey,
    s.StagingTransactionID,
    s.Invoice,

    c.CustomerKey,
    c.CustomerID,
    c.Country AS CustomerCountry,

    p.ProductKey,
    p.StockCode,
    p.ProductDescription,

    d.DateKey,
    d.FullDate,
    d.CalendarYear,
    d.CalendarQuarter,
    d.MonthNumber,
    d.MonthName,
    d.YearMonth,
    d.WeekNumber,
    d.DayName,
    d.IsWeekend,

    s.Quantity,
    s.UnitPrice,
    s.GrossRevenue,

    s.Country AS TransactionCountry,
    s.InvoiceDate

FROM core.Sales s

INNER JOIN core.Products p
    ON s.ProductKey = p.ProductKey

INNER JOIN core.Dates d
    ON s.DateKey = d.DateKey

LEFT JOIN core.Customers c
    ON s.CustomerKey = c.CustomerKey;
GO


CREATE OR ALTER VIEW analytics.vw_MonthlySalesPerformance
AS

SELECT
    d.CalendarYear,
    d.MonthNumber,
    d.MonthName,
    d.YearMonth,

    COUNT(DISTINCT s.Invoice) AS TotalOrders,

    COUNT(DISTINCT s.CustomerKey) AS IdentifiedCustomers,

    SUM(s.Quantity) AS UnitsSold,

    CAST(
        SUM(s.GrossRevenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(s.GrossRevenue)
        / NULLIF(
            COUNT(DISTINCT s.Invoice),
            0
        )
        AS DECIMAL(18,2)
    ) AS AverageOrderValue

FROM core.Sales s

INNER JOIN core.Dates d
    ON s.DateKey = d.DateKey

GROUP BY
    d.CalendarYear,
    d.MonthNumber,
    d.MonthName,
    d.YearMonth;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerPerformance
AS

WITH CustomerSales AS
(
    SELECT
        c.CustomerKey,
        c.CustomerID,
        c.Country,

        MIN(s.InvoiceDate) AS FirstPurchaseDate,
        MAX(s.InvoiceDate) AS LastPurchaseDate,

        COUNT(DISTINCT s.Invoice) AS TotalOrders,

        COUNT(DISTINCT s.ProductKey) AS UniqueProductsPurchased,

        SUM(s.Quantity) AS UnitsPurchased,

        SUM(s.GrossRevenue) AS Revenue

    FROM core.Customers c

    INNER JOIN core.Sales s
        ON c.CustomerKey = s.CustomerKey

    GROUP BY
        c.CustomerKey,
        c.CustomerID,
        c.Country
),

CustomerCancellations AS
(
    SELECT
        CustomerKey,

        COUNT(DISTINCT CancellationInvoice)
            AS CancellationInvoices,

        SUM(CancelledQuantity)
            AS CancelledUnits,

        SUM(CancellationValue)
            AS CancellationValue

    FROM core.Cancellations

    WHERE CustomerKey IS NOT NULL

    GROUP BY CustomerKey
)

SELECT
    s.CustomerKey,
    s.CustomerID,
    s.Country,

    s.FirstPurchaseDate,
    s.LastPurchaseDate,

    s.TotalOrders,
    s.UniqueProductsPurchased,
    s.UnitsPurchased,

    CAST(
        s.Revenue
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        s.Revenue /
        NULLIF(s.TotalOrders, 0)
        AS DECIMAL(18,2)
    ) AS AverageOrderValue,

    ISNULL(c.CancellationInvoices, 0)
        AS CancellationInvoices,

    ISNULL(c.CancelledUnits, 0)
        AS CancelledUnits,

    CAST(
        ISNULL(c.CancellationValue, 0)
        AS DECIMAL(18,2)
    ) AS CancellationValue,

    CAST(
        ISNULL(c.CancellationValue, 0)
        /
        NULLIF(
            s.Revenue,
            0
        ) * 100
        AS DECIMAL(10,2)
    ) AS CancellationValuePct

FROM CustomerSales s

LEFT JOIN CustomerCancellations c
    ON s.CustomerKey = c.CustomerKey;
GO


CREATE OR ALTER VIEW analytics.vw_ProductPerformance
AS

WITH ProductSales AS
(
    SELECT
        p.ProductKey,
        p.StockCode,
        p.ProductDescription,

        COUNT(DISTINCT s.Invoice)
            AS OrdersContainingProduct,

        COUNT(DISTINCT s.CustomerKey)
            AS UniqueCustomers,

        SUM(s.Quantity)
            AS UnitsSold,

        SUM(s.GrossRevenue)
            AS Revenue,

        AVG(
            CAST(s.UnitPrice AS DECIMAL(18,4))
        ) AS AverageSellingPrice,

        MIN(s.InvoiceDate)
            AS FirstSaleDate,

        MAX(s.InvoiceDate)
            AS LastSaleDate

    FROM core.Products p

    INNER JOIN core.Sales s
        ON p.ProductKey = s.ProductKey

    GROUP BY
        p.ProductKey,
        p.StockCode,
        p.ProductDescription
),

ProductCancellations AS
(
    SELECT
        ProductKey,

        SUM(CancelledQuantity)
            AS CancelledUnits,

        SUM(CancellationValue)
            AS CancellationValue

    FROM core.Cancellations

    GROUP BY ProductKey
)

SELECT
    s.ProductKey,
    s.StockCode,
    s.ProductDescription,

    s.OrdersContainingProduct,
    s.UniqueCustomers,
    s.UnitsSold,

    CAST(
        s.Revenue
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        s.AverageSellingPrice
        AS DECIMAL(18,2)
    ) AS AverageSellingPrice,

    ISNULL(c.CancelledUnits, 0)
        AS CancelledUnits,

    CAST(
        ISNULL(c.CancellationValue, 0)
        AS DECIMAL(18,2)
    ) AS CancellationValue,

    CAST(
        ISNULL(c.CancelledUnits, 0) * 100.0
        /
        NULLIF(
            s.UnitsSold
            + ISNULL(c.CancelledUnits, 0),
            0
        )
        AS DECIMAL(10,2)
    ) AS UnitCancellationRatePct,

    s.FirstSaleDate,
    s.LastSaleDate

FROM ProductSales s

LEFT JOIN ProductCancellations c
    ON s.ProductKey = c.ProductKey;
GO

CREATE OR ALTER VIEW analytics.vw_CountryPerformance
AS

SELECT
    s.Country,

    COUNT(DISTINCT s.CustomerKey)
        AS IdentifiedCustomers,

    COUNT(DISTINCT s.Invoice)
        AS Orders,

    SUM(s.Quantity)
        AS UnitsSold,

    CAST(
        SUM(s.GrossRevenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(s.GrossRevenue)
        /
        NULLIF(
            COUNT(DISTINCT s.Invoice),
            0
        )
        AS DECIMAL(18,2)
    ) AS AverageOrderValue

FROM core.Sales s

GROUP BY s.Country;
GO

CREATE OR ALTER VIEW analytics.vw_CancellationPerformance
AS

SELECT
    d.YearMonth,

    COUNT(DISTINCT c.CancellationInvoice)
        AS CancellationInvoices,

    SUM(c.CancelledQuantity)
        AS CancelledUnits,

    CAST(
        SUM(c.CancellationValue)
        AS DECIMAL(18,2)
    ) AS CancellationValue

FROM core.Cancellations c

INNER JOIN core.Dates d
    ON c.DateKey = d.DateKey

GROUP BY d.YearMonth;
GO

SELECT
    'Sales Detail' AS ViewName,
    COUNT(*) AS RecordCount
FROM analytics.vw_SalesDetail

UNION ALL

SELECT
    'Customer Performance',
    COUNT(*)
FROM analytics.vw_CustomerPerformance

UNION ALL

SELECT
    'Product Performance',
    COUNT(*)
FROM analytics.vw_ProductPerformance

UNION ALL

SELECT
    'Monthly Sales Performance',
    COUNT(*)
FROM analytics.vw_MonthlySalesPerformance

UNION ALL

SELECT
    'Country Performance',
    COUNT(*)
FROM analytics.vw_CountryPerformance

UNION ALL

SELECT
    'Cancellation Performance',
    COUNT(*)
FROM analytics.vw_CancellationPerformance;

SELECT TOP 10
    CustomerID,
    Country,
    TotalOrders,
    Revenue,
    AverageOrderValue,
    CancellationValuePct
FROM analytics.vw_CustomerPerformance
ORDER BY Revenue DESC;

SELECT TOP 10
    StockCode,
    ProductDescription,
    UnitsSold,
    Revenue,
    UniqueCustomers,
    UnitCancellationRatePct
FROM analytics.vw_ProductPerformance
ORDER BY Revenue DESC;

SELECT TOP 20
    StockCode,
    ProductDescription,
    UnitsSold,
    CancelledUnits,
    UnitCancellationRatePct,
    Revenue
FROM analytics.vw_ProductPerformance
WHERE UnitsSold >= 100
ORDER BY UnitCancellationRatePct DESC;

SELECT TOP 15
    Country,
    IdentifiedCustomers,
    Orders,
    Revenue,
    AverageOrderValue
FROM analytics.vw_CountryPerformance
WHERE Country <> 'United Kingdom'
ORDER BY Revenue DESC;

SELECT
    'Sales Detail' AS ViewName,
    COUNT(*) AS RecordCount
FROM analytics.vw_SalesDetail

UNION ALL

SELECT
    'Customer Performance',
    COUNT(*)
FROM analytics.vw_CustomerPerformance

UNION ALL

SELECT
    'Product Performance',
    COUNT(*)
FROM analytics.vw_ProductPerformance

UNION ALL

SELECT
    'Monthly Sales Performance',
    COUNT(*)
FROM analytics.vw_MonthlySalesPerformance

UNION ALL

SELECT
    'Country Performance',
    COUNT(*)
FROM analytics.vw_CountryPerformance

UNION ALL

SELECT
    'Cancellation Performance',
    COUNT(*)
FROM analytics.vw_CancellationPerformance;

SELECT TOP 10
    CustomerID,
    Country,
    TotalOrders,
    Revenue,
    AverageOrderValue,
    CancellationValuePct
FROM analytics.vw_CustomerPerformance
ORDER BY Revenue DESC;

SELECT TOP 10
    StockCode,
    ProductDescription,
    UnitsSold,
    Revenue,
    UniqueCustomers,
    UnitCancellationRatePct
FROM analytics.vw_ProductPerformance
ORDER BY Revenue DESC;

SELECT TOP 20
    StockCode,
    ProductDescription,
    UnitsSold,
    CancelledUnits,
    UnitCancellationRatePct,
    Revenue
FROM analytics.vw_ProductPerformance
WHERE UnitsSold >= 100
ORDER BY UnitCancellationRatePct DESC;

SELECT TOP 15
    Country,
    IdentifiedCustomers,
    Orders,
    Revenue,
    AverageOrderValue
FROM analytics.vw_CountryPerformance
WHERE Country <> 'United Kingdom'
ORDER BY Revenue DESC;