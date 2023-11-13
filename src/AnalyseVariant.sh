#!/bin/bash

. ./config.sh  # on récupère les noms de chemins et dossiers du fichier de configuration


# On récupère ensuite les arguments de la ligne de commande
while getopts f:read: flag
do
    case "${flag}" in
        f) fastaFile=${OPTARG};;  # chemin vers fichier fasta  
        read) suffixRead1= ${OPTARG};;  
    esac
done

if [  -z "$suffixRead" ] # suffix par defaut
then suffixRead1="_r1F.fastq.gz"
fi
suffixRead2=$(echo "$suffixRead1" | sed 's/1/2/')

if [ ! -d "$pathResult" ] # si pas le dossier pour ranger les resultats :
#-d est utilisée dans Bash pour vérifier si un répertoire (dossier) existe
then

	mkdir $pathResult # on le créér
fi


#########################################
#### 0. decompresser données et download
#########################################

if [ ! -d "$pathData" ] 
then 
    mkdir $pathData

    # si on a pas un chemin vers les fasta on les télécharge 

    if [  -z "$fastaFile" ] #-z verifie si une variable et vide
            
    then 
                echo ""
                echo "#########################################################"  
                echo "Telechargement fasta"
                echo "#########################################################"
                echo ""

                wget --load-cookies /tmp/cookies.txt \
                "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt \
                --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1DM9g8OulE1ScBk-HoaREfUZs6gurtkBe' -O- |\
                sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1DM9g8OulE1ScBk-HoaREfUZs6gurtkBe" -O patient7.tar.gz && rm -rf /tmp/cookies.txt \
                
                mv patient7.tar.gz $pathData/patient7.tar.gz
                fastaFile=./$pathData/patient7.tar.gz
                
    fi
    

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


# Les fasta sont dans un dossier : pas d'acces direct

if  ! ls "$pathData"/*.fastq* 1>/dev/null 2>&1 # si il n'y a pas de fasta directement dans data
then 
    pathFasta=$(ls -d $pathData/*/)
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

    fastqc $pathFasta/*.fastq* -o $pathResult/$resultFastqc   
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


	fileR1=$( ls "$pathFasta"*"$suffixRead1") # on recupère les noms (complets) des fichiers R1
	#ATTENTION : faut coller le '=' sinon erreur

	for i in ${fileR1} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le R1 sans le chemin complet (ce qui correspond à *) :
		nameFile=$(basename "$i" | sed "s/$suffixRead1$//") 

		# basename enlève tout le chemin
		# La commande | (pipe) est utilisée pour rediriger la sortie (stdout) d'une commande vers l'entrée (stdin) d'une autre commande.
		# sed : stream editor, permet de modifier une string
		#  s/ pour substitution, 
		# $ est la fin d'une string,
		#  // pour remplacer par chaine vide
		

        # trimmomatic PE fileR1 fileR2 -baseout fileResult LEADING:20 TRAILING:20 MINLEN:50
        trimmomatic PE $i ${pathFasta}${nameFile}${suffixRead2} -baseout ${pathResult}/${resultTrim}/${nameFile}.fastq LEADING:20 TRAILING:20 MINLEN:50

	done

	### fastqc des trim (que pour ceux qui ont paire de read)
	mkdir $pathResult/$resultTrim/$resultTrimFastqc
	fastqc $pathResult/$resultTrim/*P.fastq -o $pathResult/$resultTrim/$resultTrimFastqc
	
fi

chmod +rw "$pathResult"/"$resultTrim"/*.fastq


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


	### index 
    bwa index -a bwtsw $pathData/chr16.fa # met tout seul dans le même dossier que le genome de ref

    # mapping

    fileP1trim=$( ls "$pathResult"/"$resultTrim"/*1P.fastq ) # nom complet fichier P1 de trim

	for i in ${fileP1trim} # pour chacun d'eux :
	do
		# on cherche le nom du fichier avant le 1P sans le chemin complet (ce qui correspond à *) :
		name=$( echo $i | sed 's/1P.fastq$//') 
        shortname=$( basename $name )

		# applique BWA sur R1 - R2
        bwa mem -M -t 2 -A 2 -E 1 "$pathData/chr16.fa" \
         "$name"1P.fastq  \
          "$name"2P.fastq    \
         -o "$pathResult"/"$resultBWA"/"$shortname".sam   


        # Options used:
        # -t INT        Number of threads 
        # -A INT        Matching score. 
        # -E INT Gap extension penalty. A gap of length k costs O + k*E (i.e. -O
        #   is for opening a zero-length gap). 
        # -M  Mark shorter split hits as secondary (for Picard compatibility).
			
							
	done


fi


if  ! ls ${pathResult}/${resultBWA}/*.bam 1>/dev/null 2>&1 
# vrai si il n'existe pas de bam
then

	echo ""
	echo "#########################################################"  
	echo "Etape SAM"
	echo "#########################################################"
	echo ""

    fileSAM=$( ls "$pathResult"/"$resultBWA"/*.sam )

    for i in ${fileSAM} 
    do
        name=$( echo $i | sed 's/_.sam$//') 
        #Sam to Bam
        samtools view -S -b $i  > ${name}.bam
        # flagstats
        samtools flagstat ${name}.bam
        #Sort Bam
        samtools sort  ${name}.bam > ${name}_sort.bam
        #Index bam file
        samtools index ${name}_sort.bam
        #Convert to Mpileup
        samtools mpileup -B -A -f $pathData/chr16.fa  ${name}_sort.bam > \
        ${name}.mse

    done

fi


if [ ! -d "$pathResult"/"$resultVarscan" ] # si pas le dossier varscan : on fait etape bwa
then 
	echo ""
	echo "#########################################################"  
	echo "Etape varscan"
	echo "#########################################################"
	echo ""

    mkdir "$pathResult"/"$resultVarscan"

    normalFile=$(ls "$pathResult"/"$resultBWA"/*-N-*.mse)

    for i in ${normalFile} 
    do
        tumorFile=$(echo "$i" | sed 's/-N-/-T-/')
        name=$(basename $i | sed 's/-N//' | sed 's/.mse$//')
        varscan somatic $i $tumorFile "$pathResult"/"$resultVarscan"/$name.vcf
    done



    fileVCF=$(ls "$pathResult"/"$resultVarscan"/*.vcf*)
    for i in ${fileVCF}
    do
        grep -i 'somatic' $i > ${i}.vcf
        awk '{OFS="\t"; if (!/^#/){print $1,$2-1,$2,$4"/"$5,"+"}}' \
        ${i}.vcf > ${i}.bed
    done

    if [ ! -f "gencode.v24lift37.basic.annotation.gtf.gz"  ]
    then 
        wget "ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_24/GRCh37_mapping/gencode.v24lift37.basic.annotation.gtf.gz"
        gzip -d gencode.v24lift37.basic.annotation.gtf.gz

    fi

    
    fileBed=$(ls "$pathResult"/"$resultVarscan"/*.bed)
    for i in ${fileBed}
    do
        bedtools intersect -a ./gencode.v24lift37.basic.annotation.gtf -b ${i} > ${i}_inter
        grep '\sgene\s' ${i}_inter | awk '{print " " $1 " " $4 " " $5 " " $16}' > ${i}.annot
    done


fi
