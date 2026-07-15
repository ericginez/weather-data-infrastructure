-- Standardisation des métadonnées des stations Infoclimat
-- Objectif :
-- 1. harmoniser les noms de colonnes avec le schéma cible
-- 2. convertir les coordonnées et l'altitude en types numériques
-- 3. compléter les colonnes absentes dans cette source par des valeurs nulles

select
    -- Identifiant technique de la station dans la source Infoclimat
    trim(id) as station_id,

    -- Nom lisible de la station
    trim(name) as station_name,

    -- Type de station fourni par Infoclimat
    type as station_type,

    -- Licence ou conditions d'utilisation associées à la station
    license,

    -- Coordonnées géographiques converties en numérique
    cast(latitude as numeric) as latitude,
    cast(longitude as numeric) as longitude,

    -- Altitude de la station convertie en numérique
    cast(elevation as numeric) as elevation,

    -- Champs absents dans Infoclimat mais présents dans le modèle cible
    cast(null as varchar) as city,
    cast(null as varchar) as state,
    cast(null as varchar) as hardware,
    cast(null as varchar) as software

from {{ source('infoclimat_raw', 'infoclimat_stations_raw') }}