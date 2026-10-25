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
