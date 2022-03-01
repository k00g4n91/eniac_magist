# What’s the average time between the order being placed and the product being delivered?
SELECT CONCAT(ROUND(AVG(d.days_for_delivery)), ' days') AS avg_delivery_time,
	MIN(d.time_for_delivery) AS min_delivery_time,
    CONCAT(MAX(d.days_for_delivery), ' days') AS max_delivery_time
FROM
(
SELECT
	DATEDIFF(order_delivered_customer_date,order_purchase_timestamp) AS days_for_delivery,
    TIMEDIFF(order_delivered_customer_date,order_purchase_timestamp) AS time_for_delivery
FROM orders
WHERE order_status = 'delivered'
) d
;

# How many orders are delivered on time vs orders delivered with a delay?
## estimated delivery time - order_delivered_customer_date


	SELECT a.delivery_status, CONCAT(ROUND((a.ontime_late/SUM(a.ontime_late) * 100), 2),'%') AS percentage, a.ontime_late
	FROM
		(
		SELECT    
		CASE
			WHEN otol.late_early <= 0 THEN 'on time'
			WHEN otol.late_early > 0 THEN 'late'
		END AS delivery_status,
			COUNT(*) AS ontime_late
		FROM
			(
			SELECT
				DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS late_early
			FROM orders
			WHERE order_status = 'delivered'
			) otol
		GROUP BY delivery_status
		) a;


	# Is there any pattern for delayed orders, e.g. big products being delayed more often?
	-- join orders to order_items USING(order_id) 
	-- join order_items to products USING(product_id) (select avg_delivery_time GROUP BY product_weight)

SELECT * 
FROM
(
	SELECT a.weight_class, a.on_time, a.late, COUNT(*) AS count
	FROM 
	(
		SELECT
			CASE
				WHEN product_weight_g BETWEEN 0 AND 10000 THEN '0-10000g'
				WHEN product_weight_g BETWEEN 10000 AND 20000 THEN '10000g-20000g'
				WHEN product_weight_g BETWEEN 20000 AND 30000 THEN '20000g-30000g'
				WHEN product_weight_g BETWEEN 30000 AND 40000 THEN '30000g-40000g'
				WHEN product_weight_g BETWEEN 40000 AND 50000 THEN '40000g-50000g'
                ELSE 'other'
			END AS weight_class,
			CASE
				WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) > DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp) THEN 'late'
                ELSE ''
			END AS late,
			CASE
				WHEN DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) < DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp) THEN 'on time'
                ELSE ''
			END AS on_time
		FROM orders
			LEFT JOIN order_items USING(order_id)
			LEFT JOIN products USING(product_id)
		WHERE order_status = 'delivered'
	) a
	GROUP BY a.weight_class, a.on_time, a.late
	ORDER BY a.weight_class
) b
;
### ask group how i can turn that into percentages

