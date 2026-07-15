from pathlib import Path
import pandas as pd

SOURCE_DIR = Path.cwd()
OUTPUT_DIR = SOURCE_DIR / "weatherug_clean_csv"
OUTPUT_DIR.mkdir(exist_ok=True)

converted = []

for xlsx_file in SOURCE_DIR.glob("Weather*.xlsx"):
    print(f"Traitement : {xlsx_file.name}")

    df = pd.read_excel(xlsx_file)

    stem = xlsx_file.stem

    prefix = "Weather+Underground+-+"
    if not stem.startswith(prefix):
        print(f"⚠️ Préfixe inattendu : {xlsx_file.name}")
        continue

    core = stem[len(prefix):]

    # Cas observations : "<Lieu> - DDMMYY"
    if " - " in core:
        location, ddmmyy = core.split(" - ", 1)

        location_map = {
            "Ichtegem,+BE": "ichtegem",
            "La+Madeleine,+FR": "lamadeleine",
        }

        if location not in location_map:
            print(f"⚠️ Lieu inattendu : {xlsx_file.name}")
            continue

        if len(ddmmyy) != 6 or not ddmmyy.isdigit():
            print(f"⚠️ Date inattendue : {xlsx_file.name}")
            continue

        location_clean = location_map[location]
        csv_name = f"weatherug_observations_raw_{location_clean}_{ddmmyy}.csv"

    # Cas fichier stations
    elif core == "Stations":
        csv_name = "weatherug_stations_raw.csv"

    else:
        print(f"⚠️ Nom inattendu : {xlsx_file.name}")
        continue

    csv_path = OUTPUT_DIR / csv_name

    df.to_csv(
        csv_path,
        index=False,
        sep=",",
        encoding="utf-8"
    )

    converted.append(csv_name)

print("\nFichiers convertis :")
for name in converted:
    print("-", name)

print(f"\nDossier de sortie : {OUTPUT_DIR}")