# End-to-End Data Pipeline for E-commerce Analytics

Module 2 Assignment Project - ELT Pipeline with Meltano, dbt, and Dagster

## Overview

This project implements a comprehensive end-to-end data pipeline and analysis workflow for an e-commerce company using the Olist Brazilian E-commerce dataset. The pipeline follows the modern ELT (Extract, Load, Transform) approach, extracting raw data from CSV files, loading them into BigQuery data warehouse, transforming the data using dbt, orchestrating the workflow with Dagster, and conducting analysis in Python.

## Architecture

```
Raw CSV Data → Meltano (Extract & Load) → BigQuery → dbt (Transform) → Dagster (Orchestrate) → Analysis
```

## Tech Stack

- **Extract & Load**: Meltano with tap-csv and target-bigquery
- **Data Warehouse**: Google BigQuery
- **Transform**: dbt (data build tool)
- **Orchestration**: Dagster
- **Analysis**: Python with Jupyter notebooks
- **Version Control**: Git

## Project Structure

```
.
├── README.md                    # This file
├── environment.yml              # Conda environment configuration
├── requirements.txt             # Python dependencies
├── data/                       # Raw CSV datasets
│   ├── olist_customers_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_sellers_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── product_category_name_translation.csv
│   └── olist_products_dataset.csv
|     
├── meltano-ingestion/          # Meltano configuration for data ingestion
│   └── meltano.yml
├── dbt_project/                # dbt transformations
│   ├── models/
│   │   ├── staging/            # Staging models (data cleaning)
│   │   └── marts/              # Data marts (analytics-ready tables)
│   └── dbt_project.yml
├── dagster_orchestration/      # Dagster orchestration
│   └── orchestration_pipeline/
├── notebooks/                  # Analysis notebooks
│   └── clv_analysis.ipynb     # Customer Lifetime Value analysis
└── .keys/                      # GCP service account keys (not in git)
```

## Setup Instructions

### 1. Environment Setup

1. **Create and activate conda environment:**
   ```bash
   conda env update -f environment.yml
   conda activate elt
   ```

2. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Setup Google Cloud Platform:**
   - Create a GCP project
   - Enable BigQuery API
   - Create a service account with BigQuery permissions
   - Download service account key and place in `.keys/gcp-key.json`
   - Authenticate with gcloud CLI:
     ```bash
     gcloud auth application-default login
     ```

### 2. Data Ingestion Setup (Meltano)

1. **Navigate to Meltano directory:**
   ```bash
   cd meltano-ingestion
   ```

2. **Configure Meltano** (already configured in `meltano.yml`):
   - Extractor: `tap-csv` for reading CSV files
   - Loader: `target-bigquery` for loading to BigQuery
   - Source files: Olist e-commerce dataset CSVs
   - Target: BigQuery project `meltano-learn-2025`, dataset `project`

3. **Run data ingestion:**
   ```bash
   meltano run tap-csv target-bigquery
   ```

### 3. Data Transformation Setup (dbt)

1. **Navigate to dbt project:**
   ```bash
   cd dbt_project
   ```

2. **Configure dbt profile** (ensure BigQuery connection is set up)

3. **Install dbt dependencies:**
   ```bash
   dbt deps
   ```

4. **Run dbt transformations:**
   ```bash
   # Run staging models
   dbt run --select path:models/staging/
   
   # Run data quality tests
   dbt test --select path:models/staging/
   
   # Run marts models
   dbt run --select path:models/marts/
   ```

### 4. Orchestration Setup (Dagster)

1. **Navigate to Dagster orchestration:**
   ```bash
   cd dagster_orchestration/orchestration_pipeline
   ```

2. **Install Dagster dependencies:**
   ```bash
   pip install -e ["dev"]
   ```

3. **Start Dagster UI:**
   ```bash
   dagster dev
   ```

4. **Access Dagster UI** at `http://localhost:3000`

## Data Pipeline Details

### 1. Extract & Load (Meltano)

**Purpose**: Extract data from CSV files and load into BigQuery

**Configuration** (`meltano-ingestion/meltano.yml`):
- **Extractor**: `tap-csv` reads from local CSV files
- **Entities ingested**:
  - `olist_customers`
  - `olist_order_items`
  - `olist_order_payments`
  - `olist_products`
  - `olist_geolocation`
  - `olist_order_reviews`
  - `olist_sellers`
  - `product_category_name_translation`
  - `olist_orders`
- **Loader**: `target-bigquery` loads to BigQuery
- **Target**: BigQuery project [GCP Project ID], dataset `olist_data`

### 2. Transform (dbt)

**Purpose**: Clean, standardize, and model data for analytics

#### Staging Models (Data Cleaning)
Location: `dbt_project/models/staging/`

- **`stg_customers.sql`**: Clean customer data with standardized locations
- **`stg_order_items.sql`**: Clean order items with validated prices
- **`stg_order_payments.sql`**: Clean payment data
- **`stg_orders.sql`**: Clean order data
- **`stg_products.sql`**: Clean product data

**Data Quality Tests** (`staging/schema.yml`):
- Null value checks
- Unique constraint validations
- Accepted value ranges
- State code validations
- Price range validations

#### Data Marts (Analytics-Ready Tables)
Location: `dbt_project/models/marts/`

- **`fact_orders.sql`**: Central fact table combining orders, items, payments, and customers
- **`dim_customers.sql`**: Customer dimension table
- **`dim_products.sql`**: Product dimension table
- **`dim_dates.sql`**: Date dimension table

### 3. Orchestration (Dagster)

**Purpose**: Orchestrate the dbt transformation pipeline with proper dependencies

**Assets** (`dagster_orchestration/orchestration_pipeline/orchestration_pipeline/assets.py`):

1. **`run_dbt_staging`**: Execute staging models
2. **`run_dbt_tests`**: Run data quality tests (depends on staging)
3. **`run_dbt_marts`**: Execute marts models (depends on tests passing)

**Dependency Flow**:
```
run_dbt_staging → run_dbt_tests → run_dbt_marts
```

### 4. Analysis (Python)

**Purpose**: Perform business analytics and generate insights

**Notebook**: `notebooks/clv_analysis.ipynb`
- Customer Lifetime Value (CLV) analysis
- Customer segmentation
- Business insights and visualizations

## Data Model

### Source Tables (BigQuery)
- `olist_customers`: Customer master data
- `olist_order_items`: Order line items
- `olist_order_payments`: Payment transactions
- `olist_orders`: Order master data
- `olist_products`: Product catalog

### Staging Tables (Views)
- `stg_customers`: Cleaned customer data
- `stg_order_items`: Cleaned order items
- `stg_order_payments`: Cleaned payments
- `stg_orders`: Cleaned orders
- `stg_products`: Cleaned products

### Analytics Tables (Tables)
- `fact_orders`: Central fact table for order analysis
- `dim_customers`: Customer dimension
- `dim_products`: Product dimension
- `dim_dates`: Date dimension

## Data Quality & Testing

### dbt Tests
- **Not null tests**: Ensure critical fields are not null
- **Unique tests**: Validate primary key uniqueness
- **Accepted values**: Validate state codes and categories
- **Range tests**: Ensure prices and quantities are within valid ranges

### Pipeline Validation
- Dagster orchestration ensures tests pass before proceeding to marts
- Failed tests stop the pipeline execution
- Comprehensive logging for debugging

## Running the Complete Pipeline

### Option 1: Manual Execution
```bash
# 1. Ingest data
cd meltano-ingestion
meltano run tap-csv target-bigquery

# 2. Transform data
cd ../dbt_project
dbt run --select path:models/staging/
dbt test --select path:models/staging/
dbt run --select path:models/marts/

# 3. Run analysis
cd ../notebooks
jupyter notebook clv_analysis.ipynb
```

### Option 2: Orchestrated Execution (Recommended)
```bash
# Start Dagster UI
cd dagster_orchestration/orchestration_pipeline
dagster dev

# Access UI at http://localhost:3000
# Trigger asset materialization for the complete pipeline
```

## Key Features

1. **Modern ELT Architecture**: Extract-Load-Transform approach using cloud data warehouse
2. **Data Quality**: Comprehensive testing at every stage
3. **Orchestration**: Proper dependency management and error handling
4. **Scalability**: Cloud-based infrastructure (BigQuery)
5. **Modularity**: Separate concerns for ingestion, transformation, and orchestration
6. **Documentation**: Self-documenting pipeline with dbt docs
7. **Version Control**: Git-based development workflow

## Next Steps

1. **Monitoring**: Add data quality monitoring and alerting
2. **CI/CD**: Implement automated testing and deployment
3. **Scheduling**: Add production scheduling for regular pipeline runs
4. **More Analytics**: Extend analysis to cover additional business metrics
5. **Data Catalog**: Implement data catalog for better data discovery

## Troubleshooting

### Common Issues

1. **BigQuery Authentication**: Ensure service account key is properly configured
2. **dbt Connection**: Verify dbt profile is set up correctly for BigQuery
3. **Meltano Errors**: Check file paths and permissions for CSV files
4. **Dagster Issues**: Ensure all dependencies are installed and paths are correct

### Logs
- Meltano logs: `meltano-ingestion/logs/`
- dbt logs: `dbt_project/logs/`
- Dagster logs: Available in Dagster UI

## Contributors

This project was built as part of the SCTP Data Science & AI Module 2 assignment, demonstrating modern data engineering practices and tools.

