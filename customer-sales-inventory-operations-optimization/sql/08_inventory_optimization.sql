USE CustomerSalesInventoryOps;
GO

CREATE OR ALTER VIEW analytics.vw_ProductWeeklyDemand
AS

SELECT
    p.ProductKey,
    p.StockCode,
    p.ProductDescription,

    DATEADD(
        DAY,
        -(
            DATEDIFF(
                DAY,
                '19000101',
                CAST(s.InvoiceDate AS DATE)
            ) % 7
        ),
        CAST(s.InvoiceDate AS DATE)
    ) AS WeekStartDate,

    SUM(s.Quantity) AS WeeklyUnits,

    CAST(
        SUM(s.GrossRevenue)
        AS DECIMAL(18,2)
    ) AS WeeklyRevenue,

    COUNT(DISTINCT s.Invoice) AS WeeklyOrders,

    COUNT(DISTINCT s.CustomerKey) AS WeeklyCustomers

FROM core.Sales s

INNER JOIN core.Products p
    ON s.ProductKey = p.ProductKey

GROUP BY
    p.ProductKey,
    p.StockCode,
    p.ProductDescription,

    DATEADD(
        DAY,
        -(
            DATEDIFF(
                DAY,
                '19000101',
                CAST(s.InvoiceDate AS DATE)
            ) % 7
        ),
        CAST(s.InvoiceDate AS DATE)
    );
GO

CREATE OR ALTER VIEW analytics.vw_CalendarWeeks
AS

SELECT DISTINCT

    DATEADD(
        DAY,
        -(
            DATEDIFF(
                DAY,
                '19000101',
                FullDate
            ) % 7
        ),
        FullDate
    ) AS WeekStartDate

FROM core.Dates;
GO

CREATE OR ALTER VIEW analytics.vw_ProductDemandStatistics
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    COUNT(*) AS ActiveSalesWeeks,

    SUM(WeeklyUnits) AS TotalUnitsSold,

    CAST(
        AVG(
            CAST(WeeklyUnits AS DECIMAL(18,4))
        )
        AS DECIMAL(18,2)
    ) AS AverageWeeklyDemand,

    CAST(
        STDEV(
            CAST(WeeklyUnits AS DECIMAL(18,4))
        )
        AS DECIMAL(18,2)
    ) AS WeeklyDemandStdDev,

    CAST(
        CASE
            WHEN AVG(
                CAST(WeeklyUnits AS DECIMAL(18,4))
            ) = 0
            THEN NULL

            ELSE
                STDEV(
                    CAST(WeeklyUnits AS DECIMAL(18,4))
                )
                /
                AVG(
                    CAST(WeeklyUnits AS DECIMAL(18,4))
                )
        END
        AS DECIMAL(18,4)
    ) AS DemandCV,

    CAST(
        SUM(WeeklyRevenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    MIN(WeekStartDate) AS FirstActiveWeek,
    MAX(WeekStartDate) AS LastActiveWeek

FROM analytics.vw_ProductWeeklyDemand

GROUP BY
    ProductKey,
    StockCode,
    ProductDescription;
GO

CREATE OR ALTER VIEW analytics.vw_ProductDemandStatistics
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    COUNT(*) AS ActiveSalesWeeks,

    SUM(WeeklyUnits) AS TotalUnitsSold,

    CAST(
        AVG(
            CAST(WeeklyUnits AS DECIMAL(18,4))
        )
        AS DECIMAL(18,2)
    ) AS AverageWeeklyDemand,

    CAST(
        STDEV(
            CAST(WeeklyUnits AS DECIMAL(18,4))
        )
        AS DECIMAL(18,2)
    ) AS WeeklyDemandStdDev,

    CAST(
        CASE
            WHEN AVG(
                CAST(WeeklyUnits AS DECIMAL(18,4))
            ) = 0
            THEN NULL

            ELSE
                STDEV(
                    CAST(WeeklyUnits AS DECIMAL(18,4))
                )
                /
                AVG(
                    CAST(WeeklyUnits AS DECIMAL(18,4))
                )
        END
        AS DECIMAL(18,4)
    ) AS DemandCV,

    CAST(
        SUM(WeeklyRevenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    MIN(WeekStartDate) AS FirstActiveWeek,
    MAX(WeekStartDate) AS LastActiveWeek

FROM analytics.vw_ProductWeeklyDemand

GROUP BY
    ProductKey,
    StockCode,
    ProductDescription;
GO

SELECT TOP 30
    StockCode,
    ProductDescription,
    ActiveSalesWeeks,
    TotalUnitsSold,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    Revenue
FROM analytics.vw_ProductDemandStatistics
ORDER BY TotalUnitsSold DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,
    ActiveSalesWeeks,
    TotalUnitsSold,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    Revenue
FROM analytics.vw_ProductDemandStatistics
WHERE ActiveSalesWeeks >= 10
ORDER BY DemandCV DESC;

SELECT *
FROM analytics.vw_CalendarWeeks
ORDER BY WeekStartDate;

CREATE OR ALTER VIEW analytics.vw_ProductWeeklyDemandComplete
AS

WITH ProductLifecycle AS
(
    SELECT
        ProductKey,
        StockCode,
        ProductDescription,

        DATEADD(
            DAY,
            -(
                DATEDIFF(
                    DAY,
                    '19000101',
                    CAST(FirstSaleDate AS DATE)
                ) % 7
            ),
            CAST(FirstSaleDate AS DATE)
        ) AS FirstSaleWeek

    FROM core.Products

    WHERE FirstSaleDate IS NOT NULL
),

ProductWeekGrid AS
(
    SELECT
        p.ProductKey,
        p.StockCode,
        p.ProductDescription,
        w.WeekStartDate

    FROM ProductLifecycle p

    CROSS JOIN analytics.vw_CalendarWeeks w

    WHERE
        w.WeekStartDate >= p.FirstSaleWeek
)

SELECT
    g.ProductKey,
    g.StockCode,
    g.ProductDescription,
    g.WeekStartDate,

    ISNULL(
        d.WeeklyUnits,
        0
    ) AS WeeklyUnits,

    ISNULL(
        d.WeeklyRevenue,
        0
    ) AS WeeklyRevenue,

    ISNULL(
        d.WeeklyOrders,
        0
    ) AS WeeklyOrders,

    ISNULL(
        d.WeeklyCustomers,
        0
    ) AS WeeklyCustomers,

    CASE
        WHEN d.ProductKey IS NULL
        THEN 0
        ELSE 1
    END AS HadSalesActivity

FROM ProductWeekGrid g

LEFT JOIN analytics.vw_ProductWeeklyDemand d
    ON g.ProductKey = d.ProductKey
   AND g.WeekStartDate = d.WeekStartDate;
GO

SELECT
    StockCode,
    ProductDescription,
    WeekStartDate,
    WeeklyUnits,
    WeeklyRevenue,
    WeeklyOrders,
    HadSalesActivity
FROM analytics.vw_ProductWeeklyDemandComplete
WHERE StockCode = '84077'
ORDER BY WeekStartDate;

CREATE OR ALTER VIEW analytics.vw_ProductDemandStatisticsComplete
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    COUNT(*) AS LifecycleWeeks,

    SUM(
        CASE
            WHEN WeeklyUnits > 0
            THEN 1
            ELSE 0
        END
    ) AS ActiveSalesWeeks,

    SUM(
        CASE
            WHEN WeeklyUnits = 0
            THEN 1
            ELSE 0
        END
    ) AS ZeroDemandWeeks,

    CAST(
        SUM(
            CASE
                WHEN WeeklyUnits > 0
                THEN 1.0
                ELSE 0
            END
        )
        /
        NULLIF(COUNT(*), 0)
        * 100
        AS DECIMAL(10,2)
    ) AS ActiveWeekPct,

    SUM(WeeklyUnits)
        AS TotalUnitsSold,

    CAST(
        AVG(
            CAST(
                WeeklyUnits
                AS DECIMAL(18,4)
            )
        )
        AS DECIMAL(18,2)
    ) AS AverageWeeklyDemand,

    CAST(
        STDEV(
            CAST(
                WeeklyUnits
                AS DECIMAL(18,4)
            )
        )
        AS DECIMAL(18,2)
    ) AS WeeklyDemandStdDev,

    CAST(
        CASE

            WHEN AVG(
                CAST(
                    WeeklyUnits
                    AS DECIMAL(18,4)
                )
            ) = 0
                THEN NULL

            ELSE

                STDEV(
                    CAST(
                        WeeklyUnits
                        AS DECIMAL(18,4)
                    )
                )

                /

                AVG(
                    CAST(
                        WeeklyUnits
                        AS DECIMAL(18,4)
                    )
                )

        END
        AS DECIMAL(18,4)
    ) AS DemandCV,

    CAST(
        SUM(WeeklyRevenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    MIN(WeekStartDate)
        AS FirstLifecycleWeek,

    MAX(WeekStartDate)
        AS LatestAnalysisWeek

FROM analytics.vw_ProductWeeklyDemandComplete

GROUP BY
    ProductKey,
    StockCode,
    ProductDescription;
GO

SELECT TOP 30

    a.StockCode,
    a.ProductDescription,

    a.ActiveSalesWeeks,

    c.LifecycleWeeks,
    c.ZeroDemandWeeks,
    c.ActiveWeekPct,

    a.AverageWeeklyDemand
        AS ActiveWeeksOnlyAvgDemand,

    c.AverageWeeklyDemand
        AS CompleteLifecycleAvgDemand,

    c.WeeklyDemandStdDev,
    c.DemandCV,

    c.TotalUnitsSold,
    c.Revenue

FROM analytics.vw_ProductDemandStatistics a

INNER JOIN analytics.vw_ProductDemandStatisticsComplete c
    ON a.ProductKey = c.ProductKey

ORDER BY c.TotalUnitsSold DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,
    LifecycleWeeks,
    ActiveSalesWeeks,
    ZeroDemandWeeks,
    ActiveWeekPct,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    TotalUnitsSold,
    Revenue

FROM analytics.vw_ProductDemandStatisticsComplete

WHERE LifecycleWeeks >= 20

ORDER BY ActiveWeekPct ASC,
         Revenue DESC;

CREATE OR ALTER VIEW analytics.vw_ProductABCClassification
AS

WITH ProductRevenue AS
(
    SELECT
        p.ProductKey,
        p.StockCode,
        p.ProductDescription,

        SUM(s.GrossRevenue) AS Revenue

    FROM core.Products p

    INNER JOIN core.Sales s
        ON p.ProductKey = s.ProductKey

    GROUP BY
        p.ProductKey,
        p.StockCode,
        p.ProductDescription
),

RevenueContribution AS
(
    SELECT
        ProductKey,
        StockCode,
        ProductDescription,
        Revenue,

        SUM(Revenue) OVER ()
            AS TotalRevenue,

        SUM(Revenue) OVER
        (
            ORDER BY Revenue DESC, ProductKey
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS CumulativeRevenue

    FROM ProductRevenue
),

RevenuePercentages AS
(
    SELECT
        ProductKey,
        StockCode,
        ProductDescription,

        Revenue,

        Revenue * 100.0
        / NULLIF(TotalRevenue, 0)
            AS RevenueContributionPct,

        CumulativeRevenue * 100.0
        / NULLIF(TotalRevenue, 0)
            AS CumulativeRevenuePct

    FROM RevenueContribution
)

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    CAST(
        Revenue
        AS DECIMAL(18,4)
    ) AS Revenue,

    CAST(
        RevenueContributionPct
        AS DECIMAL(12,6)
    ) AS RevenueContributionPct,

    CAST(
        CumulativeRevenuePct
        AS DECIMAL(12,6)
    ) AS CumulativeRevenuePct,

    CASE
        WHEN CumulativeRevenuePct <= 80
            THEN 'A'

        WHEN CumulativeRevenuePct <= 95
            THEN 'B'

        ELSE 'C'

    END AS ABCClass

FROM RevenuePercentages;
GO

SELECT
    ProductKey,
    StockCode,
    ProductDescription,
    Revenue,
    RevenueContributionPct,
    CumulativeRevenuePct,

    CASE
        WHEN CumulativeRevenuePct <= 80
            THEN 'A'

        WHEN CumulativeRevenuePct <= 95
            THEN 'B'

        ELSE 'C'

    END AS ABCClass

FROM RevenuePercentages;
GO

SELECT TOP 30
    StockCode,
    ProductDescription,
    Revenue,
    RevenueContributionPct,
    CumulativeRevenuePct,
    ABCClass

FROM analytics.vw_ProductABCClassification

ORDER BY Revenue DESC;


SELECT
    ABCClass,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(Revenue)
        * 100.0
        /
        (
            SELECT SUM(Revenue)
            FROM analytics.vw_ProductABCClassification
        )
        AS DECIMAL(10,2)
    ) AS RevenuePct,

    CAST(
        AVG(Revenue)
        AS DECIMAL(18,2)
    ) AS AverageProductRevenue

FROM analytics.vw_ProductABCClassification

GROUP BY ABCClass

ORDER BY ABCClass;

SELECT
    COUNT(*) AS TotalProducts,

    SUM(
        CASE
            WHEN ABCClass = 'A'
            THEN 1
            ELSE 0
        END
    ) AS AClassProducts,

    CAST(
        SUM(
            CASE
                WHEN ABCClass = 'A'
                THEN 1.0
                ELSE 0
            END
        )
        / COUNT(*)
        * 100
        AS DECIMAL(10,2)
    ) AS AClassProductPct

FROM analytics.vw_ProductABCClassification;

SELECT TOP 50
    a.StockCode,
    a.ProductDescription,

    a.ABCClass,
    a.Revenue,

    d.TotalUnitsSold,
    d.LifecycleWeeks,
    d.ActiveSalesWeeks,
    d.ZeroDemandWeeks,
    d.ActiveWeekPct,

    d.AverageWeeklyDemand,
    d.WeeklyDemandStdDev,
    d.DemandCV

FROM analytics.vw_ProductABCClassification a

INNER JOIN analytics.vw_ProductDemandStatisticsComplete d
    ON a.ProductKey = d.ProductKey

ORDER BY
    a.ABCClass,
    a.Revenue DESC;

SELECT
    COUNT(DISTINCT ProductKey) AS SalesProductKeys
FROM core.Sales;


SELECT
    COUNT(*) AS DemandStatisticsProducts
FROM analytics.vw_ProductDemandStatisticsComplete;


SELECT
    COUNT(*) AS ABCProducts
FROM analytics.vw_ProductABCClassification;

SELECT
    p.ProductKey,
    p.StockCode,
    p.ProductDescription,
    COUNT(*) AS SalesRows,
    SUM(s.Quantity) AS UnitsSold,
    SUM(s.GrossRevenue) AS Revenue,
    p.FirstSaleDate,
    p.LastSaleDate

FROM core.Products p

INNER JOIN core.Sales s
    ON p.ProductKey = s.ProductKey

LEFT JOIN analytics.vw_ProductABCClassification a
    ON p.ProductKey = a.ProductKey

WHERE a.ProductKey IS NULL

GROUP BY
    p.ProductKey,
    p.StockCode,
    p.ProductDescription,
    p.FirstSaleDate,
    p.LastSaleDate;

SELECT
    p.ProductKey,
    p.StockCode,
    p.ProductDescription,
    d.TotalUnitsSold,
    d.Revenue,
    d.LifecycleWeeks

FROM core.Products p

LEFT JOIN analytics.vw_ProductDemandStatisticsComplete d
    ON p.ProductKey = d.ProductKey

WHERE p.ProductKey IN
(
    SELECT DISTINCT ProductKey
    FROM core.Sales
)
AND d.ProductKey IS NULL;

SELECT
    COUNT(DISTINCT ProductKey) AS SalesProducts
FROM core.Sales;

SELECT
    COUNT(*) AS ABCProducts
FROM analytics.vw_ProductABCClassification;

SELECT
    SUM(GrossRevenue) AS SalesRevenue
FROM core.Sales;

SELECT
    SUM(Revenue) AS ABCRevenue
FROM analytics.vw_ProductABCClassification;

SELECT
    ABCClass,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(Revenue) * 100.0
        /
        (
            SELECT SUM(Revenue)
            FROM analytics.vw_ProductABCClassification
        )
        AS DECIMAL(10,2)
    ) AS RevenuePct,

    CAST(
        AVG(Revenue)
        AS DECIMAL(18,2)
    ) AS AverageProductRevenue

FROM analytics.vw_ProductABCClassification

GROUP BY ABCClass

ORDER BY ABCClass;

CREATE OR ALTER VIEW analytics.vw_ProductXYZClassification
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    LifecycleWeeks,
    ActiveSalesWeeks,
    ZeroDemandWeeks,
    ActiveWeekPct,

    TotalUnitsSold,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    Revenue,

    CASE

        WHEN LifecycleWeeks < 4
            THEN 'Z'

        WHEN DemandCV IS NULL
            THEN 'Z'

        WHEN DemandCV <= 0.50
            THEN 'X'

        WHEN DemandCV <= 1.00
            THEN 'Y'

        ELSE 'Z'

    END AS XYZClass,

    CASE

        WHEN LifecycleWeeks < 4
            THEN 'Insufficient History'

        WHEN DemandCV IS NULL
            THEN 'Insufficient History'

        WHEN DemandCV <= 0.50
            THEN 'Stable Demand'

        WHEN DemandCV <= 1.00
            THEN 'Moderate Variability'

        ELSE 'High Variability'

    END AS DemandPattern

FROM analytics.vw_ProductDemandStatisticsComplete;
GO

SELECT
    XYZClass,
    DemandPattern,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        AVG(DemandCV)
        AS DECIMAL(18,4)
    ) AS AverageDemandCV

FROM analytics.vw_ProductXYZClassification

GROUP BY
    XYZClass,
    DemandPattern

ORDER BY XYZClass;

CREATE OR ALTER VIEW analytics.vw_ProductABCXYZ
AS

SELECT
    a.ProductKey,
    a.StockCode,
    a.ProductDescription,

    a.ABCClass,
    x.XYZClass,

    CONCAT(
        a.ABCClass,
        x.XYZClass
    ) AS ABCXYZClass,

    a.Revenue,

    x.TotalUnitsSold,
    x.LifecycleWeeks,
    x.ActiveSalesWeeks,
    x.ZeroDemandWeeks,
    x.ActiveWeekPct,

    x.AverageWeeklyDemand,
    x.WeeklyDemandStdDev,
    x.DemandCV,
    x.DemandPattern

FROM analytics.vw_ProductABCClassification a

INNER JOIN analytics.vw_ProductXYZClassification x
    ON a.ProductKey = x.ProductKey;
GO

SELECT
    ABCXYZClass,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        AVG(AverageWeeklyDemand)
        AS DECIMAL(18,2)
    ) AS AvgWeeklyDemand,

    CAST(
        AVG(DemandCV)
        AS DECIMAL(18,4)
    ) AS AvgDemandCV

FROM analytics.vw_ProductABCXYZ

GROUP BY ABCXYZClass

ORDER BY
    ABCXYZClass;

SELECT TOP 30
    StockCode,
    ProductDescription,
    ABCXYZClass,
    Revenue,
    TotalUnitsSold,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    ActiveWeekPct,
    DemandPattern

FROM analytics.vw_ProductABCXYZ

WHERE ABCClass = 'A'

ORDER BY Revenue DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,
    ABCXYZClass,
    Revenue,
    TotalUnitsSold,
    LifecycleWeeks,
    ActiveWeekPct,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV

FROM analytics.vw_ProductABCXYZ

WHERE ABCXYZClass = 'AZ'

ORDER BY Revenue DESC;

CREATE OR ALTER VIEW analytics.vw_ProductMovementClassification
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    LifecycleWeeks,
    ActiveSalesWeeks,
    ZeroDemandWeeks,
    ActiveWeekPct,

    TotalUnitsSold,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,
    Revenue,

    CASE

        WHEN LifecycleWeeks < 4
            THEN 'Insufficient History'

        WHEN ActiveWeekPct >= 75
            THEN 'Fast Moving'

        WHEN ActiveWeekPct >= 40
            THEN 'Medium Moving'

        WHEN ActiveWeekPct >= 10
            THEN 'Slow Moving'

        ELSE 'Intermittent'

    END AS MovementClass

FROM analytics.vw_ProductDemandStatisticsComplete;
GO

SELECT
    MovementClass,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(TotalUnitsSold)
        AS BIGINT
    ) AS UnitsSold,

    CAST(
        AVG(ActiveWeekPct)
        AS DECIMAL(10,2)
    ) AS AvgActiveWeekPct,

    CAST(
        AVG(AverageWeeklyDemand)
        AS DECIMAL(18,2)
    ) AS AvgWeeklyDemand

FROM analytics.vw_ProductMovementClassification

GROUP BY MovementClass

ORDER BY
    CASE MovementClass
        WHEN 'Fast Moving' THEN 1
        WHEN 'Medium Moving' THEN 2
        WHEN 'Slow Moving' THEN 3
        WHEN 'Intermittent' THEN 4
        ELSE 5
    END;

CREATE OR ALTER VIEW analytics.vw_ProductInventoryProfile
AS

SELECT
    a.ProductKey,
    a.StockCode,
    a.ProductDescription,

    a.ABCClass,
    x.XYZClass,
    a.ABCXYZClass,

    m.MovementClass,

    a.Revenue,
    a.TotalUnitsSold,

    a.LifecycleWeeks,
    a.ActiveSalesWeeks,
    a.ZeroDemandWeeks,
    a.ActiveWeekPct,

    a.AverageWeeklyDemand,
    a.WeeklyDemandStdDev,
    a.DemandCV,
    a.DemandPattern

FROM analytics.vw_ProductABCXYZ a

INNER JOIN analytics.vw_ProductMovementClassification m
    ON a.ProductKey = m.ProductKey

INNER JOIN analytics.vw_ProductXYZClassification x
    ON a.ProductKey = x.ProductKey;
GO

SELECT TOP 50
    StockCode,
    ProductDescription,

    ABCClass,
    XYZClass,
    ABCXYZClass,
    MovementClass,

    Revenue,
    TotalUnitsSold,

    LifecycleWeeks,
    ActiveWeekPct,

    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV

FROM analytics.vw_ProductInventoryProfile

WHERE ABCClass = 'A'

ORDER BY Revenue DESC;

CREATE OR ALTER VIEW analytics.vw_InventoryPriority
AS

SELECT
    *,

    CASE

        WHEN ABCXYZClass = 'AX'
         AND MovementClass = 'Fast Moving'
            THEN 'Critical Replenishment'

        WHEN ABCClass = 'A'
         AND XYZClass IN ('Y', 'Z')
            THEN 'High-Value Demand Review'

        WHEN ABCClass = 'A'
            THEN 'High Priority'

        WHEN ABCClass = 'B'
         AND MovementClass IN
         (
             'Fast Moving',
             'Medium Moving'
         )
            THEN 'Standard Replenishment'

        WHEN ABCClass = 'C'
         AND MovementClass IN
         (
             'Slow Moving',
             'Intermittent'
         )
            THEN 'Inventory Reduction Review'

        WHEN MovementClass = 'Insufficient History'
            THEN 'Manual Review'

        ELSE 'Routine Monitoring'

    END AS InventoryPriority

FROM analytics.vw_ProductInventoryProfile;
GO

SELECT
    InventoryPriority,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    CAST(
        SUM(TotalUnitsSold)
        AS BIGINT
    ) AS UnitsSold

FROM analytics.vw_InventoryPriority

GROUP BY InventoryPriority

ORDER BY Revenue DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,
    ABCXYZClass,
    MovementClass,
    Revenue,
    TotalUnitsSold,
    LifecycleWeeks,
    ActiveWeekPct,
    AverageWeeklyDemand,
    DemandCV,
    InventoryPriority

FROM analytics.vw_InventoryPriority

WHERE InventoryPriority =
      'Inventory Reduction Review'

ORDER BY Revenue ASC,
         ActiveWeekPct ASC;

CREATE OR ALTER VIEW analytics.vw_InventoryPlanningEligibility
AS

SELECT
    *,

    CASE

        WHEN LifecycleWeeks < 12
            THEN 'Limited History'

        WHEN WeeklyDemandStdDev IS NULL
            THEN 'Limited History'

        WHEN MovementClass IN
        (
            'Intermittent',
            'Slow Moving'
        )
            THEN 'Intermittent / Slow Demand Review'

        WHEN MovementClass IN
        (
            'Fast Moving',
            'Medium Moving'
        )
            THEN 'Planning Eligible'

        ELSE 'Manual Review'

    END AS PlanningStatus

FROM analytics.vw_InventoryPriority;
GO

SELECT
    PlanningStatus,
    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue

FROM analytics.vw_InventoryPlanningEligibility

GROUP BY PlanningStatus

ORDER BY Revenue DESC;

CREATE OR ALTER VIEW analytics.vw_InventoryReorderRecommendations
AS

WITH Parameters AS
(
    SELECT
        CAST(2.0 AS FLOAT) AS LeadTimeWeeks,
        CAST(1.0 AS FLOAT) AS ReviewPeriodWeeks,
        CAST(95.0 AS DECIMAL(5,2)) AS ServiceLevelPct,
        CAST(1.645 AS FLOAT) AS ZScore
)

SELECT
    i.ProductKey,
    i.StockCode,
    i.ProductDescription,

    i.ABCClass,
    i.XYZClass,
    i.ABCXYZClass,
    i.MovementClass,
    i.InventoryPriority,
    i.PlanningStatus,

    i.Revenue,
    i.TotalUnitsSold,

    i.LifecycleWeeks,
    i.ActiveWeekPct,

    i.AverageWeeklyDemand,
    i.WeeklyDemandStdDev,
    i.DemandCV,

    CAST(p.LeadTimeWeeks AS DECIMAL(5,2))
        AS AssumedLeadTimeWeeks,

    CAST(p.ReviewPeriodWeeks AS DECIMAL(5,2))
        AS AssumedReviewPeriodWeeks,

    p.ServiceLevelPct,

    CAST(p.ZScore AS DECIMAL(6,3))
        AS ZScore,

    CASE
        WHEN i.PlanningStatus = 'Planning Eligible'
        THEN CEILING(
            i.AverageWeeklyDemand
            * p.LeadTimeWeeks
        )
        ELSE NULL
    END AS LeadTimeDemandUnits,

    CASE
        WHEN i.PlanningStatus = 'Planning Eligible'
        THEN CEILING(
            p.ZScore
            * i.WeeklyDemandStdDev
            * SQRT(p.LeadTimeWeeks)
        )
        ELSE NULL
    END AS SafetyStockUnits,

    CASE
        WHEN i.PlanningStatus = 'Planning Eligible'
        THEN CEILING(
            (
                i.AverageWeeklyDemand
                * p.LeadTimeWeeks
            )
            +
            (
                p.ZScore
                * i.WeeklyDemandStdDev
                * SQRT(p.LeadTimeWeeks)
            )
        )
        ELSE NULL
    END AS ReorderPointUnits,

    CASE
        WHEN i.PlanningStatus = 'Planning Eligible'
        THEN CEILING(
            (
                i.AverageWeeklyDemand
                *
                (
                    p.LeadTimeWeeks
                    + p.ReviewPeriodWeeks
                )
            )
            +
            (
                p.ZScore
                * i.WeeklyDemandStdDev
                * SQRT(p.LeadTimeWeeks)
            )
        )
        ELSE NULL
    END AS TargetStockLevelUnits

FROM analytics.vw_InventoryPlanningEligibility i

CROSS JOIN Parameters p;
GO

SELECT TOP 30
    StockCode,
    ProductDescription,

    ABCXYZClass,
    MovementClass,
    InventoryPriority,
    PlanningStatus,

    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,

    AssumedLeadTimeWeeks,
    ServiceLevelPct,

    LeadTimeDemandUnits,
    SafetyStockUnits,
    ReorderPointUnits,
    TargetStockLevelUnits

FROM analytics.vw_InventoryReorderRecommendations

WHERE PlanningStatus = 'Planning Eligible'

ORDER BY Revenue DESC;

SELECT
    StockCode,
    ProductDescription,
    ABCXYZClass,
    MovementClass,

    Revenue,
    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,

    SafetyStockUnits,
    ReorderPointUnits,
    TargetStockLevelUnits

FROM analytics.vw_InventoryReorderRecommendations

WHERE InventoryPriority =
      'Critical Replenishment'

ORDER BY Revenue DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,
    ABCXYZClass,
    MovementClass,

    Revenue,

    AverageWeeklyDemand,
    WeeklyDemandStdDev,
    DemandCV,

    SafetyStockUnits,
    ReorderPointUnits,
    TargetStockLevelUnits

FROM analytics.vw_InventoryReorderRecommendations

WHERE ABCXYZClass = 'AZ'
  AND PlanningStatus = 'Planning Eligible'

ORDER BY Revenue DESC;

SELECT
    PlanningStatus,

    COUNT(*) AS Products,

    SUM(
        CASE
            WHEN ReorderPointUnits IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithReorderRecommendation

FROM analytics.vw_InventoryReorderRecommendations

GROUP BY PlanningStatus;

SELECT
    PlanningStatus,
    COUNT(*) AS Products
FROM analytics.vw_InventoryReorderRecommendations
WHERE InventoryPriority = 'Critical Replenishment'
GROUP BY PlanningStatus;

CREATE OR ALTER VIEW analytics.vw_FinalInventoryRecommendations
AS

SELECT
    r.ProductKey,
    r.StockCode,
    r.ProductDescription,

    r.ABCClass,
    r.XYZClass,
    r.ABCXYZClass,
    r.MovementClass,

    r.InventoryPriority,
    r.PlanningStatus,

    r.Revenue,
    r.TotalUnitsSold,

    r.LifecycleWeeks,
    r.ActiveWeekPct,

    r.AverageWeeklyDemand,
    r.WeeklyDemandStdDev,
    r.DemandCV,

    r.AssumedLeadTimeWeeks,
    r.AssumedReviewPeriodWeeks,
    r.ServiceLevelPct,

    r.LeadTimeDemandUnits,
    r.SafetyStockUnits,
    r.ReorderPointUnits,

    r.TargetStockLevelUnits
        AS RecommendedInventoryLevelUnits,

    p.UnitCancellationRatePct,

    CASE

        WHEN r.PlanningStatus = 'Limited History'
            THEN 'Manual Planning Review'

        WHEN r.PlanningStatus =
             'Intermittent / Slow Demand Review'
             AND r.ABCClass = 'C'
            THEN 'Reduce / Rationalize Inventory'

        WHEN r.PlanningStatus = 'Planning Eligible'
             AND r.InventoryPriority =
                 'Critical Replenishment'
            THEN 'Priority Replenishment'

        WHEN r.PlanningStatus = 'Planning Eligible'
             AND r.InventoryPriority =
                 'High-Value Demand Review'
            THEN 'Safety Stock / Demand Review'

        WHEN r.PlanningStatus = 'Planning Eligible'
             AND r.InventoryPriority =
                 'Standard Replenishment'
            THEN 'Standard Replenishment'

        WHEN r.PlanningStatus = 'Planning Eligible'
            THEN 'Routine Replenishment'

        ELSE 'Manual Inventory Review'

    END AS RecommendedAction,

    CASE

        WHEN r.ABCClass = 'C'
             AND r.MovementClass IN
             (
                 'Slow Moving',
                 'Intermittent'
             )
             AND r.LifecycleWeeks >= 20
            THEN 1

        ELSE 0

    END AS ConversionReviewCandidate,

    CASE

        WHEN r.ABCClass = 'C'
             AND r.MovementClass = 'Intermittent'
             AND r.LifecycleWeeks >= 20
            THEN 'Low-value intermittent demand'

        WHEN r.ABCClass = 'C'
             AND r.MovementClass = 'Slow Moving'
             AND r.LifecycleWeeks >= 20
            THEN 'Low-value slow-moving demand'

        ELSE NULL

    END AS ConversionReviewReason

FROM analytics.vw_InventoryReorderRecommendations r

LEFT JOIN analytics.vw_ProductPerformance p
    ON r.ProductKey = p.ProductKey;
GO

SELECT
    RecommendedAction,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    SUM(
        CASE
            WHEN RecommendedInventoryLevelUnits
                 IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithInventoryRecommendation

FROM analytics.vw_FinalInventoryRecommendations

GROUP BY RecommendedAction

ORDER BY Revenue DESC;

SELECT
    COUNT(*) AS TotalProducts,

    SUM(
        CASE
            WHEN ReorderPointUnits IS NOT NULL
            THEN 1
            ELSE 0
        END
    ) AS ProductsWithReorderPoint,

    SUM(
        CASE
            WHEN ConversionReviewCandidate = 1
            THEN 1
            ELSE 0
        END
    ) AS ConversionReviewCandidates,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS TotalRevenue

FROM analytics.vw_FinalInventoryRecommendations;

CREATE OR ALTER VIEW analytics.vw_ProductConversionReviewCandidates
AS

SELECT
    ProductKey,
    StockCode,
    ProductDescription,

    ABCXYZClass,
    MovementClass,

    Revenue,
    TotalUnitsSold,

    LifecycleWeeks,
    ActiveWeekPct,

    AverageWeeklyDemand,
    DemandCV,

    UnitCancellationRatePct,

    ConversionReviewReason

FROM analytics.vw_FinalInventoryRecommendations

WHERE ConversionReviewCandidate = 1;
GO

SELECT TOP 30
    *
FROM analytics.vw_ProductConversionReviewCandidates
ORDER BY
    Revenue ASC,
    ActiveWeekPct ASC;

SELECT
    ConversionReviewReason,

    COUNT(*) AS Products,

    CAST(
        SUM(Revenue)
        AS DECIMAL(18,2)
    ) AS Revenue,

    SUM(TotalUnitsSold) AS UnitsSold,

    CAST(
        AVG(ActiveWeekPct)
        AS DECIMAL(10,2)
    ) AS AverageActiveWeekPct

FROM analytics.vw_ProductConversionReviewCandidates

GROUP BY ConversionReviewReason

ORDER BY Products DESC;

SELECT TOP 30
    StockCode,
    ProductDescription,

    ABCXYZClass,
    MovementClass,
    PlanningStatus,

    Revenue,

    AverageWeeklyDemand,
    WeeklyDemandStdDev,

    SafetyStockUnits,
    ReorderPointUnits,
    RecommendedInventoryLevelUnits,

    RecommendedAction

FROM analytics.vw_FinalInventoryRecommendations

WHERE ABCClass = 'A'

ORDER BY Revenue DESC;