CREATE VIEW v_rfm_analysis AS
WITH base_rfm AS (
    -- 1. Hitung metrik dasar per pelanggan
    SELECT 
        f.customer_id,
        c.customer_city,
        c.customer_state,
        MAX(f.purchase_date) AS last_purchase_date,
        COUNT(DISTINCT f.order_id) AS frequency,
        SUM(f.payment_value) AS monetary
    FROM fact_sales_clean f
    JOIN olist_customers_dataset c ON f.customer_id = c.customer_id
    GROUP BY f.customer_id, c.customer_city, c.customer_state
),
date_reference AS (
    -- 2. Tentukan tanggal referensi (tanggal transaksi terakhir di dataset)
    -- Agar recency dihitung relatif terhadap periode data, bukan hari ini.
    SELECT MAX(purchase_date) AS reference_date 
    FROM fact_sales_clean
),
rfm_with_recency AS (
    -- 3. Hitung Recency (hari sejak pembelian terakhir)
    SELECT 
        b.*,
        (SELECT reference_date FROM date_reference) - b.last_purchase_date AS recency_days
    FROM base_rfm b
)
-- 4. Segmentasi Pelanggan menggunakan Dynamic Thresholding (Percentiles)
SELECT 
    *,
    CASE 
        -- Champions: Belanja banyak (Top 25%) DAN baru belanja (Bottom 25% recency)
        WHEN monetary >= (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monetary) FROM rfm_with_recency)
             AND recency_days <= (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency_days) FROM rfm_with_recency)
        THEN 'Champions'
        
        -- At Risk: Belanja banyak (Top 25%) TAPI sudah lama tidak belanja (Top 75% recency)
        WHEN monetary >= (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monetary) FROM rfm_with_recency)
             AND recency_days > (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency_days) FROM rfm_with_recency)
        THEN 'At Risk'
        
        -- New Customers: Belanja sedikit (Bottom 75%) TAPI baru belanja (Bottom 25% recency)
        WHEN monetary < (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monetary) FROM rfm_with_recency)
             AND recency_days <= (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency_days) FROM rfm_with_recency)
        THEN 'New Customers'
        
        -- Lost: Belanja sedikit DAN sudah lama tidak belanja
        ELSE 'Lost'
    END AS customer_segment
FROM rfm_with_recency;
