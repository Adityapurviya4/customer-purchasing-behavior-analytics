select * FROM mytable ;
SELECT 
    Gender,
    SUM(`Purchase Amount (USD)`) AS revenue
FROM mytable
GROUP BY Gender
ORDER BY revenue DESC;

SELECT 
    `Customer ID`,
    `Purchase Amount (USD)`
FROM mytable
WHERE 
    `Discount Applied` = 'Yes'
    AND `Purchase Amount (USD)` >= (
        SELECT AVG(`Purchase Amount (USD)`)
        FROM mytable
    );

SELECT 
    `Item Purchased`,
    ROUND(AVG(`Review Rating`), 2) AS `Average Product Rating`
FROM mytable
GROUP BY `Item Purchased`
ORDER BY AVG(`Review Rating`) DESC
LIMIT 5;

SELECT 
    `Shipping Type`,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_purchase
FROM mytable
WHERE `Shipping Type` IN ('Standard', 'Express')
GROUP BY `Shipping Type`;

SELECT 
    `Subscription Status`,
    COUNT(`Customer ID`) AS total_customers,
    ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
    ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM mytable
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC, avg_spend DESC;

SELECT 
    `Item Purchased`,
    ROUND(
        100.0 * SUM(CASE WHEN `Discount Applied` = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS discount_rate
FROM mytable
GROUP BY `Item Purchased`
ORDER BY discount_rate DESC
LIMIT 5;

WITH customer_type AS (
    SELECT 
        `Customer ID`,
        `Previous Purchases`,
        CASE 
            WHEN `Previous Purchases` = 1 THEN 'New'
            WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM mytable
)
SELECT 
    customer_segment,
    COUNT(*) AS `Number of Customers`
FROM customer_type
GROUP BY customer_segment;

WITH item_counts AS (
    SELECT 
        `Category`,
        `Item Purchased`,
        COUNT(`Customer ID`) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY `Category`
            ORDER BY COUNT(`Customer ID`) DESC
        ) AS item_rank
    FROM mytable
    GROUP BY `Category`, `Item Purchased`
)
SELECT 
    item_rank,
    `Category`,
    `Item Purchased`,
    total_orders
FROM item_counts
WHERE item_rank <= 3;

SELECT 
    `Subscription Status`,
    COUNT(`Customer ID`) AS repeat_buyers
FROM mytable
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;

SELECT 
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 25 THEN '18–25'
        WHEN Age BETWEEN 26 AND 40 THEN '26–40'
        WHEN Age BETWEEN 41 AND 60 THEN '41–60'
        ELSE '60+'
    END AS age_group,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM mytable
GROUP BY age_group
ORDER BY total_revenue DESC;
