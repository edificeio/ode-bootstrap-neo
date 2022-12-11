# ODE Bootsrap NEO

ODE Bootstrap NEO is a theme based on ODE bootstrap framework.
This theme is customisable through variables, so it is possible to create a new theme based on this one.

## Install

Install it by cloning the repository:
```
git clone https://github.com/opendigitaleducation/ode-bootstrap-neo.git
./build.sh clean initDev
```

## Dev

Working with `ode-dev-server`, you can watch the SCSS files to copy them directly in the right folder.

```
yarn watch
```

Working on `ode-react-ui` library, you can watch the SCSS files to copy them inside Storybook folder.

```
yarn watch:react
```

## Components

To override styles we use SCSS and CSS Variables.

```scss
// ode-bootstrap-neo > _treeview.scss

$selected-background-color: $blue-100;

.treeview {
  --#{$prefix}selected-background-color: #{$selected-background-color};
}
```

<!-- ## Surcharges
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
``` -->