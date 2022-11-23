--*************************************************************************--
-- Title: Assignment06
-- Author: AAllen
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,AAllen,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AAllen')
	 Begin 
	  Alter Database [Assignment06DB_AAllen] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AAllen;
	 End
	Create Database Assignment06DB_AAllen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AAllen;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
Create -- Drop
View vCategories
WITH SCHEMABINDING
As
 Select CategoryID, CategoryName From dbo.Categories; 
go

go
Create -- Drop
View vProducts
WITH SCHEMABINDING
As
 Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products; 
go

go
Create -- Drop
View vEmployees
WITH SCHEMABINDING
As
 Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees; 
go

go
Create -- Drop
View vInventories
WITH SCHEMABINDING
As
 Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories; 
go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

-- Start with Select statement from Assignment 05, Question #1

/*
Select 
	c.CategoryName
	, p.ProductName 
	, p.UnitPrice
From Categories as c
	Full Join Products As p
		On c.CategoryID= p.CategoryID
Order By CategoryName, ProductName
*/

-- Wrap with view, add "Top 10000000000" to use order by, use views

go
Create -- Drop
View vProductsByCategories
As
	Select TOP 10000000000
		c.CategoryName
		, p.ProductName 
		, p.UnitPrice
	From dbo.vCategories as c
		Full Join dbo.vProducts As p
			On c.CategoryID= p.CategoryID
	Order By CategoryName, ProductName
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

-- Use Select statement from Assignment 05, #2,  change order to match table above, use views
go
Create -- Drop
View vInventoriesByProductsByDates
As
	Select TOP 10000000000
		p.ProductName 
		, i.InventoryDate
		, SUM(Count) As Count
	From dbo.vProducts as p
		Left Join dbo.vInventories as i 
			On p.ProductID=i.ProductID
	Group By ProductName, InventoryDate
	Order By ProductName, InventoryDate, Count
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Start with Select statement from Assignment 05, #3
/*
Select Distinct
	i.InventoryDate 
	,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) as EmployeeName
From Inventories As i
	Inner Join Employees As e
		On i.EmployeeID = e.EmployeeID
Order By InventoryDate, EmployeeName
*/

-- Wrap Select statement with view, use views
go
Create -- Drop
View vInventoriesByEmployeesByDates
As
	Select Distinct TOP 10000000000
		i.InventoryDate 
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) as EmployeeName
	From dbo.vInventories As i
		Inner Join dbo.vEmployees As e
			On i.EmployeeID = e.EmployeeID
	Order By InventoryDate, EmployeeName
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

-- Wrap Select statment from Assignment 05, Question #4 with a Create View, use views
go
Create -- Drop
View vInventoriesByProductsByCategories
As
	Select TOP 10000000000
		c.CategoryName
		, p.ProductName 
		, i.InventoryDate 
		, i.Count
	From dbo.vProducts As p
		Left Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Left Join dbo.vInventories as i
			On i.ProductID = p.ProductID
	Order By CategoryName, ProductName, InventoryDate, Count
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Create a View to wrap Select statement from Assignment 05, Question #5, use views
go
Create -- Drop
View vInventoriesByProductsByEmployees
As
	Select TOP 10000000000
			c.CategoryName
			, p.ProductName
			, i.InventoryDate
			, i.Count
			, EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
	From dbo.vProducts As p
		Inner Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Inner Join dbo.vInventories as i
			On i.ProductID = p.ProductID
		Inner Join dbo.vEmployees as e
			On i.EmployeeID = e.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, Count, EmployeeName
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

-- Create a View to wrap Select statement from Assignment 05, Question #6, use views

go
Create -- Drop
View vInventoriesForChaiAndChangByEmployees
As
	Select TOP 10000000000
			 c.CategoryName
			, p.ProductName
			, i.InventoryDate
			, i.Count
			, EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
	From dbo.vProducts As p
		Inner Join dbo.vCategories as c
			On c.CategoryID = p.CategoryID
		Inner Join dbo.vInventories as i
			On i.ProductID = p.ProductID
		Inner Join dbo.vEmployees as e
			On i.EmployeeID = e.EmployeeID
	Where p.ProductID IN (Select ProductID From Products Where ProductName IN ('Chai','Chang'))
	Order By InventoryDate, CategoryName, ProductName, Count, EmployeeName
go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

-- Create a View to wrap Select statement from Assignment 05, Question #7, use views

go
Create -- Drop
View vEmployeesByManager
As
	Select TOP 10000000000
				mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName As Manager
				, emp.EmployeeFirstName + ' ' + emp.EmployeeLastName As Employee
	From dbo.vEmployees as emp
		Join dbo.vEmployees as mgr
			On emp.ManagerID =  mgr.EmployeeID
	Order By Manager, Employee
go


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

/*
-- Create a view with all data from each table
go
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
As
	Select TOP 10000000000
				c.CategoryID
				, c.CategoryName
				, p.ProductID
				, p.ProductName
				, UnitPrice
				, InventoryID
				, InventoryDate
				, Count
				, e.EmployeeID
				, e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee
	From dbo.vProducts As p
			Inner Join dbo.vCategories as c
				On c.CategoryID = p.CategoryID
			Inner Join dbo.vInventories as i
				On i.ProductID = p.ProductID
			Inner Join dbo.vEmployees as e
				On i.EmployeeID = e.EmployeeID
go


-- Order by CategoryID, ProductID, InventoryID, EmployeeID
go
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
As
	Select TOP 10000000000
				c.CategoryID
				, c.CategoryName
				, p.ProductID
				, p.ProductName
				, UnitPrice
				, InventoryID
				, InventoryDate
				, Count
				, e.EmployeeID
				, e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee
	From dbo.vProducts As p
			Inner Join dbo.vCategories as c
				On c.CategoryID = p.CategoryID
			Inner Join dbo.vInventories as i
				On i.ProductID = p.ProductID
			Inner Join dbo.vEmployees as e
				On i.EmployeeID = e.EmployeeID
Order by CategoryID, ProductID, InventoryID, EmployeeID
go
*/

-- Add Employee Manager using Subquery for Manager Name
go
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
As
	Select TOP 10000000000
				c.CategoryID
				, c.CategoryName
				, p.ProductID
				, p.ProductName
				, UnitPrice
				, InventoryID
				, InventoryDate
				, Count
				, e.EmployeeID
				, e.EmployeeFirstName + ' ' + e.EmployeeLastName As Employee
				, (Select 
						mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName As Manager
					From dbo.Employees as mgr
					Where mgr.EmployeeID =  e.ManagerID) as Manager
	From dbo.vProducts As p
			Inner Join dbo.vCategories as c
				On c.CategoryID = p.CategoryID
			Inner Join dbo.vInventories as i
				On i.ProductID = p.ProductID
			Inner Join dbo.vEmployees as e
				On i.EmployeeID = e.EmployeeID
Order by CategoryID, ProductID, InventoryID, EmployeeID
go


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/