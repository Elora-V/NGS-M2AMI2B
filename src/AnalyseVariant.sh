#!/bin/bash

. ./config.sh  # on récupère les noms de chemins et dossiers du fichier de configuration


# On récupère ensuite les arguments de la ligne de commande
while getopts f: flag
do
    case "${flag}" in
        f) fastaFile=${OPTARG};;  # chemin vers fichier fasta      
    esac
done


if [ ! -d "$pathResult" ] # si pas le dossier pour ranger les resultats :
#-d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
then

	mkdir $pathResult # on le créér
fi



#############################
#### 0. decompresser données
#############################


if [ ! -z "$fastaFile" ] #-z verifie si une variable et vide
then 

    if [ ! -d "$pathData" ] # si pas le dossier pour ranger les données :
    # -d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
    then
	    mkdir $pathData 
        tar -zxvf $fastaFile -C $pathData
    fi
    
fi

########################
#### 1. fastqc
########################


if [ ! -d "$pathResult"/"$resultFastqc" ] # si pas le dossier fastqc : on fait etape fastqc
#-d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
then
    echo ""
    echo "#########################################################"  
    echo "Etape fastqc"
    echo "#########################################################"
    echo ""

    mkdir $pathResult/$resultFastqc

    fastqc $pathData/patient7.exome/*.fastq* -o $pathResult/$resultFastqc   ####AUTOMATISE LE PATIENT7.EXOME !!!!
    # fastqc [fichier (wildcard possible)] -o dossier cible
    # donne .html et .zip 
fi
