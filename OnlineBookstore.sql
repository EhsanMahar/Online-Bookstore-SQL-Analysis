-- =====================================================
-- Online Bookstore Project (MySQL Workbench version)
-- CSV folder: update the paths below to wherever you saved the /data files
-- (use forward slashes, e.g. 'C:/Users/you/Online-Bookstore-SQL-Analysis/data/Books.csv')
-- Requires local_infile enabled on both server and client (see README)
-- =====================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS OnlineBookstore;

-- Switch to the database
USE OnlineBookstore;

-- Drop tables (pehle Orders, kyunke wo baqi dono par depend karta hai)
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Books;

-- Create Tables
CREATE TABLE Books (
    Book_ID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(150),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price DECIMAL(10, 2),
    Stock INT
);

CREATE TABLE Customers (
    Customer_ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);

CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Customer_ID INT,
    Book_ID INT,
    Order_Date DATE,
    Quantity INT,
    Total_Amount DECIMAL(10, 2),
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
);

-- =====================================================
-- Import Data (LOAD DATA LOCAL INFILE chalne ke liye
-- local_infile enable hona zaroori hai, wo aap pehle kar chuke ho)
-- =====================================================

-- Import Data into Books Table
LOAD DATA LOCAL INFILE 'C:/path/to/Online-Bookstore-SQL-Analysis/data/Books.csv'
INTO TABLE Books
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Book_ID, Title, Author, Genre, Published_Year, Price, Stock);

-- Import Data into Customers Table (is file mein line ending \r\n hai)
LOAD DATA LOCAL INFILE 'C:/path/to/Online-Bookstore-SQL-Analysis/data/Customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(Customer_ID, Name, Email, Phone, City, Country);

-- Import Data into Orders Table
LOAD DATA LOCAL INFILE 'C:/path/to/Online-Bookstore-SQL-Analysis/data/Orders.csv'
INTO TABLE Orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- =====================================================
-- Basic Questions
-- =====================================================

-- 1) Retrieve all books in the "Fiction" genre:
SELECT * FROM Books
WHERE Genre = 'Fiction';

-- 2) Find books published after the year 1950:
SELECT * FROM Books
WHERE Published_Year > 1950;

-- 3) List all customers from the Canada:
SELECT * FROM Customers
WHERE Country = 'Canada';

-- 4) Show orders placed in November 2023:
SELECT * FROM Orders
WHERE Order_Date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
SELECT SUM(Stock) AS Total_Stock
FROM Books;

-- 6) Find the details of the most expensive book:
SELECT * FROM Books
ORDER BY Price DESC
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT o.Order_ID, c.Customer_ID, c.Name, o.Book_ID, o.Quantity
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Quantity > 1;

-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders
WHERE Total_Amount > 20;

-- 9) List all genres available in the Books table:
SELECT DISTINCT Genre
FROM Books;

-- 10) Find the book with the lowest stock:
-- (agar kai books ka stock barabar kam ho to sab dikhengi)
SELECT * FROM Books
WHERE Stock = (SELECT MIN(Stock) FROM Books);

-- 11) Calculate the total revenue generated from all orders:
SELECT SUM(Total_Amount) AS Total_Revenue
FROM Orders;


-- =====================================================
-- Advance Questions
-- =====================================================

-- 1) Retrieve the total number of books sold for each genre:
SELECT b.Genre, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Genre
ORDER BY Total_Books_Sold DESC;

-- 2) Find the average price of books in the "Fantasy" genre:
SELECT AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 3) List customers who have placed at least 2 orders:
SELECT c.Customer_ID, c.Name, COUNT(o.Order_ID) AS Orders_Count
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
HAVING COUNT(o.Order_ID) >= 2
ORDER BY Orders_Count DESC;

-- 4) Find the most frequently ordered book:
-- Note: 7 books are tied at 4 orders each, so ties are broken by total quantity sold.
SELECT o.Book_ID, b.Title, COUNT(o.Order_ID) AS Order_Count, SUM(o.Quantity) AS Total_Quantity
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY o.Book_ID, b.Title
ORDER BY Order_Count DESC, Total_Quantity DESC
LIMIT 1;

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre:
SELECT * FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC
LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:
SELECT b.Author, SUM(o.Quantity) AS Total_Books_Sold
FROM Orders o
JOIN Books b ON o.Book_ID = b.Book_ID
GROUP BY b.Author
ORDER BY Total_Books_Sold DESC;

-- 7) List the cities where customers who spent over $30 are located:
SELECT DISTINCT c.City
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
WHERE o.Total_Amount > 30;

-- 7 (alternate) Agar "total kharcha $30 se zyada" lena ho (customer ke saare orders ka jama):
-- SELECT DISTINCT c.City
-- FROM Customers c
-- JOIN Orders o ON o.Customer_ID = c.Customer_ID
-- GROUP BY c.Customer_ID, c.City
-- HAVING SUM(o.Total_Amount) > 30;

-- 8) Find the customer who spent the most on orders:
SELECT c.Customer_ID, c.Name, SUM(o.Total_Amount) AS Total_Spent
FROM Orders o
JOIN Customers c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Spent DESC
LIMIT 1;

-- 9) Calculate the stock remaining after fulfilling all orders:
SELECT b.Book_ID, b.Title, b.Stock,
       COALESCE(SUM(o.Quantity), 0) AS Order_Quantity,
       b.Stock - COALESCE(SUM(o.Quantity), 0) AS Remaining_Quantity
FROM Books b
LEFT JOIN Orders o ON b.Book_ID = o.Book_ID
GROUP BY b.Book_ID, b.Title, b.Stock
ORDER BY b.Book_ID;
