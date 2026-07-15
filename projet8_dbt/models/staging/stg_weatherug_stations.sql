-- Standardisation des métadonnées des stations Weather Underground
-- Objectif :
-- 1. harmoniser les noms de colonnes avec le modèle cible
-- 2. convertir latitude, longitude et altitude en types numériques
-- 3. compléter le schéma cible avec des colonnes compatibles avec les autres sources

select
    -- Identifiant technique de la station dans la source Weather Underground
    trim(id::text) as station_id,

    -- Nom lisible de la station
    trim(name::text) as station_name,

    -- Valeur forcée pour harmoniser le type de station avec le modèle cible
    cast('amateur' as varchar) as station_type,

    -- Champ absent dans Weather Underground mais présent dans le modèle cible
    cast(null as jsonb) as license,

    -- Latitude convertie en numérique
    cast(
        nullif(
            trim(regexp_replace(latitude::text, '[^0-9\.\-]', '', 'g')),
            ''
        ) as numeric
    ) as latitude,

    -- Longitude convertie en numérique
    cast(
        nullif(
            trim(regexp_replace(longitude::text, '[^0-9\.\-]', '', 'g')),
            ''
        ) as numeric
    ) as longitude,

    -- Altitude convertie en numérique
    cast(
        nullif(trim(elevation::text), '') as numeric
    ) as elevation,

    -- Informations de localisation conservées pour enrichissement éventuel
    city,

    -- La valeur '-/-' n'apporte pas d'information exploitable
    nullif(trim(state::text), '-/-') as state,

    -- Métadonnées matérielles et logicielles propres à Weather Underground
    hardware,
    software

from {{ source('weatherug_raw', 'weatherug_stations_raw') }}
