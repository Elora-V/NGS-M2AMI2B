#!/bin/bash



########################
### install tools 
########################



conda install -c bioconda fastqc # faut bioconda, conda remove fastqc

conda install -c bioconda trimmomatic 
conda activate


########################
#### get file
########################

# Vers local (en local) : scp source target (. ici)
#scp scp://ubuntu@voirSSHutilisé/<chemin>/<fichier> .
#scp ubuntu@134.158.248.133:${fichier_distant} .

# Vers VM (en local) : scp source target 
# scp cheminLocal ubuntu@134.158.248.133:.



