# SQL-DQC

## What is SQLT?
### SQLT is a collection of script to perform data profiling & quality in your SQL database using T-SQL scripts. All the script are written in Microsoft SQL Server.

## What is database profiling?
### According to the Wikipedia, Data profiling is the process of examining the data available from an existing information source (e.g. a database or a file) and collecting statistics or informative summaries about that data.[1] The purpose of these statistics may be to:

#### 1. Find out whether existing data can be easily used for other purposes
#### 2. Improve the ability to search data by tagging it with keywords, descriptions, or assigning it to a category
#### 3. Assess data quality, including whether the data conforms to particular standards or patterns[2]
#### 4. Assess the risk involved in integrating data in new applications, including the challenges of joins
#### 5. Discover metadata of the source database, including value patterns and distributions, key candidates, foreign-key candidates, and functional dependencies
#### 6. Assess whether known metadata accurately describes the actual values in the source database
#### 7. Understanding data challenges early in any data intensive project, so that late project surprises are avoided. Finding data problems late in the project can lead to delays and cost overruns.
#### 8. Have an enterprise view of all data, for uses such as master data management, where key data is needed, or data governance for improving data quality.

## How data profile is conducted?
### Data profiling utilizes methods of descriptive statistics such as minimum, maximum, mean, mode, percentile, standard deviation, frequency, variation, aggregates such as count and sum, and additional metadata information obtained during data profiling such as data type, length, discrete values, uniqueness, occurrence of null values, typical string patterns, and abstract type recognition. The metadata can then be used to discover problems such as illegal values, misspellings, missing values, varying value representation, and duplicates.

## SQLT details
### SQLT is a collection of script where each script is participating to help you profiling your data. As this is the initial release, we are launching the basic data profiling methods.

### sqlt.DQC_DB_LEVEL - Execute all the DQC or profiling method for the given database (all the tables).
### sqlt.DQC_DISTINCT_COLUMN_COUNT - Distinct values for all the columns for the given table.
### sqlt.DQC_MAX_MIN_LENGTH - Minimun and Maximum length of string type column values.
### sqlt.DQC_MAX_MIN_VALUE - Minimum & Maximum (Range) of all the numeric fields.
### sqlt.DQC_MISSING_VALUES_COUNT - Count of missing values for all the fields.
### sqlt.DQC_SPECIAL_CHARACTER - Count of columns containing special character(s) with customized REGEX string.
### sqlt.DQC_TOTAL_COUNT - total row count comparison for the table.

## Setup
### Step 1 - Open SSMS query window. Go to Query -> SQLCMD Mode
<img width="950" alt="STEP1-SQLCMD" src="https://user-images.githubusercontent.com/32331579/163580675-218772d9-8bab-4cb0-bd20-8fc1b2514ece.png">

### Step 2 - Paste the content of INITIAL_SETUP/OBJECT_CREATIONS.sql to the query window (SQLMODE)
<img width="933" alt="STEP2-COMMAND" src="https://user-images.githubusercontent.com/32331579/163580750-470a845d-be1d-49ca-b70f-dff4261d01c1.png">

### Step 3 - Press F5 or run
<img width="954" alt="STEP3-COMMANDRUN" src="https://user-images.githubusercontent.com/32331579/163580822-df8a6024-3f94-4ff8-95d6-dafe301567fc.png">

## How to use it?
### All the DQC output will be saved in a table named sqlt.assertlog. You can select this table to check the output.

<img width="943" alt="image" src="https://user-images.githubusercontent.com/32331579/163581719-2ed01adb-1380-4772-8eee-da267a838bc6.png">


### Run DQC for the  whole database
#### Go to procedures & execute sqlt.DQC_DB_LEVEL.
#### sqlt.DQC_DB_LEVEL @db_name = 'YOUR DB'

## Run DQC for individual table
#### You can run DQC procedure individually.
#### sqlt.DQC_DISTINCT_COLUMN_COUNT @table_name = 'Table-Name'

## Examples
####  EXEC sqlt.DQC_TOTAL_COUNT @table_name = 'EmployeeDest', @predicted_value=2
#### EXEC sqlt.DQC_TOTAL_COUNT @table_name = 'EmployeeDest', @predicted_value=4
#### EXEC sqlt.DQC_MISSING_VALUES_COUNT @table_name = 'SALES'
#### EXEC sqlt.DQC_SPECIAL_CHARACTER @table_name = 'SALES'
#### EXEC sqlt.DQC_MAX_MIN_LENGTH @table_name = 'EMPLOYEEDEST'
#### EXEC sqlt.DQC_MAX_MIN_VALUE @table_name = 'SALES'
#### EXEC sqlt.DQC_DISTINCT_COLUMN_COUNT @table_name = 'EMPLOYEE'
#### EXEC sqlt.DQC_DB_LEVEL @db_name ='AdventureWorksDW2019'

#### As this is the first version of the scripts, we have included only basic DQC. In future commit we are planning to include statistical profiling, meta profiling (Number of partitions, partition size, type of partition). 

## Keep Supporting...
