# POPULATION GENETICS PROJECT
### Searching and tracking disease causing variants of individuals using the ClinVar database.
#### Author: Iñaki Sasiain Casado
#### BIOS29
## INTRODUCTION
## USAGE
## PROCEDURE

### --> Setting the working environment

The required software is installed and the directory structure needed for the project is generated. The raw data is downloaded and stored into the ./01_Raw_data directory.

1. Downloading the equired software into an independent conda environment.
```bash
conda create -n pop_gen;
conda activate pop_gen;

#Installing plink (v1.90b6.21)
conda install -c bioconda plink=1.90b6.21;
```

2. Creating the directory structure;
```bash
mkdir 01_Raw_data;
mkdir 02_Preprocessed_data;
mkdir 03_Generate_input;
mkdir 04_Users_interface;
mkdir bin;

#Adding the bin file to .bashrc
echo 'export PATH="$PATH:/home/inf-52-2022/pop_gen_project/bin"' >> ~/.bashrc
```

3. Getting the required Data. Downloading the variants included in the ClinVar database (version 2023-03-06 14:11:06), and the current and ancient DNA plink files.

```bash
cd 01_Raw_data;
mkdir clinvar;
mkdir current_data;
mkdir ancient_data;

#Downloading and unzippiing the clinvar database
cd clinvar;
wget wget https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz;
gunzip variant_summary.txt.gz;
```
> The remaining files were obtained from the course Canvas page (current DNA plink files) or were provided by the teacher (ancient DNA plink files.) The current files were stored into the current_data directory, and the ancient files into the ancien_data directory.

3. Filtering the clinvar database to keep the ones classified as pathogenic or likely pathogenic.
```bash
cd ../clinvar;
#Filtering the data to pathogenic and likely pathogenic variants which have a rs identifier 
awk -F "\t" -v OFS="\t" ' BEGIN {print "#Chr", "VarID", "Effect", "Gene", "Phenotype"} ($7=="Pathogenic" || $7=="Likely pathogenic") && $10!="-1"  {print $19 ,"rs" $10, $7, $5, $14}' variant_summary.txt > pathogenic_variants.tsv;
```

### --> Preprocessing the plink data

Taking into account that the aim of this project is to identify pathogenic variants of one individual and track its frequency across time and among populations precomputing the MAF of all the variants of the current and ancient populations that are going to be used for the tracking can be helpful to improve the speed of the created app.

1. Determining the MAF of all the variants in current samples using the snp_per_population.R R script, which van be found in the bim directory.
```bash
cd ../../02_Preprocessed_data;
mkdir current_data;
#Running the R script. The output will be a matrix with the different populations and columns and with all teh variants as rows which will show the MAF of each.
Rscript ../bin/snp_per_population.R ../01_Raw_data/current_data/MARITIME_ROUTE ./current_data/curr_SNP_matrix.txt
```

2. Editing the ancient DNA plink files to add the sample population (Country of origin) obtained from the annotation file as the population ID.
```bash
cd ../Data/ancient_data;
#Creating the ped file
plink --bfile v54.1_1240K_public --recode --out full_ancient_ped;

#Editing the group id of the ped file to the country specified in the annotation file

#Generating a file with the new group ID
cat v54.1_1240K_public.anno | cut -f 14 | grep -v "Political Entity" | tr " " "_" > groupID.txt;
#Generating a file with the ped file without the first column
cat full_ancient_ped.ped | cut -d " " -f 2- > ped_minus_group.txt;
#Merging the files (they do not have to be sorted first because the order of the original ped file and the annotation file are the same)
paste -d " " groupID.txt ped_minus_group.txt > ancient_data.ped;
#Removing the temporal files created
rm ped_minus_group.txt rm groupID.txt;
```
3. Generating filtering txt files to get different plink files per each time period specified (0-1000, 1000-2000, 2000-3000, 3000-4000, 4000-5000, 5000-6000, 6000-7000, 7000-8000, 8000-9000, 9000-10000, 10000-12000 and >12000 years BC).

```bash
#Creating .txt files to filter the ped file according to each time interval using a Rscript
mkdir grouping_files;
Rscript ../../bin/ancient_splitter.R ./v54.1_1240K_public.anno ./grouping_files/
```

4. Generating plink files (bim, bed and fam) for each time period.

```bash
#Generating bed, bim and fam files for each time interval
mkdir groupped_plink_files;
or file in grouping_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --file ancient_data --keep $file --make-bed -out ./groupped_plink_files/${name_core}; done;
```

2. Determining the MAF of all the variants of the populations of diffrerent time intervals from the ancient DNA samples.
```bash
#Generating the new filtering txt files into the ./filtering_files directory using the ancient_splitter.R script, which is available in the bin directory.
mkdir filtering_files;
Rscript ../bin/ancient_splitter.R ../Data/ancient_data/filtered/filtered_annotation.tsv ./filtering_files/;

#Generating bed, bim and fam files for each time interval
mkdir grouped_plink_files;
or file in grouping_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --file ancient_data --keep $file --make-bed -out ./groupped_plink_files/${name_core}; done;

#Changing directory and crating a subfolder
cd ../../02_Preprocessed_data/
mkdir ancient_data;
cd ancient_data;

#Generating MAF matrix per each time period
ls ../../01_Raw_data/ancient_data/groupped_plink_files/*.fam | while read line; do name=$(echo $line | cut -d \/ -f 6 | sed 's/.fam//'); Rscript ../../bin/snp_per_population.R .../../01_Raw_data/ancient_data/groupped_plink_files/${name} ./${name}_SNP_matrix.txt; done;
```
### --> Generating input files

In order to check if the app designed works individual input plink files were created by choosing randomly individuals from the current plink files (MARITIME_ROUTE).

1. Generating a sample input file by selecting a random individual from the PLINK files.
```bash
cd ../03_Generate_input;

#Generate input file choosing the individual "Basque 249"
mkdir bq249;
cd bq249;
echo "Basque 249" > ind_bq249.txt;
plink --bfile ../../01_Raw_data/current_data/MARITIME_ROUTE --keep ind_bq249.txt --make-bed --out bq249;

#Generate input file choosing the individual "Macedonia 688"
mkdir ../mc688;
cd ../mc688;
echo "Macedonia 688" > ind_mc688.txt;
plink --bfile ../../01_Raw_data/current_data/MARITIME_ROUTE --keep ind_mc688.txt --make-bed --out mc688;
```

#########################################################################


4. Generating a sample input file by selecting a random individual from the PLINK files.
```bash
cd ../02_Generate_input;

#Create a file choosing the individual of interest and usE it to generate individual PLINK files
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

10. Preprocessing the full ancidnt DNA data. Getting the ped file, and changing the group identifiers to the country names using ancient_data_adapter R script.
```bash
cd ../Data/full_ancient_data;
#Creating the ped file
plink --bfile v54.1_1240K_public --recode --out full_ancient_ped;
#Editing the group id of the ped file to the country specified in the annotation file
cat v54.1_1240K_public.anno | cut -f 14 | grep -v "Political Entity" | tr " " "_" > groupID.txt;
cat full_ancient_ped.ped | cut -d " " -f 2- > ped_minus_group.txt;
paste -d " " groupID.txt ped_minus_group.txt > ancient_data.ped;
rm ped_minus_group.txt rm groupID.txt;

#Creating .txt files to filter the ped file according to each time interval using a Rscript
Rscript ../../bin/ancient_splitter.R ./v54.1_1240K_public.anno ./grouping_files/

#Generating bed, bim and fam files for each time interval
mkdir groupped_plink_files;
or file in grouping_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --file ancient_data --keep $file --make-bed -out ./groupped_plink_files/${name_core}; done;

#Generating MAF matrix per each time period
ls groupped_plink_files/*.fam | while read line; do name=$(echo $line | cut -d \/ -f 2 | sed 's/.fam//'); Rscript ../../bin/snp_per_population.R ./groupped_plink_files/${name} ./groupped_plink_files/MAF_matrix/${name}_SNP_matrix.txt; done;
```

### Creating an interface
