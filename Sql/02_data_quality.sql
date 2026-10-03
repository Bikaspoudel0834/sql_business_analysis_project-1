-- ============================================
-- PROJECT 1: OLIST E-COMMERCE BUSINESS ANALYSIS
-- FILE: 02_data_quality.sql
-- PURPOSE: Check data quality before analysis
-- ============================================


-- ============================================
-- NULL CHECK: CUSTOMERS TABLE
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_zip,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_state
FROM customers;

-- Result:
-- 99,441 total rows.
-- No NULL values found in key customer fields.


-- ============================================
-- DUPLICATE CHECK: CUSTOMER_ID
-- ============================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Result:
-- No duplicate customer_id values found.


-- ============================================
-- DUPLICATE CHECK: CUSTOMER_UNIQUE_ID
-- ============================================

SELECT
    customer_unique_id,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY customer_count DESC;

-- Result:
-- customer_unique_id contains repeated values.
-- This is expected because the same real customer
-- can place multiple orders.


-- ============================================
-- UNIQUE CUSTOMER COUNT
-- ============================================

SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;

-- Result:
-- 99,441 customer records.
-- 96,096 unique customers.


-- ============================================
-- NULL CHECK: ORDERS TABLE
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS null_order_status,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_purchase_time,
    COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS null_approved_at,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS null_carrier_date,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS null_customer_delivery,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS null_estimated_delivery
FROM orders;

-- Result:
-- 99,441 total orders.
-- 0 NULL order IDs.
-- 0 NULL customer IDs.
-- 0 NULL order statuses.
-- 0 NULL purchase timestamps.
-- 160 NULL approval timestamps.
-- 1,783 NULL carrier delivery timestamps.
-- 2,965 NULL customer delivery timestamps.
-- 0 NULL estimated delivery dates.


-- ============================================
-- DUPLICATE CHECK: ORDER_ID
-- ============================================

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Result:
-- No duplicate order_id values found.

-- ============================================
-- ORDER STATUS CHECK
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
-- All 99,441 orders fall into valid/expected status categories.

-- ============================================
-- DATE CHECK: APPROVAL BEFORE PURCHASE
-- ============================================

SELECT COUNT(*) AS approval_before_purchase
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- Result: 0 orders were approved before the purchase timestamp.

-- ============================================
-- DATE CHECK: CARRIER BEFORE PURCHASE
-- ============================================

SELECT COUNT(*) AS carrier_before_purchase
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;

-- Result: 166 orders have a carrier delivery timestamp
-- earlier than the purchase timestamp.
-- These records should be investigated before analysis.

-- ============================================
-- DATE CHECK: CUSTOMER DELIVERY BEFORE CARRIER
-- ============================================

SELECT COUNT(*) AS customer_delivery_before_carrier
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- Result: 23 orders have a customer delivery timestamp
-- earlier than the carrier delivery timestamp.
-- These records should be investigated before analysis.

-- ============================================
-- DATE CHECK: CUSTOMER DELIVERY BEFORE CARRIER
-- ============================================

SELECT COUNT(*) AS customer_delivery_before_carrier
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- Result: 23 orders have a customer delivery timestamp
-- earlier than the carrier delivery timestamp.
-- These records should be investigated before analysis.

-- ============================================
-- NULL CHECK: ORDER_ITEMS TABLE
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS null_order_item_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE shipping_limit_date IS NULL) AS null_shipping_limit_date,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight_value
FROM order_items;

-- Result:
-- 112,650 total order-item records.
-- No NULL values found in the checked order-item fields.

-- ============================================
-- DUPLICATE CHECK: ORDER_ID + ORDER_ITEM_ID
-- ============================================

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Result: No duplicate order_id + order_item_id combinations found.

-- ============================================
-- VALUE CHECK: PRICE AND FREIGHT
-- ============================================

SELECT
    COUNT(*) FILTER (WHERE price <= 0) AS non_positive_price,
    COUNT(*) FILTER (WHERE freight_value < 0) AS negative_freight
FROM order_items;

-- Result:
-- 0 order items have a non-positive price.
-- 0 order items have negative freight values.

-- ============================================
-- NULL CHECK: PRODUCTS TABLE
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE product_name_lenght IS NULL) AS null_name_length,
    COUNT(*) FILTER (WHERE product_description_lenght IS NULL) AS null_description_length,
    COUNT(*) FILTER (WHERE product_photos_qty IS NULL) AS null_photos_qty,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS null_weight,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS null_length,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS null_height,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS null_width
FROM products;

-- Result:
-- 32,951 total product records.
-- 0 NULL product IDs.
-- 0 NULL product categories.
-- 610 NULL product name lengths.
-- 610 NULL product description lengths.
-- 610 NULL photo quantities.
-- 2 NULL values each for weight, length, height, and width.

-- ============================================
-- DUPLICATE CHECK: PRODUCT_ID
-- ============================================

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Result: No duplicate product_id values found.

-- ============================================
-- BLANK CHECK: PRODUCT CATEGORY
-- ============================================

SELECT COUNT(*) AS blank_product_categories
FROM products
WHERE TRIM(product_category_name) = '';

-- Result:
-- 610 product records have a blank product_category_name.
-- These values are not NULL, but they represent missing category information.

-- ============================================
-- VALUE CHECK: PRODUCT DIMENSIONS
-- ============================================

SELECT
    COUNT(*) FILTER (WHERE product_weight_g <= 0) AS invalid_weight,
    COUNT(*) FILTER (WHERE product_length_cm <= 0) AS invalid_length,
    COUNT(*) FILTER (WHERE product_height_cm <= 0) AS invalid_height,
    COUNT(*) FILTER (WHERE product_width_cm <= 0) AS invalid_width
FROM products;

-- Result:
-- 4 products have non-positive weight values.
-- 0 products have invalid length values.
-- 0 products have invalid height values.
-- 0 products have invalid width values.
-- The 4 weight records should be investigated before weight-based analysis.

-- ============================================
-- NULL CHECK: CATEGORY_TRANSLATION TABLE
-- ============================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_portuguese_category,
    COUNT(*) FILTER (WHERE product_category_name_english IS NULL) AS null_english_category
FROM category_translation;

-- Result:
-- 71 total category translation records.
-- 0 NULL Portuguese category names.
-- 0 NULL English category names.

-- ============================================
-- DUPLICATE CHECK: CATEGORY NAME
-- ============================================

SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM category_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

-- Result: No duplicate product_category_name values found.

-- ============================================
-- RELATIONSHIP CHECK: ORDERS WITHOUT CUSTOMERS
-- ============================================

SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Result: 0 orders are missing a matching customer record.

-- ============================================
-- RELATIONSHIP CHECK: ORDER ITEMS WITHOUT ORDERS
-- ============================================

SELECT COUNT(*) AS order_items_without_order
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Result: 0 order items are missing a matching order record.

-- ============================================
-- RELATIONSHIP CHECK: ORDER ITEMS WITHOUT PRODUCTS
-- ============================================

SELECT COUNT(*) AS order_items_without_product
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Result: 0 order items are missing a matching product record.

-- ============================================
-- RELATIONSHIP CHECK: PRODUCTS WITHOUT TRANSLATION
-- ============================================

SELECT COUNT(*) AS products_without_translation
FROM products p
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL;

-- Result:
-- 623 product records do not have a matching category translation.
-- 610 of these have blank product_category_name values.
-- 13 additional product records have non-blank categories
-- that do not match the translation table.

-- ============================================
-- CHECK: UNTRANSLATED NON-BLANK CATEGORIES
-- ============================================

SELECT
    p.product_category_name,
    COUNT(*) AS product_count
FROM products p
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL
  AND TRIM(p.product_category_name) <> ''
GROUP BY p.product_category_name
ORDER BY product_count DESC;

-- Result:
-- portateis_cozinha_e_preparadores_de_alimentos = 10 products
-- pc_gamer = 3 products
--
-- Together with 610 products having blank categories,
-- this explains all 623 products without a matching translation.

-- ============================================
-- DATA QUALITY SUMMARY
-- ============================================

-- CUSTOMERS:
-- 99,441 customer records.
-- 96,096 unique customers.
-- No NULL values in key customer fields.
-- No duplicate customer_id values.

-- ORDERS:
-- 99,441 orders.
-- No duplicate order_id values.
-- Some missing approval and delivery timestamps exist.
-- 166 orders have carrier timestamps before purchase.
-- 23 orders have customer delivery timestamps before carrier delivery.

-- ORDER_ITEMS:
-- 112,650 order-item records.
-- No NULL values in checked fields.
-- No duplicate order_id + order_item_id combinations.
-- No non-positive prices or negative freight values.

-- PRODUCTS:
-- 32,951 products.
-- No duplicate product_id values.
-- 610 blank product categories.
-- 610 missing name/description/photo fields.
-- 2 missing values in each physical-dimension field.
-- 4 products have non-positive weight values.

-- CATEGORY TRANSLATION:
-- 71 translation records.
-- No NULL values.
-- No duplicate category names.

-- RELATIONSHIP INTEGRITY:
-- 0 orders without customers.
-- 0 order items without orders.
-- 0 order items without products.
-- 623 products without matching English category translations.
-- 610 are blank categories.
-- 10 belong to portateis_cozinha_e_preparadores_de_alimentos.
-- 3 belong to pc_gamer.

-- CONCLUSION:
-- Core relational integrity is strong.
-- Identified data-quality issues will be considered during analysis
-- rather than automatically deleting affected records.