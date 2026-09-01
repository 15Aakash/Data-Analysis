USE rivercare_analytics;
GO

/* ============================================================
   RIVERCARE HEALTH SYSTEM
   02 - OPERATIONAL TREND ANALYSIS
   ============================================================ */

SELECT
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth,

    COUNT(*) AS TotalEncounters,

    COUNT(
        DISTINCT CASE
            WHEN f.PatientKey <> 0
            THEN f.PatientKey
        END
    ) AS UniquePatients,

    ROUND(
        AVG(f.WaitMinutes),
        2
    ) AS AverageWaitMinutes,

    ROUND(
        SUM(f.EncounterCost),
        2
    ) AS TotalEncounterCost

FROM dbo.fact_encounter AS f

INNER JOIN dbo.dim_date AS d
    ON f.EncounterDateKey = d.DateKey

WHERE
    f.EncounterDateKey <> 0

GROUP BY
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth

ORDER BY
    d.Year,
    d.Month;

/* ------------------------------------------------------------
   2. Month-over-Month Encounter Volume Change
   ------------------------------------------------------------ */

WITH MonthlyEncounters AS
(
    SELECT
        d.Year,
        d.Month,
        d.YearMonth,
        COUNT(*) AS TotalEncounters

    FROM dbo.fact_encounter AS f

    INNER JOIN dbo.dim_date AS d
        ON f.EncounterDateKey = d.DateKey

    WHERE
        f.EncounterDateKey <> 0

    GROUP BY
        d.Year,
        d.Month,
        d.YearMonth
),

EncounterTrend AS
(
    SELECT
        Year,
        Month,
        YearMonth,
        TotalEncounters,

        LAG(TotalEncounters)
        OVER (
            ORDER BY Year, Month
        ) AS PreviousMonthEncounters

    FROM MonthlyEncounters
)

SELECT
    Year,
    Month,
    YearMonth,
    TotalEncounters,
    PreviousMonthEncounters,

    TotalEncounters
        - PreviousMonthEncounters
        AS EncounterChange,

    ROUND(
        100.0
        * (
            TotalEncounters
            - PreviousMonthEncounters
        )
        / NULLIF(
            PreviousMonthEncounters,
            0
        ),
        2
    ) AS MoMChangePercentage

FROM EncounterTrend

ORDER BY
    Year,
    Month;

/* ------------------------------------------------------------
   3. Monthly Wait-Time Trend
   ------------------------------------------------------------ */

SELECT
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth,

    COUNT(*) AS EncounterCount,

    ROUND(
        AVG(f.WaitMinutes),
        2
    ) AS AverageWaitMinutes,

    ROUND(
        MIN(f.WaitMinutes),
        2
    ) AS MinimumWaitMinutes,

    ROUND(
        MAX(f.WaitMinutes),
        2
    ) AS MaximumWaitMinutes

FROM dbo.fact_encounter AS f

INNER JOIN dbo.dim_date AS d
    ON f.EncounterDateKey = d.DateKey

WHERE
    f.EncounterDateKey <> 0
    AND f.WaitMinutes IS NOT NULL

GROUP BY
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth

ORDER BY
    d.Year,
    d.Month;

/* ------------------------------------------------------------
   4. Monthly Emergency Department Utilization
   ------------------------------------------------------------ */

SELECT
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth,

    COUNT(*) AS TotalEncounters,

    SUM(
        CASE
            WHEN f.EncounterType = 'Emergency'
            THEN 1
            ELSE 0
        END
    ) AS EmergencyEncounters,

    ROUND(
        100.0
        *
        SUM(
            CASE
                WHEN f.EncounterType = 'Emergency'
                THEN 1
                ELSE 0
            END
        )
        /
        NULLIF(
            COUNT(*),
            0
        ),
        2
    ) AS EDUtilizationPercentage

FROM dbo.fact_encounter AS f

INNER JOIN dbo.dim_date AS d
    ON f.EncounterDateKey = d.DateKey

WHERE
    f.EncounterDateKey <> 0

GROUP BY
    d.Year,
    d.Month,
    d.MonthName,
    d.YearMonth

ORDER BY
    d.Year,
    d.Month;

/* ------------------------------------------------------------
   5. Department Ranking by Average Wait Time
   ------------------------------------------------------------ */

WITH DepartmentWaitTime AS
(
    SELECT
        d.DepartmentName,

        COUNT(*) AS TotalEncounters,

        ROUND(
            AVG(f.WaitMinutes),
            2
        ) AS AverageWaitMinutes

    FROM dbo.fact_encounter AS f

    INNER JOIN dbo.dim_department AS d
        ON f.DepartmentKey = d.DepartmentKey

    WHERE
        f.DepartmentKey <> 0
        AND f.WaitMinutes IS NOT NULL

    GROUP BY
        d.DepartmentName
)

SELECT
    DepartmentName,
    TotalEncounters,
    AverageWaitMinutes,

    RANK() OVER (
        ORDER BY AverageWaitMinutes DESC
    ) AS WaitTimeRank

FROM DepartmentWaitTime

ORDER BY
    WaitTimeRank,
    DepartmentName;

/* ------------------------------------------------------------
   6. Year-over-Year Encounter Volume Change
   ------------------------------------------------------------ */

WITH YearlyEncounters AS
(
    SELECT
        d.Year,
        COUNT(*) AS TotalEncounters

    FROM dbo.fact_encounter AS f

    INNER JOIN dbo.dim_date AS d
        ON f.EncounterDateKey = d.DateKey

    WHERE
        f.EncounterDateKey <> 0

    GROUP BY
        d.Year
),

YearlyComparison AS
(
    SELECT
        Year,
        TotalEncounters,

        LAG(TotalEncounters)
        OVER (
            ORDER BY Year
        ) AS PreviousYearEncounters

    FROM YearlyEncounters
)

SELECT
    Year,
    TotalEncounters,
    PreviousYearEncounters,

    TotalEncounters
        - PreviousYearEncounters
        AS EncounterChange,

    ROUND(
        100.0
        * (
            TotalEncounters
            - PreviousYearEncounters
        )
        /
        NULLIF(
            PreviousYearEncounters,
            0
        ),
        2
    ) AS YoYChangePercentage

FROM YearlyComparison

ORDER BY
    Year;

/* ------------------------------------------------------------
   7. Month-over-Month Encounter Cost Trend
   ------------------------------------------------------------ */

WITH MonthlyCost AS
(
    SELECT
        d.Year,
        d.Month,
        d.YearMonth,

        COUNT(*) AS TotalEncounters,

        ROUND(
            SUM(f.EncounterCost),
            2
        ) AS TotalEncounterCost,

        ROUND(
            AVG(f.EncounterCost),
            2
        ) AS AverageEncounterCost

    FROM dbo.fact_encounter AS f

    INNER JOIN dbo.dim_date AS d
        ON f.EncounterDateKey = d.DateKey

    WHERE
        f.EncounterDateKey <> 0
        AND f.EncounterCost IS NOT NULL

    GROUP BY
        d.Year,
        d.Month,
        d.YearMonth
),

CostComparison AS
(
    SELECT
        Year,
        Month,
        YearMonth,
        TotalEncounters,
        TotalEncounterCost,
        AverageEncounterCost,

        LAG(TotalEncounterCost)
        OVER (
            ORDER BY Year, Month
        ) AS PreviousMonthCost

    FROM MonthlyCost
)

SELECT
    Year,
    Month,
    YearMonth,

    TotalEncounters,
    TotalEncounterCost,
    AverageEncounterCost,
    PreviousMonthCost,

    ROUND(
        TotalEncounterCost
        - PreviousMonthCost,
        2
    ) AS CostChange,

    ROUND(
        100.0
        * (
            TotalEncounterCost
            - PreviousMonthCost
        )
        /
        NULLIF(
            PreviousMonthCost,
            0
        ),
        2
    ) AS MoMCostChangePercentage

FROM CostComparison

ORDER BY
    Year,
    Month;