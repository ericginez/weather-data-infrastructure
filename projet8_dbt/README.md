--------------
PIPELINE LOCAL
--------------

Sources RAW
   ↓
Staging = nettoyage + cast + standardisation + contexte technique
   ↓
Intermediate = union + harmonisation métier
   ↓
Marts = dimension + table de faits
   ↓
Tests dbt = qualité + cohérence + intégrité référentielle

------------
ARCHITECTURE
------------

RAW / SOURCES
│
├─ Weather Underground
│  ├─ weatherug_stations_raw
│  ├─ weatherug_ichtegem_011024_raw
│  ├─ ...
│  ├─ weatherug_ichtegem_071024_raw
│  ├─ weatherug_lamadeleine_011024_raw
│  ├─ ...
│  └─ weatherug_lamadeleine_011024_raw
│
└─ Infoclimat
   ├─ infoclimat_stations_raw
   ├─ infoclimat_observations_raw


STAGING
│
├─ Stations
│  ├─ stg_weatherug_stations
│  │   - trim / cast
│  │   - standardisation des noms de colonnes
│  │   - conserve hardware / software
│  │
│  └─ stg_infoclimat_stations
│      - trim / cast
│      - standardisation des noms de colonnes
│      - conserve type / license
│
└─ Observations
   ├─ stg_weatherug_observations
   │   - union des tables journalières WeatherUG
   │   - ajout station_id + date
   │   - conversions d’unités :
   │       °F -> °C
   │       in -> hPa
   │       mph -> km/h
   │   - conversion wind_direction en degrés
   │   - ajoute source_system = 'weatherug'
   │   - conserve precip_rate / precip_accum
   │
   └─ stg_infoclimat_observations
       - union des tables de relevés Infoclimat
       - cast des colonnes numériques
       - wind_direction en numeric
       - ajoute source_system = 'infoclimat'
       - conserve precip_1h / precip_3h


INTERMEDIATE
│
├─ int_dim_weather_stations
│   - union des 2 modèles de stations
│   - harmonisation métier
│   - création de station_source
│   - création de license_unified
│
└─ int_fact_weather_observations
    - union des 2 modèles d’observations
    - structure commune des mesures météo
    - conservation des champs spécifiques pluie :
      precip_1h / precip_3h / precip_rate / precip_accum


MARTS
│
├─ dim_weather_stations
│   - dimension finale des stations
│   - clé : station_id
│
└─ fact_weather_observations
    - table de faits finale
    - clé analytique : station_id + observed_at
    - mesures météo harmonisées


TESTS DBT
│
├─ staging/schema.yml
│   - not_null
│   - unique
│   - accepted_values
│   - accepted_range
│
└─ marts/schema.yml
    - not_null
    - unique
    - relationships fact -> dim
    - accepted_values

------------
PIPELINE AWS
------------

Sources (API / fichiers)
        ↓
     Airbyte (AWS)
        ↓
PostgreSQL (Amazon RDS)
        ↓
      DBT (ECS)
        ↓
    Tables marts
        ↓
Monitoring + logs (CloudWatch)

Sources de données
   ↓
Airbyte sur EC2
   ↓
Amazon RDS PostgreSQL
   ↓
DBT dans un conteneur ECS Fargate
   ↓
EventBridge Scheduler déclenche les runs DBT
   ↓
CloudWatch centralise logs + métriques
