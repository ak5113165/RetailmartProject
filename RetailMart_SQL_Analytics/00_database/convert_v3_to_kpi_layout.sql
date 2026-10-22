-- =====================================================================
-- FILE: 00_database/convert_v3_to_kpi_layout.sql
-- PURPOSE: Reshape a RetailMart V3 database into the table/column names
--          the KPI queries (02_kpi_queries/) expect.
--
-- You normally DON'T need to run this: retailmart_v3_kpi.sql is already
-- converted. It's kept so you can see exactly what changed, or re-run it
-- on a fresh load of the original retailmart_v3.sql:
--     psql -d retailmart -f retailmart_v3.sql
--     psql -d retailmart -f 00_database/convert_v3_to_kpi_layout.sql
--
-- Approach: rename columns where the meaning is the same (foreign keys
-- follow automatically), and add columns/tables that the KPI queries need.
-- No V3 data is deleted. All other schemas (finance, hr, marketing ...)
-- are left as they are.
-- =====================================================================
SET client_min_messages = warning;
BEGIN;

-- ---------------------------------------------------------------------
-- core.dim_date
--   KPI queries join  order_date = dim_date.date_key  (a DATE)
--   and use short names: 'Mon'..'Sun', 'Jan'..'Dec'
-- ---------------------------------------------------------------------
ALTER TABLE core.dim_date RENAME COLUMN date_key TO date_id;      -- int yyyymmdd kept as date_id
ALTER TABLE core.dim_date RENAME COLUMN full_date TO date_key;    -- DATE is now date_key
UPDATE core.dim_date
SET day_name   = LEFT(day_name, 3),
    month_name = LEFT(month_name, 3);

-- ---------------------------------------------------------------------
-- products.products
--   KPI queries use prod_id, prod_name, category, brand
-- ---------------------------------------------------------------------
ALTER TABLE products.products RENAME COLUMN product_id TO prod_id;
ALTER TABLE products.products RENAME COLUMN product_name TO prod_name;
ALTER TABLE products.products ADD COLUMN category VARCHAR(40);
ALTER TABLE products.products ADD COLUMN brand VARCHAR(60);
UPDATE products.products p
SET category = c.category_name,
    brand    = b.brand_name
FROM core.dim_brand b
JOIN core.dim_category c ON b.category_id = c.category_id
WHERE p.brand_id = b.brand_id;

-- products.inventory: prod_id, stock_qty
ALTER TABLE products.inventory RENAME COLUMN product_id TO prod_id;
ALTER TABLE products.inventory RENAME COLUMN quantity_on_hand TO stock_qty;

-- ---------------------------------------------------------------------
-- stores
-- ---------------------------------------------------------------------
-- stores.stores: region as text
ALTER TABLE stores.stores ADD COLUMN region VARCHAR(20);
UPDATE stores.stores s
SET region = r.region_name
FROM core.dim_region r
WHERE s.region_id = r.region_id;

-- stores.employees: emp_id
ALTER TABLE stores.employees RENAME COLUMN employee_id TO emp_id;

-- stores.departments: copy of core.dim_department
-- (a few employees have a dept_id that isn't here - on purpose in V3)
CREATE TABLE stores.departments AS
SELECT dept_id, dept_name, dept_code, division, cost_center
FROM core.dim_department;
ALTER TABLE stores.departments ADD PRIMARY KEY (dept_id);

-- ---------------------------------------------------------------------
-- customers.customers
--   KPI queries use cust_id, full_name, gender, age, city, state, join_date
-- ---------------------------------------------------------------------
ALTER TABLE customers.customers RENAME COLUMN customer_id TO cust_id;
ALTER TABLE customers.customers ADD COLUMN full_name VARCHAR(100);
ALTER TABLE customers.customers ADD COLUMN gender CHAR(1);
ALTER TABLE customers.customers ADD COLUMN age INT;
ALTER TABLE customers.customers ADD COLUMN city VARCHAR(40);
ALTER TABLE customers.customers ADD COLUMN state VARCHAR(40);
ALTER TABLE customers.customers ADD COLUMN join_date DATE;

UPDATE customers.customers
SET full_name = TRIM(first_name) || ' ' || TRIM(last_name),
    join_date = registration_date;

-- city / state from the customer's default address
UPDATE customers.customers c
SET city  = a.city,
    state = a.state
FROM (
    SELECT DISTINCT ON (customer_id) customer_id, city, state
    FROM customers.addresses
    ORDER BY customer_id, is_default DESC, address_id
) a
WHERE c.cust_id = a.customer_id;

-- gender / age: V3 has none, so these are GENERATED practice values.
-- Derived from cust_id with a hash, so every load gives the same result.
UPDATE customers.customers
SET gender = CASE WHEN abs(hashtext('g' || cust_id)) % 100 < 52 THEN 'M' ELSE 'F' END,
    age    = 18 + abs(hashtext('a' || cust_id)) % 53;                 -- 18 to 70

-- customers.reviews: cust_id, prod_id
ALTER TABLE customers.reviews RENAME COLUMN customer_id TO cust_id;
ALTER TABLE customers.reviews RENAME COLUMN product_id TO prod_id;

-- customers.loyalty_points: built from loyalty.members
CREATE TABLE customers.loyalty_points AS
SELECT customer_id as cust_id,
       COALESCE(points_balance, 0) as total_points,   -- a few NULL balances in V3
       joined_date as last_updated
FROM loyalty.members;
ALTER TABLE customers.loyalty_points ADD PRIMARY KEY (cust_id);
ALTER TABLE customers.loyalty_points
    ADD FOREIGN KEY (cust_id) REFERENCES customers.customers(cust_id);

-- ---------------------------------------------------------------------
-- sales
-- ---------------------------------------------------------------------
-- sales.orders: total_amount = net_total (amount after discount)
ALTER TABLE sales.orders ADD COLUMN total_amount NUMERIC(12,2);
UPDATE sales.orders SET total_amount = net_total;

-- sales.order_items: discount as a PERCENT
-- KPI queries compute  quantity * unit_price * (1 - discount / 100),
-- so discount = discount_amount / (quantity * unit_price) * 100.
-- Kept to 8 decimals so the result matches net_amount to the paisa.
ALTER TABLE sales.order_items ADD COLUMN discount NUMERIC(12,8);
UPDATE sales.order_items
SET discount = ROUND(100.0 * discount_amount / NULLIF(quantity * unit_price, 0), 8);
UPDATE sales.order_items SET discount = 0 WHERE discount IS NULL;

-- sales.payments and sales.returns already have the columns the KPI
-- queries use (payment_mode, amount, return_date, refund_amount).

COMMIT;

ANALYZE;
