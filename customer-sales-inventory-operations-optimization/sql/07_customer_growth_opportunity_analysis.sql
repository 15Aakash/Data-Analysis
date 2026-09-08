USE CustomerSalesInventoryOps;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerGrowthTrend
AS

WITH Snapshot AS
(
    SELECT
        CAST(MAX(InvoiceDate) AS DATE) AS SnapshotDate
    FROM core.Sales
),

Periods AS
(
    SELECT
        SnapshotDate,

        DATEADD(
            DAY,
            -89,
            SnapshotDate
        ) AS CurrentPeriodStart,

        DATEADD(
            DAY,
            -179,
            SnapshotDate
        ) AS PreviousPeriodStart,

        DATEADD(
            DAY,
            -90,
            SnapshotDate
        ) AS PreviousPeriodEnd

    FROM Snapshot
),

CustomerPeriodMetrics AS
(
    SELECT
        c.CustomerKey,
        c.CustomerID,
        c.Country,

        p.SnapshotDate,
        p.CurrentPeriodStart,
        p.PreviousPeriodStart,
        p.PreviousPeriodEnd,

        SUM(
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.CurrentPeriodStart
                     AND p.SnapshotDate

                THEN s.GrossRevenue
                ELSE 0
            END
        ) AS Current90Revenue,

        SUM(
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.PreviousPeriodStart
                     AND p.PreviousPeriodEnd

                THEN s.GrossRevenue
                ELSE 0
            END
        ) AS Previous90Revenue,

        COUNT(
            DISTINCT
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.CurrentPeriodStart
                     AND p.SnapshotDate

                THEN s.Invoice
            END
        ) AS Current90Orders,

        COUNT(
            DISTINCT
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.PreviousPeriodStart
                     AND p.PreviousPeriodEnd

                THEN s.Invoice
            END
        ) AS Previous90Orders,

        SUM(
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.CurrentPeriodStart
                     AND p.SnapshotDate

                THEN s.Quantity
                ELSE 0
            END
        ) AS Current90Units,

        SUM(
            CASE
                WHEN CAST(s.InvoiceDate AS DATE)
                     BETWEEN p.PreviousPeriodStart
                     AND p.PreviousPeriodEnd

                THEN s.Quantity
                ELSE 0
            END
        ) AS Previous90Units

    FROM core.Customers c

    INNER JOIN core.Sales s
        ON c.CustomerKey = s.CustomerKey

    CROSS JOIN Periods p

    GROUP BY
        c.CustomerKey,
        c.CustomerID,
        c.Country,
        p.SnapshotDate,
        p.CurrentPeriodStart,
        p.PreviousPeriodStart,
        p.PreviousPeriodEnd
)

SELECT
    CustomerKey,
    CustomerID,
    Country,

    SnapshotDate,
    CurrentPeriodStart,
    PreviousPeriodStart,
    PreviousPeriodEnd,

    CAST(Current90Revenue AS DECIMAL(18,2))
        AS Current90Revenue,

    CAST(Previous90Revenue AS DECIMAL(18,2))
        AS Previous90Revenue,

    CAST(
        Current90Revenue - Previous90Revenue
        AS DECIMAL(18,2)
    ) AS RevenueChange,

    CAST(
        CASE

            WHEN Previous90Revenue = 0
                THEN NULL

            ELSE
                (
                    Current90Revenue
                    - Previous90Revenue
                )
                * 100.0
                / Previous90Revenue

        END
        AS DECIMAL(10,2)
    ) AS RevenueGrowthPct,

    Current90Orders,
    Previous90Orders,

    Current90Units,
    Previous90Units,

    CASE

        WHEN Current90Revenue = 0
         AND Previous90Revenue > 0
            THEN 'Reactivation Opportunity'

        WHEN Current90Revenue > 0
         AND Previous90Revenue = 0
            THEN 'Newly Active'

        WHEN Current90Revenue = 0
         AND Previous90Revenue = 0
            THEN 'Dormant'

        WHEN Current90Revenue >=
             Previous90Revenue * 1.20
            THEN 'Growing'

        WHEN Current90Revenue <=
             Previous90Revenue * 0.80
            THEN 'Declining'

        ELSE 'Stable'

    END AS TrendStatus

FROM CustomerPeriodMetrics;
GO

SELECT
    TrendStatus,
    COUNT(*) AS Customers,

    CAST(
        SUM(Previous90Revenue)
        AS DECIMAL(18,2)
    ) AS Previous90Revenue,

    CAST(
        SUM(Current90Revenue)
        AS DECIMAL(18,2)
    ) AS Current90Revenue,

    CAST(
        SUM(Current90Revenue)
        -
        SUM(Previous90Revenue)
        AS DECIMAL(18,2)
    ) AS RevenueChange

FROM analytics.vw_CustomerGrowthTrend

GROUP BY TrendStatus

ORDER BY Customers DESC;
GO

CREATE OR ALTER VIEW analytics.vw_CustomerAccountOpportunities
AS

SELECT
    g.CustomerKey,
    g.CustomerID,
    g.Country,

    s.CustomerSegment,
    s.RFMCode,
    s.RFMTotalScore,
    s.RScore,
    s.FScore,
    s.MScore,

    s.RecencyDays,
    s.TotalOrders,

    CAST(
        s.Revenue
        AS DECIMAL(18,2)
    ) AS HistoricalRevenue,

    g.Previous90Revenue,
    g.Current90Revenue,
    g.RevenueChange,
    g.RevenueGrowthPct,
    g.TrendStatus,

    CAST(
        CASE
            WHEN g.Previous90Revenue > g.Current90Revenue
            THEN g.Previous90Revenue - g.Current90Revenue
            ELSE 0
        END
        AS DECIMAL(18,2)
    ) AS RevenueGapVsPrior90Days,

    p.CancellationValuePct,

    CASE

        WHEN g.TrendStatus = 'Reactivation Opportunity'
             AND s.MScore >= 4
            THEN 'High-Value Reactivation'

        WHEN g.TrendStatus = 'Declining'
             AND s.CustomerSegment IN
             (
                 'Champions',
                 'Loyal Customers',
                 'High Value At Risk'
             )
            THEN 'Revenue Recovery Review'

        WHEN g.TrendStatus = 'Growing'
             AND s.CustomerSegment IN
             (
                 'Champions',
                 'Loyal Customers',
                 'Potential Loyalists'
             )
            THEN 'Expansion Review'

        WHEN p.CancellationValuePct >= 10
            THEN 'Service / Cancellation Review'

        WHEN s.CustomerSegment = 'High Value At Risk'
            THEN 'Retention Review'

        ELSE 'Monitor'

    END AS OpportunityType,

    CASE

        WHEN
        (
            g.TrendStatus = 'Reactivation Opportunity'
            AND s.MScore >= 4
        )

        OR
        (
            g.TrendStatus = 'Declining'
            AND s.CustomerSegment IN
            (
                'Champions',
                'Loyal Customers',
                'High Value At Risk'
            )
        )

        OR s.CustomerSegment = 'High Value At Risk'
            THEN 'High'

        WHEN g.TrendStatus = 'Declining'

        OR p.CancellationValuePct >= 10

        OR s.CustomerSegment IN
        (
            'At Risk',
            'Needs Attention'
        )
            THEN 'Medium'

        ELSE 'Normal'

    END AS OpportunityPriority

FROM analytics.vw_CustomerGrowthTrend g

INNER JOIN analytics.vw_CustomerSegments s
    ON g.CustomerKey = s.CustomerKey

INNER JOIN analytics.vw_CustomerPerformance p
    ON g.CustomerKey = p.CustomerKey;
GO

SELECT
    OpportunityPriority,
    OpportunityType,

    COUNT(*) AS Customers,

    CAST(
        SUM(HistoricalRevenue)
        AS DECIMAL(18,2)
    ) AS HistoricalRevenue,

    CAST(
        SUM(RevenueGapVsPrior90Days)
        AS DECIMAL(18,2)
    ) AS RevenueGapVsPrior90Days

FROM analytics.vw_CustomerAccountOpportunities

GROUP BY
    OpportunityPriority,
    OpportunityType

ORDER BY
    CASE OpportunityPriority
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        ELSE 3
    END,
    Customers DESC;

SELECT TOP 30
    CustomerID,
    Country,

    CustomerSegment,
    RFMCode,

    RecencyDays,
    TotalOrders,

    HistoricalRevenue,

    Previous90Revenue,
    Current90Revenue,

    RevenueChange,
    RevenueGrowthPct,

    RevenueGapVsPrior90Days,

    CancellationValuePct,

    TrendStatus,
    OpportunityType,
    OpportunityPriority

FROM analytics.vw_CustomerAccountOpportunities

WHERE OpportunityPriority = 'High'

ORDER BY
    RevenueGapVsPrior90Days DESC,
    HistoricalRevenue DESC;