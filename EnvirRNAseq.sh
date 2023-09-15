#!/bin/bash

. ./config.sh # recup nom de dossier mis dans fichier config

########################
### get file fasta
######################## 

mkdir $directory
mkdir $directory/$dirfasta
# mkdir [dossier]
wget http://rssf.i2bc.paris-saclay.fr/X-fer/AtelierNGS/TPrnaseq.tar.gz -P $directory/$dirfasta
# wget [url] -P [dossier]
tar -zxvf $directory/$dirfasta/TPrnaseq.tar.gz -C $directory/$dirfasta
# tar -zxvf [fichier_à_desarchiver] -C dossier cible
chmod +rx $directory/$dirfasta/*.fastq #blocage plus loin si pas les droits

## commande pour plus info sur fichiers
# more nomfichier (voir fichier)
# ls -lh (voir taille fichier, chiffre au milieu)
# wc nomfichier ( number of lines, characters, words, and bytes of a file )

########################
### install tools 
########################

conda install -c bioconda fastqc # faut bioconda, conda remove fastqc

conda install -c bioconda trimmomatic 
conda activate



