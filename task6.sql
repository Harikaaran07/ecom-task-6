-- =====================================================
-- Week 6: Product Review and Rating Management System (MySQL 8.0.16+)
-- =====================================================
 
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;
 
-- =====================================================
-- 1. TABLE CREATION
-- =====================================================
 
-- Existing modules (stubs: replace with your own Customer and Product tables)
CREATE TABLE IF NOT EXISTS Customer (
    Customer_ID   INT PRIMARY KEY,
    Customer_Name VARCHAR(50) NOT NULL,
    Email         VARCHAR(80)
);
 
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Product;
 
CREATE TABLE Product (
    Product_ID   INT PRIMARY KEY,
    Product_Name VARCHAR(50)   NOT NULL,
    Price        DECIMAL(10,2) NOT NULL
);
 
-- New module: Review
CREATE TABLE Review (
    Review_ID   VARCHAR(10) PRIMARY KEY,
    Customer_ID INT         NOT NULL,
    Product_ID  INT         NOT NULL,
    Rating      TINYINT     NOT NULL,
    Review_Text VARCHAR(500),
    Review_Date DATE        NOT NULL,
    CONSTRAINT fk_review_customer FOREIGN KEY (Customer_ID)
        REFERENCES Customer(Customer_ID),
    CONSTRAINT fk_review_product  FOREIGN KEY (Product_ID)
        REFERENCES Product(Product_ID),
    CONSTRAINT chk_rating CHECK (Rating BETWEEN 1 AND 5)
);
 
-- =====================================================
-- 2. SAMPLE DATA
-- =====================================================
 
-- IGNORE keeps any customers already created in earlier weeks
INSERT IGNORE INTO Customer VALUES
(1,'Arun Kumar','arun@mail.com'),
(2,'Priya Nair','priya@mail.com'),
(3,'Rahul Sharma','rahul@mail.com'),
(4,'Meena Iyer','meena@mail.com'),
(5,'Karthik Raj','karthik@mail.com'),
(6,'John Mathew','john@mail.com');
 
INSERT INTO Product VALUES
(101,'Laptop',55000.00),
(102,'Mobile',22000.00),
(103,'Headphones',2500.00),
(104,'Smart Watch',6000.00),
(105,'Keyboard',1200.00),
(106,'Tablet',18000.00);
 
-- =====================================================
-- 3. STORE CUSTOMER FEEDBACK AND RATINGS
-- =====================================================
 
-- 3.1 / 3.2 Add reviews with ratings 1 to 5
INSERT INTO Review VALUES
('R101',6,101,5,'Excellent performance',        '2026-11-01'),
('R102',2,102,4,'Good battery life',            '2026-11-02'),
('R103',1,101,5,'Fast and reliable',            '2026-11-03'),
('R104',3,101,4,'Good value for money',         '2026-11-04'),
('R105',4,102,5,'Great camera quality',         '2026-11-05'),
('R106',5,102,3,'Average performance',          '2026-11-05'),
('R107',1,103,2,'Poor sound quality',           '2026-11-06'),
('R108',2,103,3,'Okay for the price',           '2026-11-07'),
('R109',3,104,4,'Nice display',                 '2026-11-08'),
('R110',6,104,5,'Accurate tracking',            '2026-11-08'),
('R111',4,105,1,'Keys stopped working',         '2026-11-09'),
('R112',5,105,2,'Not durable',                  '2026-11-10'),
('R113',2,101,4,'Good display',                 '2026-11-10'),
('R114',6,102,4,'Smooth performance',           '2026-11-11');
 
SELECT * FROM Review;
 
-- 3.3 Update review comments if required
UPDATE Review
SET Review_Text = 'Average performance, battery could be better'
WHERE Review_ID = 'R106';
 
-- 3.4 Remove inappropriate or invalid reviews
INSERT INTO Review VALUES
('R115',5,106,1,'Buy cheap watches at my website','2026-11-12');
 
DELETE FROM Review WHERE Review_ID = 'R115';
 
-- Constraint tests (run one at a time; each should be REJECTED)
-- INSERT INTO Review VALUES ('R116',1,101,6,'Too high','2026-11-12');          -- CHECK rating 1 to 5
-- INSERT INTO Review VALUES ('R117',1,101,0,'Too low','2026-11-12');           -- CHECK rating 1 to 5
-- INSERT INTO Review VALUES ('R118',1,101,NULL,'No rating','2026-11-12');      -- NOT NULL rating
-- INSERT INTO Review VALUES ('R119',1,101,4,'No date',NULL);                   -- NOT NULL date
-- INSERT INTO Review VALUES ('R120',99,101,4,'Unknown customer','2026-11-12'); -- FK Customer_ID
-- INSERT INTO Review VALUES ('R121',1,999,4,'Unknown product','2026-11-12');   -- FK Product_ID
 
-- =====================================================
-- 4. RETRIEVE PRODUCT REVIEW DETAILS
-- =====================================================
 
-- 4.1 Display all reviews for a product (Laptop)
SELECT p.Product_Name, r.Review_ID, r.Rating, r.Review_Text, r.Review_Date
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
WHERE p.Product_ID = 101;
 
-- 4.2 Display customer name with their reviews
SELECT c.Customer_Name, p.Product_Name, r.Rating, r.Review_Text
FROM Review r
JOIN Customer c ON r.Customer_ID = c.Customer_ID
JOIN Product  p ON r.Product_ID  = p.Product_ID
ORDER BY c.Customer_Name;
 
-- 4.3 Find products having maximum reviews (includes ties)
SELECT p.Product_Name, COUNT(r.Review_ID) AS Total_Reviews
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING COUNT(r.Review_ID) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM Review GROUP BY Product_ID
    ) t
);
 
-- 4.4 Display recent customer feedback (latest 5)
SELECT c.Customer_Name, p.Product_Name, r.Rating, r.Review_Text, r.Review_Date
FROM Review r
JOIN Customer c ON r.Customer_ID = c.Customer_ID
JOIN Product  p ON r.Product_ID  = p.Product_ID
ORDER BY r.Review_Date DESC, r.Review_ID DESC
LIMIT 5;
 
-- 4.5 Retrieve reviews with ratings above 4
SELECT p.Product_Name, r.Rating, r.Review_Text
FROM Review r
JOIN Product p ON r.Product_ID = p.Product_ID
WHERE r.Rating > 4;
 
-- =====================================================
-- 5. CALCULATE AVERAGE PRODUCT RATINGS
-- =====================================================
 
-- 5.1 Average rating for each product
SELECT p.Product_Name, ROUND(AVG(r.Rating),2) AS Avg_Rating
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name;
 
-- 5.2 Number of reviews per product
SELECT p.Product_Name, COUNT(r.Review_ID) AS Total_Reviews
FROM Product p
LEFT JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name;
 
-- 5.3 Highest-rated products (includes ties)
SELECT p.Product_Name, ROUND(AVG(r.Rating),2) AS Avg_Rating
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) = (
    SELECT MAX(a) FROM (
        SELECT AVG(Rating) AS a FROM Review GROUP BY Product_ID
    ) t
);
 
-- 5.4 Products with average rating above 4
SELECT p.Product_Name, ROUND(AVG(r.Rating),2) AS Avg_Rating
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) > 4;
 
-- =====================================================
-- 6. PRODUCT RATING REPORTS
-- =====================================================
 
-- ---------- Report 1: Product Rating Analysis ----------
-- LEFT JOIN keeps products that have no reviews yet
SELECT p.Product_Name,
       COUNT(r.Review_ID)        AS Number_of_Reviews,
       ROUND(AVG(r.Rating),2)    AS Average_Rating
FROM Product p
LEFT JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
ORDER BY Average_Rating DESC;
 
-- ---------- Report 2: Customer Feedback Analysis ----------
 
-- Most reviewed products (includes ties)
SELECT p.Product_Name, COUNT(r.Review_ID) AS Total_Reviews
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING COUNT(r.Review_ID) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(*) AS cnt FROM Review GROUP BY Product_ID
    ) t
);
 
-- Highly rated products (average 4 or above)
SELECT p.Product_Name, ROUND(AVG(r.Rating),2) AS Avg_Rating
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) >= 4
ORDER BY Avg_Rating DESC;
 
-- Products requiring improvement (average below 3)
SELECT p.Product_Name, ROUND(AVG(r.Rating),2) AS Avg_Rating
FROM Product p
JOIN Review r ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING AVG(r.Rating) < 3
ORDER BY Avg_Rating;
 
-- ---------- Report 3: Rating Distribution ----------
 
-- Number of reviews for each star rating
SELECT Rating, COUNT(*) AS Total_Reviews
FROM Review
GROUP BY Rating
ORDER BY Rating DESC;
 
-- Number of 5-star ratings
SELECT COUNT(*) AS Five_Star_Ratings FROM Review WHERE Rating = 5;
 
-- Number of 4-star ratings
SELECT COUNT(*) AS Four_Star_Ratings FROM Review WHERE Rating = 4;
 
-- Number of low-rated products (average below 3)
SELECT COUNT(*) AS Low_Rated_Products
FROM (
    SELECT Product_ID
    FROM Review
    GROUP BY Product_ID
    HAVING AVG(Rating) < 3
) t;
 
-- Number of low ratings (1 or 2 stars)
SELECT COUNT(*) AS Low_Star_Ratings FROM Review WHERE Rating <= 2;
 