# POPULATION GENETICS PROJECT
### Searching and tracking disease causing variants of individuals using the ClinVar database.
#### Author: Iñaki Sasiain Casado
#### BIOS29
## INTRODUCTION
## USAGE
## SCRIPTS

The following R scripts, which are available in the bin folder of the project's directory were created for this work. The function of each will be summarized next.

gsub("> 12000", "12000_Inf", gsub("^0_", "-Inf_", gsub("-", "_", gsub(" BC", "", gsub("\\.","",selected_interval())))))), "_SNP_matrix.txt", sep="")

- **snp_per_population.R**

    This script takes plink files in bed, bim and fam format as the input and outputs a matrix of the Minor Allele Frequency of the variants in all the populations (families specified in the fam file) of the plink file. The output matrix has the variants as rows and the populations as columns. The created files is stored in the directory specified as an argument.

- **ancient_splitter.R**

    This scripts takes the annotation file of an ancient DNA plink file as an input and creates filtering.txt files  (files that can be used to filter plink files using the command line plink programme)  to split the plink database un subplink files based on the estimated mean age of the ancient DNA samples. The time intervals in which the plink file is splitted are the following; 0-1000, 1000-2000, 2000-3000, 3000-4000, 4000-5000, 5000-6000, 6000-7000, 7000-8000, 8000-9000, 9000-10000, 10000-12000 and >12000 years BC. THe files generated are stored in the directory specified as an argument.

- **var_track_app.R**

    This scipts contains the code necessary for running a user's interface using R and rShiny. The functions needed are defined in th var_track_functions.R script.

- **var_track_functions.R**

    This script contains the functions  needed to run the user's interface defined in the var_track_app.R.

## APPLICATION DEVELOPMENT

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
#Tranforming the annotation file to remove white spaces
cat v54.1_1240K_public.anno | tr " " "_" > v54.1_1240K_public.anno;
#Creating .txt files to filter the ped file according to each time interval using a Rscript
mkdir grouping_files;
Rscript ../../bin/ancient_splitter.R ./v54.1_1240K_public.anno ./grouping_files/
```

4. Generating plink files (bim, bed and fam) for each time period.

```bash
#Generating bed, bim and fam files for each time interval
mkdir groupped_plink_files;
for file in grouping_files/*; do name_core=$( echo ${file} | cut -d \/ -f 2 | cut -d "." -f 1 ); plink --file ancient_data --keep $file --make-bed -out ./groupped_plink_files/${name_core}; done;
```

2. Determining the MAF of all the variants of the populations of diffrerent time intervals from the ancient DNA samples.
```bash

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

### --> Creating an interface

1. Creating csv files containing the coordinates of the populations.
>The coordinates of populations included in both, current and ancient DNA files were created in order to plot the MAFs. The coordinate values were determined for the capital of the country/region and obtained from diverese sources.

2. Running the interface
>The user's inteface was designed  using a Rshiny script "var_track_app.R", which is stored in the bin folder. Tis script makes use of the functions defined in the "var_track_functions.R" script to locate the pathogenic variants and plot the results.