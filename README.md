# Infrastructure de données météorologiques avec dbt, PostgreSQL et AWS

Projet réalisé dans le cadre du parcours **Data Engineer OpenClassrooms**.

L’objectif est de construire et tester une infrastructure de données capable
d’intégrer des observations météorologiques issues de plusieurs sources,
de les normaliser et de produire un modèle analytique unifié.

Le projet s’appuie sur :

- **Python** et **Pandas** pour extraire et préparer les données ;
- **PostgreSQL** pour stocker les données ;
- **dbt** pour transformer, documenter et tester les modèles ;
- **Docker** pour rendre l’environnement reproductible ;
- **AWS** pour déployer et planifier les traitements dans le cloud.

---

## Contexte

Les données météorologiques proviennent de deux systèmes distincts :

- **Infoclimat** ;
- **Weather Underground**.

Chaque source possède :

- ses propres identifiants de stations ;
- ses propres structures de fichiers ;
- ses propres noms de colonnes ;
- des formats de dates différents ;
- des unités ou métadonnées spécifiques.

Le projet consiste à réunir ces données dans une infrastructure cohérente afin
de produire :

- une dimension harmonisée des stations météorologiques ;
- une table de faits contenant les observations météorologiques ;
- des contrôles de qualité automatisés ;
- une architecture locale reproductible ;
- une infrastructure cloud permettant l’exécution planifiée des traitements.

---

## Objectifs

Le projet permet de :

- extraire les stations et observations Infoclimat ;
- convertir les fichiers Weather Underground ;
- charger les données brutes dans PostgreSQL ;
- normaliser les structures des deux sources ;
- harmoniser les unités météorologiques ;
- rapprocher les stations provenant de plusieurs systèmes ;
- produire un modèle dimensionnel ;
- contrôler la qualité des données avec dbt ;
- documenter les modèles et leurs colonnes ;
- exécuter les transformations dans Docker ;
- déployer l’image de traitement dans AWS ;
- planifier l’exécution du pipeline dans le cloud.

---

## Architecture générale

```text
┌──────────────────────────────┐
│ Sources météorologiques      │
│                              │
│ - Infoclimat                 │
│ - Weather Underground        │
└──────────────┬───────────────┘
               │
               │ Extraction et conversion Python
               ▼
┌──────────────────────────────┐
│ Tables brutes PostgreSQL     │
│                              │
│ - stations                   │
│ - observations              │
│ - fichiers journaliers      │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Couche dbt staging           │
│                              │
│ - typage                     │
│ - renommage                  │
│ - conversion des unités      │
│ - contrôles élémentaires     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Couche dbt intermediate      │
│                              │
│ - union des sources          │
│ - harmonisation              │
│ - préparation analytique     │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Couche dbt marts             │
│                              │
│ dim_weather_stations         │
│ fact_weather_observations    │
└──────────────────────────────┘
```

---

## Architecture cloud

L’architecture cloud mise en œuvre utilise plusieurs services AWS.

```text
Sources de données
       │
       ▼
Airbyte sur Amazon EC2
       │
       ▼
Amazon RDS for PostgreSQL
       │
       ▼
Image dbt stockée dans Amazon ECR
       │
       ▼
Tâche planifiée Amazon ECS
       │
       ▼
Modèles staging, intermediate et marts
```

Les principaux composants sont :

| Service | Utilisation |
|---|---|
| Amazon EC2 | Hébergement de l’instance Airbyte |
| Amazon RDS for PostgreSQL | Stockage des données brutes et transformées |
| Amazon ECR | Stockage de l’image Docker du projet dbt |
| Amazon ECS | Exécution conteneurisée des transformations dbt |
| Planification ECS | Déclenchement automatique du traitement |
| IAM | Gestion des autorisations entre les services |

Le déploiement AWS a été réalisé dans la région :

```text
eu-west-3
```

---

## Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Python 3.12 | Extraction et conversion des données |
| Pandas | Manipulation des données tabulaires |
| OpenPyXL | Lecture des fichiers Excel |
| PostgreSQL 15 | Stockage relationnel local |
| Amazon RDS PostgreSQL | Stockage cloud |
| dbt-postgres | Transformation, tests et documentation |
| dbt-utils | Tests génériques complémentaires |
| Docker | Conteneurisation de dbt |
| Docker Compose | Exécution locale de PostgreSQL |
| Airbyte | Ingestion des données |
| Amazon EC2 | Hébergement d’Airbyte |
| Amazon ECR | Registre d’images Docker |
| Amazon ECS | Exécution planifiée des traitements |
| Poetry | Gestion des dépendances Python |
| Git et GitHub | Versionnement et publication |

---

## Arborescence du dépôt

```text
.
├── .gitignore
├── README.md
├── poetry.lock
├── pyproject.toml
├── docker/
│   └── docker-compose.yml
└── projet8_dbt/
    ├── Dockerfile
    ├── dbt_project.yml
    ├── packages.yml
    ├── package-lock.yml
    ├── data/
    │   ├── convert_weatherug.py
    │   ├── extract_infoclimat_observations.py
    │   └── extract_infoclimat_stations.py
    ├── docker_dbt/
    │   └── profiles.yml
    ├── macros/
    │   └── generate_schema_name.sql
    ├── models/
    │   ├── sources.yml
    │   ├── staging/
    │   │   ├── schema.yml
    │   │   ├── stg_infoclimat_observations.sql
    │   │   ├── stg_infoclimat_stations.sql
    │   │   ├── stg_weatherug_observations.sql
    │   │   └── stg_weatherug_stations.sql
    │   ├── intermediate/
    │   │   ├── int_weather_observations.sql
    │   │   └── int_weather_stations.sql
    │   └── marts/
    │       ├── schema.yml
    │       ├── dim_weather_stations.sql
    │       └── fact_weather_observations.sql
    ├── analyses/
    ├── seeds/
    ├── snapshots/
    └── tests/
```

Les fichiers de données brutes, les profils contenant les identifiants, les
logs et les artefacts générés par dbt ne sont pas versionnés.

---

## Dépendances Python

Le projet utilise Python 3.12 ou une version ultérieure.

Les dépendances principales sont déclarées dans `pyproject.toml` :

```toml
dependencies = [
    "dbt-postgres (>=1.10.0,<2.0.0)",
    "openpyxl (>=3.1.5,<4.0.0)",
    "pandas (>=3.0.2,<4.0.0)"
]
```

Installer les dépendances avec Poetry :

```powershell
poetry install
```

Vérifier l’environnement :

```powershell
poetry run python --version
poetry run dbt --version
```

---

## Sources de données

Les données brutes proviennent de deux sources.

### Infoclimat

Les scripts suivants assurent l’extraction :

```text
projet8_dbt/data/extract_infoclimat_stations.py
projet8_dbt/data/extract_infoclimat_observations.py
```

Ils permettent de récupérer :

- les métadonnées des stations ;
- les observations météorologiques ;
- les identifiants des stations ;
- les coordonnées géographiques ;
- les mesures météorologiques disponibles.

Les tables sources déclarées dans dbt sont :

```text
staging.infoclimat_stations_raw
staging.infoclimat_observations_raw
```

### Weather Underground

Le script suivant convertit les fichiers Excel Weather Underground :

```text
projet8_dbt/data/convert_weatherug.py
```

Les données couvrent deux stations :

```text
ILAMAD25
IICHTE19
```

Les observations sont réparties dans des tables journalières pour la période
du 1er au 7 octobre 2024.

La table des stations est :

```text
staging.weatherug_stations_raw
```

Les tables d’observations suivent le modèle :

```text
weatherug_observations_raw_<station>_<date>
```

---

## Sources déclarées dans dbt

Le fichier suivant référence les tables brutes :

```text
projet8_dbt/models/sources.yml
```

Deux sources dbt sont définies :

```yaml
weatherug_raw
infoclimat_raw
```

La source Weather Underground comprend :

- une table de stations ;
- sept tables journalières pour Ichtegem ;
- sept tables journalières pour La Madeleine.

La source Infoclimat comprend :

- une table de stations ;
- une table d’observations.

---

## Architecture dbt

Le projet dbt utilise trois couches de transformation.

### Couche staging

Configuration :

```yaml
staging:
  +materialized: view
  +schema: staging
```

Les modèles staging sont matérialisés sous forme de vues.

Ils assurent :

- le renommage des colonnes ;
- la conversion des types ;
- la standardisation des dates ;
- la normalisation des unités ;
- la sélection des champs utiles ;
- le contrôle initial de la qualité.

Les quatre modèles sont :

```text
stg_infoclimat_stations
stg_infoclimat_observations
stg_weatherug_stations
stg_weatherug_observations
```

---

### Couche intermediate

Configuration :

```yaml
intermediate:
  +materialized: view
  +schema: intermediate
```

Les modèles intermédiaires réunissent les données des deux systèmes.

Les deux modèles sont :

```text
int_weather_stations
int_weather_observations
```

Ils assurent notamment :

- l’union des stations ;
- l’union des observations ;
- l’ajout de la source d’origine ;
- l’harmonisation des colonnes ;
- la préparation des modèles analytiques finaux.

---

### Couche marts

Configuration :

```yaml
marts:
  +materialized: table
  +schema: marts
```

Les modèles de marts sont matérialisés sous forme de tables.

Ils constituent le modèle analytique final :

```text
dim_weather_stations
fact_weather_observations
```

---

## Modèle dimensionnel

### Dimension des stations

```text
marts.dim_weather_stations
```

Cette dimension décrit les stations météorologiques harmonisées.

Principales colonnes :

| Colonne | Description |
|---|---|
| `station_id` | Identifiant unique de la station |
| `station_name` | Nom lisible de la station |
| `station_source` | Source Infoclimat ou Weather Underground |
| `station_type` | Type ou catégorie de station |
| `latitude` | Latitude |
| `longitude` | Longitude |
| `elevation` | Altitude en mètres |
| `license_unified` | Licence ou métadonnée unifiée |

La configuration de staging attend :

- quatre identifiants Infoclimat ;
- deux identifiants Weather Underground.

---

### Table de faits des observations

```text
marts.fact_weather_observations
```

La granularité est :

```text
une station à un instant d’observation
```

Principales colonnes :

| Colonne | Description |
|---|---|
| `station_id` | Identifiant de la station |
| `observed_at` | Date et heure de l’observation |
| `temperature` | Température en degrés Celsius |
| `humidity` | Humidité relative en pourcentage |
| `pressure` | Pression atmosphérique en hPa |
| `dew_point` | Point de rosée en degrés Celsius |
| `wind_speed_avg` | Vitesse moyenne du vent en km/h |
| `wind_direction` | Direction du vent en degrés |
| `precip_1h` | Précipitations sur une heure |
| `precip_3h` | Précipitations sur trois heures |
| `precip_rate` | Intensité des précipitations |
| `precip_accum` | Cumul de précipitations |
| `source_system` | Source de l’observation |

---

## Tests de qualité dbt

Les tests sont déclarés dans :

```text
projet8_dbt/models/staging/schema.yml
projet8_dbt/models/marts/schema.yml
```

### Tests d’intégrité

Les tests vérifient notamment :

- l’absence de valeurs nulles ;
- l’unicité des identifiants de stations ;
- l’unicité du couple `station_id` et `observed_at` ;
- la cohérence des relations entre faits et dimensions ;
- la validité de la source d’origine.

### Tests sur les valeurs autorisées

Les sources autorisées sont :

```text
infoclimat
weatherug
```

Les identifiants de stations attendus sont contrôlés avec des tests
`accepted_values`.

### Tests de plages métier

Les observations doivent respecter les plages suivantes :

| Mesure | Minimum | Maximum |
|---|---:|---:|
| Température | -50 °C | 60 °C |
| Humidité | 0 % | 100 % |
| Pression | 850 hPa | 1 100 hPa |
| Vitesse moyenne du vent | 0 km/h | 150 km/h |

Ces tests utilisent la macro :

```text
dbt_utils.accepted_range
```

### Tests de relations

Chaque observation doit correspondre à une station présente dans :

```text
dim_weather_stations
```

Le test `relationships` garantit cette intégrité référentielle.

### Test d’unicité composite

Le couple suivant doit être unique :

```text
station_id + observed_at
```

Le test utilisé est :

```text
dbt_utils.unique_combination_of_columns
```

---

## Environnement PostgreSQL local

Le fichier :

```text
docker/docker-compose.yml
```

démarre une instance PostgreSQL 15.

Configuration locale :

```text
Conteneur : projet8_postgres
Port      : 5432
Base      : weather_db
Utilisateur : postgres
```

Démarrer PostgreSQL :

```powershell
docker compose -f docker\docker-compose.yml up -d
```

Vérifier le conteneur :

```powershell
docker compose -f docker\docker-compose.yml ps
```

Afficher les journaux :

```powershell
docker compose -f docker\docker-compose.yml logs -f postgres
```

Arrêter PostgreSQL :

```powershell
docker compose -f docker\docker-compose.yml down
```

Supprimer également le volume local :

```powershell
docker compose -f docker\docker-compose.yml down -v
```

---

## Configuration dbt

Le profil dbt doit fournir les paramètres de connexion PostgreSQL.

Exemple de structure à enregistrer dans un fichier local `profiles.yml` :

```yaml
projet8_dbt:
  target: dev

  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: postgres
      password: postgres
      dbname: weather_db
      schema: public
      threads: 4
```

Le fichier réel `profiles.yml` n’est pas publié, car il peut contenir des
identifiants ou des secrets.

Il est recommandé de fournir un fichier :

```text
profiles.example.yml
```

ne contenant aucune donnée sensible.

---

## Exécution locale de dbt

Installer les packages dbt :

```powershell
poetry run dbt deps `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Tester la connexion :

```powershell
poetry run dbt debug `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Construire les modèles :

```powershell
poetry run dbt run `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Exécuter les tests :

```powershell
poetry run dbt test `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Exécuter modèles et tests en une seule commande :

```powershell
poetry run dbt build `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

---

## Documentation dbt

Générer la documentation :

```powershell
poetry run dbt docs generate `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Servir la documentation localement :

```powershell
poetry run dbt docs serve `
    --project-dir projet8_dbt `
    --profiles-dir projet8_dbt\docker_dbt
```

Les artefacts générés dans `target/` ne sont pas versionnés.

---

## Conteneurisation de dbt

Le fichier suivant permet de construire l’image dbt :

```text
projet8_dbt/Dockerfile
```

Construire l’image localement :

```powershell
docker build `
    -t projet8-dbt:latest `
    projet8_dbt
```

Cette image regroupe :

- l’environnement Python ;
- dbt-postgres ;
- les dépendances du projet ;
- les modèles SQL ;
- les tests dbt.

L’image peut ensuite être publiée dans Amazon ECR et exécutée par Amazon ECS.

---

## Déploiement dans AWS

Le déploiement suit les étapes générales suivantes :

1. création de l’instance PostgreSQL dans Amazon RDS ;
2. création de l’instance EC2 utilisée pour Airbyte ;
3. configuration de l’ingestion des données ;
4. construction de l’image Docker dbt ;
5. authentification auprès d’Amazon ECR ;
6. publication de l’image ;
7. création de la définition de tâche ECS ;
8. configuration du réseau et des autorisations ;
9. création d’une tâche planifiée ;
10. exécution de dbt dans ECS ;
11. vérification des tables et des tests dans RDS.

---

## Sécurité

Les éléments suivants ne doivent jamais être publiés :

- les clés privées EC2 ;
- les fichiers `.pem` ;
- les mots de passe PostgreSQL ;
- les identifiants AWS ;
- les fichiers `.env` ;
- les profils dbt contenant des secrets ;
- les URL de connexion intégrant un mot de passe.

Le fichier :

```text
oc-projet8-key.pem
```

est explicitement exclu par `.gitignore`.

Les secrets de production doivent être gérés avec :

- les variables d’environnement ;
- AWS Secrets Manager ;
- AWS Systems Manager Parameter Store ;
- les rôles IAM.

---

## Résultats

Le projet permet de produire :

- quatre modèles de staging ;
- deux modèles intermédiaires ;
- une dimension des stations ;
- une table de faits des observations ;
- six enregistrements de stations attendus dans les contrôles de staging ;
- une harmonisation des données Infoclimat et Weather Underground ;
- des tests de qualité automatisés ;
- une documentation dbt ;
- une image Docker déployable ;
- une exécution planifiée dans Amazon ECS.

Les données finales sont structurées pour faciliter :

- l’analyse temporelle des observations ;
- la comparaison des stations ;
- la comparaison des sources ;
- le calcul d’indicateurs météorologiques ;
- l’alimentation d’un outil de reporting.

---

## Limites et évolutions possibles

Le projet pourrait être enrichi avec :

- une ingestion réellement incrémentale ;
- une historisation des chargements ;
- des tests de fraîcheur des sources ;
- une gestion des doublons en amont ;
- des snapshots dbt ;
- une orchestration plus complète ;
- des alertes en cas d’échec ;
- une supervision des coûts AWS ;
- un déploiement avec Terraform ;
- un pipeline CI/CD ;
- une séparation des environnements de développement et de production ;
- une centralisation des logs dans CloudWatch ;
- une politique de rétention des données ;
- un data catalog ;
- une couche de visualisation.

---

## Compétences démontrées

- conception d’une infrastructure de données ;
- intégration de plusieurs sources ;
- extraction de données avec Python ;
- traitement de fichiers Excel et JSON ;
- modélisation dimensionnelle ;
- transformation de données avec dbt ;
- structuration en couches staging, intermediate et marts ;
- création de tests de qualité ;
- contrôle de l’intégrité référentielle ;
- documentation de modèles ;
- utilisation de PostgreSQL ;
- conteneurisation avec Docker ;
- déploiement d’images dans Amazon ECR ;
- exécution de traitements dans Amazon ECS ;
- utilisation d’Amazon RDS ;
- gestion des secrets et des accès cloud ;
- diagnostic d’une infrastructure locale et cloud.

---

## Auteur

**Eric Ginez**  
Parcours Data Engineer — OpenClassrooms