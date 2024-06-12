

--Showing the names of the customers whose count of purchase orders from October 1 - December 31 2013 is less than 30 and also having 
--the purchase order count from Janauary 1 to June 30 of 2014 greater than 25. 
--Ordered result set by customer name alphabetically.

select [CustomerName] 
from [Sales].[Customers] c
where exists 
    (select distinct [CustomerID]
    from [Sales].[Orders] o
    where [CustomerID] in 
    
        (select [CustomerID]
        from [Sales].[Orders] o2
        where o2.[OrderDate] between '2014-01-01' and '2014-06-30'
        group by [CustomerID]
        having count(o2.[OrderID]) > 25)

    and o.[CustomerID] = c.[CustomerID])  

and exists

    (select distinct [CustomerID]
    from [Sales].[Orders] o
    where [CustomerID] in
    
        (select [CustomerID]
        from [Sales].[Orders] o2
        where o2.[OrderDate] between '2013-10-01' and '2013-12-31' 
        group by [CustomerID]
        having count(o2.[OrderID]) < 30)
    
    and o.[CustomerID] = c.[CustomerID]) 
order by [CustomerName] ASC

--Returning a result set of customer names along with the BuyingGroupName with sales orders of stock items 'Chocolate frogs 250g' and 'Chocolate sharks 250g' purchased from February 1
--to March 31 of 2016.  Ordering the resultset alphabetically by customer name. 


select [CustomerName],[BuyingGroupName]
from [Sales].[Customers] c
left join [Sales].[BuyingGroups] bg on c.[BuyingGroupID] = bg.[BuyingGroupID]
where [CustomerID] in
    (select c.[CustomerID]
    from [Sales].[Orders] o
    inner join [Sales].[OrderLines] ol on o.[OrderID] = ol.[OrderID]
    inner join [Warehouse].[StockItems] si on ol.[StockItemID] = si.[StockItemID]
    where o.[OrderDate] between '2016-02-01' and '2016-03-31'
    and [StockItemName] ='Chocolate frogs 250g'
    and o.[CustomerID] = c.[CustomerID])
and [CustomerID] in
    (select c.[CustomerID]
    from [Sales].[Orders] o
    inner join [Sales].[OrderLines] ol on o.[OrderID] = ol.[OrderID]
    inner join [Warehouse].[StockItems] si on ol.[StockItemID] = si.[StockItemID]
    where o.[OrderDate] between '2016-02-01' and '2016-03-31'
    and [StockItemName] = 'Chocolate sharks 250g'
    and o.[CustomerID] = c.[CustomerID])
order by [CustomerName] ASC



--Find Entertainers who play Jazz but not Contemporary musical styles.

Select [EntStageName] ,  EntertainerID,
(case when [EntertainerID]  in                              
                 ( select entertainerid
from Entertainers
where entertainerid in
       ( select [EntertainerID]
        From [dbo].[Entertainer_Styles] as ES
        Inner join [dbo].[Musical_Styles] as MS on ES.StyleID=MS.StyleID
        Where [StyleName] = 'Jazz' )
and entertainerid not in
             (    select [EntertainerID]
        From [dbo].[Entertainer_Styles] as ES
        Inner join [dbo].[Musical_Styles] as MS on ES.StyleID=MS.StyleID
        Where [StyleName] = 'Contemporary' ))
 then 'Jazz but not Contemporary' else 'No' End)
From [dbo].[Entertainers]



--Listing the customers who have purchased a bike but not a helmet.

SELECT DISTINCT CustFirstName, CustLastName
FROM Customers c
WHERE NOT EXISTS (
    SELECT *
    FROM Products p
    INNER JOIN Order_Details od ON p.ProductNumber = od.ProductNumber
    INNER JOIN [dbo].[Categories] cat ON cat.CategoryID = p.CategoryID
    INNER JOIN [dbo].[Orders] o ON o.OrderNumber = od.OrderNumber
    WHERE c.CustomerID = o.CustomerID AND [ProductName] LIKE ('%helmet%')
)
AND EXISTS (
    SELECT *
    FROM Products p
    INNER JOIN Order_Details od ON p.ProductNumber = od.ProductNumber
    INNER JOIN [dbo].[Categories] cat ON cat.CategoryID = p.CategoryID
    INNER JOIN [dbo].[Orders] o ON o.OrderNumber = od.OrderNumber
    WHERE c.CustomerID = o.CustomerID AND [ProductName] LIKE ('%bike%')
)


--Showing the customer orders that have a bike but do not have a helmet.

SELECT *
FROM [dbo].[Orders] AS O
WHERE EXISTS ( SELECT *
FROM [dbo].[Order_Details] AS OD
INNER JOIN [dbo].[Products] AS P ON P.[ProductNumber]=OD.[ProductNumber]
WHERE OD.[OrderNumber] = O.[OrderNumber]
 AND  P.ProductName LIKE '%Bike')
AND NOT EXISTS (SELECT * 
FROM [dbo].[Order_Details] AS OD
INNER JOIN [dbo].[Products] AS P ON P.[ProductNumber]=OD.[ProductNumber]
WHERE OD.[OrderNumber] = O.[OrderNumber]
AND P.ProductName LIKE '%Helmet')