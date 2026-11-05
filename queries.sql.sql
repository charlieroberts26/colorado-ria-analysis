-- =====================================================
-- Colorado Independent Wealth Management Industry Analysis
-- Objective: Describe Colorado's SEC-registered investment advisory firms and identify which firms that offer financial planning are growing.
-- =====================================================


-- =====================================================
-- 1. Data Validation
-- =====================================================

-- Do row counts match the source files, and did assets and dates import correctly?

SELECT
    snapshot,
    COUNT(*) AS firms,
    SUM(aum_total = 0) AS firms_with_zero_aum,
    MIN(latest_adv_date) AS earliest_filing,
    MAX(latest_adv_date) AS latest_filing
FROM ria_snapshot
GROUP BY snapshot;


-- =====================================================
-- 2. Location and Size Analysis
-- =====================================================

-- Where are Colorado's firms and how big are they?

SELECT
    city,
    COUNT(*) AS firms,
    ROUND(SUM(aum_total) / 1000000000, 1) AS total_aum_billions,
    ROUND(AVG(employees_total)) AS avg_employees
FROM ria_snapshot
WHERE snapshot = '2026-11'
GROUP BY city
ORDER BY firms DESC
LIMIT 15;


-- =====================================================
-- 3. Financial Planning Analysis
-- =====================================================

-- How do firms that offer financial planning differ from those that don't?

SELECT
    offers_financial_planning,
    COUNT(*) AS firms,
    ROUND(AVG(aum_total) / 1000000) AS avg_aum_millions,
    ROUND(AVG(employees_total)) AS avg_employees,
    ROUND(100 * AVG(fee_hourly = 'Y')) AS pct_hourly,
    ROUND(100 * AVG(fee_fixed = 'Y')) AS pct_fixed_fee,
    ROUND(100 * AVG(fee_performance = 'Y')) AS pct_performance_fee,
    ROUND(100 * AVG(clients_individual + clients_hnw > 0)) AS pct_serving_individuals
FROM ria_snapshot
WHERE snapshot = '2026-11'
GROUP BY offers_financial_planning;


-- What is the median firm size in each group?
-- MySQL has no MEDIAN function, so firms are numbered in order of size and the middle firm is selected.

WITH ranked_firms AS (

SELECT
    offers_financial_planning,
    aum_total,
    ROW_NUMBER() OVER(PARTITION BY offers_financial_planning ORDER BY aum_total) AS row_num,
    COUNT(*) OVER(PARTITION BY offers_financial_planning) AS firm_count
FROM ria_snapshot
WHERE snapshot = '2026-11')

SELECT
    offers_financial_planning,
    ROUND(AVG(aum_total) / 1000000) AS median_aum_millions
FROM ranked_firms
WHERE row_num IN (FLOOR((firm_count + 1) / 2), CEIL((firm_count + 1) / 2))
GROUP BY offers_financial_planning;


-- =====================================================
-- 4. Fee Structure Analysis
-- =====================================================

-- How do fee structures change with firm size?

WITH sized_firms AS (

SELECT
    *,
    CASE
        WHEN aum_total < 500000000 THEN '1. Under $500M'
        WHEN aum_total < 2000000000 THEN '2. $500M-$2B'
        ELSE '3. Over $2B'
    END AS size_band
FROM ria_snapshot
WHERE snapshot = '2026-11')

SELECT
    size_band,
    COUNT(*) AS firms,
    ROUND(100 * AVG(fee_pct_of_aum = 'Y')) AS pct_aum_fee,
    ROUND(100 * AVG(fee_hourly = 'Y')) AS pct_hourly,
    ROUND(100 * AVG(fee_fixed = 'Y')) AS pct_fixed_fee,
    ROUND(100 * AVG(fee_performance = 'Y')) AS pct_performance_fee,
    ROUND(100 * AVG(offers_financial_planning = 'Y')) AS pct_financial_planning
FROM sized_firms
GROUP BY size_band
ORDER BY size_band;


-- =====================================================
-- 5. Growth Analysis
-- =====================================================

-- How many firms grew or shrank between the two snapshots?
-- Only firms that filed updated figures in between are counted.

WITH paired_snapshots AS (

SELECT
    crd,
    snapshot,
    aum_total,
    latest_adv_date,
    LAG(aum_total) OVER(PARTITION BY crd ORDER BY snapshot) AS prev_aum,
    LAG(latest_adv_date) OVER(PARTITION BY crd ORDER BY snapshot) AS prev_filing
FROM ria_snapshot),

firm_growth AS (

SELECT
    crd,
    latest_adv_date,
    prev_filing,
    ROUND(100 * (aum_total - prev_aum) / prev_aum, 1) AS aum_growth_pct
FROM paired_snapshots
WHERE snapshot = '2026-11'
    AND prev_aum > 0
    AND aum_total > 0)

SELECT
    COUNT(*) AS firms_compared,
    SUM(aum_growth_pct > 0) AS firms_grew,
    SUM(aum_growth_pct < 0) AS firms_shrank
FROM firm_growth
WHERE latest_adv_date <> prev_filing;


-- Which firms under $5 billion grew the fastest?

WITH paired_snapshots AS (

SELECT
    crd,
    firm_name,
    city,
    snapshot,
    offers_financial_planning,
    aum_total,
    LAG(aum_total) OVER(PARTITION BY crd ORDER BY snapshot) AS prev_aum
FROM ria_snapshot)

SELECT
    firm_name,
    city,
    offers_financial_planning,
    ROUND(prev_aum / 1000000) AS jan_aum_millions,
    ROUND(aum_total / 1000000) AS nov_aum_millions,
    ROUND(100 * (aum_total - prev_aum) / prev_aum, 1) AS aum_growth_pct,
    RANK() OVER(ORDER BY (aum_total - prev_aum) / prev_aum DESC) AS growth_rank
FROM paired_snapshots
WHERE snapshot = '2026-11'
    AND prev_aum > 0
    AND aum_total > 0
    AND aum_total < 5000000000
ORDER BY growth_rank
LIMIT 15;


-- Which growing firms offer financial planning?

WITH paired_snapshots AS (

SELECT
    crd,
    firm_name,
    city,
    snapshot,
    offers_financial_planning,
    aum_total,
    employees_total,
    LAG(aum_total) OVER(PARTITION BY crd ORDER BY snapshot) AS prev_aum,
    LAG(employees_total) OVER(PARTITION BY crd ORDER BY snapshot) AS prev_employees
FROM ria_snapshot)

SELECT
    firm_name,
    city,
    ROUND(prev_aum / 1000000) AS jan_aum_millions,
    ROUND(aum_total / 1000000) AS nov_aum_millions,
    ROUND(100 * (aum_total - prev_aum) / prev_aum, 1) AS aum_growth_pct,
    employees_total,
    employees_total - prev_employees AS employee_change
FROM paired_snapshots
WHERE snapshot = '2026-11'
    AND offers_financial_planning = 'Y'
    AND prev_aum > 0
    AND aum_total > prev_aum
    AND aum_total < 5000000000
ORDER BY aum_growth_pct DESC
LIMIT 20;


-- =====================================================
-- 6. Firm Entry and Exit Analysis
-- =====================================================

-- Which firms joined or left the Colorado list between the two snapshots?

SELECT
    'joined' AS change_type,
    n.firm_name,
    n.city,
    ROUND(n.aum_total / 1000000) AS aum_millions,
    n.offers_financial_planning
FROM ria_snapshot AS n
LEFT JOIN ria_snapshot AS o
    ON o.crd = n.crd
    AND o.snapshot = '2026-01'
WHERE n.snapshot = '2026-11'
    AND o.crd IS NULL

UNION ALL

SELECT
    'left' AS change_type,
    o.firm_name,
    o.city,
    ROUND(o.aum_total / 1000000) AS aum_millions,
    o.offers_financial_planning
FROM ria_snapshot AS o
LEFT JOIN ria_snapshot AS n
    ON n.crd = o.crd
    AND n.snapshot = '2026-11'
WHERE o.snapshot = '2026-01'
    AND n.crd IS NULL
ORDER BY change_type, aum_millions DESC;
