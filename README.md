# NGS-M2AMI2B

<h2> Version courte des commandes </h2>

```bash
git clone https://github.com/Elora-V/NGS-M2AMI2B.git
cd NGS-M2AMI2B
source ./src/EnvirRNAseq.sh
sh ./src/AnalyseRNAseq.sh
 ```


<h2> Version détaillée des commandes </h2>


<h3> Connection à la machine virtuelle </h3>


```bash
ssh [mettre url ssh VM]
```

<h3> Configuration environnement </h3>

- Installer git (si besoin)

```bash
sudo apt update
sudo apt install git
```
  
- Recupération du dépot git
  
```bash
git clone https://github.com/Elora-V/NGS-M2AMI2B.git
 ```

Le dépot git est composé d'un dossier `doc` contenant des documents tel que le fichier de tutoriel VM, un fichier de commande bash ou l'énoncé du TP. Le fichier `src`contient les codes, et `config.sh` permet de choisir la nomenclature des dossiers crées par ces codes (dossier de données, de résultats ...).

```bash
cd NGS-M2AMI2B
```

- Installation outils

```bash 
source ./src/EnvirRNAseq.sh
# mettre source est non pas sh est important: sinon cela entraine un probleme d'environnement conda 
#(conda activate ne fonctionne pas dans le script alors qu'il fonctionne en ligne de commande directement dans le terminal)
```

- Recupération résultats présent en local (si besoin)

```bash
# scp source target (Faire en local !!)
scp cheminLocal ubuntu@134.158.248.133:${chemin sur VM ou .}
```

<h3> Analyse RNA-seq </h3>

```bash 
sh ./src/AnalyseRNAseq.sh
```

Ce script crée un dossier `data`où sont les fasta à analyser, et un dossier `result` comprennant les résultats des différentes étapes.

```bash
# avec les noms actuels du fichier config.sh, voilà ce que ça donne :

├── data
├── doc
├── result
│   ├── result_counts
│   ├── result_fastqc
│   ├── result_star
│   │   ├── result_star_align
│   │   └── result_star_index
│   └── result_trim
│       └── fastqc_of_trim
└── src

``` 

<h3> Récupérer les résultats et quitter la VM </h3>

- Recupérer les résultats (si besoin)
  
```bash
tar -czvf result.tar.gz result # avant on compresse les resultats

```

```bash
scp ubuntu@134.158.248.133:${fichier_VM} ${lieu arrivée (. si pas précision)} #remplacer url VM, (Faire en local !!)
```

```bash
tar -zxvf result.tar.gz # on decompresse en local si veut voir les resultats
```

- Recupérer code sur git (si besoin)

```bash 
git add ./src/*
git commit -m "message"
git push
```
Ou tous récupérer mais faut supprimer les dossiers trop lourd ! ( dossier data et result ).
  
- Quitter la VM

```bash
exit
```




