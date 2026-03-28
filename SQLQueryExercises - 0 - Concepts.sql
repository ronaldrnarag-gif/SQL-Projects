/* Review 

SQL-Playbook/
   window-functions.sql
   ranking-patterns.sql
   date-dimension.sql
   performance-tests.sql

-- Common Data Types 
-- Variables (simple and table variable declarations, declare multiple variables in 1 line, set separately)
-- Temporary Table # and ## Global
-- Grouping Sets, Rollup, cube
-- Recursive CTE's
-- Conditional Aggregation or Pivot and Unpivot concept (sum(case when..))
-- Window Functions (row_number, over (), rank, dense_rank, lag, lead, partition by, order by, rows between..), (cummulative balances, %contributions)
-- Derived Tables and Subqueries
-- TopN (using subsequery or CTE)
-- Joins (INNER, LEFT, RIGHT, FULL OUTER, CROSS, and self joins). 
-- Exists, Not Exists (anti-join and semi join)
-- Order by 1, or Select 1
-- ; and GO

***/

/*New Concepts
-- Date/time manipulation — DATE_TRUNC, DATEDIFF, DATEADD, EXTRACT
-- Grouping_ID
-- Any Operator
-- Execution Plans
-- Index Strategy
-- Apply Operators
-- SCD Patterns
-- Metadata SQL
-- Fabric SQL
-- Transactions & DML (INSERT, UPDATE, DELETE, MERGE (upserts))
-- Type casting — CAST, TRY_CAST, implicit vs explicit conversion, handling nulls with COALESCE and NULLIF.
-- String functions — CONCAT, SPLIT_PART, REGEXP, TRIM, UPPER/LOWER, SUBSTRING.
***/


-- Header Comment

/*
Purpose:
    ABC Segmentation based on 90-day sales and margin

Logic:
    - Partition by Company + Subclass + Brand
    - Sales weight 40%
    - Margin weight 60%

Author: Ronald
Created: 2026-03-19
*/