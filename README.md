# ODE Bootsrap Neo

Ce thème NEO est une déclinaison du framework ODE Bootstrap.

## Installation

Installer Git et lancer la commande suivante dans un terminal
```
git clone git@code.web-education.net:ode/ode-bootstrap-neo.git
```

Lancer la tâche init:
```
./build.sh init
```

### Lancer le mode développeur

Lancer la commande suivante:
```
./build.sh install watch
```

Un serveur web démarre et l'URL s'affiche en console (généralement http://localhost:8080/doc).
Toutes les modifications sur le code source sont détectées et entrainent un rafraichissement de la page.

### Lancer un build

Lancer la commande suivante:
```
./build.sh build
```

Le css minifié est généré dans le dossier "dist".

### Lancer un build incorporant la version locale de ode-bootstrap

Lancer la commande suivante:
```
./build.sh clean init localDep build
```

Après chaque modification locale de ode-bootstrap, il faudra lancer la commande suivante:
```
./build.sh localDep build
```

Le css minifié est généré dans le dossier "dist".

## Linter SCSS

Lancer le linter sur les fichers scss du projet
```
./build.sh lint
```

Lancer le linter sur les fichers scss du projet et corriger certains problèmes de mise en forme
```
./build.sh lint-fix
```

Pour un affichage des problèmes en temps réel, installer le plugin VSC stylelint.
Pour une correction du formattage à l'enregistrement, ajouter au ficher de configuration settings.json:
```
"editor.codeActionsOnSave": {
    "source.fixAll.stylelint": true
},
```

## Documentation

Une documentation contenant l'ensemble de nos composants est disponible dans [ici](doc/index.html).

Voici la liste des variables personnalisables:

TODO

