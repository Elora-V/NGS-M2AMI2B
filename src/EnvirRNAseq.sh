#!/bin/bash



########################
### install tools 
########################

# réalisé avec l'aide de bioconda :
# conda install -c bioconda [nom outils]
# conda remove [nom outils]


echo -e "######################################################### \n  Installation fastqc \n 
######################################################### \n "

conda install -c bioconda fastqc 

echo -e "######################################################### \n  Installation trimmomatic \n 
######################################################### \n "

conda install -c bioconda trimmomatic 

echo -e "######################################################### \n  Installation star \n 
######################################################### \n "

conda install -c bioconda star 

echo -e "######################################################### \n  Installation samtools \n 
######################################################### \n "

conda install -c bioconda samtools 

echo -e "######################################################### \n  Activation conda \n 
######################################################### \n "

conda activate


########################
#### get file
########################

# Vers local (en local) : scp source target (. ici)
#scp scp://ubuntu@voirSSHutilisé/<chemin>/<fichier> .
#scp ubuntu@134.158.248.133:${fichier_distant} .

# Vers VM (en local) : scp source target 
# scp cheminLocal ubuntu@134.158.248.133:.



