USE CustomerSalesInventoryOps;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerPurchasingProfile
AS

WITH Snapshot AS
(
    SELECT
        DATEADD(
            DAY,
            1,
            CAST(MAX(InvoiceDate) AS DATE)
        ) AS SnapshotDate
    FROM core.Sales
),

CustomerMetrics AS
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
)

SELECT
    m.CustomerKey,
    m.CustomerID,
    m.Country,

    m.FirstPurchaseDate,
    m.LastPurchaseDate,

    DATEDIFF(
        DAY,
        CAST(m.LastPurchaseDate AS DATE),
        s.SnapshotDate
    ) AS RecencyDays,

    DATEDIFF(
        DAY,
        CAST(m.FirstPurchaseDate AS DATE),
        CAST(m.LastPurchaseDate AS DATE)
    ) + 1 AS CustomerActiveSpanDays,

    m.TotalOrders,
    m.UniqueProductsPurchased,
    m.UnitsPurchased,

    CAST(
        m.Revenue
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        m.Revenue /
        NULLIF(m.TotalOrders, 0)
        AS DECIMAL(18,2)
    ) AS AverageOrderValue

FROM CustomerMetrics m

CROSS JOIN Snapshot s;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerRFM
AS

WITH ScoredCustomers AS
(
    SELECT
        *,

        NTILE(5) OVER
        (
            ORDER BY RecencyDays DESC
        ) AS RScore,

        NTILE(5) OVER
        (
            ORDER BY TotalOrders ASC
        ) AS FScore,

        NTILE(5) OVER
        (
            ORDER BY Revenue ASC
        ) AS MScore

    FROM analytics.vw_CustomerPurchasingProfile
)

SELECT
    CustomerKey,
    CustomerID,
    Country,

    FirstPurchaseDate,
    LastPurchaseDate,
    RecencyDays,

    TotalOrders,
    UniqueProductsPurchased,
    UnitsPurchased,
    Revenue,
    AverageOrderValue,

    RScore,
    FScore,
    MScore,

    CONCAT(
        RScore,
        FScore,
        MScore
    ) AS RFMCode,

    RScore + FScore + MScore AS RFMTotalScore

FROM ScoredCustomers;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerSegments
AS

SELECT
    r.*,

    CASE

        WHEN RScore >= 4
         AND FScore >= 4
         AND MScore >= 4
            THEN 'Champions'

        WHEN RScore >= 3
         AND FScore >= 4
         AND MScore >= 3
            THEN 'Loyal Customers'

        WHEN RScore >= 4
         AND FScore BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

        WHEN RScore >= 4
         AND FScore = 1
            THEN 'New Customers'

        WHEN RScore <= 2
         AND (
                FScore >= 4
                OR MScore >= 4
             )
            THEN 'High Value At Risk'

        WHEN RScore <= 2
         AND FScore >= 3
            THEN 'At Risk'

        WHEN RScore BETWEEN 2 AND 3
         AND FScore BETWEEN 2 AND 3
            THEN 'Needs Attention'

        ELSE 'Low Engagement'

    END AS CustomerSegment

FROM analytics.vw_CustomerRFM r;
GO

SELECT
    CustomerSegment,
    COUNT(*) AS Customers,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        AVG(Revenue)
        AS DECIMAL(18,2)
    ) AS AverageCustomerRevenue

FROM analytics.vw_CustomerSegments

GROUP BY CustomerSegment

ORDER BY Revenue DESC;

SELECT TOP 20
    CustomerID,
    Country,
    RecencyDays,
    TotalOrders,
    Revenue,
    AverageOrderValue,
    RFMCode,
    CustomerSegment
FROM analytics.vw_CustomerSegments
ORDER BY Revenue DESC;

SELECT TOP 30
    CustomerID,
    Country,
    RecencyDays,
    TotalOrders,
    Revenue,
    AverageOrderValue,
    RFMCode,
    CustomerSegment
FROM analytics.vw_CustomerSegments

WHERE CustomerSegment = 'High Value At Risk'

ORDER BY Revenue DESC;

SELECT
    'Purchasing Profile' AS ViewName,
    COUNT(*) AS RecordCount
FROM analytics.vw_CustomerPurchasingProfile

UNION ALL

SELECT
    'RFM',
    COUNT(*)
FROM analytics.vw_CustomerRFM

UNION ALL

SELECT
    'Customer Segments',
    COUNT(*)
FROM analytics.vw_CustomerSegments;