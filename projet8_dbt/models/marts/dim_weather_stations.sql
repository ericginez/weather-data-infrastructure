{{ config(
    materialized='table',
    indexes=[
      {'columns': ['station_id'], 'unique': true}
    ]
) }}

-- Dimension des stations météorologiques
-- Objectif :
-- 1. fournir les attributs descriptifs des stations
-- 2. permettre les jointures avec la table de faits
-- 3. centraliser les métadonnées issues des différentes sources
-- Index unique pour garantir l’unicité des stations

select
    -- Identifiant unique de la station (clé de dimension)
    station_id,

    -- Nom lisible de la station
    station_name,

    -- Source d'origine de la station (Infoclimat ou Weather Underground)
    station_source,

    -- Type de station (normalisé ou enrichi)
    station_type,

    -- Localisation géographique
    latitude,
    longitude,

    -- Altitude de la station en mètres
    elevation,

    -- Métadonnée unifiée issue de la source
    -- (licence Infoclimat ou information équivalente côté Weather Underground)
    license_unified

from {{ ref('int_weather_stations') }}
