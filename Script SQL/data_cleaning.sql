CREATE DATABASE olist_db;

-- 1. Tabel Pelanggan (Customers)
CREATE TABLE olist_customers_dataset (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
);

-- 2. Tabel Geolokasi (Geolocation)
CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

-- 3. Tabel Penjual (Sellers)
CREATE TABLE olist_sellers_dataset (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
);

-- 4. Tabel Produk (Products)
CREATE TABLE olist_products_dataset (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 5. Tabel Kategori Produk
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50)
);

-- 6. Tabel Pesanan (Orders) - Ini akan menjadi 'Fact Table' utama
CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 7. Tabel Item Pesanan (Order Items)
CREATE TABLE olist_order_items_dataset (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date TIMESTAMP,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id)
);

-- 8. Tabel Pembayaran (Order Payments)
CREATE TABLE olist_order_payments_dataset (
    order_id VARCHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential)
);

-- 9. Tabel Ulasan (Order Reviews)
CREATE TABLE olist_order_reviews_dataset (
    review_id VARCHAR(32) PRIMARY KEY,
    order_id VARCHAR(32),
    review_score INT,
    review_comment_title VARCHAR(100),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);
