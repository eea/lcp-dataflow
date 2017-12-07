
Large Consumption Plants (LCP) data aggregation tool

Setup:
 1. Make a tmp directory and ensure that the script has write-permission in it
 2. Create LCP folder in FTP

Aggregation process:
 1. Downloads valid XML files from released envelopes in CDR
 2. Converts the XML files into SQL INSERT statements using XSLs
 3. Executes SQL INSERT statements in MS Access database, using HXTT jdbc driver and sjsql.class
 4. Uploads the resulting MS Access file to FTP available to ETCs
 5. ETC will do their analyses in article21-extraction-`date +%F`.accdb

How-to run the tool: 
 1. Configure CDR accounts in accounts.conf
 2. Copy the HXXT driver jar into the same directory or configure -cp in "runit"
 3. Configure output file names "runit and execute the scripts for aggregating LCP data
