{{ config(
    materialized='table',
    indexes=[
      {'columns': ['station_id']},
      {'columns': ['observed_at']},
      {'columns': ['station_id', 'observed_at'], 'unique': true}
    ]
) }}

-- Table de faits principale contenant les observations météorologiques
-- Granularité : une observation par station et par instant (timestamp)
-- Source : consolidation intermédiaire des données multi-sources
-- Index :
-- 1. filtrage par station
-- 2. filtrage par période
-- 3. garantie d’unicité métier sur (station_id, observed_at)

select
    -- Clé de la station météo
    station_id,

    -- Horodatage précis de l'observation
    observed_at,

    -- Mesures météorologiques standardisées
    temperature,        -- °C
    humidity,           -- %
    pressure,           -- hPa
    dew_point,          -- °C

    -- Vent
    wind_speed_avg,     -- km/h
    wind_direction,     -- degrés

    -- Précipitations (selon disponibilité des sources)
    precip_1h,          -- mm
    precip_3h,          -- mm
    precip_rate,        -- mm
    precip_accum,       -- mm

    -- Traçabilité de la source d'origine
    source_system,

    -- Traçabilité de la planification des run dbt dans aws
    CAST('{{ run_started_at }}' AS timestamp) AS dbt_run_at,
	'{{ invocation_id }}' AS dbt_invocation_id
	
from {{ ref('int_weather_observations') }}
