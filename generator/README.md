# Railway Snapshot Generator

This module creates two realistic railway operation snapshots (T1 and T2) aligned with the project specification. Each snapshot contains consistent CSV exports for the OLTP schema plus an external weather feed, with about one million `Ride_Section` records per snapshot by default.

- T1 covers 2023-01-01 to 2024-06-30.
- T2 replays all T1 rows and appends new data through 2025-10-31 together with dimension changes (crossing upgrades, operator switches, additional drivers).

## Quick start

```bash
cd generator
uv run main.py  # or: python -m pip install -r requirements.txt && python main.py
```

The script writes CSVs into `output/T1` and `output/T2` (relative to this folder) unless overridden.

## Configuration knobs

Set optional environment variables before running to adjust scale or target paths:

- `RAILGEN_T1_RIDES` (default `100000`)
- `RAILGEN_T2_RIDES` (default `100000`)
- `RAILGEN_OUTPUT_DIR` (default `output` relative to `main.py`)
- `RAILGEN_SEED` (default `42`)

Example (generate smaller sample for smoke tests):

```bash
RAILGEN_T1_RIDES=1000 RAILGEN_T2_RIDES=1000 uv run main.py
```

## Output layout

For each snapshot the generator produces:

- `Train.csv`, `Driver.csv`, `Station.csv`, `Crossing.csv`, `Event.csv`
- `Ride.csv`, `Ride_Section.csv`, `Event_On_Route.csv`
- `weather.csv` (kept outside the database to mirror the second data source)

T2 files always include the full T1 history plus incremental changes. Facts are appended by copying T1 CSVs to the T2 folder and writing only the delta rows.

## Built-in business effects

- Crossing upgrades: hundreds of legacy crossings gain full protection from 2025-02-01 onward and show lower incident probabilities afterward.
- Operator changes: several dozen PKP Cargo trains receive new DB Cargo Polska rows and swap over from 2025-03-01 rides.
- Workforce churn: a few hundred new drivers arrive in T2 with more recent employment years.
- Delay signals follow the plan (weather, hotspots, time of day, driver experience, operator differences, seasonal precipitation).

Weather is produced exclusively in the CSV feed (`weather.csv`) using Polish headers (`id_odcinka`, `data_pomiaru`, `temperatura`, `ilosc_opadow`, `typ_opadow`).
