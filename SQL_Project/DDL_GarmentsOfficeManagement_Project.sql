--Drop with (If condition) Database GarmentsOfficeManagement System
Use Master
Go
IF DB_ID ('GarmentsOfficeManagement') IS NOT NULL
Drop Database GarmentsOfficeManagement
GO
----===========DATABASE CREATE===========
----CREATE DATABASE GarmentsOfficeManagement
----gO

----======================================
----Drop Database GarmentsOfficeManagement System
-------==================================
----Use Master 
----Drop Database GarmentsOfficeManagement
----GO
-------


----Create Database for Default Location==

DECLARE @data_path nvarchar(256);
SET @data_path = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1)
      FROM master.sys.master_files
      WHERE database_id = 1 AND file_id = 1);
EXECUTE ('CREATE DATABASE GarmentsOfficeManagement
ON PRIMARY
(NAME = GarmentsOfficeManagement_data, FILENAME = ''' + @data_path + 'GarmentsOfficeManagement_data.mdf'', SIZE = 16MB, MAXSIZE = Unlimited, FILEGROWTH = 2MB)
LOG ON 
(NAME = GarmentsOfficeManagement_log, FILENAME = ''' + @data_path + 'GarmentsOfficeManagement_log.ldf'', SIZE = 10MB, MAXSIZE = 500MB, FILEGROWTH = 1MB)'
);
Go



-------==================================
----Alter Database to Modify size and Name=====
-------==================================
Alter Database GarmentsOfficeManagement Modify File
(Name=N'GarmentsOfficeManagement_data', Size=50MB, MaxSize=1000, FileGrowth=5%)
GO
Alter Database GarmentsOfficeManagement Modify File
(Name=N'GarmentsOfficeManagement_log', Size=25MB, MaxSize=100MB, FileGrowth=2%)
GO


-------==================================
--Create Schema
-------==================================
Use GarmentsOfficeManagement
GO
CREATE SCHEMA GMS
GO
-------==================================
--Create Table: Product
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Product
(
	ProductID int Primary Key identity,
	ProductName varchar(30) Not Null,
	ProductSize varchar(5) Not Null,
	ProductCode nvarchar(10) Not Null,
	ProductQuantity varchar(10) Not Null,
	PoductPrice Money Not Null,
	ProductTotal as (ProductQuantity*PoductPrice)
)
GO

-------==================================
--Create Table: Category
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Category
(
	CategoryID int Primary Key identity,
	CategoryName varchar(30) Not Null,
	ProductID int Foreign Key References GMS.Product(ProductID)ON UPDATE CASCADE
)
GO

-------==================================
--Create Table: Stock
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Stock
(
	StocktID int Primary Key identity,
	StockName varchar(30) Not Null,
	Company varchar(30) Sparse,
	CompanyAddress nvarchar(10) Not Null,
	CompanyPhone char(15) Not Null Check((CompanyPhone like'[+][8][8][0][1][1-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9][0-9]')),
	DateInSystem Datetime Not Null Constraint Cn_CustomerDafaultDateInSystem Default (Getdate()) Check ((DateInSystem<=Getdate())),
	ProductID int Foreign Key References GMS.Product(ProductID),
	CategoryID int Foreign Key References GMS.Category(CategoryID) ON UPDATE CASCADE
)
GO


-------==================================
--Create Table: Suplier
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Supplier
(
	SupplierID INT PRIMARY KEY IDENTITY,
	SupplierName VARCHAR (50) NOT NULL,
	ContactPersonName VARCHAR (30) NOT NULL,
	Email VARCHAR(40) NULL,
	Contact VARCHAR (15) NOT NULL,
	City VARCHAR (20) NULL,
	[State] VARCHAR (20) NULL,
	Country VARCHAR (20) NULL,
	IsActive BIT DEFAULT 0,
	SupplierPhone char(15) Not Null CHECK (SupplierPhone LIKE '[+][8][8][0][1][1-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO

-------==================================
--Create Table: Purchase
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Purchase
(
	PurchaseID int Primary Key identity,
	PurchaseDate Date Default (Getdate()),
	PurchaseQuantity varchar(10) Not Null,
	PurchasePrice Money Not Null,
	PurchaseTotal as (PurchaseQuantity*PurchasePrice),
	ProductID int Foreign Key References GMS.Product (ProductID),
	SupplierID int Foreign Key References GMS.Supplier(SupplierID)ON DELETE CASCADE
)
GO




-------==================================
--Create Table: Customers
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Customers
(
	CustomerID INT PRIMARY KEY IDENTITY,
	CustomerName VARCHAR (50) NOT NULL,
	CustomersEmail VARCHAR(40) NULL,
	CustomersContact VARCHAR (15) NOT NULL,
	CustomersCity VARCHAR (20) NULL,
	CustomersIsActive BIT DEFAULT 0,
	CustomersMobile char(15) Not Null CHECK (CustomersMobile LIKE '[+][8][8][0][1][1-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9][0-9]'),
	ProductID int Foreign Key References GMS.Product (ProductID)
)
GO

-------==================================
--Create Table: Order
-------==================================
Use GarmentsOfficeManagement
CREATE TABLE GMS.[Order]
(
	OrderID INT IDENTITY PRIMARY KEY,
	OrderType VARCHAR (30) NOT NULL,
	[Date] DATE,
	Rate MONEY NOT NULL,
	Quantity INT NOT NULL,
	GrossAmount as (Rate*Quantity),
	Discount MONEY NULL,
	Vat MONEY NULL,
	NetAmount as (((Quantity*Rate)+(Quantity*Rate)*vat)),
	CustomerID int Foreign Key References GMS.Customers(CustomerID)
)
GO


-------==================================
--Create Table: OrderDtails
-------==================================
Use GarmentsOfficeManagement
CREATE TABLE OrderDetails
(
	OrderID INT,
	OrderType VARCHAR (30) NOT NULL,
	[Date] DATE,
	Rate MONEY NOT NULL,
	Quantity INT NOT NULL,
	GrossAmount as (Rate*Quantity),
	Discount MONEY NULL,
	Vat MONEY NULL,
	NetAmount as (((Quantity*Rate)+(Quantity*Rate)*vat)),
	OrderDetails varchar(20) Null,
	CustomerID int Foreign Key References GMS.Customers(CustomerID)
)
GO

-------==================================
--Create Table: Employee
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Employee
(
	EmployeeID INT PRIMARY KEY IDENTITY,
	EmployeeName VARCHAR (50) NOT NULL,
	Desingration VARCHAR (30) NOT NULL,
	Email VARCHAR(40) NULL,
	Contact VARCHAR (15) NOT NULL,
	IsActive BIT DEFAULT 0,
	EmployeePhone char(15) Not Null CHECK (EmployeePhone LIKE '[+][8][8][0][1][1-9][0-9][0-9][-][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CustomersID int Foreign Key References GMS.Customers (CustomerID)
)
GO


-------==================================
--Create Table: Office
-------==================================
Use GarmentsOfficeManagement
Create Table GMS.Office
(
	OfficeID int identity(1,1) Not Null,
	FormattedOfficeID as ('Forkan' + Left('Ctg' + Cast(OfficeID as varchar(10)),15)),
	OfficeName varchar(30),
	OfficeCode nvarchar(10),
	Constraint PK_Office Primary Key(OfficeID,OfficeCode),
	EmployeeID int Foreign Key References GMS.Employee (EmployeeID)
)
GO


-------==================================
--Create Table: Sales
-------==================================
Use GarmentsOfficeManagement
CREATE TABLE GMS.Sales
(
	SalesID INT IDENTITY PRIMARY KEY,
	SalesRate MONEY NOT NULL,
	SalesQuantity INT NOT NULL,
	Vat MONEY NULL,
	NetAmount as (((SalesQuantity*SalesRate)+(SalesQuantity*SalesRate)*vat)),
	EmployeeID int Foreign Key References GMS.Employee (EmployeeID)
)
GO
-------==================================
--Create Clustered And Non Clustered
-------==================================
Create Clustered Index Cl_Index On OrderDetails(OrderID)
GO

Create Index NCL_Index On OrderDetails(OrderType)
GO