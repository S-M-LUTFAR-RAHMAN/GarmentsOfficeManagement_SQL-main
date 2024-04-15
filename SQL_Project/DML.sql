Use GarmentsOfficeManagement
Go
-------==================================
--Create Tabular and Scalar Function
-------==================================
--Create Tabular Function
Create Function fn_Tabular
(
@productsize varchar(20)
)
Returns Table
AS
Return
(
Select p.ProductID,ProductCode,ProductName,c.CategoryID,CategoryName
From GMS.Product as p
Join GMS.Category as c
On p.ProductID= c.ProductID
Where ProductSize = @productsize
)
GO


--OutPut
Select * from fn_Tabular('L')
GO

--Create Scalar Function
Create Function fn_Scalar
(
@ProductTotal decimal
)
Returns int
AS
Begin
	Return
	(
	Select sum(ProductTotal) as [Total amount]
	From GMS.Product as p
	)
End
GO

--OutPut
Print dbo.fn_Scalar()
GO
-------==================================
----Create View With Schemabinding
-------==================================
Create View vw_Pro_Stock
With Schemabinding
AS
Select p.PoductPrice, s.Company
From GMS.Product as p join GMS.Stock as s
On p.ProductID=s.ProductID;
Go

-------==================================
----Create View With Encryption
-------==================================
Create View vw_Pro_Stock_E
With Encryption
AS
Select p.PoductPrice, s.Company
From GMS.Product as p join GMS.Stock as s
On p.ProductID=s.ProductID;
Go

-------==================================
----Create View With Check Option 
-------==================================
Create View vw_Product
As
Select ProductID, ProductName, ProductCode, ProductQuantity, ProductSize
From GMS.Product
Where ProductName Like 'Pol%'
Or ProductName Like 'T-___rt%'
With Check Option;
GO


Select * From vw_Product
-------==================================
---------------Merge
-------==================================
--MERGE GMS.Product As T Using GMS.Stock As S
---On T.productid=S.productid
---When MATCHED Then UPDATE SET T.ProductName=s.Company
---WHEN NOT MATCHED THEN INSERT (ProductName,ProductName) VALUES (S.Company,S.Company) ;
Go

-------==================================
--Update, Alter and Drop Table
-------==================================
--Update vw_CustomersCheck
Update vw_Product
Set ProductName='T-Shirt'
Where ProductCode=2;
GO

-------==================================
--------- Alter Drop Table
------- Alter Column(Column, Column name, data type )
-------==================================
Alter Table Office
Add Address varchar(20)
GO
Alter Table Office
Alter Column Salary Decimal
Go
Alter Table Office
Drop Column Address
GO



-------==================================
---------Truncate Table
-------==================================
---Truncate Table OrderTrigger
---Truncate Table GMS.Customer   ------Don't Truncate beacuse its a references Table
--Go
---===========[Create Procidure Table for Insert]
create proc Ps_insert_Inpo
(
@employeeid smallint,
@employeename nvarchar (11) ,
@desingration nvarchar (11),
@email nvarchar (25)
)
as 
begin 
insert into GMS.Employee (employeeid,employeename,desingration,email)
						values(@employeeid,@employeename, @desingration,@email )
end

Go
exec Ps_insert_Inpo 'kjk',12,'125'
exec Ps_insert_Inpo 'kjhuk',12,'1125' 
Go

select *from GMS.Employee
go
---=============[Create Procidure Table for Update

create proc Sp_Update2
(
@employeeid smallint,
@employeename nvarchar (11) ,
@desingration nvarchar (11),
@email nvarchar (25)
)
as
begin
update GMS.Employee
set employeename=@employeename, desingration=@desingration,email=@email
where EmployeeID=@employeeid

end
Go
exec Sp_Update2 1 ,'ghg','ggf','yyt'

select *from GMS.Employee
go
----========[Create Procidure Table for Delete

create proc Sp_Delete
(
@employeeid smallint

)
as

  Delete GMS.Employee
   Where EmployeeID=@employeeid
Go

Exec Sp_Delete 1
-------==================================
-- Create Procedures and Alter
-------==================================
Create Proc sp_Employee_Sales
	@employeeid INT,
	@employeename VARCHAR (50),
	@desingration VARCHAR (30),
	@email VARCHAR(40),
	@contact VARCHAR (15),
	@isactive BIT,
	@employeephone char(15),
	@customersid int,
	@salesid INT,
	@salesrate MONEY,
	@salesquantity INT,
	@vat MONEY,
	@tablename varchar(20),
	@operationname varchar(25)
As
Begin
	If(@tablename= 'GMS.Employee' and @operationname= 'Insert')
	Begin
		Insert GMS.Employee values (@employeename, @desingration,@email,@contact,@isactive,@employeephone,@customersid)
	End
	If(@tablename= 'GMS.Employee' and @operationname= 'Update')
	Begin
		Update GMS.Employee Set EmployeeName=@employeename Where EmployeeID=@employeeid
	End
	If(@tablename= 'GMS.Employee' and @operationname= 'Delete')
	Begin
		Delete From GMS.Employee Where EmployeeID=@employeeid
	End

	If(@tablename= 'GMS.Sales' and @operationname= 'Insert')
	Begin
		Insert GMS.Sales values (@salesrate,@salesquantity,@vat)
	End
	If(@tablename= 'GMS.Sales' and @operationname= 'Update')
	Begin
		Update GMS.Sales Set SalesRate=@salesrate Where SalesID=@salesid
	End
	If(@tablename= 'GMS.Sales' and @operationname= 'Delete')
	Begin
		Delete From GMS.Sales Where SalesID=@salesid
	End
End
GO


Exec sp_Employee_Sales 1,'Tusar','Manager','tusar@gmail.com','Chittagong',1,'+8801813-148110',2,'store.Product','Insert'
GO


-------==================================
-- Create Procedures For Office: Try, Begin Tran, Commit, Catch, Rollback Tran, Print
-------==================================
Create proc sp_Office
@officeid int ,
@formattedofficeid varchar(30),
@officename varchar(30),
@officecode nvarchar(10),
@employeeid int,
@message varchar(30) output	 -- For Message Passing
as
	Begin
		Begin Try
			Begin Tran
				Insert GMS.Office(OfficeID,FormattedOfficeID,OfficeName,OfficeCode,EmployeeID)
				Values(@officeid,@formattedofficeid,@officename,@officecode,@employeeid)
				Set @message='Data Inserted Completed'
				Print @message
			Commit Tran
		End Try
		Begin Catch
			Rollback Tran
			Print 'Something Was Wrong!!!'
		End Catch
	End
GO
--Insereted
Declare @ar varchar(30)
exec sp_Office 1,'07','Arefin','101',1,@ar output
GO


-------==================================
--Create Trigger for Insert Table: store.Order
-------==================================
Create Trigger Tr_Order ON GMS.[Order]
For Insert
As
Declare @orderid int, @ordertype varchar(30), @date date, @rate money, @quantity int, @discound money, @orderdtails varchar(20), @customerid int
Select @orderid=i.OrderID From inserted i;
Select @ordertype=i.OrderType From inserted i; 
Select @date=i.[Date] From inserted i; 
Select @rate=i.Rate From inserted i;
Select @quantity=i.Quantity From inserted i; 
Select @discound=i.Discount From inserted i; 
Select @customerid=i.CustomerID From inserted i;
Set @orderdtails='Inserted Record_After Insert Trigger'
Insert into OrderDetails(OrderID,OrderType,[Date],Rate,Quantity,Discount,OrderDetails,CustomerID)
Values (@orderid,@ordertype,@date,@rate,@quantity,@discound,@orderdtails,@customerid);
Print 'After insert Trigger Fired'
GO


-------==================================
--Create Trigger for Insted Update and Delete Table: store.Order
-------==================================
Create Trigger trg_UpdateDelete on GMS.Product
Instead of Update, Delete
AS
Declare @rowcount int
Set @rowcount=@@ROWCOUNT
IF(@rowcount>1)
				BEGIN
				Raiserror('You cannot Update or Delete more than 1 Record',16,1)
				END
Else 
	Print 'Update or Delete Successful'
GO


Use GarmentsOfficeManagement
GO
-------==================================
--Value Insert Table: GMS.Product
-------==================================
Insert Into GMS.Product (ProductName,ProductSize,ProductCode,ProductQuantity,PoductPrice)
Values ('T-Shirt','M',11,50,10),
		('Polo Shirt','L',11,60,10),
		('Max Shirt','L',15,70,10),
		('Data Shirt','M',15,90,10),
		('Jeans Pants','M',15,50,10),
		('T-Shirt','S',10,50,10);
Go

-------==================================
--Value Insert Table: GMS.Category
-------==================================
Insert Into GMS.Category (CategoryName,ProductID)
Values ('Shirt',1),('Shirt',2),('Shirt',2),('Shirt',1),
('Jeans',6),('Jeans',6),('Shirt',5);
GO

-------==================================
--Value Insert Table: GMS.Stock
-------==================================
Insert Into GMS.Stock (StockName,Company,CompanyAddress,CompanyPhone,DateInSystem,ProductID)
						Values ('Shirt','Clipton Group','Chittagong','+8801813-148110','10/16/2018', 2),
								('Shirt','Clipton Group','Chittagong','+8801813-148110',Getdate(), 2),
								('Shirt','Clipton Group','Chittagong','+8801813-148110',Getdate(), 2),
								('Jeans','Youngone','Dhaka','+8801813-148110',Getdate(), 5),
								('Jeans','Youngone','Dhaka','+8801813-148110',Getdate(), 4),
								('Jeans','Youngone','Dhaka','+8801813-148110',Getdate(), 2),
								('Shirt','Mam Gropu','Chittagong','+8801813-148110',Getdate(), 4),
								('Shirt','Shamim Group','Rangpur','+8801813-148110',Getdate(), 4);
Go

-------==================================
--Value Insert Table: GMS.Supplier
-------==================================
Insert Into GMS.Supplier (SupplierName,ContactPersonName,Email,Contact,City,[State],Country,IsActive,SupplierPhone)
						Values ('Md. Rahim','Mr. Karim','rahim@gmail.com','Dhaka','Dhaka','Dhaka','Bangladesh',1, '+8801813-148110'),
						 ('Md. Salam','Mr. Sharif','rahim@gmail.com','Dhaka','Dhaka','Dhaka','Bangladesh', 1,'+8801813-148110'),
						 ('Md. Faruk','Mr. Hamid','rahim@gmail.com','Chittagong','Dhaka','Dhaka','Bangladesh',1, '+8801813-148110'),
						 ('Md. Amjad','Mr. Younus','rahim@gmail.com','Sham','Velgiam','Velgiam','Chin', 1,'+8801813-148110'),
						 ('Md. Foysal','Mr. Wahid','rahim@gmail.com','Gain','Hamida','Hamida','Turky', 0,'+8801813-148110'),
						 ('Md. Jahid','Mr. Ashraf','rahim@gmail.com','Dhaka','Dhaka','Dhaka','Bangladesh',1, '+8801813-148110'),
						 ('Md. Rahim','Mr. Moin','rahim@gmail.com','Dhaka','Dhaka','Dhaka','Bangladesh',1, '+8801813-148110'),
						 ('Md. Rahim','Mr. Arefin','rahim@gmail.com','Vargin','Rohingga','Rohingga','Mayenmar',1, '+8801813-148110');
Go

-------==================================
--Value Insert Table: store.Purchase
-------==================================
Insert Into GMS.Purchase values('10/16/2019',10,15,1,1), ('10/16/2019',10,15,1,2), ('10/16/2019',10,15,2,1), ('10/16/2019',10,15,3,2), ('10/16/2019',10,15,3,3), ('10/16/2019',10,15,3,4), ('10/16/2019',10,15,4,5), ('10/16/2019',10,15,6,6);
GO

-------==================================
--Value Insert Table: GMS.Customers
-------==================================
Insert Into GMS.Customers (CustomerName,CustomersEmail,CustomersContact,CustomersCity,CustomersIsActive,CustomersMobile,ProductID)
Values ('Arif','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',1),
('Rifat','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',2),
('Halim','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',3),
('Sultan','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',4),
('Shahin','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',5),
('Mustak','mmm@gmail.com','Dhaka','Dhaka',0,'+8801813-148110',6),
('Moin','mmm@gmail.com','Dhaka','Dhaka',1,'+8801813-148110',2);
GO
-------==================================
--Insert Trigger for Table: GMS.Order
-------==================================
Insert into GMS.[Order](OrderType,[Date],Rate,Quantity,Discount) values('Garments','',20,25,5),
															('Garments','',20,250,5),
															('Garments','',200,25,5);
GO
-------==================================
---------------Update
-------==================================
Update GMS.[Order]
Set OrderType='Wahis'
Where OrderID=3
GO

-------==================================
--------------Delate
-------==================================
Delete GMS.[Order]
Where OrderID=2
GO


-------==================================
--Transaction (Commit,Rollback,Save Point)
-------==================================

Begin tran 
Save Tran SP10
insert into GMS.[Order] Values  ( 2,'Chittagong')
Go 

Begin Tran
Save Tran SP11
Update GMS.[Order]
set OrderType='Wahis' Where OrderID=2
Go

Begin Tran
Delete From GMS.[Order]
Where OrderID=2
Go

Commit Tran
Go

RollBack Tran ;
Go

Begin Tran
Save Tran SP11
Delete From GMS.[Order]
Where OrderID=2
Rollback Tran SP11

Go
-------==================================
--============Create Sequence============
-------==================================
Use GarmentsOfficeManagement
Create Sequence sq_Sequence
	As Bigint
	Start With 1
	Increment By 1
	Minvalue 1
	Maxvalue 99999
	No Cycle
	Cache 10;
	GO

Select Next value for sq_Sequence
GO
-------==================================
-------------Table Variable
-------==================================
Declare @employee table
(
EmpId int,
EmployeeName varchar(20),
Designation varchar(10),
Salary decimal(8,2)
)
Insert into @employee values (1,'Anwar','Manager',50000)
Select * from @employee
go
-------==================================
----=====Temporary Table(Local and Global)
-------==================================
CREATE TABLE #tmp_HRM
(
ID int identity ,
Address Varchar(30) CONSTRAINT CN_Defaultaddress DEFAULT ('UNKNOWN'),
Phone Char(15) Not Null  CHECK ((Phone Like '[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]' )),
DateInSystem DATE Not Null CONSTRAINT CN_dateinsystem DEFAULT (GETDATE())
)
GO

CREATE TABLE ##tmp_Resource
(
ID int identity ,
Address Varchar(30) CONSTRAINT CN_Dfltaddress DEFAULT ('UNKNOWN'),
Phone Char(15) Not Null  CHECK ((Phone Like '[0][1][1-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]' )),
DateInSystem DATE Not Null CONSTRAINT CN_dateinmethod DEFAULT (GETDATE())
)
GO

Drop Table #tmp_HRM
GO
Drop Table ##tmp_Resource
GO
-------==================================
-- With Loop, If, Else and While
-------==================================
Use GarmentsOfficeManagement
Declare @i int=0;
While @i <10
Begin
	If @i%2=0
		Begin
			Print @i
		End
	Else
		Begin
			Print Cast(@i as varchar) + 'Skip'
		End
	Set @i=@i+1-1*2/2
End
GO

-------==================================
-- With Loop, If, Else and While
-------==================================
Declare @i int=0;
While @i <10
Begin
	If @i%2=0
		Begin
			Print @i
		End
	Else
		Begin
			Print Cast(@i as varchar) + 'Skip'
		End
	Set @i=@i+1-1*2/2
End
GO

-------==================================
---------- DatedIF Function========
-------==================================
Declare @x money =12.49;
Select FLOOR(@x) As FloorRuselt, ROUND(@x,0) as RoundRuselt

Select DATEDIFF(yy,CAST('10/12/1990' as datetime), GETDATE ()) As Years,
	   DATEDIFF(MM,CAST('10/12/1990' as datetime), GETDATE ())%12 As Months,
	   DATEDIFF(DD,CAST('10/12/1990' as datetime), GETDATE ())%30 As Days
GO

Select Getdate() AS Moin_Sir
----=============Floor, Round, Ceiling========
-------======================================
Declare @value decimal(10,2)=11.05
Select ROUND(@value,1)
Select Ceiling(@value)
Select Floor(@value)
GO


-------==================================
--Between, All, Any, And, Or, Not
-------==================================
SELECT * FROM GMS.Stock
WHERE (StockName = 'Shirt' AND StocktID <> 20)
OR (StocktID = 100);
SELECT * FROM GMS.Stock
Where StockName NOT IN ('Jeans') 
SELECT * FROM GMS.Stock
WHERE StocktID BETWEEN 2 AND 4;
SELECT * FROM GMS.Product
WHERE ProductTotal > ANY (Select ProductTotal From GMS.Product Where ProductID>2);
SELECT * FROM GMS.Product
WHERE ProductTotal > ALL (Select ProductTotal From GMS.Product Where ProductID>2);

-------==================================
--Join: Inner, Outer(Left, Right), Full, Self, cross/
--Union, All Union, Intersection
-------==================================
--Inner Join
Select p.ProductID, ProductName, ProductCode, CategoryName, PurchaseID, PurchasePrice, PurchaseQuantity, StockName
From GMS.Product as p
Inner Join GMS.Category as c
ON p.ProductID=c.CategoryID
Join GMS.Purchase as u
ON u.ProductID=p.ProductID
join GMS.Stock as s
ON s.ProductID=p.ProductID

--Left Outer Join
Select p.ProductID, ProductName, ProductCode, CategoryName, PurchaseID, PurchasePrice, PurchaseQuantity, StockName
From GMS.Product as p
Left Join GMS.Category as c
ON p.ProductID=c.CategoryID
Join GMS.Purchase as u
ON u.ProductID=p.ProductID
join GMS.Stock as s
ON s.ProductID=p.ProductID

--Right outer Join
Select p.ProductID, ProductName, ProductCode, CategoryName, PurchaseID, PurchasePrice, PurchaseQuantity, StockName
From GMS.Product as p
Right Join GMS.Category as c
ON p.ProductID=c.CategoryID
Join GMS.Purchase as u
ON u.ProductID=p.ProductID
Left join GMS.Stock as s
ON s.ProductID=p.ProductID

--Full Join
Select p.ProductID, ProductName, ProductCode, CategoryName, PurchaseID, PurchasePrice, PurchaseQuantity, StockName
From GMS.Product as p
Inner Join GMS.Category as c
ON p.ProductID=c.CategoryID
Full Join GMS.Purchase as u
ON u.ProductID=p.ProductID
join GMS.Stock as s
ON s.ProductID=p.ProductID

--Cross Join
Select p.ProductID, ProductName, ProductCode, CategoryName
From GMS.Product as p
Cross Join GMS.Category as c

--Self Join
Select p.ProductID, c.ProductName, p.ProductCode
From GMS.Product as p, GMS.Product as c
Where p.ProductID <> c.ProductID


-- Union Operator 
Select ProductID From GMS.Product
Union 
Select CategoryID From GMS.Category
GO


-- Union All Operator 
Select ProductID From GMS.Product
Union 
Select CategoryID From GMS.Category
GO

--Intersection Operator
Select ProductID From GMS.Product
Interrsection
Select CategoryID From GMS.Category
GO


--=====================
--All Clauses: Select, From, Where, Group By, Having, OrderBY
--====================

--Order by
Select ProductSize,count(ProductID) as p
From GMS.Product
Where ProductSize='M'
Group By ProductSize
Having Count(ProductSize)<12
--Order BY ASC
GO



-------==================================
------------Select Queary
-------==================================
Select * From GMS.Product
Select * From GMS.Category
Select * From GMS.Stock
Select * From GMS.Supplier
Select * From GMS.Purchase
Select * From GMS.Customers
Select * From GMS.[Order]
Select * From OrderDetails
Select * From GMS.Employee
Select * From GMS.Office
Select * From GMS.Sales


--=====================================
--Cube, Rollup, Compute, Computeby, Grouping
--=====================================

Select 'A' [Class], 1 [Roll], 'a' [Section], 80 [Marks], 'Moin' [StuName]
into #tampTable
Union
Select 'A', 2, 'a', 70, 'Rasel'
Union
Select 'A', 3, 'a', 80, 'Arifin'
Union
Select 'A', 4, 'b', 90, 'Elias'
Union
Select 'A', 5, 'b', 90, 'Alamgir'
Union
Select 'A', 6, 'b', 50, 'Iqbal'
Union
Select 'B', 1, 'a', 60, 'You'
Union
Select 'B', 2, 'a', 50, 'Mizan'
Union
Select 'B', 3, 'a', 80, 'Sayed'
Union
Select 'B', 4, 'b', 90, 'Ashraf'
Union
Select 'B', 5, 'b', 50, 'Hasan'
Union
Select 'B', 6, 'b', 70, 'Mahbub'
GO


Select * From #tampTable
GO


--Rollup
Select Class, Section, Sum(Marks) As [Sum]
From #tampTable
Group By Class, Section With Rollup
GO

--Cube
Select Class, Section, Sum(Marks) AS [Total Sum]
From #tampTable
Group By Class, Section With Cube
GO

--Again RollUp
Select Class, Section, Roll, Sum(Marks) As [Sum]
From #tampTable
Group By Class, Section, Roll With Rollup
GO

--Grouping
Select Class, Section, Roll, Sum(Marks) As [Sum]
From #tampTable
Group By Grouping Sets (
		 (Class, Section, Roll)
		,(Class)
)
GO

-------==================================
--Select Queary and Subqueary, CLE expression name and Column list
-------==================================
Use GarmentsOfficeManagement
With Office_CTE(OfficeID,FormattedOfficeID,OfficeName,OfficeCode)
As
(
	Select OfficeID,FormattedOfficeID,OfficeName,OfficeCode
	From GMS.Office
	Where OfficeCode Is Not Null
)
Select * From Office_CTE

-------==================================
----- Sequence for Table
-------==================================
Use GarmentsOfficeManagement
Create Sequence sq_Contacts
	As Bigint
	Start With 1
	Increment By 1
	Minvalue 1
	Maxvalue 99999
	No Cycle
	Cache 10;
	GO

Select Next value for sq_Contacts;
GO

-------==================================
-------Case
-------==================================
Select ProductID, StockID,
	Case StockID
		When 1 then 'MS Dos'
		When 2 then 'Web Design'
		When 3 then 'Base'
		When 4 then 'Trade'
		When 5 then 'C#'
		
	End	as 'Not Allow'
From GMS.Stock
Go

-------==================================
--Cast, Convert, Concatenation
-------==================================
SELECT 'Today : ' + CAST(GETDATE() as varchar)
Go

SELECT 'Today : ' + CONVERT(varchar,GETDATE(),1)
Go
PRINT CAST(100 as decimal)
GO
PRINT CONVERT(datetime,'2016-June-01 10:00:00',103)
GO

--=====================================
--Operator
--=====================================
Select 10+2 as [Sum]
Go
Select 10-5 as [Substraction]
Go
Select 10*5 as [Multiplication]
Go
Select 10/3 as [Divide]
Go
Select 10%4 as [Remainder]
Go


--Distinct
Select Distinct ProductID,ProductName,ProductCode
From GMS.Product
Go

--Sub Query
Select * 
From GMS.Product
Where ProductCode in (Select ProductCode From GMS.Product Where ProductCode>20)
Go
