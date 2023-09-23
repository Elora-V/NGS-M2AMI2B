#!/bin/bash

########################
### Environnement conda 
########################

echo ""
echo "#########################################################"  
echo "Environnement conda "
echo "#########################################################"
echo ""

conda init bash
conda create -n RNAseq

echo ""
echo "#########################################################"  
echo "Activation conda"
echo "#########################################################"
echo ""

conda activate RNAseq

########################
### install tools 
########################

# réalisé avec l'aide de bioconda :
# conda install -c bioconda [nom outils]
# conda remove [nom outils]

echo ""
echo "#########################################################"  
echo "Installation fastqc"
echo "#########################################################"
echo ""

conda install -c bioconda fastqc 

echo ""
echo "#########################################################"  
echo "Installation trimmomatic"
echo "#########################################################"
echo ""

conda install -c bioconda trimmomatic 

echo ""
echo "#########################################################"  
echo "Installation star"
echo "#########################################################"
echo ""

conda install -c bioconda star 

echo ""
echo "#########################################################"  
echo "Installation samtools"
echo "#########################################################"
echo ""

conda install -c bioconda samtools 



echo ""
echo "#########################################################"  
echo "Installation subread (feature count)"
echo "#########################################################"
echo ""

conda install -c bioconda subread


########################
#### get file
########################

# Vers local (en local) : scp source target (. ici)
#scp scp://ubuntu@voirSSHutilisé/<chemin>/<fichier> .
#scp ubuntu@134.158.248.133:${fichier_distant} .

# Vers VM (en local) : scp source target 
# scp cheminLocal ubuntu@134.158.248.133:.


