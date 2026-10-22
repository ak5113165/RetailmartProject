# Fix Log

Changes made to the original project files, and why. Everything was tested end to end on the
RetailMart V3 dataset (`retailmart_v3.sql`): SQL modules, JSON export and dashboard.

## RetailMart V3 database

The KPI queries were **not** changed for V3. Instead, `00_database/retailmart_v3_kpi.sql` reshapes the
V3 data into the layout the queries expect (see `convert_v3_to_kpi_layout.sql` for every step).

- Columns renamed where the meaning is the same (foreign keys follow automatically).
- Columns/tables added where the queries need them: `orders.total_amount`, `order_items.discount` (%),
  `products.category/brand`, `stores.region`, `stores.departments`, `customers.full_name/city/state/join_date/gender/age`,
  `customers.loyalty_points`.
- `gender` and `age` are generated (hash of the customer id, so they're the same on every load). V3 has no such data.
- Everything else in V3 (finance, hr, marketing, support, ... 16 schemas) is unchanged.
- The file uses plain INSERTs, so it runs in `psql` and in pgAdmin's Query Tool.

Verified: loaded twice into a fresh database (re-runnable). The unchanged KPI modules run with no errors.
Every revenue view totals ₹33,70,90,499.83, the sum of `net_total` for Delivered orders in the
original V3 file. Recomputing line revenue from the new discount % reproduces `net_amount` exactly on all line items.

---

## Earlier fixes (original project)

## SQL — wrong numbers

| # | Where | Problem | Fix |
|---|-------|---------|-----|
| 1 | `vw_daily_sales_summary`, `mv_monthly_sales_dashboard`, `vw_quarterly_sales` (sales) | `orders` was joined straight to `order_items`, so `SUM(total_amount)` repeated once per line item. Revenue came out **~4x too high** (25.6M vs the real 6.4M on test data). AOV and order-based averages were also skewed. | `order_items` is aggregated per order first, then joined. |
| 2 | `mv_customer_lifetime_value` (customer) | Same double counting, so lifetime revenue, AOV and **CLV tiers** were calculated on inflated revenue and pushed customers into higher tiers. | Same fix. |
| 3 | `vw_brand_performance` (product) | Reviews were joined to order items, which multiplied revenue and review counts by each other (one brand showed 405,912 "reviews" on test data). | Sales and reviews aggregated separately, then joined. |
| 4 | Product module (`mv_top_products`, `vw_category_performance`, `mv_abc_analysis`, brands) | Counted **cancelled and pending** orders as revenue, while the sales module counts only Delivered, so the tabs didn't agree. | Only `Delivered` orders are counted, same as the sales module. |

All revenue views now total exactly the same as `SUM(total_amount)` of delivered orders.

## SQL — limits that did nothing

`LIMIT` written after `json_agg(...)` limits the one output row, not the rows being aggregated. So:

| Function | Promised | Actually returned (test data) |
|----------|----------|------------------|
| `get_top_customers_json` | top 50 | 1,994 |
| `get_churn_risk_json` → highPriorityCustomers | top 20 | 151 |
| `get_brand_performance_json` | top 20 | 24 |
| `get_monthly_trend_json` | 12 months | 13 |
| `get_quarterly_sales_json` | 8 quarters | 9 |
| `get_geography_json` | top 50 | all |

Fixed by moving `ORDER BY ... LIMIT n` into a subquery.

## SQL — dates

| Problem | Fix |
|---------|-----|
| `vw_recent_sales_trend` said "last 30 days" but used **156 days** (likely a workaround because the dataset ended months ago). It also included empty future dates from `dim_date`. | Exactly 30 days, and the 7-day moving average is computed before filtering so the first days are correct. |
| All "last N days" logic used `CURRENT_DATE`. With a historical dataset every customer looks churned and "last 30 days" is empty. | New `analytics.fn_data_as_of_date()` = latest delivered order date. Used for last 30/60/90 days, today/7-day summary, recency, churn and CLV status. |

## Export script (`export_all_json.sh`)

- psql errors were written **into** the `.json` file, which then crashed the dashboard. Errors now go to the log and the terminal.
- The refresh step checked `tee`'s exit code instead of `psql`'s, so a failed refresh still printed "success". It now checks psql and any `FAILED` module rows.
- It always printed "All JSON files exported successfully!" even when some failed. It now counts failures and exits non-zero.
- DB name/user/host/port can be overridden with environment variables.
- Works when called from any folder.
- Keeps only the last 3 `data_backup_*` folders.
- File counts corrected (customers module has 7 functions, 23 total).

## Dashboard

- **Cohort Retention chart showed hardcoded fake numbers.** `cohort_retention.json` was exported but never loaded. The chart now shows real average retention for months 1–12.
- The "+12.5% vs last month" style badges on the KPI cards were **hardcoded text**. They now show the real 30-day revenue growth plus real context numbers.
- The header showed the browser's clock as "Last Updated". It now shows the data's as-of date and the export timestamp.
- ABC pie colours depended on JSON key order, so "C - Low Value" could show green and "A - High Value" red. Sorted and colour-mapped by class.
- Churn chart had 4 colours for up to 6 risk levels. Each level now has its own colour.
- Tab buttons relied on the global `event` object (not reliable in all browsers). The button is now passed in explicitly, and charts resize when their tab opens.
- Daily chart dates could shift by a day in some time zones. Fixed.
- Added a "Reload" button, a clear message when the page is opened by double-click (`file://`), and no-cache fetches so a fresh export always shows.
