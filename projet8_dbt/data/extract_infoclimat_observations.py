import json
import csv
from pathlib import Path

input_path = Path("infoclimat_raw.json")
output_path = Path("infoclimat_observations_raw.csv")

with input_path.open("r", encoding="utf-8") as f:
    payload = json.load(f)

hourly = payload.get("hourly", {})
if not hourly:
    raise SystemExit("Clé 'hourly' introuvable ou vide.")

rows = []

for station_key, observations in hourly.items():
    if station_key.startswith("_"):
        continue
    if not isinstance(observations, list):
        continue

    for obs in observations:
        if not isinstance(obs, dict):
            continue

        row = dict(obs)

        # Sécurité minimale :
        # si id_station est absent ou vide dans une observation,
        # on le renseigne à partir de la clé de niveau hourly.
        if "id_station" not in row or row["id_station"] in (None, ""):
            row["id_station"] = station_key

        rows.append(row)

if not rows:
    raise SystemExit("Aucune observation extraite.")

fieldnames = sorted({k for row in rows for k in row.keys()})

with output_path.open("w", encoding="utf-8", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"CSV créé : {output_path}")
print(f"Lignes : {len(rows)}")
print("Colonnes :")
for c in fieldnames:
    print(f"- {c}")