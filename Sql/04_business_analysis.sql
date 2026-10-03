-- ============================================
-- PROJECT 1: OLIST E-COMMERCE BUSINESS ANALYSIS
-- FILE: 04_business_analysis.sql
-- PURPOSE: Answer business-focused questions,
-- identify important patterns, and develop
-- actionable recommendations from the data
-- ============================================

-- ============================================
-- BUSINESS QUESTION 1:
-- WHICH CATEGORIES DRIVE THE MOST REVENUE?
-- ============================================

WITH category_sales AS (
    SELECT
        COALESCE(
            NULLIF(TRIM(ct.product_category_name_english), ''),
            NULLIF(TRIM(p.product_category_name), ''),
            'unknown'
        ) AS category_name,
        SUM(oi.price) AS revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY 1
)

SELECT
    category_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM category_sales
ORDER BY revenue DESC
LIMIT 10;

-- Result:
-- health_beauty         = 1,258,681.34 | 9.26%
-- watches_gifts         = 1,205,005.68 | 8.87%
-- bed_bath_table        = 1,036,988.68 | 7.63%
-- sports_leisure        =   988,048.97 | 7.27%
-- computers_accessories =   911,954.32 | 6.71%
-- furniture_decor       =   729,762.49 | 5.37%
-- cool_stuff            =   635,290.85 | 4.67%
-- housewares            =   632,248.66 | 4.65%
-- auto                  =   592,720.11 | 4.36%
-- garden_tools          =   485,256.46 | 3.57%
--
-- Business Insight:
-- The top 10 categories generate 62.36% of total product revenue.
-- health_beauty is the largest revenue contributor at 9.26%.
-- Revenue is concentrated across several strong categories rather
-- than being dependent on a single category.

-- ============================================
-- BUSINESS QUESTION 2:
-- WHICH PRODUCT CATEGORIES GREW THE FASTEST?
-- ============================================

SELECT
    category_name,
    ROUND(revenue_2017, 2) AS revenue_2017,
    ROUND(revenue_2018, 2) AS revenue_2018,
    ROUND(
        100.0 * (revenue_2018 - revenue_2017) / revenue_2017,
        2
    ) AS growth_pct
FROM (
    SELECT
        COALESCE(
            NULLIF(TRIM(ct.product_category_name_english), ''),
            NULLIF(TRIM(p.product_category_name), ''),
            'unknown'
        ) AS category_name,

        SUM(
            CASE
                WHEN o.order_purchase_timestamp >= '2017-01-01'
                 AND o.order_purchase_timestamp < '2017-09-01'
                THEN oi.price
                ELSE 0
            END
        ) AS revenue_2017,

        SUM(
            CASE
                WHEN o.order_purchase_timestamp >= '2018-01-01'
                 AND o.order_purchase_timestamp < '2018-09-01'
                THEN oi.price
                ELSE 0
            END
        ) AS revenue_2018

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY 1
) AS category_growth

WHERE revenue_2017 >= 10000
ORDER BY growth_pct DESC
LIMIT 10;

-- Result:
-- home_appliances_2   = 12,788.82  -> 89,252.86  | 597.90%
-- home_appliances     = 14,232.62  -> 56,320.70  | 295.72%
-- stationery         = 37,414.56  -> 136,360.31 | 264.46%
-- baby               = 70,788.37  -> 256,800.70 | 262.77%
-- electronics        = 29,654.23  -> 102,928.59 | 247.10%
-- watches_gifts      = 210,247.18 -> 708,850.94 | 237.15%
-- health_beauty      = 247,917.28 -> 772,238.15 | 211.49%
-- housewares         = 133,986.33 -> 399,888.10 | 198.45%
-- telephony          = 61,228.74  -> 180,293.31 | 194.46%
-- musical_instruments= 38,656.40  -> 109,614.95 | 183.56%

-- Business Insight:
-- home_appliances_2 had the highest growth rate at 597.90%.
-- watches_gifts and health_beauty are especially important because
-- they combine strong growth with already large revenue bases.
-- Jan-Aug periods were compared for both years to avoid using
-- incomplete late-2018 data.

-- ============================================
-- BUSINESS QUESTION 3:
-- WHICH STATES ARE THE MOST VALUABLE MARKETS?
-- ============================================

WITH order_values AS (
    SELECT
        c.customer_state,
        c.customer_unique_id,
        o.order_id,
        SUM(oi.price) AS product_revenue,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_state,
        c.customer_unique_id,
        o.order_id
)

SELECT
    customer_state,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(SUM(product_revenue), 2) AS product_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(
        SUM(product_revenue) / COUNT(DISTINCT customer_unique_id),
        2
    ) AS revenue_per_customer
FROM order_values
GROUP BY customer_state
ORDER BY product_revenue DESC
LIMIT 10;

-- Result:
-- SP | 41,375 orders | 39,981 customers | 5,202,955.05 revenue | 143.12 AOV | 130.14 revenue/customer
-- RJ | 12,762 orders | 12,303 customers | 1,824,092.67 revenue | 166.88 AOV | 148.26 revenue/customer
-- MG | 11,544 orders | 11,178 customers | 1,585,308.03 revenue | 160.79 AOV | 141.82 revenue/customer
-- RS | 5,432 orders  | 5,249 customers  |   750,304.02 revenue | 163.08 AOV | 142.94 revenue/customer
-- PR | 4,998 orders  | 4,840 customers  |   683,083.76 revenue | 160.25 AOV | 141.13 revenue/customer
-- SC | 3,612 orders  | 3,513 customers  |   520,553.34 revenue | 168.94 AOV | 148.18 revenue/customer
-- BA | 3,358 orders  | 3,257 customers  |   511,349.99 revenue | 182.10 AOV | 157.00 revenue/customer
-- DF | 2,125 orders  | 2,062 customers  |   302,603.94 revenue | 166.23 AOV | 146.75 revenue/customer
-- GO | 2,007 orders  | 1,942 customers  |   294,591.95 revenue | 173.25 AOV | 151.70 revenue/customer
-- ES | 2,025 orders  | 1,956 customers  |   275,037.31 revenue | 160.40 AOV | 140.61 revenue/customer

-- Business Insight:
-- SP is the company's largest market by scale and total product revenue.
-- However, SP has a lower average order value and revenue per customer
-- than several smaller markets.
-- Among these top-revenue states, BA has the highest average order value
-- and revenue per customer.
-- This suggests SP is valuable mainly because of its large customer base,
-- while markets such as BA and GO show stronger spending per customer. 

-- ============================================
-- BUSINESS QUESTION 4:
-- HOW VALUABLE ARE REPEAT CUSTOMERS?
-- ============================================

WITH customer_summary AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.price + oi.freight_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'one_time_customer'
        ELSE 'repeat_customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(SUM(total_spent), 2) AS total_spending,
    ROUND(AVG(total_spent), 2) AS avg_spending_per_customer,
    ROUND(AVG(total_orders), 2) AS avg_orders_per_customer
FROM customer_summary
GROUP BY customer_type
ORDER BY avg_spending_per_customer DESC;

-- Result:
-- repeat_customer  | 2,913 customers | 904,446.25 spending
--                  | 310.49 average spending/customer
--                  | 2.11 average orders/customer
--
-- one_time_customer | 92,507 customers | 14,939,106.99 spending
--                   | 161.49 average spending/customer
--                   | 1.00 average orders/customer

-- Business Insight:
-- Repeat customers spend about 310.49 per customer compared with
-- 161.49 for one-time customers, nearly twice as much.
--
-- Although repeat customers represent only a small portion of the
-- customer base, they are considerably more valuable per customer.
-- Improving customer retention could therefore create meaningful
-- additional revenue opportunities.
--
-- Note:
-- This analysis includes only customers with matching order-item records,
-- which is why 2,913 repeat customers appear here instead of the 2,997
-- identified when analyzing the complete orders table.


-- ============================================
-- BUSINESS QUESTION 5:
-- HOW WELL IS THE COMPANY MEETING DELIVERY DATES?
-- ============================================

SELECT
    COUNT(*) AS analyzed_deliveries,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date <= order_estimated_delivery_date
    ) AS on_time_deliveries,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date > order_estimated_delivery_date
    ) AS late_deliveries,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE order_delivered_customer_date > order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_pct

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- Result:
-- Analyzed deliveries = 96,470
-- On-time deliveries  = 88,644
-- Late deliveries     = 7,826
-- Late delivery rate  = 8.11%

-- Business Insight:
-- Approximately 91.89% of analyzed deliveries were completed
-- on or before the estimated delivery date.
-- However, 8.11% of delivered orders arrived late.
-- Reducing late deliveries could improve customer satisfaction
-- and strengthen the overall customer experience.

-- ============================================
-- BUSINESS QUESTION 6:
-- WHICH STATES HAVE THE HIGHEST LATE-DELIVERY RATES?
-- ============================================

SELECT
    c.customer_state,
    COUNT(*) AS analyzed_deliveries,

    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
    ) AS late_deliveries,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
        ) / COUNT(*),
        2
    ) AS late_delivery_pct

FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_delivery_pct DESC
LIMIT 10;

-- Result:
-- AL | 397 deliveries   | 95 late   | 23.93%
-- MA | 717 deliveries   | 141 late  | 19.67%
-- PI | 476 deliveries   | 76 late   | 15.97%
-- CE | 1,279 deliveries | 196 late  | 15.32%
-- SE | 335 deliveries   | 51 late   | 15.22%
-- BA | 3,256 deliveries | 457 late  | 14.04%
-- RJ | 12,350 deliveries| 1,664 late| 13.47%
-- TO | 274 deliveries   | 35 late   | 12.77%
-- PA | 946 deliveries   | 117 late  | 12.37%
-- ES | 1,995 deliveries | 244 late  | 12.23%

-- Business Insight:
-- AL has the highest late-delivery rate at 23.93%.
-- MA also shows a high late-delivery rate at 19.67%.
-- RJ is especially important because it combines a high late-delivery rate
-- with very large delivery volume, meaning operational improvements there
-- could affect a large number of customers.
-- Delivery performance should be reviewed regionally rather than only
-- at the national level.

-- ============================================
-- BUSINESS QUESTION 7:
-- WHICH CATEGORIES COMBINE HIGH REVENUE AND HIGH SALES VOLUME?
-- ============================================

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name)
HAVING COUNT(*) >= 4000
ORDER BY product_revenue DESC
LIMIT 10;

-- Result:
-- health_beauty         | 9,670 items  | 1,258,681.34 revenue | 130.16 avg price
-- watches_gifts         | 5,991 items  | 1,205,005.68 revenue | 201.14 avg price
-- bed_bath_table        | 11,115 items | 1,036,988.68 revenue | 93.30 avg price
-- sports_leisure        | 8,641 items  |   988,048.97 revenue | 114.34 avg price
-- computers_accessories | 7,827 items  |   911,954.32 revenue | 116.51 avg price
-- furniture_decor       | 8,334 items  |   729,762.49 revenue | 87.56 avg price
-- housewares            | 6,964 items  |   632,248.66 revenue | 90.79 avg price
-- auto                  | 4,235 items  |   592,720.11 revenue | 139.96 avg price
-- garden_tools          | 4,347 items  |   485,256.46 revenue | 111.63 avg price
-- toys                  | 4,117 items  |   483,946.60 revenue | 117.55 avg price

-- Business Insight:
-- health_beauty is the strongest balanced category,
-- combining very high sales volume with the highest total revenue.
--
-- watches_gifts generates nearly as much revenue with much lower
-- sales volume because of its higher average item price.
--
-- bed_bath_table leads in sales volume but produces less revenue
-- than health_beauty and watches_gifts because of its lower average price.
--
-- These categories represent strong strategic areas because they
-- combine meaningful customer demand with substantial revenue generation.



-- ============================================
-- BUSINESS ANALYSIS SUMMARY
-- ============================================

-- Revenue is diversified across several strong product categories.
-- The top 10 categories generate 62.36% of total product revenue.

-- health_beauty is the largest revenue category,
-- while watches_gifts combines strong revenue with a high average item price.

-- Several categories showed strong year-over-year growth,
-- including home_appliances_2, watches_gifts, and health_beauty.

-- SP is the largest market by scale and total revenue,
-- but smaller markets such as BA and GO show stronger spending per customer.

-- Repeat customers are far more valuable per customer than one-time customers,
-- suggesting customer retention is an important growth opportunity.

-- Approximately 8.11% of analyzed delivered orders arrived late.
-- Delivery performance varies significantly by state.

-- RJ is especially important operationally because it combines
-- a high late-delivery rate with a large number of deliveries.

-- health_beauty, watches_gifts, and bed_bath_table are strategically important
-- because they combine strong demand with substantial revenue generation.

-- Overall, the strongest business opportunities are:
-- 1. Improve customer retention.
-- 2. Reduce late deliveries in high-risk states.
-- 3. Protect and grow high-performing product categories.
-- 4. Expand high-value regional markets.
