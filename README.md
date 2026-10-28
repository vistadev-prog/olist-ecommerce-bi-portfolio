# olist-ecommerce-bi-portfolio
End-to-end BI Dashboard for E-Commerce Customer Segmentation (RFM Analysis) using PostgreSQL and Power BI.
![Dashboard Preview](dashboard-1.jpg)
![Dashboard Preview](dashboard-2.jpg)

## 📊 E-Commerce Customer Intelligence Dashboard

### 📌 Project Overview
This dashboard analyzes e-commerce transaction data (Olist) to identify customer behavior patterns and maximize retention. It utilizes a modified RFM (Recency, Frequency, Monetary) approach adapted into 2D segmentation, specifically designed to address the dataset's characteristic of being dominated by *one-time buyers*.

### 🛠️ Tech Stack
- **Database**: PostgreSQL (Star Schema Modeling, Data Cleaning)
- **BI Tool**: Power BI (DAX, Data Modeling, Interactive Visuals)
- **Analysis**: SQL (CTEs, Window Functions, Percentiles)

### 💡 Key Business Insights
1. **Critical Retention Issue**: 56% of customers are classified as "Lost" (inactive & low monetary value).
2. **Hidden Revenue Opportunity**: The "At Risk" segment (18% of customers) contributes the highest revenue but has been inactive for >300 days. This is the primary target for *re-engagement* campaigns.
3. **Growth Trend**: The business shows consistent growth with a significant spike in Q4 2017.

### 🚀 How to Use
1. Clone this repository.
2. Run the SQL scripts in schema.sql and rfm_analysis.sql on your PostgreSQL database.
3. Impor the dataset from [Kaggle Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
4. Open the .pbix file in Power BI Desktop and connect it to your local database.
