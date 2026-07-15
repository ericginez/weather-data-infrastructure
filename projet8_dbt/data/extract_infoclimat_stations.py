import json
import csv

with open("infoclimat_raw.json", "r", encoding="utf-8") as f:
    data = json.load(f)

stations = data.get("stations", [])

if not stations:
    raise Exception("La clé 'stations' est introuvable ou vide")

# récupérer toutes les colonnes
columns = sorted({k for row in stations for k in row.keys()})

with open("infoclimat_stations_raw.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=columns)
    writer.writeheader()
    writer.writerows(stations)

print(f"OK : {len(stations)} stations extraites")
print("Colonnes :", columns)