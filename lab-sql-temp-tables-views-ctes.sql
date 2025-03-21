/*
Introduction
Welcome to the Temporary Tables, Views and CTEs lab!
In this lab, you will be working with the Sakila database on movie rentals. The goal of this lab is to help you practice and gain proficiency in using views, CTEs,
and temporary tables in SQL queries.
Temporary tables are physical tables stored in the database that can store intermediate results for a specific query or stored procedure. Views and CTEs, on the other hand, 
are virtual tables that do not store data on their own and are derived from one or more tables or views. 
They can be used to simplify complex queries. Views are also used to provide controlled access to data without granting direct access to the underlying tables.
Through this lab, you will practice how to create and manipulate temporary tables, views, and CTEs. By the end of the lab, 
you will have gained proficiency in using these concepts to simplify complex queries and analyze data effectively.

Challenge
Creating a Customer Summary Report
In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.
*/
USE sakila;
-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_summary AS
SELECT
     c.customer_id,
     c.first_name, c.last_name, 
     c.email,
     CoUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;
     

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE  temp_customer_payments AS
SELECT 
     crs.customer_id,
     crs.first_name,
     crs.last_name,
     crs.email,
     SUM(p.amount) AS total_paid
FROM customer_rental_summary crs
JOIN payment p ON crs.customer_id = p.customer_id
GROUP BY crs.customer_id, crs.first_name, crs.last_name, crs.email;

SELECT * FROM temp_customer_payments;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH customer_summary AS (
    SELECT 
        crs.first_name,
        crs.last_name,
        crs.email,                 
        crs.rental_count,          
        tcp.total_paid             
    FROM customer_rental_summary crs  
    LEFT JOIN temp_customer_payments tcp  
    ON crs.customer_id = tcp.customer_id  
)


-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
SELECT 
    first_name,   
    last_name,
    rental_count,                                   
    total_paid,                                     
    CASE                                            
        WHEN rental_count > 0 THEN total_paid / rental_count 
        ELSE 0                                       
    END AS average_payment_per_rental                
FROM customer_summary;  