-- Consolidation intermédiaire des observations météo
-- Objectif :
-- 1. regrouper les observations standardisées provenant d'Infoclimat et de Weather Underground
-- 2. conserver une structure homogène pour l'alimentation de la table de faits finale
-- 3. préserver la traçabilité de la source via source_system

select
    station_id,
    observed_at,
    temperature,
    humidity,
    pressure,
    dew_point,
    wind_speed_avg,
    wind_direction,
    precip_1h,
    precip_3h,
    precip_rate,
    precip_accum,
    source_system
from {{ ref('stg_infoclimat_observations') }}

union all

select
    station_id,
    observed_at,
    temperature,
    humidity,
    pressure,
    dew_point,
    wind_speed_avg,
    wind_direction,
    precip_1h,
    precip_3h,
    precip_rate,
    precip_accum,
    source_system
from {{ ref('stg_weatherug_observations') }}
