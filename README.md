# NGS-M2AMI2B

<h3> Configuration environnement </h3>

- Installer git

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

<h3> Analyse RNA-seq </h3>

```bash 
sh ./scr/AnalyseRNAseq.sh
```

