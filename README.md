# Cours de L3

Ce repo contient mes notes des cours de mathématiques dispensés aux L3 à l'ENS de Lyon. Il contient:

- Les cours de prémaster (Thomas Budzinski)
- Les cours d'algèbre (François Brunault, Sandra Rozensztajn)
- Les cours de topologie et de calcul différentiel (Laurent Berger)
- Les cours d'intégration et de théorie de la mesure (Claude Danthony, Grégory Miermont)

Il ne contient pas les cours d'analyse d'Emmanuel Peyre, qui nous a fourni un support de cours numérique.

Les notes et les erreurs qui peuvent s'y glisser n'engagent évidemment que moi.

### Compilation

Un Makefile (autodocumenté) permet la compilation aisée des fichiers du repo. Il faut avoir installé `latexmk`.
Pour obtenir une liste des targets disponible, utiliser simplement `make`. Pour tout compiler, utilise `make all`.

### PDF Compilés

À chaque push, Github Actions se charge de compiler le projet et déploie les fichiers compilés en tant que release.
La dernière version des fichiers compilés est donc toujours disponible [ici](https://github.com/FliiFe/cours-l3/releases/latest)

Le fichier `cours.zip` contient l'ensemble de tous les fichiers compilés, y compris les pdf des chapitres compilés individuellement.
