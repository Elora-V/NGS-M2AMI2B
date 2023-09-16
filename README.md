# NGS-M2AMI2B


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

- Installation outils

```bash 
sh ./scr/EnvirRNAseq.sh
```

- Recupération résultats présent en local (si besoin)

```bash
# scp source target (Faire en local !!)
scp cheminLocal ubuntu@134.158.248.133:${chemin sur VM ou .}
```

<h3> Analyse RNA-seq </h3>

```bash 
sh ./scr/AnalyseRNAseq.sh
```

Ce script crée un dossier `data`où sont les fasta à analyser, et un dossier `result` comprennant les résultats des différentes étapes.


<h3> Récupérer les résultats et quitter la VM </h3>

- Recupérer les résultats

```bash
scp ubuntu@134.158.248.133:${fichier_VM} ${lieu arrivée (. si pas précision)} #remplacer url VM, (Faire en local !!)
```

- Recupérer code sur git

```bash 
git add ./scr/EnvirRNAseq.sh
git add ./scr/AnalyseRNAseq.sh
```
Ou tous récupérer mais faut supprimer les docciers trop lourd ! ( dossier data et result ).
  
- Quitter la VM

```bash
exit
```




