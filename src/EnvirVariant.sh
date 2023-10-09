#!/bin/bash

########################
### Environnement conda 
########################

echo ""
echo "#########################################################"  
echo "Environnement conda "
echo "#########################################################"
echo ""

conda create --name Variant

echo ""
echo "#########################################################"  
echo "Activation conda"
echo "#########################################################"
echo ""

conda activate Variant

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

conda install -c bioconda fastqc -y

echo ""
echo "#########################################################"  
echo "Installation trimmomatic"
echo "#########################################################"
echo ""

conda install -c bioconda trimmomatic -y

# -y pour dire 'oui' à la question posée lors du téléchargement

echo ""
echo "#########################################################"  
echo "Installation bwa"
echo "#########################################################"
echo ""

conda install -c bioconda bwa -y

echo ""
echo "#########################################################"  
echo "Installation varscan"
echo "#########################################################"
echo ""

conda install -c bioconda varscan -y
