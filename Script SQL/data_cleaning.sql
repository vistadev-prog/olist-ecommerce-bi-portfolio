-- 1. MEMBUAT FACT TABLE (TABEL FAKTA PENJUALAN)
CREATE TABLE fact_sales_clean AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    -- Konversi timestamp menjadi Date saja untuk kemudahan analisis harian
    CAST(o.order_purchase_timestamp AS DATE) AS purchase_date,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS purchase_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS purchase_month,
    
    -- Mengambil nilai pembayaran (menggunakan payment_sequential = 1 untuk menghindari duplikasi)
    p.payment_value,
    p.payment_type,
    p.payment_installments
    
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE 
    o.order_status = 'delivered' -- Fokus hanya pada pesanan yang sukses terkirim
    AND p.payment_sequential = 1; -- Ambil record pembayaran pertama per order

-- Tambahkan Primary Key agar tabel ini bisa di-relasikan nanti di Power BI
ALTER TABLE fact_sales_clean ADD PRIMARY KEY (order_id);

-- 2. MEMBUAT DIMENSION TABLE (TABEL KALENDER/WAKTU)
CREATE TABLE dim_date AS
SELECT 
    DISTINCT CAST(order_purchase_timestamp AS DATE) AS date_key,
    EXTRACT(DAY FROM order_purchase_timestamp) AS day,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    TO_CHAR(order_purchase_timestamp, 'Month') AS month_name,
    TO_CHAR(order_purchase_timestamp, 'Day') AS day_name,
    EXTRACT(DOW FROM order_purchase_timestamp) AS day_of_week_num,
    EXTRACT(QUARTER FROM order_purchase_timestamp) AS quarter
FROM olist_orders_dataset
ORDER BY date_key;

ALTER TABLE dim_date ADD PRIMARY KEY (date_key);

-- ==========================================
-- VIEW 1: Performa Kategori Produk
-- Digunakan untuk visualisasi Top 10 Categories
-- ==========================================
CREATE OR REPLACE VIEW v_category_performance AS
SELECT 
    p.product_category_name AS category_name,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price)::numeric, 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered' -- Hanya hitung pesanan yang sukses sampai
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- ==========================================
-- VIEW 2: Analisis Keterlambatan Pengiriman
-- Digunakan untuk korelasi Delivery vs Review Score
-- ==========================================
CREATE OR REPLACE VIEW v_delivery_delay AS
SELECT 
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    -- Hitung selisih hari (positif = telat, negatif = datang lebih cepat)
    EXTRACT(DAY FROM (order_delivered_customer_date - order_estimated_delivery_date)) AS delay_days
FROM olist_orders_dataset
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL;
