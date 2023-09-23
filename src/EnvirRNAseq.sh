#!/bin/bash

########################
### Environnement conda 
########################

echo ""
echo "#########################################################"  
echo "Environnement conda "
echo "#########################################################"
echo ""

conda create --name RNA_Seq

echo ""
echo "#########################################################"  
echo "Activation conda"
echo "#########################################################"
echo ""

conda activate RNA_Seq

# Vérification de l'activation réussie
if [ $? -eq 0 ]; then
    echo "L'environnement conda RNA-seq a été activé avec succès."
else
    echo "Erreur lors de l'activation de l'environnement conda."
    exit 1  # Quitte le script en cas d'erreur
fi

# Explication du if :
    
# -  $? est une variable spéciale qui stocke le code de sortie de la dernière commande exécutée.
#    Un code de sortie de 0 signifie généralement que la commande s'est terminée sans erreur.

# -  -eq est un opérateur de comparaison qui signifie "égal à".

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

# Memo des commandes pour récupérer un fichier de la VM à l'ordinateur local, ou inversement :

# Vers local (en local) : scp source target (. ici)
#scp scp://ubuntu@voirSSHutilisé/<chemin>/<fichier> .
#scp ubuntu@134.158.248.133:${fichier_distant} .

# Vers VM (en local) : scp source target 
# scp cheminLocal ubuntu@134.158.248.133:.


