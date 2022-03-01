USE magist;

# How many sellers are there?
SELECT COUNT(*)
FROM sellers;
-- 3095

# What’s the average monthly revenue of Magist’s sellers?
SELECT ROUND(AVG(a.avg_revenue))
FROM (
	SELECT rym.seller_id, AVG(rym.revenue_ym) AS avg_revenue
	FROM (
		SELECT YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id, SUM(price) AS revenue_ym  
		FROM order_items
		GROUP BY MONTH(shipping_limit_date), seller_id
		) rym
	GROUP BY 1
	ORDER BY 2 DESC
    ) a
;

# What’s the average revenue of sellers that sell tech products?

SELECT ROUND(AVG(a.avg_revenue)) AS average_tech_revenue_per_annum
FROM 
	(
	SELECT rym.seller_id, AVG(rym.revenue_ym) AS avg_revenue
	FROM (
		SELECT YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id, SUM(price) AS revenue_ym, product_category_name_english AS prod_cat
		FROM order_items
		LEFT JOIN products USING(product_id)
		LEFT JOIN product_category_name_translation USING(product_category_name)
		WHERE product_category_name_english in ( 
		"watches_gifts",
		"electronics",
		"computers_accessories",
		"computers",
		"telephony" )
		GROUP BY YEAR(shipping_limit_date), seller_id, prod_cat
		) rym
	GROUP BY 1
	ORDER BY 2 DESC
	) a
;







