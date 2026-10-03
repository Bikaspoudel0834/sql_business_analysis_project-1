-- ============================================
-- PROJECT 1: OLIST E-COMMERCE BUSINESS ANALYSIS
-- FILE: 03_exploratory_analysis.sql
-- PURPOSE: Explore overall business performance,
-- customers, orders, revenue, products, and trends
-- ============================================

-- ============================================
-- BUSINESS SIZE: ORDERS WITH ITEM RECORDS
-- ============================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT oi.product_id) AS unique_products
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id;

-- Result:
-- 98,666 orders have matching order-item records.
-- 95,420 unique customers are represented in these orders.
-- 32,951 unique products appear in order items.
-- The orders table contains 99,441 total orders, so some orders
-- do not have matching item records and should be investigated.

-- ============================================
-- CHECK: ORDERS WITHOUT ORDER ITEMS
-- ============================================

SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- Result:
-- 775 orders do not have matching order-item records.
-- Therefore, 98,666 of the 99,441 total orders contain item-level data.

-- ============================================
-- STATUS CHECK: ORDERS WITHOUT ORDER ITEMS
-- ============================================

SELECT
    o.order_status,
    COUNT(*) AS order_count
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status
ORDER BY order_count DESC;

-- Result:
-- unavailable = 603
-- canceled    = 164
-- created     = 5
-- invoiced    = 2
-- shipped     = 1
--
-- Most orders without item records are unavailable or canceled.
-- This explains why they do not appear in item-level sales analysis.

-- ============================================
-- DATASET DATE RANGE
-- ============================================

SELECT
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM orders;

-- Result:
-- First order: 2016-09-04 21:15:19
-- Last order:  2018-10-17 17:30:18
-- The dataset covers a little over two years of order activity.

-- ============================================
-- OVERALL ORDER STATUS DISTRIBUTION
-- ============================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Result:
-- delivered   = 96,478
-- shipped     = 1,107
-- canceled    = 625
-- unavailable = 609
-- invoiced    = 314
-- processing  = 301
-- created     = 5
-- approved    = 2
--
-- Delivered orders make up the overwhelming majority
-- of all orders in the dataset.

-- ============================================
-- TOTAL SALES REVENUE
-- ============================================

SELECT
    ROUND(SUM(price), 2) AS total_product_revenue
FROM order_items;

-- Result:
-- Total product revenue = 13,591,643.70.
-- This includes product prices only and does not include freight charges.

-- ============================================
-- TOTAL FREIGHT VALUE
-- ============================================

SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_value
FROM order_items;

-- Result:
-- Total freight value = 2,251,909.54.

-- ============================================
-- TOTAL ORDER VALUE: PRODUCT + FREIGHT
-- ============================================

SELECT
    ROUND(SUM(price + freight_value), 2) AS total_order_value
FROM order_items;

-- Result:
-- Total order value including product price and freight = 15,843,553.24.

-- ============================================
-- AVERAGE ORDER VALUE
-- ============================================

SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_totals;

-- Result:
-- Average order value including product price and freight = 160.58.

-- ============================================
-- AVERAGE ITEMS PER ORDER
-- ============================================

SELECT
    ROUND(AVG(item_count), 2) AS average_items_per_order
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
) AS order_item_counts;

-- Result:
-- Average items per order = 1.14.

-- ============================================
-- AVERAGE PRODUCT PRICE
-- ============================================

SELECT
    ROUND(AVG(price), 2) AS average_product_price
FROM order_items;

-- Result:
-- Average product price = 120.65.

-- ============================================
-- AVERAGE FREIGHT PER ITEM
-- ============================================

SELECT
    ROUND(AVG(freight_value), 2) AS average_freight_per_item
FROM order_items;

-- Result:
-- Average freight per item = 19.99.

-- ============================================
-- MONTHLY ORDER TREND
-- ============================================

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY order_month;

-- Result:
-- Order volume increased substantially through 2017.
-- November 2017 had the highest monthly order volume with 7,544 orders.
-- Most months in 2018 recorded roughly 6,000–7,000 orders.
-- September and October 2018 contain only partial activity and
-- should not be treated as full-month comparisons.

-- ============================================
-- MONTHLY REVENUE TREND
-- ============================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY order_month;

-- Result:
-- Product revenue generally increased through 2017.
-- November 2017 recorded the highest monthly product revenue
-- at 1,010,271.37.
-- Several months in 2018 generated close to 1 million in product revenue.
-- September 2018 contains only partial item-level activity.
-- October 2018 does not appear because its orders have no matching
-- order-item records.

-- ============================================
-- TOP PRODUCT CATEGORIES BY REVENUE
-- ============================================

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY product_revenue DESC
LIMIT 10;

-- Result:
-- health_beauty          = 1,258,681.34
-- watches_gifts          = 1,205,005.68
-- bed_bath_table         = 1,036,988.68
-- sports_leisure         =   988,048.97
-- computers_accessories  =   911,954.32
-- furniture_decor        =   729,762.49
-- cool_stuff             =   635,290.85
-- housewares             =   632,248.66
-- auto                   =   592,720.11
-- garden_tools           =   485,256.46
--
-- health_beauty generated the highest product revenue
-- among all product categories.

-- ============================================
-- TOP PRODUCT CATEGORIES BY ITEMS SOLD
-- ============================================

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY items_sold DESC
LIMIT 10;

-- Result:
-- bed_bath_table        = 11,115 items
-- health_beauty         = 9,670 items
-- sports_leisure        = 8,641 items
-- furniture_decor       = 8,334 items
-- computers_accessories = 7,827 items
-- housewares            = 6,964 items
-- watches_gifts         = 5,991 items
-- telephony             = 4,545 items
-- garden_tools          = 4,347 items
-- auto                  = 4,235 items
--
-- bed_bath_table had the highest item sales volume,
-- while health_beauty generated the highest revenue.

-- ============================================
-- CUSTOMER BEHAVIOR: ONE-TIME VS REPEAT CUSTOMERS
-- ============================================

SELECT
    COUNT(*) FILTER (WHERE order_count = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE order_count > 1) AS repeat_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- Result:
-- One-time customers = 93,099
-- Repeat customers   = 2,997
-- Total unique customers = 96,096
--
-- Most customers placed only one order.

-- ============================================
-- REPEAT CUSTOMER PERCENTAGE
-- ============================================

SELECT
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;

-- Result:
-- Repeat customer percentage = 3.12%.
-- Most customers in the dataset purchased only once.

-- ============================================
-- TOP STATES BY UNIQUE CUSTOMERS
-- ============================================

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers
GROUP BY customer_state
ORDER BY unique_customers DESC
LIMIT 10;

-- Result:
-- SP = 40,302 unique customers
-- RJ = 12,384 unique customers
-- MG = 11,259 unique customers
-- RS = 5,277 unique customers
-- PR = 4,882 unique customers
-- SC = 3,534 unique customers
-- BA = 3,277 unique customers
-- DF = 2,075 unique customers
-- ES = 1,964 unique customers
-- GO = 1,952 unique customers
--
-- SP has by far the largest customer base in the dataset.


-- ============================================
-- TOP STATES BY NUMBER OF ORDERS
-- ============================================

SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC
LIMIT 10;

-- Result:
-- SP = 41,746 orders
-- RJ = 12,852 orders
-- MG = 11,635 orders
-- RS = 5,466 orders
-- PR = 5,045 orders
-- SC = 3,637 orders
-- BA = 3,380 orders
-- DF = 2,140 orders
-- ES = 2,033 orders
-- GO = 2,020 orders
--
-- SP has the highest order volume by a wide margin,
-- which is consistent with it also having the largest customer base.

-- ============================================
-- TOP STATES BY PRODUCT REVENUE
-- ============================================

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS product_revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY product_revenue DESC
LIMIT 10;
-- Result:
-- SP = 5,202,955.05
-- RJ = 1,824,092.67
-- MG = 1,585,308.03
-- RS =   750,304.02
-- PR =   683,083.76
-- SC =   520,553.34
-- BA =   511,349.99
-- DF =   302,603.94
-- GO =   294,591.95
-- ES =   275,037.31
--
-- SP generates the highest product revenue
-- and also leads in customer count and order volume.

-- ============================================
-- AVERAGE ORDER VALUE BY STATE
-- ============================================

SELECT
    customer_state,
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        c.customer_state,
        o.order_id,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_state, o.order_id
) AS state_order_totals
GROUP BY customer_state
ORDER BY average_order_value DESC
LIMIT 10;

-- Result:
-- PB = 265.01
-- AC = 242.84
-- AP = 239.16
-- AL = 234.13
-- RO = 233.03
-- PA = 224.38
-- TO = 219.91
-- PI = 219.34
-- RR = 218.80
-- SE = 211.69
--
-- PB has the highest average order value among states.
-- These states are not necessarily the largest markets by total revenue,
-- showing that high order value and high total sales are different metrics.


-- ============================================
-- TOP CUSTOMERS BY TOTAL SPENDING
-- ============================================

SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;

-- Result:
-- 0a0a92112bd4c708ca5fde585afaa872 = 13,664.08
-- da122df9eeddfedc1dc1f5349a1a690c = 7,571.63
-- 763c8b1c9c68a0229c42c9fc6f662b93 = 7,274.88
-- dc4802a71eae9be1dd28f5d788ceb526 = 6,929.31
-- 459bef486812aa25204be022145caa62 = 6,922.21
-- ff4159b92c40ebe40454e3e6a7c35ed6 = 6,726.66
-- 4007669dec559734d6f53e029e360987 = 6,081.54
-- 5d0a2980b292d049061542014e8960bf = 4,809.44
-- eebb5dda148d3893cdaf5b5ca3040ccb = 4,764.34
-- 48e1ac109decbb87765a3eade6854098 = 4,681.78
--
-- The highest-spending customer generated 13,664.08
-- in combined product and freight value.

-- ============================================
-- TOP CUSTOMERS BY NUMBER OF ORDERS
-- ============================================

SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC
LIMIT 10;

-- Result:
-- 8d50f5eadf50201ccdcedfb9e2ac8455 = 17 orders
-- 3e43e6105506432c953e165fb2acf44c = 9 orders
-- ca77025e7201e3b30c44b472ff346268 = 7 orders
-- 1b6c7548a2a1f9037c1fd3ddfed95f33 = 7 orders
-- 6469f99c1f9dfae7733b25662e7f1782 = 7 orders
-- dc813062e0fc23409cd255f7f53c7074 = 6 orders
-- 63cfc61cee11cbe306bff5857d00bfe4 = 6 orders
-- 12f5d6e1cbf93dafd9dcc19095df0b3d = 6 orders
-- 47c1a3033b8b77b3ab6e109eb4d5fdf3 = 6 orders
-- de34b16117594161a6a89c50b289d35a = 6 orders
--
-- The most frequent customer placed 17 orders.

-- ============================================
-- MOST EXPENSIVE ITEMS SOLD
-- ============================================

SELECT
    oi.product_id,
    p.product_category_name,
    oi.price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
ORDER BY oi.price DESC
LIMIT 10;

-- Result:
-- 489ae2aa008f021502940f251d4cce7f | utilidades_domesticas     | 6,735.00
-- 69c590f7ffc7bf8db97190b6cb6ed62e | pcs                       | 6,729.00
-- 1bdf5e6731585cf01aa8169c7028d6ad | artes                     | 6,499.00
-- a6492cc69376c469ab6f61d8f44de961 | eletroportateis           | 4,799.00
-- c3ed642d592594bb648ff4a04cee2747 | eletroportateis           | 4,690.00
-- 259037a6a41845e455183f89c5035f18 | pcs                       | 4,590.00
-- a1beef8f3992dbd4cd8726796aa69c53 | instrumentos_musicais     | 4,399.87
-- 6cdf8fc1d741c76586d8b6b15e9eef30 | consoles_games            | 4,099.99
-- dd113cb02b2af9c8e5787e8f1f0722f6 | esporte_lazer             | 4,059.00
-- 6902c1962dd19d540807d0ab8fade5c6 | relogios_presentes        | 3,999.90
--
-- The highest-priced individual item sold for 6,735.00.

-- ============================================
-- TOP PRODUCTS BY TOTAL REVENUE
-- ============================================

SELECT
    oi.product_id,
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
    ROUND(SUM(oi.price), 2) AS total_product_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY total_product_revenue DESC
LIMIT 10;

-- Result:
-- bb50f2e236e5eea0100680137654686c | health_beauty         | 63,885.00
-- 6cdd53843498f92890544667809f1595 | health_beauty         | 54,730.20
-- d6160fb7873f184099d9bc95e30376af | computers             | 48,899.34
-- d1c427060a0f73f6b889a5c7c61f2ac4 | computers_accessories | 47,214.51
-- 99a4788cb24856965c36a24e339b6058 | bed_bath_table        | 43,025.56
-- 3dd2a17168ec895c781a9191c1e95ad7 | computers_accessories | 41,082.60
-- 25c38557cf793876c5abdd5931f922db | baby                  | 38,907.32
-- 5f504b3a1c75b73d6151be81eb05bdc9 | cool_stuff            | 37,733.90
-- 53b36df67ebb7c41585e8d54d6772e08 | watches_gifts         | 37,683.42
-- aca2eb7d00ea1a7b8ebd4e68314663af | furniture_decor       | 37,608.90
--
-- The highest-revenue individual product generated 63,885.00.
-- Two health_beauty products occupy the top two positions.

-- ============================================
-- TOP PRODUCTS BY ITEMS SOLD
-- ============================================

SELECT
    oi.product_id,
    COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(ct.product_category_name_english, p.product_category_name)
ORDER BY items_sold DESC
LIMIT 10;

-- Result:
-- aca2eb7d00ea1a7b8ebd4e68314663af | furniture_decor       | 527
-- 99a4788cb24856965c36a24e339b6058 | bed_bath_table        | 488
-- 422879e10f46682990de24d770e7f83d | garden_tools          | 484
-- 389d119b48cf3043d311335e499d9c6b | garden_tools          | 392
-- 368c6c730842d78016ad823897a372db | garden_tools          | 388
-- 53759a2ecddad2bb87a079a1f1519f73 | garden_tools          | 373
-- d1c427060a0f73f6b889a5c7c61f2ac4 | computers_accessories | 343
-- 53b36df67ebb7c41585e8d54d6772e08 | watches_gifts         | 323
-- 154e7e31ebfa092203795c972e5804a6 | health_beauty         | 281
-- 3dd2a17168ec895c781a9191c1e95ad7 | computers_accessories | 274
--
-- The highest-selling individual product sold 527 units.
-- Garden_tools appears several times among the highest-volume products.



-- ============================================
-- EXPLORATORY ANALYSIS SUMMARY
-- ============================================

-- The dataset contains 99,441 orders, with 98,666 having item-level records.
-- Total product revenue is 13,591,643.70.
-- Total order value including freight is 15,843,553.24.
-- Average order value is 160.58.
-- Average items per order is 1.14.

-- November 2017 recorded the highest monthly order volume
-- and the highest monthly product revenue.

-- health_beauty generated the highest category revenue.
-- bed_bath_table had the highest category sales volume.

-- Only 3.12% of unique customers placed more than one order,
-- indicating a low repeat-customer rate.

-- SP is the largest market by customers, orders, and total revenue.

-- The highest-spending customer spent 13,664.08.
-- The most frequent customer placed 17 orders.

-- Product sales volume and product revenue rankings differ,
-- showing that high-volume products are not always the highest-revenue products.