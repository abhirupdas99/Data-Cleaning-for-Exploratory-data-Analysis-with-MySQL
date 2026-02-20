📌 Project Overview

This project demonstrates an end-to-end data cleaning workflow using MySQL 8.0, transforming raw layoff data into a structured, analysis-ready dataset.

The objective was to build a production-style cleaning pipeline including:

Raw data ingestion from CSV

Staging table creation

Duplicate removal using window functions

Data standardization

Missing value handling

Final dataset export for exploratory data analysis (EDA)

This project simulates a real-world data engineering workflow for preparing messy datasets before analytics or dashboard development.

🛠 Tech Stack

MySQL 8.0+

SQL Window Functions (ROW_NUMBER())

CSV Import / Export (LOAD DATA INFILE, INTO OUTFILE)

Data Cleaning & Transformation Techniques

📂 Repository Structure
world-layoffs-data-cleaning/
│
├── sql/
│   └── world_layoffs_cleaning.sql
│
├── data/
│   ├── layoffs.csv
│   └── layoffs_cleaned.csv
│
├── README.md
└── LICENSE
🔄 Data Cleaning Workflow
1️⃣ Database Setup

Created a new database: layoffs

Defined raw table schema

Loaded CSV data using LOAD DATA INFILE

Cleaned special characters in numeric fields during ingestion

LOAD DATA INFILE 'layoffs.csv'
INTO TABLE layoffs
...
2️⃣ Staging Table Creation

To protect the original dataset:

Created a staging table (layoffs_staged)

Copied raw data into the staging layer

This mirrors real-world ETL best practices where raw data remains untouched.

3️⃣ Duplicate Removal Using Window Functions

Used ROW_NUMBER() with PARTITION BY across all columns to detect full-row duplicates:

ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, ...
)

Removed records where row_num > 1

Dropped helper column after cleanup

✔ Demonstrates practical use of window functions in data engineering.

4️⃣ Data Standardization

Performed multiple normalization steps:

✅ Trimmed whitespace

TRIM() applied to text columns

✅ Standardized industry labels

Consolidated variations like Crypto* → Crypto

Converted 'unknown' → NULL

✅ Standardized country names

Unified variations of "United States" into one value

✅ Converted date format

Converted from TEXT to proper DATE type using:

STR_TO_DATE(date, '%m/%d/%Y')
5️⃣ Missing Value Handling
🔹 Industry Imputation

Filled missing industry values using self-join based on company name.

UPDATE t1
JOIN t2
ON t1.company = t2.company
🔹 Removed Invalid Rows

Deleted records where both:

total_laid_off IS NULL

percentage_laid_off IS NULL

🔹 Standardized stage column

Replaced NULL or blank stage values with 'Unknown'

6️⃣ Final Cleanup & Export

Dropped temporary helper columns

Verified no duplicate rows remain

Exported cleaned dataset to CSV:

INTO OUTFILE 'layoffs_cleaned.csv'

✔ Final table: layoffs_staged_unique
✔ Ready for EDA, dashboards, or further modeling

📊 Data Schema
Column	Description
company	Company name
location	City/Region
industry	Industry classification
total_laid_off	Number of employees laid off
percentage_laid_off	Layoff percentage
date	Layoff date (converted to DATE type)
stage	Company funding stage
country	Country
funds_raised_millions	Total funding raised
🚀 Key SQL Concepts Demonstrated

Window functions (ROW_NUMBER())

Safe update mode handling

Data normalization

Self-joins for imputation

Type conversion

File import/export operations

Data validation & duplicate auditing

💼 Business & Engineering Relevance

This project demonstrates:

Real-world ETL mindset

Data quality control techniques

Production-style staging workflows

Structured problem-solving in SQL

Reproducible cleaning pipelines

This cleaned dataset can now be used for:

Layoff trend analysis

Industry-level impact studies

Geographic analysis

Time-series insights

Dashboard visualization (Tableau / Power BI)

🔮 Future Improvements

Add data validation checks using constraints

Automate cleaning process via stored procedures

Add logging table for cleaning steps

Convert into scheduled ETL job

Build dashboard from cleaned dataset

▶ How to Run

Install MySQL 8.0+

Enable secure_file_priv

Place layoffs.csv inside the permitted upload directory

Run the SQL script:

SOURCE world_layoffs_cleaning.sql;

Cleaned dataset will be exported as:

layoffs_cleaned.csv
👨‍💻 Author

Abhirup Das
Computer Science Graduate | Data & Analytics Enthusiast
GitHub: (add link)
LinkedIn: (add link)
