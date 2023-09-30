#!/bin/bash

. ./config.sh  # on récupère les noms de chemins et dossiers du fichier de configuration

# On récupère ensuite les arguments de la ligne de commande
while getopts a:d: flag
do
    case "${flag}" in
        a) all=${OPTARG};;  # indique si on veut faire les étapes fastqc et d'index (vrai si on veut, faux sinon)
        d) pathfasta=${OPTARG};; # chemin vers le dossier contenat les fichiers fasta
    esac
done


# On transforme la variable all en booléen (0-1)
if [ "$all" = "T" ] || [ "$all" = "True" ] || [ "$all" = "true" ] || [ "$all" = "t" ]
then
  All=1 # vrai
else
  All=0 # faux
fi

echo $pathfasta

########################
### 0. get file fasta
######################## 

if [ ! -d "$pathData" ] # si pas le dossier pour ranger les données :
# -d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
then

	mkdir $pathData # on créer le dossier et on telecharge les données :

	### sequences ARN :

	# si on a pas un chemin vers les fasta on les télécharge :
	if [ -z "$pathfasta" ] 
	#-z verifie si une variable et vide
	then 
		echo ""
		echo "#########################################################"  
		echo "Telechargement sequences ARN"
		echo "#########################################################"
		echo ""

		wget http://rssf.i2bc.paris-saclay.fr/X-fer/AtelierNGS/TPrnaseq.tar.gz -P $pathData
		# wget [url] -P [dossier]
		tar -zxvf $pathData/TPrnaseq.tar.gz -C $pathData
		# tar -zxvf [fichier_à_desarchiver] -C dossier cible
		pathfasta="$pathData" 
		# on indique le chemin du dossier fasta (celui qu'on vient de créer)
		echo $pathData
		echo $pathfasta
	fi 


	### genome humain :

	echo ""
	echo "#########################################################"  
	echo "Telechargement genome humain"
	echo "#########################################################"
	echo ""

	wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/chromosomes/chr18.fa.gz -P $pathData
	gunzip $pathData/chr18.fa.gz # decompresser format fasta

	### annotation genome :

	echo ""
	echo "#########################################################"  
	echo "Telechargement annotation genome"
	echo "#########################################################"
	echo ""

	wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_24/GRCh37_mapping/gencode.v24lift37.basic.annotation.gtf.gz -P $pathData
	gunzip $pathData/gencode.v24lift37.basic.annotation.gtf.gz # decompresser format gtf

	chmod +rx $pathfasta/*.fastq #blocage plus loin si pas les droits

fi

## commande pour plus info sur fichiers :
# more nomfichier (voir fichier)
# ls -lh (voir taille fichier, chiffre au milieu)
# wc nomfichier ( number of lines, characters, words, and bytes of a file )



if [ ! -d "$pathResult" ] # si pas le dossier pour ranger les resultats :
#-d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
then

	mkdir $pathResult # on le créér
fi





########################
#### 1. fastqc
########################

if [  $All -eq 1 ] # si on fait toutes les étapes : on fait celle de fastqc
then
	if [ ! -d "$pathResult"/"$resultFastqc" ] # si pas le dossier fastqc : on fait etape fastqc
	#-d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
	then
		echo ""
		echo "#########################################################"  
		echo "Etape fastqc"
		echo "#########################################################"
		echo ""

		mkdir $pathResult/$resultFastqc

		fastqc $pathfasta/*.fastq -o $pathResult/$resultFastqc
		# fastqc [fichier (wildcard possible)] -o dossier cible
		# donne .html et .zip 
	fi
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


	fileR1=$( ls "$pathfasta"/*.R1.fastq ) # on recupère les noms (complets) des fichiers R1
	#ATTENTION : faut coller le '=' sinon erreur


	for i in ${fileR1} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le R1 sans le chemin complet (ce qui correspond à *) :
		nameFile=$(basename "$i" | sed 's/.R1.fastq$//') 
		# basename enlève tout le chemin
		# La commande | (pipe) est utilisée pour rediriger la sortie (stdout) d'une commande vers l'entrée (stdin) d'une autre commande.
		# sed : stream editor, permet de modifier une string
		#  s/ pour substitution, 
		# $ est la fin d'une string,
		#  // pour remplacer par chaine vide
		
		
		# on regarde si sa version R2 existe :
		if [ -f "$pathfasta"/"$nameFile".R2.fastq ]
		# -f : Vérifie spécifiquement si un chemin correspond à un fichier existant (pas un répertoire).
		then 
			# si oui : on applique trimmomatic
			trimmomatic PE $i "$pathfasta"/"$nameFile".R2.fastq -baseout "$pathResult"/"$resultTrim"/"$nameFile".fastq LEADING:20 TRAILING:20 MINLEN:50
			# trimmomatic PE fileR1 fileR2 -baseout fileResult LEADING:20 TRAILING:20 MINLEN:50

		fi 					
	done

	if [  $All -eq 1 ] # on fait fastqc ? 
	then
		### fastqc des trim (que pour ceux qui ont paire de read)
		mkdir $pathResult/$resultTrim/$resultTrimFastqc
		fastqc $pathResult/$resultTrim/*P.fastq -o $pathResult/$resultTrim/$resultTrimFastqc
	fi

fi	


########################
#### 3.Star
########################


### Recupérer le genome complet pour le mappage : en partie 0

if [ ! -d "$pathResult"/"$resultStar" ] # si pas le dossier star : on fait etape star
then
	echo ""
	echo "#########################################################"  
	echo "Etape star"
	echo "#########################################################"
	echo ""

	mkdir $pathResult/$resultStar
	mkdir $pathResult/$resultStar/$resultStarindex
	mkdir $pathResult/$resultStar/$resultStaralign

	### index star
	STAR --runMode genomeGenerate --runThreadN 4 \
	--genomeDir $pathResult/$resultStar/$resultStarindex \
	--genomeFastaFiles $pathData/chr18.fa \
	--sjdbGTFfile $pathData/gencode.v24lift37.basic.annotation.gtf

	### application star pour chaque duo R1-R2

	fileP1trim=$( ls "$pathResult"/"$resultTrim"/*1P.fastq ) # nom complet fichier P1 de trim

	for i in ${fileP1trim} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le 1P sans le chemin complet (ce qui correspond à *) :
		nameFile=$(basename "$i" | sed 's/1P.fastq$//') 
		nameFileShort=$(echo "$nameFile" | sed 's/.sampled_$//') # enleve bout 'moche' du nom pour nommer le resultat de star sans 'sampled'

		# applique star sur R1 - R2
		STAR --runThreadN 4 --outFilterMultimapNmax 1\
		--genomeDir  $pathResult/$resultStar/$resultStarindex \
		--outSAMattributes All --outSAMtype BAM SortedByCoordinate \
		--outFileNamePrefix  $pathResult/$resultStar/$resultStaralign/$nameFileShort \
		--readFilesIn "$pathResult"/"$resultTrim"/"$nameFile"1P.fastq "$pathResult"/"$resultTrim"/"$nameFile"2P.fastq
			
							
	done


fi

########################
#### 4.Samtools
########################


### VERSION 1 DU IF (avec find) [ne pas lire]
#if ! find "$pathResult"/"$resultStar"/"$resultStaralign" -type f -name "*.bai" | grep -q . # si pas de bai : on fait etape samtools

# find: C'est la commande principale que vous utilisez pour rechercher des fichiers et des répertoires dans un système de fichiers.
# -type f: C'est une option pour spécifier que vous recherchez des fichiers (f pour file)
# -name "*.bai" : C'est une autre option qui spécifie le motif ou le nom que vous recherchez

# La commande | (pipe) est utilisée pour rediriger la sortie (stdout) d'une commande vers l'entrée (stdin) d'une autre commande.

#  La commande grep ici recherche la présence d'au moins un caractère dans la chaîne de texte ou le flux de données fourni avant le | :
# Si au moins un caractère est trouvé, grep renverra un code de sortie (0), indiquant que le motif (un caractère quelconque) a été trouvé. 
# Sinon, si aucun caractère n'est trouvé, le code de sortie sera différent de zéro (généralement 1), indiquant qu'aucun caractère n'a été trouvé.
# -q : Lorsque cette option est utilisée, grep ne produit aucune sortie (ni résultats affichés à l'écran) ;
# elle est principalement utilisée pour vérifier si un motif existe sans afficher le résultat à l'écran.
# . : Dans ce contexte, le point (.) est un motif qui signifie "n'importe quel caractère". 

# on met ! pour inverser le resultat : action si grep trouve rien

if [  $All -eq 1 ] # on fait samtools ?
then

	# VERSION 2 (avec ls, donc plus efficace)
	if  ! ls "$pathResult/$resultStar/$resultStaralign"/*.bai 1>/dev/null 2>&1
	# 1>/dev/null 2>&1: Cette partie redirige la sortie standard (stdout) et la sortie d'erreur standard (stderr) de la commande ls vers /dev/null, 
	# ce qui signifie que la sortie de ls est supprimée et ne sera pas affichée à l'écran.
	#
	# 1> : Cela signifie "rediriger la sortie standard (stdout)". 
	# Le 1 représente le descripteur de fichier standard pour la sortie standard (qui est généralement le terminal).
	# /dev/null : Tout ce qui est écrit dans /dev/null est jeté, ce qui signifie qu'il disparaît. 
	# 2>&1 : Cela signifie "rediriger la sortie d'erreur standard (stderr) vers la sortie standard (stdout)". 
	# Le 2 représente le descripteur de fichier standard pour la sortie d'erreur standard.
	#
	# =>  les deux sorties sont supprimées (celle du ls et celle de l'erreur) car redirigé vers dev/null
	# permet de ne pas afficher le ls

	# if est vrai si il existe des bai : donc met ! 
	then

		echo ""
		echo "#########################################################"  
		echo "Etape samtools"
		echo "#########################################################"
		echo ""

		fileBam=$( ls "$pathResult"/"$resultStar"/"$resultStaralign"/*.bam ) # liste des fichier  bam
		for i in ${fileBam} # pour chacun d'eux :
		do
			samtools index $i 
			
		done
	fi
fi

########################
#### 5.Feature counts
########################


if [ ! -d "$pathResult"/"$resultFeatureCounts" ] # si pas le dossier counts : on fait etape counts
then
	echo ""
	echo "#########################################################"  
	echo "Etape feature counts"
	echo "#########################################################"
	echo ""

	mkdir $pathResult/$resultFeatureCounts

	featureCounts -p -t exon -g gene_id \
	-a $pathData/gencode.v24lift37.basic.annotation.gtf \
	-o $pathResult/$resultFeatureCounts/comptage.txt \
	$pathResult/$resultStar/$resultStaralign/*.bam
	# featureCounts -p -t exon -g gene_id -a {annotation.gtf} -o {sortie} {bam}



	# Le fichier de sortie contient un tableau de comptages avec les informations suivantes :

	# Geneid : Identifiant du gène.
	# Chr : Chromosome sur lequel le gène est situé.
	# Start : Position de départ du gène sur le chromosome.
	# End : Position de fin du gène sur le chromosome.
	# Strand : Orientation du gène (+ ou -).
	# Length : Longueur du gène.
	# ... : Les colonnes suivantes représentent les échantillons, et chaque cellule contient le nombre de lectures alignées sur le gène correspondant dans l'échantillon spécifique.
	

	# on trie le resultat 
	sort $pathResult/$resultFeatureCounts/comptage.txt \
	> $pathResult/$resultFeatureCounts/sortComptage.txt
	# tri est effectué sur la première colonne (Geneid) par défaut


	# Récupérer les noms de gènes avec perl (langage pour regex) :

	perl -ne 'print "$1 $2\n" if /gene_id \"(.*?)\".*gene_name \"(.*?)\"/' \
	$pathData/gencode.v24lift37.basic.annotation.gtf | sort | uniq \
	> $pathResult/$resultFeatureCounts/id_name.txt


	#  -ne non-interactif  pour traiter chaque ligne du fichier gtf en entrée.
	#
	# if /gene_id \"(.*?)\".*gene_name \"(.*?)\"/ : Cette partie utilise une expression régulière pour rechercher 
	# des motifs dans la ligne en cours. On recupère l'id du gene et son nom  et on les stocke dans les variables $1 et $2.
	#
	# on sort les lignes et on supprime les doublons (uniq)


	sort $pathResult/$resultFeatureCounts/id_name.txt \
	> $pathResult/$resultFeatureCounts/sort_id_name.txt
	# on sort le fichier en fonction des identiants

	# On assemble (join) ces deux fichiers :
	# cela permet d'avoir les compte avec les noms de gènes, et pas que id 
	# On passe de plus par un filtre : on garde que les lignes avec "chr18"

	join $pathResult/$resultFeatureCounts/sortComptage.txt $pathResult/$resultFeatureCounts/sort_id_name.txt  \
	|grep "chr18" \
	> $pathResult/$resultFeatureCounts/comptageAnnot.txt

	# Tableau de comptage
	# On ne récupère que les colonnes voulus (nom de gène et compte)
	awk '{print $13 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12}' $pathResult/$resultFeatureCounts/comptageAnnot.txt \
	>  $pathResult/$resultFeatureCounts/tableCounts.txt

fi



