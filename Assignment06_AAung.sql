--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-08-07,AAung,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AAung')
	 Begin 
	  Alter Database [Assignment06DB_AAung] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AAung;
	 End
	Create Database Assignment06DB_AAung;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AAung;

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


-- View for the Cateogires
CREATE VIEW vCategoriess
	WITH SchemaBinding
	AS
		SELECT 
		CategoryID, 
		CategoryName
		FROM dbo.Categories;
GO

-- View for the Products
CREATE VIEW vProductss
	WITH SchemaBinding
	AS
		SELECT ProductID, 
		ProductName, 
		CategoryID, 
		UnitPrice
		FROM dbo.Products;
GO

-- View for the Employees
CREATE VIEW vEmployeess
	WITH SchemaBinding
	AS
		SELECT EmployeeID, 
		EmployeeFirstName, 
		EmployeeLastName, 
		ManagerID
		FROM dbo.Employees;
GO

-- View for the Inventories
CREATE VIEW vInventoriess
	WITH SchemaBinding
	AS
		SELECT InventoryID, 
		InventoryDate, 
		EmployeeID, 
		ProductID, 
		[COUNT]
		FROM dbo.Inventories;
GO



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON	Categories TO PUBLIC;
DENY SELECT ON	Products TO PUBLIC;
DENY SELECT ON	Employees TO PUBLIC;
DENY SELECT ON	Inventories TO PUBLIC;
GO

GRANT SELECT ON vCategoriess TO PUBLIC;
GRANT SELECT ON	vProductss TO PUBLIC;
GRANT SELECT ON	vEmployeess TO PUBLIC;
GRANT SELECT ON	vInventoriess TO PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategoriess
	AS 
		SELECT TOP 100 PERCENT
		c.CategoryName,
		p.ProductName,
		p.UnitPrice
		FROM vCategoriess AS c
			INNER JOIN vProductss AS p
			ON c.CategoryID = p.CategoryID
	ORDER BY 1, 2, 3;
GO 


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDatess
	AS 
		SELECT TOP 100 PERCENT
		p.ProductName,
		i.InventoryDate,
		i.[COUNT]
		FROM vProductss AS p
			INNER JOIN vInventoriess AS i
			ON p.ProductID = i.ProductID
	ORDER BY 2, 1, 3;
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDatess
	AS 
		SELECT TOP 100 PERCENT
		i.InventoryDate,
		e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
		FROM vInventoriess AS i
			INNER JOIN vEmployeess AS e
			ON i.EmployeeID = e.EmployeeID
	ORDER BY 1, 2;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategoriess
	AS
		SELECT TOP 100 PERCENT
		c.CategoryName,
		p.ProductName,
		i.InventoryDate,
		i.[COUNT]
		FROM vInventories AS i
			INNER JOIN vEmployeess AS e
			ON i.EmployeeID = e.EmployeeID
			INNER JOIN vProductss AS p
			ON i.ProductID = p.ProductID
			INNER JOIN vCategoriess AS c
			ON p.CategoryID = c.CategoryID
	ORDER BY 1, 2, 3, 4;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployeess
	AS 
		SELECT TOP 100 PERCENT
		c.CategoryName,
		p.ProductName,
		i.InventoryDate,
		i.[COUNT],
		e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
		FROM vInventories AS i
			INNER JOIN vEmployeess AS e
			ON i.EmployeeID = e.EmployeeID
			INNER JOIN vProductss AS p
			ON i.ProductID = p.ProductID
			INNER JOIN vCategoriess AS c
			ON p.CategoryID = c.CategoryID
	ORDER BY 3, 1, 2, 4;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployeess
	AS
		SELECT TOP 100 PERCENT
			c.CategoryName,
			p.ProductName,
			i.InventoryDate,
			i.[COUNT],
			e.EmployeeFirstName + ' ' + e.EmployeeLastName AS EmployeeName
			FROM vInventoriess AS i
				INNER JOIN vEmployeess AS e
				ON i.EmployeeID = e.EmployeeID
				INNER JOIN vProductss AS p
				ON i.ProductID = p.ProductID
				INNER JOIN vCategoriess AS c
				ON p.CategoryID = c.CategoryID
	WHERE i.ProductID in (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang'))
	ORDER BY 3, 1, 2, 4;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManagers
	AS
		SELECT TOP 100 PERCENT
		m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager,
		e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
		FROM vEmployeess AS e
				INNER JOIN vEmployeess AS m
				ON e.ManagerID = e.EmployeeID
	ORDER BY 1, 2;
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployeess
	AS
		SELECT TOP 100 PERCENT
		c.CategoryID,
		c.CategoryName,
		p.ProductID,
		p.ProductName,
		p.UnitPrice,
		i.InventoryID,
		i.InventoryDate,
		i.[COUNT],
		e.EmployeeID,
		e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee,
		m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
		FROM vCategoriess AS c
			INNER JOIN vProductss AS p
			ON p.CategoryID = c.CategoryID
			INNER JOIN vInventoriess AS i
			ON p.CategoryID = i.ProductID
			INNER JOIN vEmployeess AS e
			ON i.EmployeeID = e.EmployeeID
			INNER JOIN vEmployeess AS m
			ON e.ManagerID = m.EmployeeID
	ORDER BY 1, 3, 6, 9;
GO


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategoriess]
Select * From [dbo].[vInventoriesByProductsByDatess]
Select * From [dbo].[vInventoriesByEmployeesByDatess]
Select * From [dbo].[vInventoriesByProductsByCategoriess]
Select * From [dbo].[vInventoriesByProductsByEmployeess]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployeess]
Select * From [dbo].[vEmployeesByManagers]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployeess]

/***************************************************************************************/