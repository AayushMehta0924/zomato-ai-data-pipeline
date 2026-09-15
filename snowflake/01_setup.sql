-- =====================================================================
-- Phase 2 · Step 1 — Warehouse, database, schemas, role
-- Run in Snowsight as ACCOUNTADMIN (a worksheet).
-- =====================================================================
-- Only ACCOUNTADMIN can create warehouses, databases and roles.
USE ROLE ACCOUNTADMIN;

-- Compute: extra-small, auto-suspend fast so the trial credits last.
CREATE WAREHOUSE IF NOT EXISTS ZOMATO_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND   = 60
  AUTO_RESUME    = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- Database + medallion schemas.
CREATE DATABASE IF NOT EXISTS ZOMATO;
CREATE SCHEMA  IF NOT EXISTS ZOMATO.BRONZE;    -- Iceberg tables Spark wrote (dbt sources)
CREATE SCHEMA  IF NOT EXISTS ZOMATO.RAW;       -- only used by the COPY fallback path
CREATE SCHEMA  IF NOT EXISTS ZOMATO.STAGING;   -- cleaned / conformed (dbt)
CREATE SCHEMA  IF NOT EXISTS ZOMATO.MARTS;     -- Gold, Iceberg (dbt)
CREATE SCHEMA  IF NOT EXISTS ZOMATO.SNAPSHOTS; -- SCD2 history (dbt)
CREATE SCHEMA  IF NOT EXISTS ZOMATO.AI;        -- LLM-enriched tables (OpenAI jobs)

-- A role dbt/Airflow will use.
CREATE ROLE IF NOT EXISTS DBT_ROLE;
GRANT USAGE   ON WAREHOUSE ZOMATO_WH TO ROLE DBT_ROLE;  -- can select the warehouse to run queries on
GRANT OPERATE ON WAREHOUSE ZOMATO_WH TO ROLE DBT_ROLE;  -- can resume/suspend it (needed for auto-resume)
GRANT ALL     ON DATABASE  ZOMATO    TO ROLE DBT_ROLE;
GRANT ALL     ON ALL SCHEMAS IN DATABASE ZOMATO TO ROLE DBT_ROLE;
-- FUTURE grants so dbt-created schemas/tables/views inherit access automatically,
-- without re-running this script every time a new model is added.
GRANT ALL     ON FUTURE SCHEMAS IN DATABASE ZOMATO TO ROLE DBT_ROLE;
GRANT ALL     ON FUTURE TABLES IN DATABASE ZOMATO TO ROLE DBT_ROLE;
GRANT ALL     ON FUTURE VIEWS  IN DATABASE ZOMATO TO ROLE DBT_ROLE;

-- Let your login use the role (CURRENT_USER() avoids hardcoding a username).
SET my_user = CURRENT_USER();
GRANT ROLE DBT_ROLE TO USER IDENTIFIER($my_user);

-- Sanity check: if this returns a row, everything above ran without error.
SELECT 'setup complete' AS status;