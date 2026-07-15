-- Consolidation intermédiaire des métadonnées des stations météo
-- Objectif :
-- 1. regrouper les stations issues des différentes sources dans une structure commune
-- 2. harmoniser certains attributs pour faciliter l'exploitation analytique
-- 3. conserver l'information de provenance via station_source

-- Stations Infoclimat
select
    st.station_id,
    st.station_name,
    'infoclimat' as station_source,
    case
        when st.station_type is not null then st.station_type
        else 'unknown'
    end as station_type,
    st.latitude,
    st.longitude,
    st.elevation,
    st.license as license_unified
from {{ ref('stg_infoclimat_stations') }} st

union all

-- Stations Weather Underground
select
    st.station_id,
    st.station_name,
    'weatherug' as station_source,
    'amateur' as station_type,
    st.latitude,
    st.longitude,
    st.elevation,
    st.software as license_unified
from {{ ref('stg_weatherug_stations') }} st
