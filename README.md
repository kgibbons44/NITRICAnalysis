The NITRIC study dataset is contained within two REDCap databases; the first containing records on all screened patients (data fields include date of screening, inclusion criteria, exclusion criteria, eligibility status, informed consent process, withdrawal of consent), and the second containing records on all consented patients (randomisation details, demographics, clinical history, pre-surgical assessment, anaesthetic and surgical data, perfusion data, PICU treatments and management, outcomes, delirium, biobanking and 12-month follow up).  Both databases also contain additional forms to undertake and record details of data monitoring processes.

The two NITRIC study datasets will be exported from REDCap using the in-built functionality into Stata format; a Stata compatible dataset in comma-separated value (CSV) format (.csv) and Stata do-file (.do) are generated for both.  The do-files are used to undertake preliminary data transformations; these files import the data from the CSV file, label the variable sand assign value labels to categorical variables.  These do-files are not provided in this repository as they were not constructed by the authors.

The screening dataset contains one row per screened patient.  There are no repeating events and therefore further data transformation is not required prior to analysis.

The primary study dataset contains one row per consent patient per repeating event.  This is not the optimal format for analysis, and as such, significant data transformation occurs prior to analysis to result in a dataset that contains one row per patient.

The code is broken into the four sections:

Part A: Analysis of screening dataset (“NITRIC CONSORT Analysis.do”)

Part B: Transformation of primary study dataset (“NITRIC Data Transformation.do”)

Part C: Calculation of outcomes (“NITRIC Outcome Calculations.do”)

Part D: Analysis of primary dataset (“NITRIC SAP Analysis.do”)

We have chosen to include all code, including code for assessing completeness, distribution and range, as well as the code to undertake the analyses.

The do files should be executed in the order contained in "NITRIC Analysis.do".

Notes:
1. "NITRIC Data Transformation.do": As the primary analyses do not include data on delirium, 12-month follow-up or biobanking, these components of the database have not been imported into the primary dataset for analysis. Prior to this code being run, the REDCap code to import the CSV file and prepare the variables has been run, and the dataset is sitting in memory.
