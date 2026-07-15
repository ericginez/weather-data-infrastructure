{% macro generate_schema_name(custom_schema_name, node) %}

    -- Cette macro dbt permet de définir dynamiquement le schéma dans lequel les modèles seront créés.

    -- custom_schema_name : schéma défini dans le modèle (ex: staging, marts, etc.)
    -- node : objet dbt représentant le modèle (non utilisé ici)

    -- Ici, on retourne directement le nom du schéma personnalisé sans le modifier ni le préfixer.

    {{ custom_schema_name }}

{% endmacro %}