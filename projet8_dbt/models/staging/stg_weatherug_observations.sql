-- ============================================================
-- Modèle : stg_weatherug_observations
-- Objectif :
-- 1. consolider les fichiers journaliers Weather Underground chargés dans RDS
-- 2. standardiser les unités et les noms de colonnes
-- 3. produire une structure homogène avec les autres sources météo
--
-- Remarque :
-- Les tables raw conservent les noms issus des fichiers S3, avec un suffixe
-- de date au format DDMMYY (ex: weatherug_observations_raw_ichtegem_011024).
-- ============================================================

with raw_union as (

    -- Station IICHTE19 - Ichtegem
    select 'IICHTE19' as station_id, '2024-10-01' as obs_date, *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_011024') }}

    union all
    select 'IICHTE19', '2024-10-02', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_021024') }}

    union all
    select 'IICHTE19', '2024-10-03', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_031024') }}

    union all
    select 'IICHTE19', '2024-10-04', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_041024') }}

    union all
    select 'IICHTE19', '2024-10-05', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_051024') }}

    union all
    select 'IICHTE19', '2024-10-06', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_061024') }}

    union all
    select 'IICHTE19', '2024-10-07', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_ichtegem_071024') }}

    union all

    -- Station ILAMAD25 - La Madeleine
    select 'ILAMAD25', '2024-10-01', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_011024') }}

    union all
    select 'ILAMAD25', '2024-10-02', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_021024') }}

    union all
    select 'ILAMAD25', '2024-10-03', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_031024') }}

    union all
    select 'ILAMAD25', '2024-10-04', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_041024') }}

    union all
    select 'ILAMAD25', '2024-10-05', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_051024') }}

    union all
    select 'ILAMAD25', '2024-10-06', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_061024') }}

    union all
    select 'ILAMAD25', '2024-10-07', *
    from {{ source('weatherug_raw', 'weatherug_observations_raw_lamadeleine_071024') }}

)

select
    -- Identifiant de la station
    station_id,

    -- Horodatage reconstruit à partir de la date portée par le nom du fichier
    -- et du champ horaire présent dans le contenu brut
    cast(obs_date || ' ' || "Time" as timestamp) as observed_at,

    -- Température : Fahrenheit -> Celsius
    round(
        (cast(regexp_replace("Temperature", '[^0-9\.\-]', '', 'g') as numeric) - 32) * 5.0 / 9.0,
        2
    ) as temperature,

    -- Humidité relative déjà exprimée en %
    cast(regexp_replace("Humidity", '[^0-9\.\-]', '', 'g') as numeric) as humidity,

    -- Pression : inches of mercury -> hPa
    round(
        cast(regexp_replace("Pressure", '[^0-9\.\-]', '', 'g') as numeric) * 33.8639,
        2
    ) as pressure,

    -- Point de rosée : Fahrenheit -> Celsius
    round(
        (cast(regexp_replace("Dew_Point", '[^0-9\.\-]', '', 'g') as numeric) - 32) * 5.0 / 9.0,
        2
    ) as dew_point,

    -- Vitesse moyenne du vent : mph -> km/h
    round(
        cast(regexp_replace("Speed", '[^0-9\.\-]', '', 'g') as numeric) * 1.60934,
        2
    ) as wind_speed_avg,

    -- Direction du vent : cardinal -> degrés
    case trim("Wind")
        when 'North' then 0
        when 'NNE' then 22.5
        when 'NE' then 45
        when 'ENE' then 67.5
        when 'East' then 90
        when 'ESE' then 112.5
        when 'SE' then 135
        when 'SSE' then 157.5
        when 'South' then 180
        when 'SSW' then 202.5
        when 'SW' then 225
        when 'WSW' then 247.5
        when 'West' then 270
        when 'WNW' then 292.5
        when 'NW' then 315
        when 'NNW' then 337.5
        else null
    end as wind_direction,

    -- Champs absents dans cette source mais présents dans le schéma cible
    cast(null as numeric) as precip_1h,
    cast(null as numeric) as precip_3h,

    -- Précipitations : inches -> mm
    round(
        cast(nullif(regexp_replace("Precip__Rate_", '[^0-9\.\-]', '', 'g'), '') as numeric) * 25.4,
        2
    ) as precip_rate,
    round(
        cast(nullif(regexp_replace("Precip__Accum_", '[^0-9\.\-]', '', 'g'), '') as numeric) * 25.4,
        2
    ) as precip_accum,

    -- Source d'origine pour la traçabilité
    'weatherug' as source_system

from raw_union
