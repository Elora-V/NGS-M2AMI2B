#!/bin/bash

. ./config.sh


########################
#### 1. fastqc
########################

mkdir $directory/$dirfastqc

fastqc $directory/$dirfasta/*.fastq -o $directory/$dirfastqc
# fastqc [fichier (wildcard possible)] -o dossier cible
# donne .html et .zip 

########################
#### 2.trimmomatic
########################

mkdir $directory/$dirtrim 

fileR1=$( ls "$directory"/"$dirfasta"/*.R1.fastq ) # on recupère les noms (complet) des fichiers R1
# "$variable"mot ou $variable'mot'
#ATTENTION : faut coller le '=' sinon erreur


for i in ${fileR1} # pour chacun d'eux :
do
	# on cherche le nom du fichier avant le R1 sans le chemin complet (ce qui correspond à *) :
	nameFile=$(basename "$i" | sed 's/.R1.fastq$//') 
	# sed enleve l'expression regulière qui suit 
	# $ est la fin d'une string, s/ pour substitution, // pour remplacer par chaine vide
	# basename enlève tous le chemin
	
	# on regarde si sa version R2 existe : -e pr test existance fichier
	if [ -e "$directory"/"$dirfasta"/"$nameFile".R2.fastq ]; 
	then 
		# si oui : on applique trimmomatic
		trimmomatic PE $i "$directory"/"$dirfasta"/"$nameFile".R2.fastq -baseout "$directory"/"$dirtrim"/"$nameFile".fastq LEADING:20 TRAILING:20 MINLEN:50
		# trimmomatic PE fileR1 fileR2 -baseout fileResult LEADING:20 TRAILING:20 MINLEN:50

	fi 					
done



		

########### get the file :

# Vers local (en local) : scp source target (. ici)
#scp scp://ubuntu@voirSSHutilisé/<chemin>/<fichier> .
#scp ubuntu@134.158.248.133:${fichier_distant} .

# Vers VM (en local) : scp source target 
# scp cheminLocal ubuntu@134.158.248.133:.



### exit 
