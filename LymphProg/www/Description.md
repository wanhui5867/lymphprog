

## Introduction


A 24-gene expression score has been developed as an independent prognostic tool for predicting treatment outcomes in DLBCL patients undergoing R-CHOP therapy. The tool automatically normalizes transcriptomic data, identifies specific genes, calculates risk scores, and classifies individual samples into high-risk or low-risk groups. High-risk DLBCL patients identified by this tool face a significantly elevated risk of experiencing refractory/relapse disease within two years.
This tool not only functions independently as a prognostic indicator for early disease progression but also complements existing molecular and genetic subtyping approaches, allowing for further refinement in stratifying high-risk patients.


You could find details of the tool in [our paper](https://ki.se/en/mbb/pan-hammarstrom-lab) which will be published in 2024.

## Input file

1. Data type: RNAseq (TPM or FPKM), microarray data ( Log2, log10, etc.)
2. Data format: The first column is gene symbol and must be named as “Gene”. The first row is the sample names. The rest of the data matrix are the gene expression value of individual samples.
3. File format: the tool accepts the files with .txt format which uses Tab as a seperator.



## Citation


Please cite our paper: Ren W., Wan H., et al., Genetic and transcriptomic analyses of diffuse large B-cell lymphoma patients with poor outcomes within two years of diagnosis, Revision.



## Contact us


If you need any help, please send email to hui.wan@ki.se
