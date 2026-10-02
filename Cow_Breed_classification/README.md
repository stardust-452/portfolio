## Cow breed classification using Machine Learning

[![Scikit-learn](https://img.shields.io/badge/Scikit--learn-Machine%20Learning-F7931E.svg)]()
[![Optuna](https://img.shields.io/badge/Optuna-Hyperparameter%20Optimization-3B82F6.svg)]()
[![Matplotlib](https://img.shields.io/badge/Matplotlib-Visualization-11557C.svg)]()
[![UMAP](https://img.shields.io/badge/UMAP-Dimensionality%20Reduction-6A5ACD.svg)]()

### Research question: Is it possible to classify Indian cow breeds from a small set of SNPs using Machine Learning?
- Pre-processed Whole Genome Sequencing (WGS) VCF data, including QC from 157 samples using PLINK.
- Collected public bovine SNP chip data from WIDDE and remapped coordinates from UMD 3.1 to ARS-UCD 1.2 using UCSC liftover.
- Calculated SNP scores using TRES software.
- Merged and filtered VCF and chip data, and numerically encoded them using PLINK.
- Trained various supervised models (SVM, Logistic, RF, etc.) to classify breeds.
- Trained a Logistic Regression model with Lasso Regularization and performed C-value tuning using Optuna.
  
**Results**: The model achieved an AUC of 99.99% and an accuracy of 96% for 9 Indian cow breeds.

This project was done at IDEA Lab, School of Data Science & Gedit Lab, School of Biology at IISER TVM for my Minor degree in Data Science.

