USE CustomerSalesInventoryOps;
GO

IF OBJECT_ID('staging.Transactions', 'U') IS NOT NULL
    DROP TABLE staging.Transactions;
GO

CREATE TABLE staging.Transactions
(
    StagingTransactionID BIGINT IDENTITY(1,1) PRIMARY KEY,

    Invoice NVARCHAR(20) NOT NULL,
    StockCode NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255) NULL,
    CustomerID INT NULL,
    Country NVARCHAR(100) NULL,
    SourceSheet NVARCHAR(30) NULL,

    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,4) NOT NULL,
    TransactionValue DECIMAL(18,4) NOT NULL,
    InvoiceDate DATETIME2 NOT NULL,

    InvoiceYear SMALLINT NULL,
    InvoiceMonth TINYINT NULL,
    YearMonth CHAR(7) NULL,
    InvoiceWeek NVARCHAR(30) NULL,
    DayOfWeek NVARCHAR(15) NULL,

    TransactionType NVARCHAR(60) NOT NULL,

    IsCancellation BIT NOT NULL,
    IsNegativeQuantity BIT NOT NULL,
    IsZeroPrice BIT NOT NULL,
    IsNegativePrice BIT NOT NULL,
    IsMissingCustomer BIT NOT NULL,
    IsMissingDescription BIT NOT NULL,
    AppearsAcrossSheets BIT NOT NULL,

    TransactionHash VARCHAR(20) NULL,

    LoadDate DATETIME2 NOT NULL
        DEFAULT SYSDATETIME()
);
GO

SELECT COUNT(*) AS TransactionCount
FROM staging.Transactions;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'staging'
    AND TABLE_NAME = 'Transactions'
ORDER BY ORDINAL_POSITION;

SELECT COUNT(*) AS TransactionCount
FROM staging.Transactions;

SELECT COUNT(*) AS TransactionCount
FROM staging.Transactions;

SELECT
    TransactionType,
    COUNT(*) AS TransactionCount
FROM staging.Transactions
GROUP BY TransactionType
ORDER BY TransactionCount DESC;

SELECT
    SUM(
        CASE
            WHEN TransactionType = 'Merchandise Sale'
            THEN TransactionValue
            ELSE 0
        END
    ) AS MerchandiseRevenue
FROM staging.Transactions;

SELECT COUNT(*) AS TransactionCount
FROM staging.Transactions;

SELECT
    TransactionType,
    COUNT(*) AS TransactionCount
FROM staging.Transactions
GROUP BY TransactionType
ORDER BY TransactionCount DESC;