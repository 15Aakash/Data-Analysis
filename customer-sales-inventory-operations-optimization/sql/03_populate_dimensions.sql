USE CustomerSalesInventoryOps;
GO

CREATE INDEX IX_StagingTransactions_CustomerID
ON staging.Transactions(CustomerID)
INCLUDE (
    TransactionType,
    Country,
    InvoiceDate
);
GO

CREATE INDEX IX_StagingTransactions_StockCode
ON staging.Transactions(StockCode)
INCLUDE (
    TransactionType,
    Description,
    InvoiceDate
);
GO

SELECT
    i.name AS IndexName
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('staging.Transactions')
  AND i.name IN
  (
      'IX_StagingTransactions_CustomerID',
      'IX_StagingTransactions_StockCode',
      'IX_StagingTransactions_InvoiceDate'
  )
ORDER BY i.name;

CREATE INDEX IX_StagingTransactions_InvoiceDate
ON staging.Transactions(InvoiceDate);
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_StagingTransactions_InvoiceDate'
      AND object_id = OBJECT_ID('staging.Transactions')
)
BEGIN
    CREATE INDEX IX_StagingTransactions_InvoiceDate
    ON staging.Transactions(InvoiceDate);
END;
GO

SELECT
    'Customers' AS TableName,
    COUNT(*) AS RecordCount
FROM core.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM core.Products

UNION ALL

SELECT
    'Dates',
    COUNT(*)
FROM core.Dates;

SELECT
    'Customers' AS TableName,
    COUNT(*) AS RecordCount
FROM core.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM core.Products

UNION ALL

SELECT
    'Dates',
    COUNT(*)
FROM core.Dates;

SELECT
    COUNT(*) AS CustomerRows,
    COUNT(DISTINCT CustomerID) AS UniqueCustomerIDs
FROM core.Customers;

SELECT
    COUNT(*) AS ProductRows,
    COUNT(DISTINCT StockCode) AS UniqueStockCodes
FROM core.Products;

SELECT
    MIN(FullDate) AS FirstDate,
    MAX(FullDate) AS LastDate,
    COUNT(*) AS DateCount
FROM core.Dates;

SELECT TOP 10 *
FROM core.Customers
ORDER BY CustomerKey;

SELECT
    'Customers' AS TableName,
    COUNT(*) AS RecordCount
FROM core.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM core.Products

UNION ALL

SELECT
    'Dates',
    COUNT(*)
FROM core.Dates;

SET DATEFIRST 1;
GO

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT
    @StartDate = CAST(MIN(InvoiceDate) AS DATE),
    @EndDate = CAST(MAX(InvoiceDate) AS DATE)
FROM staging.Transactions;

;WITH DateSeries AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)

INSERT INTO core.Dates
(
    DateKey,
    FullDate,
    CalendarYear,
    CalendarQuarter,
    MonthNumber,
    MonthName,
    YearMonth,
    WeekNumber,
    DayOfMonth,
    DayOfWeekNumber,
    DayName,
    IsWeekend
)

SELECT
    CAST(CONVERT(CHAR(8), FullDate, 112) AS INT),
    FullDate,
    YEAR(FullDate),
    DATEPART(QUARTER, FullDate),
    MONTH(FullDate),
    DATENAME(MONTH, FullDate),
    CONVERT(CHAR(7), FullDate, 126),
    DATEPART(ISO_WEEK, FullDate),
    DAY(FullDate),
    DATEPART(WEEKDAY, FullDate),
    DATENAME(WEEKDAY, FullDate),

    CASE
        WHEN DATEPART(WEEKDAY, FullDate) IN (6, 7)
        THEN 1
        ELSE 0
    END

FROM DateSeries

OPTION (MAXRECURSION 0);
GO

SELECT COUNT(*) AS DateCount
FROM core.Dates;

;WITH RelevantCustomerTransactions AS
(
    SELECT
        CustomerID,
        Country,
        InvoiceDate,
        TransactionType
    FROM staging.Transactions
    WHERE CustomerID IS NOT NULL
      AND TransactionType IN
      (
          'Merchandise Sale',
          'Merchandise Cancellation'
      )
),

CustomerCountryStats AS
(
    SELECT
        CustomerID,
        Country,
        COUNT(*) AS CountryTransactionCount,
        MAX(InvoiceDate) AS LatestCountryDate
    FROM RelevantCustomerTransactions
    GROUP BY
        CustomerID,
        Country
),

RankedCustomerCountry AS
(
    SELECT
        CustomerID,
        Country,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY
                CountryTransactionCount DESC,
                LatestCountryDate DESC,
                Country
        ) AS CountryRank

    FROM CustomerCountryStats
),

CustomerPurchaseDates AS
(
    SELECT
        CustomerID,

        MIN(
            CASE
                WHEN TransactionType = 'Merchandise Sale'
                THEN InvoiceDate
            END
        ) AS FirstPurchaseDate,

        MAX(
            CASE
                WHEN TransactionType = 'Merchandise Sale'
                THEN InvoiceDate
            END
        ) AS LastPurchaseDate

    FROM RelevantCustomerTransactions
    GROUP BY CustomerID
)

INSERT INTO core.Customers
(
    CustomerID,
    Country,
    FirstPurchaseDate,
    LastPurchaseDate
)

SELECT
    d.CustomerID,
    c.Country,
    d.FirstPurchaseDate,
    d.LastPurchaseDate

FROM CustomerPurchaseDates d

LEFT JOIN RankedCustomerCountry c
    ON d.CustomerID = c.CustomerID
   AND c.CountryRank = 1;
GO

SELECT
    COUNT(*) AS CustomerRows,
    COUNT(DISTINCT CustomerID) AS UniqueCustomerIDs
FROM core.Customers;

;WITH RelevantProductTransactions AS
(
    SELECT
        StockCode,
        Description,
        InvoiceDate,
        TransactionType
    FROM staging.Transactions
    WHERE TransactionType IN
    (
        'Merchandise Sale',
        'Merchandise Cancellation'
    )
),

ProductDescriptionStats AS
(
    SELECT
        StockCode,
        Description,
        COUNT(*) AS DescriptionCount,
        MAX(InvoiceDate) AS LatestDescriptionDate
    FROM RelevantProductTransactions
    WHERE Description IS NOT NULL
      AND LTRIM(RTRIM(Description)) <> ''
    GROUP BY
        StockCode,
        Description
),

RankedProductDescriptions AS
(
    SELECT
        StockCode,
        Description,

        ROW_NUMBER() OVER
        (
            PARTITION BY StockCode
            ORDER BY
                DescriptionCount DESC,
                LatestDescriptionDate DESC,
                Description
        ) AS DescriptionRank

    FROM ProductDescriptionStats
),

ProductSalesDates AS
(
    SELECT
        StockCode,

        MIN(
            CASE
                WHEN TransactionType = 'Merchandise Sale'
                THEN InvoiceDate
            END
        ) AS FirstSaleDate,

        MAX(
            CASE
                WHEN TransactionType = 'Merchandise Sale'
                THEN InvoiceDate
            END
        ) AS LastSaleDate

    FROM RelevantProductTransactions
    GROUP BY StockCode
)

INSERT INTO core.Products
(
    StockCode,
    ProductDescription,
    FirstSaleDate,
    LastSaleDate
)

SELECT
    p.StockCode,
    d.Description,
    p.FirstSaleDate,
    p.LastSaleDate

FROM ProductSalesDates p

LEFT JOIN RankedProductDescriptions d
    ON p.StockCode = d.StockCode
   AND d.DescriptionRank = 1;
GO

SELECT
    COUNT(*) AS ProductRows,
    COUNT(DISTINCT StockCode) AS UniqueStockCodes
FROM core.Products;

SELECT
    'Customers' AS TableName,
    COUNT(*) AS RecordCount
FROM core.Customers

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM core.Products

UNION ALL

SELECT
    'Dates',
    COUNT(*)
FROM core.Dates;

/* =========================================================
   CUSTOMER DIMENSION VALIDATION
   ========================================================= */

SELECT
    COUNT(DISTINCT CustomerID) AS SalesCustomers
FROM staging.Transactions
WHERE TransactionType = 'Merchandise Sale'
  AND CustomerID IS NOT NULL;


SELECT
    COUNT(DISTINCT CustomerID) AS SalesAndCancellationCustomers
FROM staging.Transactions
WHERE TransactionType IN
(
    'Merchandise Sale',
    'Merchandise Cancellation'
)
AND CustomerID IS NOT NULL;


SELECT
    COUNT(*) AS CoreCustomerCount
FROM core.Customers;


/* =========================================================
   PRODUCT DIMENSION VALIDATION
   ========================================================= */

SELECT
    COUNT(DISTINCT StockCode) AS DefaultSQLProductCount
FROM staging.Transactions
WHERE TransactionType = 'Merchandise Sale';


SELECT
    COUNT(
        DISTINCT StockCode COLLATE Latin1_General_100_BIN2
    ) AS CaseSensitiveProductCount
FROM staging.Transactions
WHERE TransactionType = 'Merchandise Sale';


SELECT
    COUNT(*) AS CoreProductCount
FROM core.Products;


/* =========================================================
   FIND STOCK CODES THAT DIFFER ONLY BY CASE
   ========================================================= */

SELECT TOP 30
    UPPER(StockCode) AS NormalizedStockCode,

    COUNT(
        DISTINCT StockCode COLLATE Latin1_General_100_BIN2
    ) AS CaseVariantCount,

    STRING_AGG(
        CAST(StockCode AS NVARCHAR(MAX)),
        ', '
    ) AS ObservedCodes

FROM staging.Transactions

WHERE TransactionType = 'Merchandise Sale'

GROUP BY UPPER(StockCode)

HAVING
    COUNT(
        DISTINCT StockCode COLLATE Latin1_General_100_BIN2
    ) > 1

ORDER BY CaseVariantCount DESC;

UPDATE core.Products
SET StockCode = UPPER(LTRIM(RTRIM(StockCode)));
GO

SELECT
    COUNT(*) AS ProductRows,
    COUNT(DISTINCT StockCode) AS UniqueCanonicalStockCodes
FROM core.Products;

SELECT
    COUNT(DISTINCT UPPER(LTRIM(RTRIM(StockCode))))
        AS CanonicalSalesProducts
FROM staging.Transactions
WHERE TransactionType = 'Merchandise Sale';

SELECT
    COUNT(DISTINCT UPPER(LTRIM(RTRIM(StockCode))))
        AS CanonicalSalesAndCancellationProducts
FROM staging.Transactions
WHERE TransactionType IN
(
    'Merchandise Sale',
    'Merchandise Cancellation'
);