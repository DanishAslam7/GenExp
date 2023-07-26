# The extraction and analysis of gene expression data related to Alzheimer's disease

## Set Working Directory:
setwd("~/Desktop/Desktop/Alzheimer Disease/Minor Project/")

## Load Required Libraries:
# The code loads several R packages that are necessary for data analysis and processing
library(affy)
library(GEOquery)
library(tidyverse)
library(RCurl)
library(oligo)
require(dplyr)

## Download data
# This function downloads supplementary files associated with the GEO dataset
getGEOSuppFiles("GSE28146")

## Reading and Normalizing Data
# Here, the code reads the raw gene expression data from CEL files, normalizes it using the Robust Multi-array Average (RMA) method
# RMA is a common method used to normalize gene expression data obtained from microarrays
celFiles <- list.celfiles('myCELS', full.names=TRUE)
rawData <- read.celfiles(celFiles)
normalized.data <- rma(rawData)

## Data Manipulation
normalized.expr <- exprs(normalized.data)
normalized.expr <- as.data.frame(exprs(normalized.data))

## Fetching Additional Data
# This part fetches additional information related to the gene expression data, particularly feature-level data such as gene annotation
# It then selects specific columns from this data
gse <- getGEO("GSE28146", GSEMatrix = TRUE)
feature.data <- gse$GSE28146_series_matrix.txt.gz@featureData@data
feature.data <- feature.data[,c(1,11)]

## Merging Data
# This line of code merges the normalized gene expression data with the feature-level data based on a common identifier (ID)
normalized.expr <- normalized.expr %>% rownames_to_column(var = 'ID') %>% inner_join(.,feature.data, by='ID')

## Reordering Columns
# Gene ID before dataset identifiers
normalized.expr <- normalized.expr %>% relocate(`Gene Symbol`, .before= GSM697308.CEL)

## Extracting Specific Data
# Gene ID have been found using GEO "Find genes" interface for microarray datasets
# This needs to be repeated for all genes of interest
extracted.data <- subset(normalized.expr, ID== "224335_s_at", select =c("GSM697308.CEL", "GSM697309.CEL", ... "GSM697336.CEL", "GSM697337.CEL"))
