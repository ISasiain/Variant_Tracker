# POPULATION GENETICS PROJECT
### Searching and tracking disease causing variants of individuals using the ClinVar database.
#### Author: Iñaki Sasiain Casado
#### BIOS29
## INTRODUCTION
## USAGE
## PROCEDURE

1. Downloading the required software to be used.
```bash

conda create -n pop_gen;
conda activate pop_gen;

#Installing plink to deal with plink files
conda install -c bioconda plink=1.90b6.21;

```

2. Getting the required data. Downloading the clinvar database (variant_summary.txt). Filtering the Clinvar data to remove all the variants not classified as Pathogenic or likely pathogenic.
```bash
#Getting the data from NCBI
wget wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz;
gunzip variant_summary.txt.gz;

#Filtering the data to pathogenic and likely pathogenic variants
awk -F "\t" ' BEGIN {print "#Chr", "VarID", "Gene", "Phenotype"} ($7=="Pathogenic" || $7=="Likely pathogenic")  {print $19 ,"rs" $10, $5, $14}' variant_summary.txt > pathogenic_variants.tsv;
```