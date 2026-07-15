-- ============================================================
-- Modèle : stg_infoclimat_observations
-- Objectif :
-- Standardiser les observations météo issues de la source Infoclimat
-- avec une structure raw fidèle à la source.
-- ============================================================

select
    trim(id_station) as station_id,
    cast(dh_utc as timestamp) as observed_at,
    cast(temperature as numeric) as temperature,
    cast(humidite as numeric) as humidity,
    cast(pression as numeric) as pressure,
    cast(point_de_rosee as numeric) as dew_point,
    cast(vent_moyen as numeric) as wind_speed_avg,
    cast(nullif(trim(vent_direction::text), '') as numeric) as wind_direction,
    cast(pluie_1h as numeric) as precip_1h,
    cast(pluie_3h as numeric) as precip_3h,
    cast(null as numeric) as precip_rate,
    cast(null as numeric) as precip_accum,
    'infoclimat' as source_system
from {{ source('infoclimat_raw', 'infoclimat_observations_raw') }}