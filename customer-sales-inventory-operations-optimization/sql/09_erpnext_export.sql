USE CustomerSalesInventoryOps;
GO

WITH RankedProducts AS
(
    SELECT
        ProductKey,
        StockCode,
        ProductDescription,
        ABCClass,
        XYZClass,
        ABCXYZClass,
        MovementClass,
        Revenue,
        AverageWeeklyDemand,
        SafetyStockUnits,
        ReorderPointUnits,
        RecommendedInventoryLevelUnits,
        RecommendedAction,

        ROW_NUMBER() OVER
        (
            PARTITION BY ABCXYZClass
            ORDER BY Revenue DESC
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations

    WHERE ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(ProductDescription)) <> ''
)

SELECT
    ProductKey,
    StockCode,
    ProductDescription,
    ABCClass,
    XYZClass,
    ABCXYZClass,
    MovementClass,
    Revenue,
    AverageWeeklyDemand,
    SafetyStockUnits,
    ReorderPointUnits,
    RecommendedInventoryLevelUnits,
    RecommendedAction

FROM RankedProducts

WHERE ClassRank <= 4

ORDER BY
    ABCXYZClass,
    Revenue DESC;

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,

        f.ABCClass,
        f.XYZClass,
        f.ABCXYZClass,
        f.MovementClass,

        f.Revenue,
        f.AverageWeeklyDemand,
        f.SafetyStockUnits,
        f.ReorderPointUnits,
        f.RecommendedInventoryLevelUnits,
        f.RecommendedAction,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''
),

SellingPrice AS
(
    SELECT
        ProductKey,

        CAST(
            AVG(UnitPrice)
            AS DECIMAL(18,2)
        ) AS AverageSellingPrice

    FROM core.Sales

    WHERE UnitPrice > 0

    GROUP BY ProductKey
)

SELECT
    r.StockCode AS ItemCode,
    r.ProductDescription AS ItemName,

    'Retail Merchandise' AS ItemGroup,
    'Nos' AS StockUOM,

    1 AS MaintainStock,

    p.AverageSellingPrice,

    r.ABCXYZClass,
    r.MovementClass,

    r.ReorderPointUnits,
    r.RecommendedInventoryLevelUnits,

    r.RecommendedAction

FROM RankedProducts r

LEFT JOIN SellingPrice p
    ON r.ProductKey = p.ProductKey

WHERE r.ClassRank <= 4

ORDER BY
    r.ABCXYZClass,
    r.Revenue DESC;

USE CustomerSalesInventoryOps;
GO

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,
        f.ABCXYZClass,
        f.Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC, f.ProductKey
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''
)

SELECT
    CAST(r.StockCode AS VARCHAR(50)) AS [Item Code],

    'Retail Merchandise' AS [Item Group],

    'Nos' AS [Default Unit of Measure],

    r.ProductDescription AS [Item Name],

    0 AS [Disabled],

    1 AS [Maintain Stock],

    1 AS [Allow Sales],

    1 AS [Allow Purchase],

    r.ProductDescription AS [Description]

FROM RankedProducts r

WHERE r.ClassRank <= 4

ORDER BY
    r.ABCXYZClass,
    r.Revenue DESC;

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,
        f.ABCXYZClass,
        f.Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC, f.ProductKey
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''
)

SELECT
    StockCode,
    ProductDescription,
    ABCXYZClass,
    Revenue
FROM RankedProducts
WHERE ClassRank <= 4
  AND
  (
      UPPER(ProductDescription) LIKE '%CARRIAGE%'
      OR UPPER(ProductDescription) LIKE '%POSTAGE%'
      OR UPPER(ProductDescription) LIKE '%SHIPPING%'
      OR UPPER(ProductDescription) LIKE '%FREIGHT%'
      OR UPPER(ProductDescription) LIKE '%DISCOUNT%'
      OR UPPER(ProductDescription) LIKE '%ADJUST%'
      OR UPPER(ProductDescription) LIKE '%BANK CHARGE%'
  );

SELECT
    p.StockCode,
    p.ProductDescription,

    COUNT(*) AS SalesRows,
    SUM(s.Quantity) AS Units,
    CAST(SUM(s.GrossRevenue) AS DECIMAL(18,2)) AS Revenue

FROM core.Sales s

INNER JOIN core.Products p
    ON s.ProductKey = p.ProductKey

WHERE
       UPPER(p.ProductDescription) LIKE '%CARRIAGE%'
    OR UPPER(p.ProductDescription) LIKE '%POSTAGE%'
    OR UPPER(p.ProductDescription) LIKE '%SHIPPING%'
    OR UPPER(p.ProductDescription) LIKE '%FREIGHT%'
    OR UPPER(p.ProductDescription) LIKE '%BANK CHARGE%'
    OR UPPER(p.ProductDescription) LIKE '%DISCOUNT%'
    OR UPPER(p.ProductDescription) LIKE '%ADJUST%'
    OR UPPER(p.ProductDescription) LIKE '%AMAZON FEE%'

GROUP BY
    p.StockCode,
    p.ProductDescription

ORDER BY Revenue DESC;

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,
        f.ABCXYZClass,
        f.Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC, f.ProductKey
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''
      AND f.StockCode <> '23444'
)

SELECT
    StockCode,
    ProductDescription,
    ABCXYZClass,
    Revenue,
    ClassRank

FROM RankedProducts

WHERE ABCXYZClass = 'CY'
  AND ClassRank <= 4

ORDER BY ClassRank;

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,
        f.ABCXYZClass,
        f.Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC, f.ProductKey
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''
      AND f.StockCode <> '23444'
),

AveragePrices AS
(
    SELECT
        ProductKey,

        CAST(
            AVG(UnitPrice)
            AS DECIMAL(18,2)
        ) AS PriceListRate

    FROM core.Sales

    WHERE UnitPrice > 0

    GROUP BY ProductKey
)

SELECT
    r.StockCode AS ItemCode,
    'Standard Selling' AS PriceList,
    'Nos' AS UOM,
    p.PriceListRate

FROM RankedProducts r

INNER JOIN AveragePrices p
    ON r.ProductKey = p.ProductKey

WHERE r.ClassRank <= 4

ORDER BY
    r.ABCXYZClass,
    r.Revenue DESC;

USE CustomerSalesInventoryOps;
GO

WITH RankedProducts AS
(
    SELECT
        f.ProductKey,
        f.StockCode,
        f.ProductDescription,
        f.ABCXYZClass,
        f.Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY f.ABCXYZClass
            ORDER BY f.Revenue DESC, f.ProductKey
        ) AS ClassRank

    FROM analytics.vw_FinalInventoryRecommendations f

    WHERE f.ProductDescription IS NOT NULL
      AND LTRIM(RTRIM(f.ProductDescription)) <> ''

      -- Exclude the non-merchandise delivery/service item
      AND f.StockCode <> '23444'
),

AveragePrices AS
(
    SELECT
        ProductKey,

        CAST(
            AVG(UnitPrice)
            AS DECIMAL(18,2)
        ) AS AverageSellingPrice

    FROM core.Sales

    WHERE UnitPrice > 0

    GROUP BY ProductKey
)

SELECT
    CAST(r.StockCode AS VARCHAR(50)) AS [Item Code],

    'Nos' AS [UOM],

    'Standard Selling' AS [Price List],

    p.AverageSellingPrice AS [Rate],

    1 AS [Selling],

    'GBP' AS [Currency]

FROM RankedProducts r

INNER JOIN AveragePrices p
    ON r.ProductKey = p.ProductKey

WHERE r.ClassRank <= 4

ORDER BY
    r.ABCXYZClass,
    r.Revenue DESC;

USE CustomerSalesInventoryOps;
GO

WITH RankedCustomers AS
(
    SELECT
        CustomerID,
        Country,
        CustomerSegment,
        TotalOrders,
        Revenue,
        AverageOrderValue,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerSegment
            ORDER BY Revenue DESC, CustomerID
        ) AS SegmentRank

    FROM analytics.vw_CustomerSegments

    WHERE CustomerID IS NOT NULL
)

SELECT
    CustomerID,

    CONCAT(
        'UCI Customer ',
        CustomerID
    ) AS ERPNextCustomerName,

    Country,
    CustomerSegment,
    TotalOrders,
    Revenue,
    AverageOrderValue

FROM RankedCustomers

WHERE SegmentRank <= 3

ORDER BY
    CustomerSegment,
    Revenue DESC;

USE CustomerSalesInventoryOps;
GO

WITH RankedCustomers AS
(
    SELECT
        CustomerID,
        CustomerSegment,
        Revenue,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerSegment
            ORDER BY Revenue DESC, CustomerID
        ) AS SegmentRank

    FROM analytics.vw_CustomerSegments

    WHERE CustomerID IS NOT NULL
)

SELECT
    CONCAT(
        'UCI Customer ',
        CustomerID
    ) AS [Customer Name],

    'Individual' AS [Customer Type],

    'Retail Customers' AS [Customer Group],

    'All Territories' AS [Territory],

    0 AS [Disabled]

FROM RankedCustomers

WHERE SegmentRank <= 3

ORDER BY
    CustomerSegment,
    Revenue DESC;

USE CustomerSalesInventoryOps;
GO

WITH SelectedCustomers AS
(
    SELECT CustomerID
    FROM
    (
        SELECT
            CustomerID,
            CustomerSegment,
            Revenue,

            ROW_NUMBER() OVER
            (
                PARTITION BY CustomerSegment
                ORDER BY Revenue DESC, CustomerID
            ) AS SegmentRank

        FROM analytics.vw_CustomerSegments

        WHERE CustomerID IS NOT NULL
    ) x

    WHERE SegmentRank <= 3
),

SelectedProducts AS
(
    SELECT ProductKey
    FROM
    (
        SELECT
            f.ProductKey,
            f.StockCode,
            f.ABCXYZClass,
            f.Revenue,

            ROW_NUMBER() OVER
            (
                PARTITION BY f.ABCXYZClass
                ORDER BY f.Revenue DESC, f.ProductKey
            ) AS ClassRank

        FROM analytics.vw_FinalInventoryRecommendations f

        WHERE f.ProductDescription IS NOT NULL
          AND LTRIM(RTRIM(f.ProductDescription)) <> ''
          AND f.StockCode <> '23444'
    ) x

    WHERE ClassRank <= 4
),

CandidateLines AS
(
    SELECT
        s.Invoice,
        c.CustomerID,
        p.StockCode,
        p.ProductDescription,
        d.FullDate AS OriginalInvoiceDate,
        s.Quantity,
        s.UnitPrice,
        s.GrossRevenue

    FROM core.Sales s

    INNER JOIN core.Customers c
        ON s.CustomerKey = c.CustomerKey

    INNER JOIN core.Products p
        ON s.ProductKey = p.ProductKey

    INNER JOIN core.Dates d
        ON s.DateKey = d.DateKey

    INNER JOIN SelectedCustomers sc
        ON c.CustomerID = sc.CustomerID

    INNER JOIN SelectedProducts sp
        ON s.ProductKey = sp.ProductKey
)

SELECT
    COUNT(*) AS CandidateTransactionLines,
    COUNT(DISTINCT Invoice) AS CandidateInvoices,
    COUNT(DISTINCT CustomerID) AS CustomersRepresented,
    COUNT(DISTINCT StockCode) AS ProductsRepresented,

    CAST(
        SUM(GrossRevenue)
        AS DECIMAL(18,2)
    ) AS CandidateRevenue

FROM CandidateLines;

SELECT TOP 20
    Invoice,
    CustomerID,

    MIN(OriginalInvoiceDate) AS OriginalInvoiceDate,

    COUNT(*) AS MatchingLines,

    COUNT(DISTINCT StockCode) AS DistinctItems,

    SUM(Quantity) AS TotalUnits,

    CAST(
        SUM(GrossRevenue)
        AS DECIMAL(18,2)
    ) AS OrderRevenue

FROM CandidateLines

GROUP BY
    Invoice,
    CustomerID

ORDER BY
    DistinctItems DESC,
    OrderRevenue DESC;

USE CustomerSalesInventoryOps;
GO

;WITH SelectedCustomers AS
(
    SELECT CustomerID
    FROM
    (
        SELECT
            CustomerID,
            CustomerSegment,
            Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY CustomerSegment
                ORDER BY Revenue DESC, CustomerID
            ) AS SegmentRank
        FROM analytics.vw_CustomerSegments
        WHERE CustomerID IS NOT NULL
    ) x
    WHERE SegmentRank <= 3
),

SelectedProducts AS
(
    SELECT ProductKey
    FROM
    (
        SELECT
            f.ProductKey,
            f.StockCode,
            f.ABCXYZClass,
            f.Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY f.ABCXYZClass
                ORDER BY f.Revenue DESC, f.ProductKey
            ) AS ClassRank
        FROM analytics.vw_FinalInventoryRecommendations f
        WHERE f.ProductDescription IS NOT NULL
          AND LTRIM(RTRIM(f.ProductDescription)) <> ''
          AND f.StockCode <> '23444'
    ) x
    WHERE ClassRank <= 4
),

CandidateLines AS
(
    SELECT
        s.Invoice,
        c.CustomerID,
        p.StockCode,
        p.ProductDescription,
        d.FullDate AS OriginalInvoiceDate,
        s.Quantity,
        s.UnitPrice,
        s.GrossRevenue
    FROM core.Sales s

    INNER JOIN core.Customers c
        ON s.CustomerKey = c.CustomerKey

    INNER JOIN core.Products p
        ON s.ProductKey = p.ProductKey

    INNER JOIN core.Dates d
        ON s.DateKey = d.DateKey

    INNER JOIN SelectedCustomers sc
        ON c.CustomerID = sc.CustomerID

    INNER JOIN SelectedProducts sp
        ON s.ProductKey = sp.ProductKey
)

SELECT TOP 20
    Invoice,
    CustomerID,
    MIN(OriginalInvoiceDate) AS OriginalInvoiceDate,
    COUNT(*) AS MatchingLines,
    COUNT(DISTINCT StockCode) AS DistinctItems,
    SUM(Quantity) AS TotalUnits,
    CAST(SUM(GrossRevenue) AS DECIMAL(18,2)) AS OrderRevenue
FROM CandidateLines
GROUP BY
    Invoice,
    CustomerID
ORDER BY
    DistinctItems DESC,
    OrderRevenue DESC;

USE CustomerSalesInventoryOps;
GO

;WITH SelectedCustomers AS
(
    SELECT CustomerID
    FROM
    (
        SELECT
            CustomerID,
            CustomerSegment,
            Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY CustomerSegment
                ORDER BY Revenue DESC, CustomerID
            ) AS SegmentRank
        FROM analytics.vw_CustomerSegments
        WHERE CustomerID IS NOT NULL
    ) x
    WHERE SegmentRank <= 3
),

SelectedProducts AS
(
    SELECT ProductKey
    FROM
    (
        SELECT
            f.ProductKey,
            f.StockCode,
            f.ABCXYZClass,
            f.Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY f.ABCXYZClass
                ORDER BY f.Revenue DESC, f.ProductKey
            ) AS ClassRank
        FROM analytics.vw_FinalInventoryRecommendations f
        WHERE f.ProductDescription IS NOT NULL
          AND LTRIM(RTRIM(f.ProductDescription)) <> ''
          AND f.StockCode <> '23444'
    ) x
    WHERE ClassRank <= 4
),

InvoiceLines AS
(
    SELECT
        s.Invoice,
        c.CustomerID,
        s.ProductKey,
        p.StockCode,
        d.FullDate AS OriginalInvoiceDate,
        s.Quantity,
        s.GrossRevenue,
        CASE
            WHEN sp.ProductKey IS NOT NULL THEN 1
            ELSE 0
        END AS IsImportedERPItem
    FROM core.Sales s

    INNER JOIN core.Customers c
        ON s.CustomerKey = c.CustomerKey

    INNER JOIN core.Products p
        ON s.ProductKey = p.ProductKey

    INNER JOIN core.Dates d
        ON s.DateKey = d.DateKey

    INNER JOIN SelectedCustomers sc
        ON c.CustomerID = sc.CustomerID

    LEFT JOIN SelectedProducts sp
        ON s.ProductKey = sp.ProductKey
)

SELECT TOP 20
    Invoice,
    CustomerID,
    MIN(OriginalInvoiceDate) AS OriginalInvoiceDate,

    COUNT(*) AS TotalInvoiceLines,

    SUM(IsImportedERPItem) AS ERPReproducibleLines,

    COUNT(DISTINCT StockCode) AS DistinctItems,

    SUM(Quantity) AS TotalUnits,

    CAST(
        SUM(GrossRevenue)
        AS DECIMAL(18,2)
    ) AS HistoricalOrderRevenue

FROM InvoiceLines

GROUP BY
    Invoice,
    CustomerID

HAVING
    COUNT(*) = SUM(IsImportedERPItem)
    AND COUNT(*) >= 2

ORDER BY
    COUNT(*) DESC,
    HistoricalOrderRevenue DESC;

USE CustomerSalesInventoryOps;
GO

;WITH SelectedCustomers AS
(
    SELECT CustomerID
    FROM
    (
        SELECT
            CustomerID,
            CustomerSegment,
            Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY CustomerSegment
                ORDER BY Revenue DESC, CustomerID
            ) AS SegmentRank
        FROM analytics.vw_CustomerSegments
        WHERE CustomerID IS NOT NULL
    ) x
    WHERE SegmentRank <= 3
),

SelectedProducts AS
(
    SELECT ProductKey
    FROM
    (
        SELECT
            f.ProductKey,
            f.StockCode,
            f.ABCXYZClass,
            f.Revenue,
            ROW_NUMBER() OVER
            (
                PARTITION BY f.ABCXYZClass
                ORDER BY f.Revenue DESC, f.ProductKey
            ) AS ClassRank
        FROM analytics.vw_FinalInventoryRecommendations f
        WHERE f.ProductDescription IS NOT NULL
          AND LTRIM(RTRIM(f.ProductDescription)) <> ''
          AND f.StockCode <> '23444'
    ) x
    WHERE ClassRank <= 4
),

InvoiceLines AS
(
    SELECT
        s.Invoice,
        c.CustomerID,
        d.FullDate AS OriginalInvoiceDate,
        s.ProductKey,
        p.StockCode,
        p.ProductDescription,
        s.Quantity,
        s.UnitPrice,
        s.GrossRevenue,

        CASE
            WHEN sp.ProductKey IS NOT NULL THEN 1
            ELSE 0
        END AS IsImportedERPItem

    FROM core.Sales s

    INNER JOIN core.Customers c
        ON s.CustomerKey = c.CustomerKey

    INNER JOIN core.Products p
        ON s.ProductKey = p.ProductKey

    INNER JOIN core.Dates d
        ON s.DateKey = d.DateKey

    INNER JOIN SelectedCustomers sc
        ON c.CustomerID = sc.CustomerID

    LEFT JOIN SelectedProducts sp
        ON s.ProductKey = sp.ProductKey
)

SELECT TOP 20
    Invoice,
    CustomerID,
    MIN(OriginalInvoiceDate) AS OriginalInvoiceDate,

    COUNT(*) AS TotalLines,

    SUM(IsImportedERPItem) AS ExistingERPLines,

    COUNT(*) - SUM(IsImportedERPItem) AS MissingLines,

    CAST(
        SUM(IsImportedERPItem) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS ERPCoveragePct,

    COUNT(DISTINCT StockCode) AS DistinctItems,

    SUM(Quantity) AS TotalUnits,

    CAST(
        SUM(GrossRevenue)
        AS DECIMAL(18,2)
    ) AS HistoricalRevenue

FROM InvoiceLines

GROUP BY
    Invoice,
    CustomerID

HAVING SUM(IsImportedERPItem) >= 2

ORDER BY
    MissingLines ASC,
    ERPCoveragePct DESC,
    ExistingERPLines DESC,
    HistoricalRevenue DESC;

USE CustomerSalesInventoryOps;
GO

;WITH SelectedProducts AS
(
    SELECT ProductKey
    FROM
    (
        SELECT
            f.ProductKey,
            f.StockCode,
            f.ABCXYZClass,
            f.Revenue,

            ROW_NUMBER() OVER
            (
                PARTITION BY f.ABCXYZClass
                ORDER BY f.Revenue DESC, f.ProductKey
            ) AS ClassRank

        FROM analytics.vw_FinalInventoryRecommendations f

        WHERE f.ProductDescription IS NOT NULL
          AND LTRIM(RTRIM(f.ProductDescription)) <> ''
          AND f.StockCode <> '23444'
    ) x

    WHERE ClassRank <= 4
),

AveragePrices AS
(
    SELECT
        ProductKey,
        CAST(
            AVG(UnitPrice)
            AS DECIMAL(18,2)
        ) AS AverageSellingPrice

    FROM core.Sales

    WHERE UnitPrice > 0

    GROUP BY ProductKey
)

SELECT
    s.Invoice,
    c.CustomerID,
    p.StockCode,
    p.ProductDescription,

    d.FullDate AS OriginalInvoiceDate,

    s.Quantity,

    CAST(
        s.UnitPrice AS DECIMAL(18,2)
    ) AS HistoricalUnitPrice,

    CAST(
        s.GrossRevenue AS DECIMAL(18,2)
    ) AS HistoricalLineRevenue,

    CAST(
        ap.AverageSellingPrice AS DECIMAL(18,2)
    ) AS ERPStandardSellingPrice,

    CASE
        WHEN sp.ProductKey IS NOT NULL
            THEN 'ALREADY IN ERP'
        ELSE 'MISSING - ADD TO ERP'
    END AS ERPStatus

FROM core.Sales s

INNER JOIN core.Customers c
    ON s.CustomerKey = c.CustomerKey

INNER JOIN core.Products p
    ON s.ProductKey = p.ProductKey

INNER JOIN core.Dates d
    ON s.DateKey = d.DateKey

LEFT JOIN SelectedProducts sp
    ON s.ProductKey = sp.ProductKey

LEFT JOIN AveragePrices ap
    ON s.ProductKey = ap.ProductKey

WHERE s.Invoice = '499039'
  AND c.CustomerID = 14646

ORDER BY
    ERPStatus,
    p.StockCode;

SELECT
    s.name AS SchemaName,
    v.name AS ViewName
FROM sys.views v
JOIN sys.schemas s
    ON v.schema_id = s.schema_id
WHERE v.name LIKE '%Growth%'
   OR v.name LIKE '%Opportun%'
   OR v.name LIKE '%Customer%'
ORDER BY v.name;