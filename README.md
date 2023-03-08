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

4. Creating the directory structure;
```bash
mkdir Data;
mkdir 01_Filtered_clinvar;
mkdir 02_Generate_input;
mkdir 03_Variant_distribution;
mkdir 04_Dividing_ancient_plink;
```

3. Getting the required data. Downloading the clinvar database (variant_summary.txt). Filtering the Clinvar data to remove all the variants not classified as Pathogenic or likely pathogenic.
```bash
cd Data;
#Getting the data from NCBI
wget wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz;
gunzip variant_summary.txt.gz;

cd ../01_Filtered_clinvar;
#Filtering the data to pathogenic and likely pathogenic variants which have a rs identifier (The cases in which this identifier was set to -1, i.e, when an identifiesr has not been yet assigned, have not been taken into consideration)
awk -F "\t" -v OFS="\t" ' BEGIN {print "#Chr", "VarID", "Effect", "Gene", "Phenotype"} ($7=="Pathogenic" || $7=="Likely pathogenic") && $10!="-1"  {print $19 ,"rs" $10, $7, $5, $14}' ../Data/variant_summary.txt > pathogenic_variants.tsv;
```

4. Generating a sample input file by selecting a random individual from the PLINK files.
```bash
cd ../02_Generate_input;

#Create a file choosing the individual of interest and using it to generate individual PLINK files
echo "Basque 249" > ind_bq249.txt;
plink --bfile ../Data/PLINK_files/MARITIME_ROUTE --keep ind_bq249.txt --make-bed --out bq249;
```

5. Use R to identify the variants associated with disease of each individual (the sample input file will be used).
```bash

```

6. Getting the distribution across populations of the variants identified in the previous step
```bash
#Getting the alelle proprtions of the variant of interest 
plink --bfile ../Data/PLINK_files/MARITIME_ROUTE --freq --snp rs3755319 --family --out variant_rs3755319;
```

7. Getting the files to track the frequency of the variants identified across time among populations
```bash
#Creating a directory in the data directory and downloading the data
cd ../Data;
mkdir ancient_data;
cd ancient_data;

#Getting the plink files
wget https://raw.githubusercontent.com/sarabehnamian/Origins-of-Ancient-Eurasian-Genomes/main/steps/Step%200/DataS1.fam;
wget https://github.com/sarabehnamian/Origins-of-Ancient-Eurasian-Genomes/raw/main/steps/Step%200/DataS1.bed;
wget https://github.com/sarabehnamian/Origins-of-Ancient-Eurasian-Genomes/raw/main/steps/Step%200/DataS1.bim;

#Getting the .xlsx file
wget https://github.com/sarabehnamian/Origins-of-Ancient-Eurasian-Genomes/raw/main/data/Reich%20dataset%20V50.xlsx;

#Running a R script to create a txt file to filter the plink files
Rscript ../../bin/ancient_filter.R Reich_dataset_V50.xlsx .

#Filtering the plink files
mkdir filtered;
cd filtered;
plink -bfile ../DataS1 --keep ../inds_to_keep.txt --make-bed --out anc_filtered;

#Filtering the annotation file using a new R script
Rscript ../../bin/annotation_filter.R Reich_dataset_V50.xlsx ./filtered/anc_filtered.fam ./filtered
```

8. Dividing the plink regarding the year of origin of the samples to determine the change of that variant across time.
```bash
cd ../../Dividing ancient plink;

#Generating the new filtering txt files into the ./filtering_files directory
mkdir filtering_files;
Rscript ../bin/ancient_splitter.R ../Data/ancient_data/filtered/filtered_annotation.tsv ./filtering_files/;

#Running plink to get the allele frequencies for each time period. THe following variant (rs3094315) was randomly choosen to evaluate the code
for file in filtering_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --bfile ../Data/ancient_data/DataS1 --keep $file --allow-no-sex --freq --snp rs3094315 --make-bed -out ${name_core}; done;

#Running plink to get the allele frequencies of each population across time. THe following variant (rs3094315) was randomly choosen to evaluate the code
for file in filtering_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --bfile ../Data/ancient_data/DataS1 --keep $file --freq --snp rs3094315 --family --makbed -out ${name_core}; done



```