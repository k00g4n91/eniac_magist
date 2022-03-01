USE magist;

SELECT * 
FROM information_schema.columns 
WHERE table_schema = 'magist';

# What categories of tech products does Magist have?
SELECT *
FROM product_category_name_translation;
-- electronics, computers, computers_accessories, watches_gifts, telephony

# How many products of these tech categories have been sold (within the time window of the database snapshot)?
SELECT product_category_name_english AS cat_eng, COUNT(*)
FROM product_category_name_translation AS cat
	LEFT JOIN products AS p 
		USING(product_category_name)
	LEFT JOIN order_items AS oi
		USING(product_id)
	LEFT JOIN orders AS o
		USING(order_id)
WHERE order_status = 'delivered' AND
product_category_name_english in ( 
"watches_gifts",
 "electronics",
 "computers_accessories",
 "computers",
 "telephony" )
GROUP BY cat_eng;
-- SOLD: computers=199, computers_accessories=7644, electronics=2729, watches_gifts=5859, telephony=4430

# What percentage does that represent from the overall number of products sold?
SELECT order_status, ROUND(((199+7644+2729+5859+4430)/COUNT(*)) *100, 1) AS percentage_tech
FROM orders
WHERE order_status = 'delivered';
-- roughly 21.6%

# average price of the products sold
SELECT ROUND(SUM(price)/COUNT(*)) AS average_price
FROM product_category_name_translation AS cat
	LEFT JOIN products AS p 
		USING(product_category_name)
	LEFT JOIN order_items AS oi
		USING(product_id)
	LEFT JOIN orders AS o
		USING(order_id)
WHERE order_status = 'delivered';

# Are expensive tech products popular? 
 
SELECT COUNT(*) AS tech_sold,
CASE
		WHEN price >= 2000 THEN '€2000+'
		WHEN price >= 1000 THEN '€1000+'
		WHEN price >= 500 THEN '€500+'
		WHEN price >= 250 THEN '€250+'
		WHEN price >= 100 THEN '€100+'
		ELSE 'less than €100'
	END AS price_cat
FROM (
		SELECT *
		FROM product_category_name_translation AS cat
			LEFT JOIN products AS p 
				USING(product_category_name)
			LEFT JOIN order_items AS oi
				USING(product_id)
			LEFT JOIN orders AS o
				USING(order_id)
		WHERE order_status = 'delivered' AND
		product_category_name_english in ( 
		"watches_gifts",
		 "electronics",
		 "computers_accessories",
		 "computers",
		 "telephony" )) jt
GROUP BY price_cat
ORDER BY tech_sold DESC;


SELECT ((13005+5862)/(199+7644+2729+5859+4430)*100);
-- 62% of tech customers spend less than €100
-- and 90% spend less than €250
-- NO, expensive tech products are not popular
