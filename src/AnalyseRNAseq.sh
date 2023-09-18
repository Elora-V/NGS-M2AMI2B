#!/bin/bash

. ./config.sh



########################
### 0. get file fasta
######################## 

if [ ! -d "$pathData" ] # si pas le dossier pour ranger les données :
then

	mkdir $pathData

	### sequences ARN :
	wget http://rssf.i2bc.paris-saclay.fr/X-fer/AtelierNGS/TPrnaseq.tar.gz -P $pathData
	# wget [url] -P [dossier]
	tar -zxvf $pathData/TPrnaseq.tar.gz -C $pathData
	# tar -zxvf [fichier_à_desarchiver] -C dossier cible

	### genome humain :
	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr18.fa.gz -P $pathData
	gunzip $pathData/chr18.fa.gz # decompresser format fasta

	### annotation genome :
	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_24/GRCh37_mapping/gencode.v24lift37.basic.annotation.gtf.gz -P $pathData
	gunzip $pathData/gencode.v24lift37.basic.annotation.gtf.gz # decompresser format gtf

	chmod +rx $pathData/*.fastq #blocage plus loin si pas les droits

fi

## commande pour plus info sur fichiers
# more nomfichier (voir fichier)
# ls -lh (voir taille fichier, chiffre au milieu)
# wc nomfichier ( number of lines, characters, words, and bytes of a file )




if [ ! -d "$pathResult" ] # si pas le dossier pour ranger les resultats :
then

	mkdir $pathResult
fi


########################
#### 1. fastqc
########################

if [ ! -d "$pathResult"/"$resultFastqc" ] # si pas le dossier fastqc : on fait etape fastqc
then

	mkdir $pathResult/$resultFastqc

	fastqc $pathData/*.fastq -o $pathResult/$resultFastqc
	# fastqc [fichier (wildcard possible)] -o dossier cible
	# donne .html et .zip 
fi







########################
#### 2.trimmomatic
########################

if [ ! -d "$pathResult"/"$resultTrim" ] # si pas le dossier trim : on fait etape trim
then

	mkdir $pathResult/$resultTrim

	fileR1=$( ls "$pathData"/*.R1.fastq ) # on recupère les noms (complet) des fichiers R1
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
		if [ -e "$pathData"/"$nameFile".R2.fastq ]; 
		then 
			# si oui : on applique trimmomatic
			trimmomatic PE $i "$pathData"/"$nameFile".R2.fastq -baseout "$pathResult"/"$resultTrim"/"$nameFile".fastq LEADING:20 TRAILING:20 MINLEN:50
			# trimmomatic PE fileR1 fileR2 -baseout fileResult LEADING:20 TRAILING:20 MINLEN:50

		fi 					
	done


	### fastqc des trim (que pour ceux qui ont pair)
	mkdir $pathResult/$resultTrim/$resultTrimFastqc
	fastqc $pathResult/$resultTrim/*P.fastq -o $pathResult/$resultTrim/$resultTrimFastqc

fi	


########################
#### 3.Star
########################

resultStar="result_star"
resultStarindex="result_star_index"

if [ ! -d "$pathResult"/"$resultStar" ] # si pas le dossier trim : on fait etape trim
then

STAR --runMode genomeGenerate --runThreadN 4 \
--genomeDir $pathResult/$resultStar/$resultStarindex \
--genomeFastaFiles $pathData/chr18.fa \
--sjdbGTFfile $pathData/gencode.v24lift37.basic.annotation.gtf

fi


### Recupérer le genome complet pour le mappage en partie 0

