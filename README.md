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

### Initier un environnement de développement incluant une version locale de ode-bootstrap

Git-cloner ode-bootstrap et ode-bootstrap-neo côte-à-côte dans un même sous-dossier (par exemple : projects/ode-boostrap et projects/ode-boostrap-neo)

Lancer un build de ode-bootstrap (voir la documentation)

Puis lancer la commande suivante:
```
./build.sh clean initDev build
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

## Surcharges
### Comment créer une surcharge ?

1. Créer un dossier avec le nom de la surcharge dans le dossier `scss/overrides`, exemple : `scss/overrides/cg77`

2. A l'intérieur de ce dossier, créer un fichier `_variables.scss` et un fichier `_overrides.scss` :

- Le fichier `_variables.scss` est destiné uniquement aux surcharges de variables
- Le fichier `_overrides.scss` est destiné aux surcharges de classes

**Note** : Ces 2 fichiers sont obligatoires, ils peuvent être laissés vides si pas de surcharge de variables ou pas de surcharge de classes

**Note** : Ne mettre que les variables et sélecteurs spécifiques à la surcharge

### Comment déployer la surcharge sur un springboard en local ?

1. Lancer la commande : `./build.sh -o="<override>" clean init install`
2. Un artefact `com.opendigitaleducation~ode-bootstrap-neo-[override]~[version]` sera installé dans les dépendances maven local (exemple : `com.opendigitaleducation~ode-bootstrap-neo-cg77~1.0-SNAPSHOT`)
3. Faire pointer votre springboard local sur l'artefact généré en éditant le fichier ent-core.json, comme suit :

exemple avec la surcharge "cg77" : 

```
{
  "name":"com.opendigitaleducation~ode-bootstrap-neo-cg77~1.0-SNAPSHOT",
  "type": "theme",
  "waitDeploy": true,
  "extension":"-fat.jar"
}
```

### Comment déployer la surcharge sur une plateforme distante ?

1. Créer un job Jenkins avec un paramètre de build `OVERRIDE` avec la valeur du nom de dossier de la surcharge créé, exemple : `cg77`
2. Le job doit pointer sur le dépôt `git@github.com:opendigitaleducation/ode-bootstrap-neo.git` et utiliser le script `Jenkinsfile`
3. Lancer le job Jenkins. Un artefact `com.opendigitaleducation~ode-bootstrap-neo-[override]~[version]` sera créé (exemple : `com.opendigitaleducation~ode-bootstrap-neo-cg77~1.0-SNAPSHOT`)
4. Configurer le springboard de la plateforme pour faire pointer le module ode-bootstraop-neo vers l'artefact de la surcharge :

exemple avec la surcharge "cg77" : 

```
{
  "name":"com.opendigitaleducation~ode-bootstrap-neo-cg77~1.0-SNAPSHOT",
  "type": "theme",
  "waitDeploy": true,
  "extension":"-fat.jar"
}
```