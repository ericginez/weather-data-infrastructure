# Image de base légère avec Python 3.12
FROM python:3.12-slim

# Répertoire de travail dans le conteneur
WORKDIR /app

# Installation de dbt avec l’adapter PostgreSQL
# --no-cache-dir permet de réduire la taille de l’image
RUN pip install --no-cache-dir dbt-postgres==1.10.0

# Copie de tout le projet dbt dans le conteneur
# (models, macros, dbt_project.yml, etc.)
COPY . /app

# Copie du fichier de configuration dbt (profiles.yml)
# dans le dossier attendu par dbt (/root/.dbt/)
COPY docker_dbt/profiles.yml /root/.dbt/profiles.yml

# Commande exécutée au démarrage du conteneur :
# 1. exécute les transformations dbt
# 2. lance les tests de qualité
# 3. génère la documentation (lineage)
CMD ["sh", "-c", "dbt run --target aws && dbt test --target aws && dbt docs generate --target aws"]