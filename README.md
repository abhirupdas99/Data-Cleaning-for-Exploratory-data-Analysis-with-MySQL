# World Layoffs Data Cleaning

End-to-end data cleaning workflow for the World Layoffs dataset using MySQL 8.0+, preparing the data for Exploratory Data Analysis (EDA).

## Repository Structure

```
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
```

## Project Overview

This project performs a full data cleaning pipeline on a real-world layoffs dataset, covering:

1. **Staging Table Creation** – Raw data is copied into a staging table to preserve the original.
2. **Duplicate Removal** – Window functions (`ROW_NUMBER()`) identify and remove exact duplicate records.
3. **Data Standardization** – Trims whitespace, normalises industry names (e.g. `Crypto%` → `Crypto`), standardises country names, and converts the `date` column from `TEXT` to `DATE`.
4. **Missing Value Handling** – Fills missing `industry` values via a self-join on `company`, removes records where both `total_laid_off` and `percentage_laid_off` are `NULL`, and sets missing `stage` values to `Unknown`.
5. **Final Dataset Export** – The cleaned table is exported to `layoffs_cleaned.csv` for downstream EDA.

## Files

| File | Description |
|------|-------------|
| `sql/world_layoffs_cleaning.sql` | Full MySQL cleaning script |
| `data/layoffs.csv` | Raw layoffs dataset (2,361 records) |
| `data/layoffs_cleaned.csv` | Cleaned dataset ready for EDA (1,995 records) |

## Requirements

- MySQL 8.0+
- The `secure_file_priv` variable must point to an accessible upload directory for `LOAD DATA INFILE` / `INTO OUTFILE` operations.

## Usage

1. Open `sql/world_layoffs_cleaning.sql` in MySQL Workbench or any MySQL client.
2. Update the file paths in the `LOAD DATA INFILE` and `INTO OUTFILE` statements to match your system's `secure_file_priv` directory.
3. Execute the script sequentially from top to bottom.
4. The cleaned data will be available in the `layoffs_staged_unique` table and exported to `layoffs_cleaned.csv`.

## Author

**Abhirup Das**
