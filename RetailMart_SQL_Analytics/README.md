# **🛒 RetailMart SQL Analytics Dashboard**

A complete SQL-driven analytics engine for real-time retail insights

It uses PostgreSQL views, materialized views, JSON functions, automation scripts, and a lightweight HTML/CSS/JS dashboard to deliver fast, reliable insights across:

• 📊 **Sales Performance**  
• 📦 **Product Analytics**  
• 👥 **Customer Behavior**  
• 🏪 **Store Operations**

This project demonstrates end-to-end BI engineering using SQL as the core processing layer—without depending on heavy BI tools

# **📁 Project Structure**

| Folder / File | Description |
|---------------|-------------|
| **00_database/** | Database for this project |
| ├── retailmart_v3_kpi.sql | RetailMart V3 data, converted to the layout the KPI queries use |
| └── convert_v3_to_kpi_layout.sql | The conversion script (for reference / re-running on the original V3) |
| **01_setup/** | Database initialization scripts |
| ├── create_analytics_schema.sql | Creates analytics schema |
| └── create_metadata_tables.sql | Creates metadata/audit tables + `fn_data_as_of_date()` |
| **02_kpi_queries/** | SQL modules for KPI logic |
| ├── sales_analytics.sql | Sales KPIs |
| ├── product_analytics.sql | Product KPIs |
| ├── customer_analytics.sql | Customer KPIs |
| └── store_analytics.sql | Store KPIs + global refresh function |
| **03_dashboard/** | Complete HTML/CSS/JS dashboard |
| ├── index.html | Main UI |
| ├── dashboard.js | Frontend logic |
| ├── styles.css | Dashboard UI styles |
| └── data/ | Auto-generated JSON files (23 KPIs) |
| **06_documentation/** | Fix log and notes |
| **export_all_json.sh** | Main automation script to export JSON |

# **🏗️ Architecture Overview**

| Layer | Components | Output |
|-------|------------|---------|
| **1. Data Source** | RetailMart V3 tables (core, sales, products, customers, stores, loyalty) | Source data |
| **2. SQL Processing** | Views + Materialized Views | Cleaned & aggregated data |
| **3. Export Layer** | SQL JSON functions | KPI result sets |
| **4. Automation Script** | `export_all_json.sh` | 23 JSON files |
| **5. Data for Dashboard** | `/03_dashboard/data/` | Ready-to-use JSON |
| **6. Frontend Logic** | `dashboard.js` | Charts, KPIs, tables |
| **7. UI Layer** | HTML + CSS + Chart.js | Interactive Dashboard |

# **🚀 Key Features**

### **🔍 SQL-Powered Analytics Engine**

•	16 optimized reporting views
•	8 high-performance materialized views
•	23 JSON export functions acting as mini APIs

### **🔄 Automation & Metadata**
•	One script refreshes all MVs + JSON files
•	Audit + metadata tracking built-in

### **🌐 Lightweight Frontend**
•	Pure HTML, CSS, JavaScript
•	Chart.js visualizations
•	Fast, responsive, and easy to deploy

# **🧮 Executive Summary Dashboard**

🎯 Objective
Provide a high-level overview of the business by displaying key performance indicators (KPIs) such as Revenue, Orders, Customers, and Average Order Value (AOV).
It also highlights monthly trends, category contribution, and top-performing products and customers for a quick understanding of overall business health.

# **📊 Rich Analytics Modules**

## **1️⃣ Sales Analytics**

### **A. Last 30 Days Revenue & Orders**

🎯 Objective
Provide a quick snapshot of revenue and orders generated in the last 30 days to understand short-term business performance.

### **B. Daily Sales Trend**

🎯 Objective

The Daily Sales Trend view visualizes day-by-day sales performance for the most recent period.

### **C. Sales by Day of Week**

🎯 Objective

This view identifies how sales perform across each weekday (Monday–Sunday).  
It helps businesses understand:

- **Which days generate the highest or lowest orders**  
- **How weekends compare to weekdays**  
- **Patterns in customer activity**  
- **Optimal timing for staffing, operations, and marketing campaigns**

### **D. Quarterly Sales Performance**

🎯 Objective

The Quarterly Sales Performance view summarizes sales metrics each quarter to reveal long-term business trends.

## **2️⃣ Product Analytics**

### **A. Top 10 Products by Revenue**

🎯 Objective

Identify top-performing products by combining sales, rating, and inventory metrics to highlight bestsellers, high-rated items, and products with strong demand.

### **B. ABC Classification**

🎯 Objective

This view classifies products into A, B, and C value groups based on their revenue contribution using the Pareto (80–20) principle.

### **C. Product Performance Details**

🎯 Objective

This view provides a consolidated performance profile for every product by combining:
### 🔹 Product-Level Metrics
- Revenue  
- Units sold  
- Selling price  

### 🔹 Category-Level Strength
- Market share  
- Demand patterns  

### 🔹 Brand-Level Performance
- Ranking within the category  
- Customer review quality
  
It enables a unified understanding of which products, categories, and brands contribute most to business performance.

## **3️⃣ Customer Analytics**

### **A. RFM Customer Segmentation**

🎯 Objective

This view segments customers based on Recency, Frequency, and Monetary value to understand their engagement, loyalty, and overall contribution.

### **B. Customer Lifetime Value Distribution**

🎯 Objective

This view builds a complete lifetime profile for every customer by combining purchases, loyalty behavior, and review activity. It calculates total lifetime revenue, order frequency, engagement history, projected annual value, and CLV tiers (Platinum, Gold, Silver, Bronze, Basic), enabling long-term customer value assessment.

### **C. Cohort Retention Analysis**

🎯 Objective

This view measures how long customers continue purchasing after their first order by grouping them into monthly cohorts and tracking retention for up to 12 months. It shows how many customers remain active over time and calculates retention rates to reveal long-term engagement and churn patterns.

### **D. Churn Risk Distribution** 

🎯 Objective

This view identifies customers likely to churn by analyzing inactivity, purchase patterns, and expected buying frequency. It classifies customers into churn risk levels (Active, Low, Medium, High, Critical – High Value) and assigns recommended actions and priority scores to support proactive retention efforts.

## **4️⃣ Store Analytics**

### **A. Top 10 stores by Revenue**

🎯 Objective

This view provides a complete performance overview for every store by combining sales, expenses, and employee metrics. It calculates revenue, profitability, customer reach, workforce cost, and operational efficiency—enabling clear benchmarking and regional performance comparison.

### **B. Regional Performance** 

🎯 Objective

This view provides a high-level summary of each region’s operational and financial performance by aggregating store-level metrics. It highlights regional sales strength, profitability, customer reach, workforce capacity, and efficiency indicators.

### **C. Store Performance Scorecard**

🎯 Objective

This view provides a high-level summary of how each region performs by aggregating store-level metrics. It combines sales, financials, customers, and workforce data to reveal overall regional strength, operational efficiency, and profitability.

# **🏁 How to Run This Project**

## ✅ Prerequisites

- **PostgreSQL** 13+ with `psql` on your PATH
- The database file `00_database/retailmart_v3_kpi.sql` (included).
- **VS Code** with the **Live Server** extension (for "Go Live")
- **Windows users:** run the `.sh` script from **Git Bash** or **WSL**

> 💡 To avoid typing the Postgres password for every query, set it once per terminal:
> `export PGPASSWORD=yourpassword` (Git Bash / Linux / Mac)

## 🔧 Project Setup Overview

| Step | Description | Command / Action |
|------|-------------|------------------|
| **0️⃣ Load the database** | Create the database and load the converted RetailMart V3 data (a few seconds) | ```createdb -U postgres retailmart``` <br><br> ```psql -U postgres -d retailmart -f 00_database/retailmart_v3_kpi.sql``` |
| **1️⃣ Setup the Database** | Create schema and metadata tables | ```psql -U postgres -d retailmart -f 01_setup/create_analytics_schema.sql``` <br><br> ```psql -U postgres -d retailmart -f 01_setup/create_metadata_tables.sql``` |
| **2️⃣ Load KPI Analytics Modules** | Load in this order (store module last — it creates the global refresh function) | ```psql -U postgres -d retailmart -f 02_kpi_queries/sales_analytics.sql``` <br><br> ```psql -U postgres -d retailmart -f 02_kpi_queries/product_analytics.sql``` <br><br> ```psql -U postgres -d retailmart -f 02_kpi_queries/customer_analytics.sql``` <br><br> ```psql -U postgres -d retailmart -f 02_kpi_queries/store_analytics.sql``` |
| **3️⃣ Export KPI JSON Files** | Refresh materialized views + generate 23 JSON files | ```chmod +x export_all_json.sh``` <br><br> ```./export_all_json.sh refresh``` |
| **4️⃣ Launch the Dashboard** | Start frontend dashboard | Open VS Code → **File → Open Folder** → select project → open `03_dashboard/index.html` → click **Go Live** |

Your dashboard will automatically launch in the browser and load KPI data from the JSON files.

> ⚠️ Don't open `index.html` by double-clicking it. Browsers block loading the JSON files from `file://`.
> Use Go Live, or run `python -m http.server` inside `03_dashboard` and open http://localhost:8000.

## ⚙️ Different database name / user?

```bash
DB_NAME=mydb DB_USER=myuser DB_HOST=localhost DB_PORT=5432 ./export_all_json.sh refresh
```

## 📅 About dates

Time-window KPIs ("last 30 days", "last 90 days", recency, churn) are measured from the
**latest delivered order date** in the data (`analytics.fn_data_as_of_date()`), not today's date.
So a historical dataset (e.g. data ending in 2025) still shows a full dashboard. If your data is
live, this is simply today. The header shows the "Data as of" date.

## 🗂️ About the database

`retailmart_v3_kpi.sql` is the RetailMart V3 practice dataset with **no data removed**, reshaped to the
table and column names the KPI queries use. The original `retailmart_v3.sql` is not changed.

| KPI queries use | Comes from in V3 |
|-----------------|------------------|
| `sales.orders.total_amount` | `net_total` (after discount) |
| `sales.order_items.discount` (%) | `discount_amount / (quantity × unit_price) × 100` |
| `products.products.prod_id / prod_name / category / brand` | `product_id`, `product_name`, `dim_brand`, `dim_category` |
| `products.inventory.prod_id / stock_qty` | `product_id`, `quantity_on_hand` |
| `stores.stores.region` | `core.dim_region.region_name` |
| `stores.employees.emp_id`, `stores.departments` | `employee_id`, `core.dim_department` |
| `customers.customers.cust_id / full_name / city / state / join_date` | `customer_id`, first + last name, default address, `registration_date` |
| `customers.customers.gender / age` | ⚠️ **Generated** practice values. V3 has no gender/age. |
| `customers.loyalty_points` | `loyalty.members.points_balance` |
| `core.dim_date.date_key` (DATE), `'Mon'`, `'Jan'` | `full_date`; the int key is kept as `date_id` |

**Things to know about this dataset**

- All money is in **₹ (INR)**. The dashboard shows Indian formatting (lakh/crore).
- **Store profit is negative for most stores.** In this synthetic data, store expenses are larger than delivered revenue.
- `sales.payments` is kept exactly as in V3: 188 delivered orders have no payment row (on purpose, for reconciliation practice), so payment-mode totals are a bit below total revenue.

## 🛠️ Troubleshooting

| Problem | Fix |
|---------|-----|
| `relation "core.dim_date" does not exist` (or similar) | The dataset isn't loaded in `retailmart`. Run step 0. |
| `column ... does not exist` | You loaded the original `retailmart_v3.sql`. Load `retailmart_v3_kpi.sql` instead (or run `convert_v3_to_kpi_layout.sql` on top of it). |
| Dashboard shows an alert / empty charts | Run `./export_all_json.sh refresh` and check `03_dashboard/data/` has 23 files. Open with Go Live, not by double-click. |
| Export says "N export(s) failed" | Open the `export_log_*.log` file. The SQL error is written next to the failed file. |
| `permission denied: ./export_all_json.sh` | `chmod +x export_all_json.sh` |

**This project showcases how SQL alone can power a complete analytics engine—including KPI generation, automated refresh pipelines, JSON APIs, and a fully interactive web dashboard.**
