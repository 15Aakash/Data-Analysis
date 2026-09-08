USE CustomerSalesInventoryOps;
GO

IF OBJECT_ID('core.Customers', 'U') IS NOT NULL
    DROP TABLE core.Customers;
GO

CREATE TABLE core.Customers
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,

    CustomerID INT NOT NULL,
    Country NVARCHAR(100) NULL,

    FirstPurchaseDate DATETIME2 NULL,
    LastPurchaseDate DATETIME2 NULL,

    CreatedDate DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_Customers_CustomerID
        UNIQUE(CustomerID)
);
GO

IF OBJECT_ID('core.Products', 'U') IS NOT NULL
    DROP TABLE core.Products;
GO

CREATE TABLE core.Products
(
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,

    StockCode NVARCHAR(50) NOT NULL,
    ProductDescription NVARCHAR(255) NULL,

    FirstSaleDate DATETIME2 NULL,
    LastSaleDate DATETIME2 NULL,

    CreatedDate DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT UQ_Products_StockCode
        UNIQUE(StockCode)
);
GO

IF OBJECT_ID('core.Dates', 'U') IS NOT NULL
    DROP TABLE core.Dates;
GO

CREATE TABLE core.Dates
(
    DateKey INT PRIMARY KEY,

    FullDate DATE NOT NULL,

    CalendarYear SMALLINT NOT NULL,
    CalendarQuarter TINYINT NOT NULL,
    MonthNumber TINYINT NOT NULL,
    MonthName NVARCHAR(15) NOT NULL,

    YearMonth CHAR(7) NOT NULL,

    WeekNumber TINYINT NOT NULL,

    DayOfMonth TINYINT NOT NULL,
    DayOfWeekNumber TINYINT NOT NULL,
    DayName NVARCHAR(15) NOT NULL,

    IsWeekend BIT NOT NULL,

    CONSTRAINT UQ_Dates_FullDate
        UNIQUE(FullDate)
);
GO

IF OBJECT_ID('core.Sales', 'U') IS NOT NULL
    DROP TABLE core.Sales;
GO

CREATE TABLE core.Sales
(
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    StagingTransactionID BIGINT NOT NULL,

    Invoice NVARCHAR(20) NOT NULL,

    ProductKey INT NOT NULL,
    CustomerKey INT NULL,
    DateKey INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(18,4) NOT NULL,
    GrossRevenue DECIMAL(18,4) NOT NULL,

    Country NVARCHAR(100) NULL,

    InvoiceDate DATETIME2 NOT NULL,

    CONSTRAINT FK_Sales_Product
        FOREIGN KEY(ProductKey)
        REFERENCES core.Products(ProductKey),

    CONSTRAINT FK_Sales_Customer
        FOREIGN KEY(CustomerKey)
        REFERENCES core.Customers(CustomerKey),

    CONSTRAINT FK_Sales_Date
        FOREIGN KEY(DateKey)
        REFERENCES core.Dates(DateKey),

    CONSTRAINT UQ_Sales_StagingTransaction
        UNIQUE(StagingTransactionID)
);
GO

IF OBJECT_ID('core.Cancellations', 'U') IS NOT NULL
    DROP TABLE core.Cancellations;
GO

CREATE TABLE core.Cancellations
(
    CancellationKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    StagingTransactionID BIGINT NOT NULL,

    CancellationInvoice NVARCHAR(20) NOT NULL,

    ProductKey INT NOT NULL,
    CustomerKey INT NULL,
    DateKey INT NOT NULL,

    CancelledQuantity INT NOT NULL,

    UnitPrice DECIMAL(18,4) NOT NULL,
    CancellationValue DECIMAL(18,4) NOT NULL,

    Country NVARCHAR(100) NULL,

    CancellationDate DATETIME2 NOT NULL,

    CONSTRAINT FK_Cancellations_Product
        FOREIGN KEY(ProductKey)
        REFERENCES core.Products(ProductKey),

    CONSTRAINT FK_Cancellations_Customer
        FOREIGN KEY(CustomerKey)
        REFERENCES core.Customers(CustomerKey),

    CONSTRAINT FK_Cancellations_Date
        FOREIGN KEY(DateKey)
        REFERENCES core.Dates(DateKey),

    CONSTRAINT UQ_Cancellations_StagingTransaction
        UNIQUE(StagingTransactionID)
);
GO

CREATE INDEX IX_Sales_ProductKey
ON core.Sales(ProductKey);
GO

CREATE INDEX IX_Sales_CustomerKey
ON core.Sales(CustomerKey);
GO

CREATE INDEX IX_Sales_DateKey
ON core.Sales(DateKey);
GO

CREATE INDEX IX_Sales_Invoice
ON core.Sales(Invoice);
GO


CREATE INDEX IX_Cancellations_ProductKey
ON core.Cancellations(ProductKey);
GO

CREATE INDEX IX_Cancellations_CustomerKey
ON core.Cancellations(CustomerKey);
GO

CREATE INDEX IX_Cancellations_DateKey
ON core.Cancellations(DateKey);
GO

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'core'
ORDER BY t.name;

SELECT 'Customers' AS TableName,
       COUNT(*) AS RecordCount
FROM core.Customers

UNION ALL

SELECT 'Products',
       COUNT(*)
FROM core.Products

UNION ALL

SELECT 'Dates',
       COUNT(*)
FROM core.Dates

UNION ALL

SELECT 'Sales',
       COUNT(*)
FROM core.Sales

UNION ALL

SELECT 'Cancellations',
       COUNT(*)
FROM core.Cancellations;