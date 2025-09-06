SELECT * FROM sales_store

SELECT * INTO sales FROM sales_store

SELECT * FROM sales

--Data Cleaning

--Step 1:- To check for duplicate

SELECT 
transaction_id,
COUNT(*) 
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) >1

TXN240646
TXN342128
TXN855235
TXN981773

WITH CTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
--DELETE FROM CTE
--WHERE Row_Num = 2

SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646', 'TXN342128', 'TXN855235', 'TXN981773')


--Step 2 :- Correction of Headers
EXEC sp_rename'sales.quantiy','quantity','COLUMN'

EXEC sp_rename'sales.prce','price','COLUMN'

--Step 3 :- To check Datatype
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME ='SALES'

--To check NULL VALUE
SELECT *
FROM sales
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR 
customer_name IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR product_name IS NULL
OR product_category IS NULL
OR quantity IS NULL
OR price IS NULL
OR payment_mode IS NULL
OR purchase_date IS NULL
OR time_of_purchase IS NULL
OR status IS NULL


DELETE FROM sales
WHERE transaction_id IS NULL

SELECT * FROM sales
WHERE customer_name = 'Ehsaan Ram'
 
UPDATE sales
SET customer_id = 'CUST9494'
WHERE customer_name = 'Ehsaan Ram'

SELECT * FROM sales
WHERE customer_name = 'Damini Raju'

UPDATE sales
SET customer_id = 'CUST1401'
WHERE customer_name = 'Damini Raju'

SELECT * FROM sales
WHERE customer_id = 'CUST1003'

UPDATE sales
SET customer_name = 'Mahika Saini',
	customer_age = '35',
	gender = 'Male'
WHERE customer_id = 'CUST1003'


SELECT * FROM sales

--Step 5 :- Data cleaning

SELECT DISTINCT gender 
FROM sales

UPDATE sales
SET gender = 'M'
WHERE gender = 'Male'

UPDATE sales
SET gender = 'F'
WHERE gender = 'Female'

SELECT DISTINCT payment_mode
FROM sales

UPDATE sales
SET payment_mode= 'Credit Card'
WHERE  payment_mode= 'CC'

--Data Analysis

--Q1 What are the top 5 most selling products by quantity?

SELECT TOP 5
	product_name,
	SUM(quantity) AS totol_qunatity_sold
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY totol_qunatity_sold DESC

--Business Problem: We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.

----------------------------------------------------------------------------------------------------------------------

--Q2 Which products are most frequently cancelled?

SELECT * FROM sales

SELECT TOP 5 product_name,
COUNT(*) AS total_cancelled
FROM sales
WHERE status = 'cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--Business Problem: Frequent cancellations affect revenue and customer trust.

--Business Impact: Identify poor-performing products to improve or remove from catalog.

------------------------------------------------------------------------------------------------------------------


--Q3 What time of the day has the highest number of purchase?

SELECT * FROM sales

SELECT
	CASE
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END AS time_of_day,
	COUNT(*) AS total_orders
FROM sales
GROUP BY CASE
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
	END 
ORDER BY total_orders DESC

--Business Problem: Find peak sales.times.

--Businees Impact: Optimize staffing, promotions, and server loads.

------------------------------------------------------------------------------------------------------------------

--Q4 Who are the top 5 highest spending customers?

SELECT * FROM sales

SELECT TOP 5 customer_name,
FORMAT(SUM(CAST(price AS Float)*quantity), 'C0', 'en-IN' ) AS total_spending
FROM sales
WHERE status = 'delivered'
GROUP BY customer_name
ORDER BY total_spending DESC

--Business Problem: Identify VIP customers

--Business Impact: Personalized offers, loyalty rewards and offers

--------------------------------------------------------------------------------------------------------------------

--Q5 Which product categories generates the Highest revenue?

SELECT * FROM sales

SELECT product_category,
FORMAT(SUM(CAST(price AS FLOAT)*quantity), 'C0', 'en-IN') AS Highest_revenue
FROM sales
WHERE status = 'delivered'
GROUP BY product_category
ORDER BY SUM(CAST(price AS FLOAT)*quantity) DESC

--Business Problem: Identify top-performing product categories

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

--Q6 What is the return/cancellation rate per product category?

SELECT * FROM sales
--CANCELLATION
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*), 'N3')+' %' AS cancelled_percent
FROM sales
GROUP BY product_category
ORDER BY cancelled_percent DESC

--RETURN
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*), 'N3')+' %' AS return_percent
FROM sales
GROUP BY product_category
ORDER BY return_percent DESC

--Business Problem Solved: Monitor dissatisfaction trends per category.

--Business Impact: Reduce returns, improve product description/expectations.
--Helps identify and fix product or logistics issues.


--Q7 What is the most preferred payment mode?

SELECT * FROM sales

SELECT payment_mode,
COUNT(*) Preferred_mode
FROM sales
GROUP BY payment_mode
ORDER BY Preferred_mode DESC

--Business Problem Solved: Know which payment option customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.

--------------------------------------------------------------------------------------------------------------------

--Q8 How does age group affect purchasing behaviour?

SELECT * FROM sales

SELECT 
	CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(CAST(price AS FLOAT)*quantity), 'C0', 'en-IN') AS total_purchase
	FROM sales
	GROUP BY 	CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
	ORDER BY SUM(CAST(price AS FLOAT)*quantity) DESC

--Business Problem solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.

---------------------------------------------------------------------------------------------------------------------

--Q9 What's the monthly sales trend?

SELECT * FROM sales

SELECT 
	FORMAT(purchase_date, 'yyyy-MM') AS Month_Year,
	FORMAT(SUM(CAST(price AS FLOAT)*quantity), 'C0', 'en-IN') AS total_sales,
	SUM(quantity) AS total_quantiy
FROM sales
GROUP BY FORMAT(purchase_date, 'yyyy-MM')

--Busines Problem: Sales fluctuations go unnoticed.

--Business Impact: Plan inventory and marketing according to seasonal trends.

------------------------------------------------------------------------------------------------------------------------

--Q10 Are certain genders buying more specific product categories?

SELECT gender, product_category, COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender, product_category
ORDER BY gender

--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.

------------------------------------------------------------------------------------------------------------------------



		



	


