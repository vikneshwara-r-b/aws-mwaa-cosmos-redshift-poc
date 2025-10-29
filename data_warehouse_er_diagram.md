# Data Warehouse ER Diagram

```mermaid
erDiagram
    %% SILVER LAYER - Cleaned and validated data
    stg_sales {
        string product_id PK
        string product_name
        string category
        decimal discounted_price
        decimal actual_price
        decimal discount_percentage
        decimal rating
        int rating_count
        string about_product
        string user_id FK
        string user_name
        string review_id
        string review_title
        string review_content
        string img_link
        string product_link
    }

    %% GOLD LAYER - Business-ready dimension tables
    DIM_PRODUCT {
        string product_id PK
        string product_name
        string category
        string about_product
        string product_link
        string img_link
    }

    DIM_USER {
        string user_id PK
        string user_name
    }

    DIM_RATING {
        string product_id FK
        string user_id FK
        decimal rating
        int rating_count
    }

    %% GOLD LAYER - Business-ready fact tables
    FACT_PRODUCT_RATING {
        string product_id FK
        string product_name
        decimal avg_rating
    }

    FACT_SALES_CATEGORY {
        string user_id FK
        string category
        decimal sales_amount
    }

    %% Relationships - ETL: Silver to Gold Layer
    stg_sales ||--o{ DIM_PRODUCT : "transforms_to"
    stg_sales ||--o{ DIM_USER : "transforms_to"
    stg_sales ||--o{ DIM_RATING : "transforms_to"

    %% Gold Layer Relationships
    DIM_PRODUCT ||--o{ FACT_PRODUCT_RATING : "aggregates_to"
    DIM_USER ||--o{ FACT_SALES_CATEGORY : "aggregates_to"
    DIM_PRODUCT ||--o{ DIM_RATING : "has_ratings"
    DIM_USER ||--o{ DIM_RATING : "provides_ratings"
    DIM_PRODUCT ||--o{ FACT_SALES_CATEGORY : "categorizes"
```

## Medallion Architecture Layers

### 🥈 Silver Layer (Light Blue)
**Purpose**: Cleaned and validated data ready for business consumption
- **stg_sales**: Standardized sales dataset with data quality improvements
  - Contains 17 attributes including product details, pricing, ratings, and user information
  - Data has been cleansed, deduplicated, and standardized from bronze layer
  - Serves as the reliable source for all downstream gold layer transformations

### 🥇 Gold Layer (Light Purple)  
**Purpose**: Business-ready analytical data including both dimensions and facts

**Dimension Tables** - Master data providing context and descriptive attributes:
- **DIM_PRODUCT**: Product master data with unique product information
  - Primary key: product_id
  - Contains curated product catalog information and metadata
- **DIM_USER**: User master data with user identifiers and names
  - Primary key: user_id  
  - Contains validated customer/user profile information
- **DIM_RATING**: Bridge/junction table containing rating information
  - Links products and users through rating transactions
  - Contains both foreign keys: product_id and user_id

**Fact Tables** - Aggregated business metrics and measurable data for analytics:
- **FACT_PRODUCT_RATING**: Product performance metrics focused on ratings
  - Contains aggregated rating data (avg_rating) per product
  - Supports product quality analysis and reporting
- **FACT_SALES_CATEGORY**: Sales performance metrics by category
  - Contains sales amount aggregations by user and product category
  - Supports revenue analysis and customer segmentation

## Data Flow & Relationships
1. **ELT Process**: stg_sales (Silver) feeds data into all Gold layer tables
2. **Star Schema**: Gold dimension tables provide reference data for fact table aggregations
3. **Bridge Pattern**: DIM_RATING acts as a bridge table between DIM_PRODUCT and DIM_USER
4. **Business Intelligence**: All Gold layer tables support analytical queries and reporting

## Visual Legend
- **Light Blue Tables**: Silver layer (cleaned and validated data)
- **Light Purple Tables**: Gold layer (business-ready analytical data - dimensions & facts)
- **Relationship Lines**: Data flow and foreign key relationships
