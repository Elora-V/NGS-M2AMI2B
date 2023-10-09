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


#### AJOUT WGET SI PAS PARAM (DRIVE)


#########################################
#### 0. decompresser données et download
#########################################


if [ ! -z "$fastaFile" ] #-z verifie si une variable et vide
then 

    if [ ! -d "$pathData" ] # si pas le dossier pour ranger les données :
    # -d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
    then
	    mkdir $pathData 

        echo ""
        echo "#########################################################"  
        echo "Decompresser les fasta"
        echo "#########################################################"
        echo ""
        tar -zxvf $fastaFile -C $pathData

        ### genome humain :

        echo ""
        echo "#########################################################"  
        echo "Telechargement genome humain"
        echo "#########################################################"
        echo ""

        wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr16.fa.gz -P $pathData
        gunzip $pathData/chr16.fa.gz # decompresser format fasta
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



########################
#### 2.trimmomatic
########################

if [ ! -d "$pathResult"/"$resultTrim" ] # si pas le dossier trim : on fait etape trim
# -d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
# concaténer variable et string : "$variable"string ou $variable'string' 
then

	echo ""
	echo "#########################################################"  
	echo "Etape trimmomatic"
	echo "#########################################################"
	echo ""

	mkdir $pathResult/$resultTrim


    # PB DIRE R1 PAS TJRS PAREIL !!!


	fileR1=$( ls "$pathData"/patient7.exome/*r1* ) # on recupère les noms (complets) des fichiers R1
	#ATTENTION : faut coller le '=' sinon erreur


	for i in ${fileR1} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le R1 sans le chemin complet (ce qui correspond à *) :
		nameFile=$(basename "$i" | sed 's/_r1F.fastq.gz$//') 
		# basename enlève tout le chemin
		# La commande | (pipe) est utilisée pour rediriger la sortie (stdout) d'une commande vers l'entrée (stdin) d'une autre commande.
		# sed : stream editor, permet de modifier une string
		#  s/ pour substitution, 
		# $ est la fin d'une string,
		#  // pour remplacer par chaine vide
		
		
		# on regarde si sa version R2 existe :
		if [ -f "$pathData"/patient7.exome/"$nameFile"_r2F.fastq.gz ]
		# -f : Vérifie spécifiquement si un chemin correspond à un fichier existant (pas un répertoire).
		then 
			# si oui : on applique trimmomatic
			trimmomatic PE $i "$pathData"/patient7.exome/"$nameFile"_r2F.fastq.gz -baseout "$pathResult"/"$resultTrim"/"$nameFile".fastq LEADING:20 TRAILING:20 MINLEN:50
			# trimmomatic PE fileR1 fileR2 -baseout fileResult LEADING:20 TRAILING:20 MINLEN:50

		fi 					
	done

	### fastqc des trim (que pour ceux qui ont paire de read)
	mkdir $pathResult/$resultTrim/$resultTrimFastqc
	fastqc $pathResult/$resultTrim/*P.fastq -o $pathResult/$resultTrim/$resultTrimFastqc
	

fi



########################
#### 3.BWA
########################


### Recupérer le genome complet pour le mappage : en partie 0

if [ ! -d "$pathResult"/"$resultBWA" ] # si pas le dossier bwa : on fait etape bwa
then
	echo ""
	echo "#########################################################"  
	echo "Etape BWA"
	echo "#########################################################"
	echo ""

	mkdir $pathResult/$resultBWA

    ### CONDITION VERIF INDEX

	### index 
    bwa index -a bwtsw $pathData/chr16.fa # met tout seul dans le même dossier que le genome de ref

    # mapping

    fileP1trim=$( ls "$pathResult"/"$resultTrim"/*1P.fastq ) # nom complet fichier P1 de trim

	for i in ${fileP1trim} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le 1P sans le chemin complet (ce qui correspond à *) :
		name=$( "$i" | sed 's/1P.fastq$//') 


		# applique BWA sur R1 - R2
        bwa mem -M -t 2 -A 2 -E 1 $pathData/chr16.fa \
         "$name"1P.fastq  \
          "$name"2P.fastq  >  \
        "$result"/"$result_bwa"/"$nameFile".sam   ## BUG !!!


        # Options used:
        # -t INT        Number of threads 
        # -A INT        Matching score. 
        # -E INT Gap extension penalty. A gap of length k costs O + k*E (i.e. -O
        #   is for opening a zero-length gap). 
        # -M  Mark shorter split hits as secondary (for Picard compatibility).
			
							
	done


fi
