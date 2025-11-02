import csv
import os
import random
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

from faker import Faker

# ---------------------------------------------------------------------------
# Configuration structures
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class StationMeta:
    station_id: int
    name: str
    city: str
    voivodeship: str
    region: str


@dataclass(frozen=True)
class CrossingMeta:
    crossing_id: int
    has_barriers: bool
    has_light_signals: bool
    is_lit: bool
    speed_limit: int
    region: str
    is_old: bool
    upgrade_target: Optional[int]


@dataclass(frozen=True)
class RouteTemplate:
    name: str
    station_ids: Sequence[int]
    section_minutes: Sequence[int]


@dataclass(frozen=True)
class SnapshotConfig:
    name: str
    start: datetime
    end: datetime
    ride_count: int
    base_event_rate: float


# ---------------------------------------------------------------------------
# Constants aligned with the business specification
# ---------------------------------------------------------------------------

VOIVODESHIPS = [
    "Dolnośląskie",
    "Kujawsko-Pomorskie",
    "Lubelskie",
    "Lubuskie",
    "Łódzkie",
    "Małopolskie",
    "Mazowieckie",
    "Opolskie",
    "Podkarpackie",
    "Podlaskie",
    "Pomorskie",
    "Śląskie",
    "Świętokrzyskie",
    "Warmińsko-Mazurskie",
    "Wielkopolskie",
    "Zachodniopomorskie",
]

COASTAL = {"Pomorskie", "Zachodniopomorskie"}
MOUNTAIN = {"Małopolskie", "Podkarpackie", "Śląskie"}

EVENT_DEFINITIONS = [
    ("wypadek", "potrącenie pieszego", 9),
    ("wypadek", "zderzenie z samochodem", 8),
    ("wypadek", "wykolejenie", 10),
    ("wypadek", "zderzenie z innym pociągiem", 10),
    ("incydent", "opóźnienie organizacyjne", 4),
    ("incydent", "przekroczenie limitu prędkości", 5),
    ("incydent", "problem z pasażerem", 3),
    ("awaria", "usterka hamulców", 7),
    ("awaria", "usterka sygnalizacji", 6),
    ("awaria", "awaria lokomotywy", 7),
    ("zdarzenie techniczne", "planowy postój", 2),
    ("zdarzenie techniczne", "test systemu", 2),
    ("zdarzenie techniczne", "brak maszynisty", 3),
]


def _env_int(name: str, default: int) -> int:
    value = os.getenv(name)
    if value is None:
        return default
    try:
        parsed = int(value)
    except ValueError:
        return default
    return parsed if parsed > 0 else default

T1_CONFIG = SnapshotConfig(
    name="T1",
    start=datetime(2023, 1, 1, 0, 0, 0),
    end=datetime(2024, 6, 30, 23, 59, 59),
    ride_count=_env_int("RAILGEN_T1_RIDES", 100_000),
    base_event_rate=0.035,
)

T2_CONFIG = SnapshotConfig(
    name="T2",
    start=datetime(2024, 7, 1, 0, 0, 0),
    end=datetime(2025, 10, 31, 23, 59, 59),
    ride_count=_env_int("RAILGEN_T2_RIDES", 100_000),
    base_event_rate=0.033,  # global improvement ~5%
)

UPGRADE_DATE = datetime(2025, 2, 1, 0, 0, 0)
SWITCH_DATE = datetime(2025, 3, 1, 0, 0, 0)


# ---------------------------------------------------------------------------
# Generator implementation
# ---------------------------------------------------------------------------


class RailwayDataGenerator:
    def __init__(self, output_root: Path, seed: int = 42) -> None:
        self.output_root = output_root
        self.rng = random.Random(seed)
        self.fake = Faker("pl_PL")
        Faker.seed(seed)

        self.stations: List[StationMeta] = []
        self.hotspot_station_ids: set[int] = set()
        self.crossings: Dict[int, CrossingMeta] = {}
        self.crossings_by_region: Dict[str, List[int]] = defaultdict(list)
        self.crossing_upgrade_map: Dict[int, int] = {}
        self.trains: Dict[int, Dict[str, str]] = {}
        self.train_switch_pairs: Dict[int, int] = {}
        self.train_switch_reverse: Dict[int, int] = {}
        self.drivers: Dict[int, Dict[str, object]] = {}
        self.events: Dict[int, Tuple[str, str, int]] = {}
        self.routes: List[RouteTemplate] = []

        self.next_train_id = 1
        self.next_crossing_id = 1
        self.next_driver_id = 1
        self.next_event_id = 1

        self.next_ride_id = 1
        self.next_section_id = 1
        self.next_event_on_route_id = 1

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def generate(self) -> None:
        self._prepare_output_dirs()
        self._build_dimensions()
        self._write_dimensions("T1")
        self._generate_facts(T1_CONFIG, snapshot_dir=self._snapshot_dir("T1"))
        self._augment_dimensions_for_t2()
        self._write_dimensions("T2")
        self._prepare_t2_fact_files()
        self._generate_facts(T2_CONFIG, snapshot_dir=self._snapshot_dir("T2"), append=True)

    # ------------------------------------------------------------------
    # Dimension preparation
    # ------------------------------------------------------------------

    def _prepare_output_dirs(self) -> None:
        self.output_root.mkdir(parents=True, exist_ok=True)
        for name in ("T1", "T2"):
            (self.output_root / name).mkdir(parents=True, exist_ok=True)

    def _build_dimensions(self) -> None:
        self._build_stations()
        self._build_crossings()
        self._build_trains()
        self._build_drivers()
        self._build_events()
        self._build_routes()

    def _augment_dimensions_for_t2(self) -> None:
        self._apply_crossing_upgrades()
        self._apply_train_switches()
        self._add_new_drivers_for_t2()

    # ------------------------------------------------------------------
    # Station generation
    # ------------------------------------------------------------------

    def _build_stations(self) -> None:
        target_count = self.rng.randint(420, 560)
        used_pairs: set[str] = set()
        used_station_names: set[str] = set()
        station_id = 1

        for _ in range(target_count):
            city, voivodeship = self._unique_city(used_pairs)
            region = self._classify_region(voivodeship)
            name = f"Stacja {city}"
            if name in used_station_names:
                suffix = self.rng.randint(1, 9)
                name = f"Stacja {city} {suffix}"
            used_station_names.add(name)
            station = StationMeta(
                station_id=station_id,
                name=name,
                city=city,
                voivodeship=voivodeship,
                region=region,
            )
            self.stations.append(station)
            station_id += 1

        hotspot_count = self.rng.randint(12, 18)
        self.hotspot_station_ids = set(self.rng.sample([s.station_id for s in self.stations], hotspot_count))

    def _unique_city(self, used_pairs: set[str]) -> Tuple[str, str]:
        for _ in range(10_000):
            city = self.fake.city()
            voivodeship = self.rng.choice(VOIVODESHIPS)
            key = f"{city}-{voivodeship}"
            if key not in used_pairs:
                used_pairs.add(key)
                return city, voivodeship
        raise RuntimeError("Unable to generate unique city names")

    def _classify_region(self, voivodeship: str) -> str:
        if voivodeship in COASTAL:
            return "coastal"
        if voivodeship in MOUNTAIN:
            return "mountain"
        return "central"

    # ------------------------------------------------------------------
    # Crossing generation and upgrades
    # ------------------------------------------------------------------

    def _build_crossings(self) -> None:
        crossing_count = self.rng.randint(9_000, 11_500)
        old_share = 0.55

        for _ in range(crossing_count):
            is_old = self.rng.random() < old_share
            has_barriers = False if is_old else self.rng.random() < 0.75
            has_light = False if is_old else self.rng.random() < 0.85
            is_lit = False if is_old else self.rng.random() < 0.9
            speed_limit = self.rng.randint(30, 100)
            station = self.rng.choice(self.stations)
            crossing = CrossingMeta(
                crossing_id=self.next_crossing_id,
                has_barriers=has_barriers,
                has_light_signals=has_light,
                is_lit=is_lit,
                speed_limit=speed_limit,
                region=station.region,
                is_old=is_old,
                upgrade_target=None,
            )
            self.crossings[self.next_crossing_id] = crossing
            self.crossings_by_region[crossing.region].append(self.next_crossing_id)
            self.next_crossing_id += 1

        eligible = [cid for cid, meta in self.crossings.items() if meta.is_old and meta.upgrade_target is None]
        upgrade_count = self.rng.randint(320, 520)
        for cid in self.rng.sample(eligible, upgrade_count):
            self.crossing_upgrade_map[cid] = -1  # placeholder updated later

    def _apply_crossing_upgrades(self) -> None:
        for old_id in list(self.crossing_upgrade_map):
            old_meta = self.crossings[old_id]
            upgraded = CrossingMeta(
                crossing_id=self.next_crossing_id,
                has_barriers=True,
                has_light_signals=True,
                is_lit=True,
                speed_limit=min(100, old_meta.speed_limit + self.rng.randint(0, 5)),
                region=old_meta.region,
                is_old=False,
                upgrade_target=None,
            )
            self.crossings[self.next_crossing_id] = upgraded
            self.crossings_by_region[upgraded.region].append(self.next_crossing_id)
            self.crossing_upgrade_map[old_id] = self.next_crossing_id
            # mark old meta with pointer for clarity
            self.crossings[old_id] = CrossingMeta(
                crossing_id=old_meta.crossing_id,
                has_barriers=old_meta.has_barriers,
                has_light_signals=old_meta.has_light_signals,
                is_lit=old_meta.is_lit,
                speed_limit=old_meta.speed_limit,
                region=old_meta.region,
                is_old=old_meta.is_old,
                upgrade_target=self.next_crossing_id,
            )
            self.next_crossing_id += 1

    # ------------------------------------------------------------------
    # Train generation and operator switches
    # ------------------------------------------------------------------

    def _build_trains(self) -> None:
        base_count = self.rng.randint(1_300, 1_650)
        operator_weights = {
            "PKP Intercity": 0.22,
            "POLREGIO": 0.24,
            "PKP Cargo": 0.18,
            "DB Cargo Polska": 0.1,
            "Koleje Mazowieckie": 0.1,
            "Koleje Śląskie": 0.08,
            "Koleje Dolnośląskie": 0.08,
        }

        for _ in range(base_count):
            operator = self._weighted_choice(operator_weights)
            train_type = "cargo" if "Cargo" in operator else "passenger"
            name = self._build_train_name(operator)
            self.trains[self.next_train_id] = {
                "id": self.next_train_id,
                "name": name,
                "train_type": train_type,
                "operator_name": operator,
            }
            self.next_train_id += 1

    def _apply_train_switches(self) -> None:
        candidates = [tid for tid, t in self.trains.items() if t["operator_name"] == "PKP Cargo"]
        switch_count = min(len(candidates), self.rng.randint(32, 58))
        switched = self.rng.sample(candidates, switch_count)
        for old_id in switched:
            old_train = self.trains[old_id]
            new_train = {
                "id": self.next_train_id,
                "name": f"{old_train['name']}-DB",
                "train_type": old_train["train_type"],
                "operator_name": "DB Cargo Polska",
            }
            self.trains[self.next_train_id] = new_train
            self.train_switch_pairs[old_id] = self.next_train_id
            self.train_switch_reverse[self.next_train_id] = old_id
            self.next_train_id += 1

    def _build_train_name(self, operator: str) -> str:
        if operator == "PKP Intercity":
            return f"IC {self.rng.randint(1000, 9999)}"
        if operator == "POLREGIO":
            return f"PR {self.rng.randint(10000, 99999)}"
        if operator == "PKP Cargo":
            return f"ET {self.rng.randint(500, 9999)}"
        if operator == "DB Cargo Polska":
            return f"DB {self.rng.randint(7000, 9999)}"
        if operator == "Koleje Mazowieckie":
            return f"KM {self.rng.randint(100, 9999)}"
        if operator == "Koleje Śląskie":
            return f"KS {self.rng.randint(100, 9999)}"
        if operator == "Koleje Dolnośląskie":
            return f"KD {self.rng.randint(100, 9999)}"
        return f"TR {self.rng.randint(1000, 99999)}"

    # ------------------------------------------------------------------
    # Driver dimension and augmentation
    # ------------------------------------------------------------------

    def _build_drivers(self) -> None:
        base_count = self.rng.randint(4_500, 5_800)
        for _ in range(base_count):
            record = self._make_driver()
            self.drivers[self.next_driver_id] = record
            self.next_driver_id += 1

    def _add_new_drivers_for_t2(self) -> None:
        hires = self.rng.randint(250, 400)
        for _ in range(hires):
            record = self._make_driver(min_employment_year=2023)
            self.drivers[self.next_driver_id] = record
            self.next_driver_id += 1

    def _make_driver(self, min_employment_year: int = 1990) -> Dict[str, object]:
        gender = "man" if self.rng.random() < 0.82 else "woman"
        first_name = self.fake.first_name_male() if gender == "man" else self.fake.first_name_female()
        last_name = self.fake.last_name()
        age = self.rng.randint(23, 62)
        current_year = 2025
        max_year = min(current_year, current_year - (age - 21))
        max_year = max(max_year, min_employment_year)
        employment_year = self.rng.randint(min_employment_year, max_year)
        return {
            "id": self.next_driver_id,
            "first_name": first_name,
            "last_name": last_name,
            "gender": gender,
            "age": age,
            "employment_year": employment_year,
        }

    # ------------------------------------------------------------------
    # Event dimension
    # ------------------------------------------------------------------

    def _build_events(self) -> None:
        for event_type, category, danger in EVENT_DEFINITIONS:
            self.events[self.next_event_id] = (event_type, category, danger)
            self.next_event_id += 1

    # ------------------------------------------------------------------
    # Route preparation
    # ------------------------------------------------------------------

    def _build_routes(self) -> None:
        route_count = self.rng.randint(240, 340)
        station_ids = [s.station_id for s in self.stations]
        used_pairs: set[str] = set()

        for _ in range(route_count):
            stops = max(3, round(self.rng.triangular(3, 20, 10)))
            stop_count = stops + 1
            sequence = self.rng.sample(station_ids, stop_count)
            key = f"{sequence[0]}-{sequence[-1]}"
            if key in used_pairs:
                name = f"Linia {sequence[0]}-{sequence[-1]} {self.rng.randint(1, 99)}"
            else:
                name = f"Linia {sequence[0]}-{sequence[-1]}"
                used_pairs.add(key)
            section_minutes = [self.rng.randint(12, 45) for _ in range(stops)]
            self.routes.append(RouteTemplate(name=name, station_ids=sequence, section_minutes=section_minutes))

    # ------------------------------------------------------------------
    # Dimensions writing
    # ------------------------------------------------------------------

    def _write_dimensions(self, snapshot: str) -> None:
        snapshot_dir = self._snapshot_dir(snapshot)
        self._write_station_csv(snapshot_dir)
        self._write_crossing_csv(snapshot_dir)
        self._write_train_csv(snapshot_dir)
        self._write_driver_csv(snapshot_dir)
        self._write_event_csv(snapshot_dir)

    def _write_station_csv(self, snapshot_dir: Path) -> None:
        path = snapshot_dir / "Station.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow(["id", "name", "city"])
            for station in self.stations:
                writer.writerow([station.station_id, station.name, station.city])

    def _write_crossing_csv(self, snapshot_dir: Path) -> None:
        path = snapshot_dir / "Crossing.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow(["id", "has_barriers", "has_light_signals", "is_lit", "speed_limit"])
            for crossing in sorted(self.crossings.values(), key=lambda c: c.crossing_id):
                writer.writerow(
                    [
                        crossing.crossing_id,
                        int(crossing.has_barriers),
                        int(crossing.has_light_signals),
                        int(crossing.is_lit),
                        crossing.speed_limit,
                    ]
                )

    def _write_train_csv(self, snapshot_dir: Path) -> None:
        path = snapshot_dir / "Train.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow(["id", "name", "train_type", "operator_name"])
            for train_id in sorted(self.trains):
                train = self.trains[train_id]
                writer.writerow([train["id"], train["name"], train["train_type"], train["operator_name"]])

    def _write_driver_csv(self, snapshot_dir: Path) -> None:
        path = snapshot_dir / "Driver.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow(["id", "first_name", "last_name", "gender", "age", "employment_year"])
            for driver_id in sorted(self.drivers):
                driver = self.drivers[driver_id]
                writer.writerow(
                    [
                        driver["id"],
                        driver["first_name"],
                        driver["last_name"],
                        driver["gender"],
                        driver["age"],
                        driver["employment_year"],
                    ]
                )

    def _write_event_csv(self, snapshot_dir: Path) -> None:
        path = snapshot_dir / "Event.csv"
        with path.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.writer(fh, lineterminator="\n")
            writer.writerow(["id", "event_type", "category", "danger_scale"])
            for event_id in sorted(self.events):
                event_type, category, danger = self.events[event_id]
                writer.writerow([event_id, event_type, category, danger])

    # ------------------------------------------------------------------
    # Fact generation driver
    # ------------------------------------------------------------------

    def _generate_facts(
        self,
        config: SnapshotConfig,
        snapshot_dir: Path,
        append: bool = False,
    ) -> None:
        ride_mode = "a" if append else "w"
        section_mode = "a" if append else "w"
        event_mode = "a" if append else "w"
        weather_mode = "a" if append else "w"

        ride_path = snapshot_dir / "Ride.csv"
        section_path = snapshot_dir / "Ride_Section.csv"
        event_path = snapshot_dir / "Event_On_Route.csv"
        weather_path = snapshot_dir / "weather.csv"

        ride_file = ride_path.open(ride_mode, newline="", encoding="utf-8")
        section_file = section_path.open(section_mode, newline="", encoding="utf-8")
        event_file = event_path.open(event_mode, newline="", encoding="utf-8")
        weather_file = weather_path.open(weather_mode, newline="", encoding="utf-8")

        ride_writer = csv.writer(ride_file, lineterminator="\n")
        section_writer = csv.writer(section_file, lineterminator="\n")
        event_writer = csv.writer(event_file, lineterminator="\n")
        weather_writer = csv.writer(weather_file, lineterminator="\n")

        if not append:
            ride_writer.writerow([
                "id",
                "route_name",
                "time_difference",
                "scheduled_departure",
                "scheduled_arrival",
                "train_id",
                "driver_id",
            ])
            section_writer.writerow(
                [
                    "id",
                    "ride_id",
                    "section_number",
                    "departure_station_id",
                    "arrival_station_id",
                    "time_difference",
                    "scheduled_arrival",
                    "scheduled_departure",
                ]
            )
            event_writer.writerow(
                [
                    "id",
                    "ride_section_id",
                    "crossing_id",
                    "event_id",
                    "caused_delay",
                    "injured_count",
                    "death_count",
                    "repair_cost",
                    "emergency_intervention",
                    "event_date",
                    "train_speed",
                ]
            )
            weather_writer.writerow([
                "id_odcinka",
                "data_pomiaru",
                "temperatura",
                "ilosc_opadow",
                "typ_opadow",
            ])

        routes_pool = self.routes
        trains_pool = list(self.trains.keys())
        drivers_pool = list(self.drivers.keys())

        for _ in range(config.ride_count):
            route = self.rng.choice(routes_pool)
            schedule_start = self._random_datetime(config.start, config.end)
            train_id = self._select_train_for_snapshot(
                snapshot_name=config.name,
                schedule_start=schedule_start,
                trains_pool=trains_pool,
            )
            driver_id = self._select_driver_for_snapshot(
                schedule_start=schedule_start,
                drivers_pool=drivers_pool,
            )
            ride_total_delay = 0.0

            ride_sections = self._build_sections_for_ride(
                route=route,
                ride_id=self.next_ride_id,
                train_id=train_id,
                driver_id=driver_id,
                schedule_start=schedule_start,
                base_event_rate=config.base_event_rate,
                weather_writer=weather_writer,
                section_writer=section_writer,
                event_writer=event_writer,
                snapshot_end=config.end,
            )

            ride_total_delay = sum(section["delay_minutes"] for section in ride_sections)
            ride_total_delay = max(-20.0, min(ride_total_delay, 360.0))

            scheduled_arrival = ride_sections[-1]["scheduled_arrival"]
            ride_writer.writerow(
                [
                    self.next_ride_id,
                    route.name,
                    int(round(ride_total_delay)),
                    schedule_start.strftime("%Y-%m-%d %H:%M:%S"),
                    scheduled_arrival.strftime("%Y-%m-%d %H:%M:%S"),
                    train_id,
                    driver_id,
                ]
            )

            self.next_ride_id += 1

        ride_file.close()
        section_file.close()
        event_file.close()
        weather_file.close()

    # ------------------------------------------------------------------
    # Section, event, and weather generation per ride
    # ------------------------------------------------------------------

    def _build_sections_for_ride(
        self,
        route: RouteTemplate,
        ride_id: int,
        train_id: int,
        driver_id: int,
        schedule_start: datetime,
        base_event_rate: float,
        weather_writer: csv.writer,
        section_writer: csv.writer,
        event_writer: csv.writer,
        snapshot_end: datetime,
    ) -> List[Dict[str, object]]:
        driver = self.drivers[driver_id]
        train = self.trains[train_id]
        schedule_cursor = schedule_start
        sections_meta: List[Dict[str, object]] = []

        for idx, (dep, arr, minutes) in enumerate(self._sections_iter(route)):
            scheduled_departure = schedule_cursor
            scheduled_arrival = scheduled_departure + timedelta(minutes=minutes)
            weather = self._sample_weather(scheduled_departure, arr)
            delay_minutes = self._calculate_delay_minutes(
                dep_station_id=dep,
                arr_station_id=arr,
                train=train,
                driver=driver,
                weather=weather,
                scheduled_departure=scheduled_departure,
            )

            crossing_choice = self._select_crossing(weather, scheduled_departure)
            event_data = self._maybe_create_event(
                base_event_rate=base_event_rate,
                crossing_id=crossing_choice,
                train=train,
                driver=driver,
                weather=weather,
                scheduled_departure=scheduled_departure,
                snapshot_end=snapshot_end,
            )

            if event_data is not None:
                delay_minutes += event_data["caused_delay"]
                delay_minutes = max(-5.0, delay_minutes)
                delay_minutes = min(240.0, delay_minutes)
                event_writer.writerow(
                    [
                        self.next_event_on_route_id,
                        self.next_section_id,
                        event_data["crossing_id"] if event_data["crossing_id"] is not None else "",
                        event_data["event_id"],
                        event_data["caused_delay"],
                        event_data["injured_count"],
                        event_data["death_count"],
                        f"{event_data['repair_cost']:.2f}",
                        int(event_data["emergency_intervention"]),
                        event_data["event_date"].strftime("%Y-%m-%d %H:%M:%S"),
                        event_data["train_speed"],
                    ]
                )
                self.next_event_on_route_id += 1

            section_writer.writerow(
                [
                    self.next_section_id,
                    ride_id,
                    idx + 1,
                    dep,
                    arr,
                    int(round(delay_minutes)),
                    scheduled_arrival.strftime("%Y-%m-%d %H:%M:%S"),
                    scheduled_departure.strftime("%Y-%m-%d %H:%M:%S"),
                ]
            )

            weather_writer.writerow(
                [
                    self.next_section_id,
                    scheduled_departure.strftime("%Y-%m-%d %H:%M:%S"),
                    f"{weather['temperature']:.1f}",
                    f"{weather['precipitation_amount']:.1f}",
                    weather["precipitation_type"],
                ]
            )

            sections_meta.append(
                {
                    "delay_minutes": delay_minutes,
                    "scheduled_arrival": scheduled_arrival,
                }
            )

            self.next_section_id += 1
            schedule_cursor = scheduled_arrival

        return sections_meta

    def _sections_iter(self, route: RouteTemplate) -> Iterator[Tuple[int, int, int]]:
        for idx in range(len(route.station_ids) - 1):
            yield route.station_ids[idx], route.station_ids[idx + 1], route.section_minutes[idx]

    # ------------------------------------------------------------------
    # Delay calculation and contributing factors
    # ------------------------------------------------------------------

    def _calculate_delay_minutes(
        self,
        dep_station_id: int,
        arr_station_id: int,
        train: Dict[str, object],
        driver: Dict[str, object],
        weather: Dict[str, object],
        scheduled_departure: datetime,
    ) -> float:
        is_hotspot = dep_station_id in self.hotspot_station_ids or arr_station_id in self.hotspot_station_ids
        base_noise = self.rng.gauss(0.0, 1.5)
        delay = base_noise + (self.rng.uniform(2, 4) if is_hotspot else 0.0)

        hour = scheduled_departure.hour
        if 7 <= hour <= 9 or 16 <= hour <= 18:
            delay += self.rng.uniform(0.5, 2.5)

        if scheduled_departure.weekday() == 4:
            delay += self.rng.uniform(0.3, 1.8)

        experience = scheduled_departure.year - int(driver["employment_year"])
        if experience < 3:
            delay *= self.rng.uniform(1.12, 1.28)
        elif experience > 5:
            delay *= self.rng.uniform(0.82, 0.92)

        operator = train["operator_name"]
        if operator == "POLREGIO":
            delay += self.rng.uniform(0.5, 2.0)
        elif operator in {"PKP Cargo", "DB Cargo Polska"}:
            delay += self.rng.uniform(-0.5, 1.0)

        weather_type = weather["precipitation_type"]
        precipitation = weather["precipitation_amount"]
        if weather_type == "snieg":
            delay += self.rng.uniform(1.5, 4.0)
        elif weather_type == "deszcz" and precipitation >= 8.0:
            delay += self.rng.uniform(1.0, 3.0)
        elif weather_type == "grad":
            delay += self.rng.uniform(0.5, 2.0)

        return delay

    # ------------------------------------------------------------------
    # Event creation logic
    # ------------------------------------------------------------------

    def _maybe_create_event(
        self,
        base_event_rate: float,
        crossing_id: Optional[int],
        train: Dict[str, object],
        driver: Dict[str, object],
        weather: Dict[str, object],
        scheduled_departure: datetime,
        snapshot_end: datetime,
    ) -> Optional[Dict[str, object]]:
        probability = base_event_rate
        crossing_meta = self.crossings.get(crossing_id) if crossing_id else None

        if crossing_meta is not None and crossing_meta.is_old:
            probability *= 1.45
        if crossing_meta is not None and crossing_meta.upgrade_target is not None and scheduled_departure >= UPGRADE_DATE:
            probability *= 0.8

        if weather["precipitation_type"] in {"deszcz", "snieg"}:
            probability *= 1.2
        if weather["precipitation_amount"] >= 8.0:
            probability *= 1.3

        experience = scheduled_departure.year - int(driver["employment_year"])
        if experience < 3:
            probability *= 1.2
        elif experience > 5:
            probability *= 0.92

        if scheduled_departure >= datetime(2025, 1, 1) and scheduled_departure <= snapshot_end:
            probability *= 0.95

        if train["operator_name"] == "POLREGIO":
            probability *= 1.1
        elif train["operator_name"] in {"DB Cargo Polska", "PKP Cargo"}:
            probability *= 0.95

        probability = min(0.35, probability)
        if self.rng.random() >= probability:
            return None

        event_id, event_type = self._pick_event_type(weather, train, crossing_meta)
        caused_delay = self._event_delay_minutes(event_type)
        injured, deaths = self._event_casualties(event_type)
        repair_cost = self._event_repair_cost(event_type)
        emergency = event_type in {"wypadek", "awaria"}
        event_time = scheduled_departure + timedelta(minutes=self.rng.uniform(2, 10))
        train_speed = self._event_speed(train, crossing_meta)

        return {
            "crossing_id": crossing_id,
            "event_id": event_id,
            "caused_delay": caused_delay,
            "injured_count": injured,
            "death_count": deaths,
            "repair_cost": repair_cost,
            "emergency_intervention": emergency,
            "event_date": event_time,
            "train_speed": train_speed,
        }

    def _pick_event_type(
        self,
        weather: Dict[str, object],
        train: Dict[str, object],
        crossing_meta: Optional[CrossingMeta],
    ) -> Tuple[int, str]:
        weights = {
            "wypadek": 0.06,
            "incydent": 0.5,
            "awaria": 0.22,
            "zdarzenie techniczne": 0.22,
        }
        if crossing_meta is not None and crossing_meta.is_old:
            weights["wypadek"] += 0.04
            weights["awaria"] += 0.03
        if weather["precipitation_type"] == "snieg":
            weights["incydent"] += 0.05
            weights["awaria"] += 0.04
        if train["operator_name"] in {"PKP Cargo", "DB Cargo Polska"}:
            weights["awaria"] += 0.04
            weights["incydent"] -= 0.02

        event_type = self._weighted_choice(weights)
        candidates = [eid for eid, data in self.events.items() if data[0] == event_type]
        event_id = self.rng.choice(candidates)
        return event_id, event_type

    def _event_delay_minutes(self, event_type: str) -> float:
        if event_type == "wypadek":
            return self.rng.uniform(25, 90)
        if event_type == "awaria":
            return self.rng.uniform(10, 45)
        if event_type == "incydent":
            return self.rng.uniform(5, 25)
        return self.rng.uniform(2, 12)

    def _event_casualties(self, event_type: str) -> Tuple[int, int]:
        if event_type == "wypadek":
            injured = int(self.rng.choice([0, 1, 2, 3, 4, 5]))
            deaths = 1 if self.rng.random() < 0.05 else 0
            return injured, deaths
        if event_type == "awaria":
            return int(self.rng.random() < 0.05), 0
        return 0, 0

    def _event_repair_cost(self, event_type: str) -> float:
        if event_type == "wypadek":
            return self.rng.uniform(40_000, 180_000)
        if event_type == "awaria":
            return self.rng.uniform(10_000, 40_000)
        if event_type == "incydent":
            return self.rng.uniform(1_000, 6_000)
        return self.rng.uniform(500, 3_000)

    def _event_speed(self, train: Dict[str, object], crossing_meta: Optional[CrossingMeta]) -> int:
        base_speed = 110 if train["train_type"] == "passenger" else 90
        if crossing_meta is not None:
            base_speed = min(base_speed, crossing_meta.speed_limit + self.rng.randint(-10, 5))
        return max(30, min(160, base_speed))

    # ------------------------------------------------------------------
    # Crossing selection for sections/events
    # ------------------------------------------------------------------

    def _select_crossing(self, weather: Dict[str, object], scheduled_departure: datetime) -> Optional[int]:
        region = weather["region"]
        if region not in self.crossings_by_region:
            return None
        crossing_id = self.rng.choice(self.crossings_by_region[region])
        crossing_meta = self.crossings[crossing_id]
        if crossing_meta.is_old and crossing_meta.upgrade_target and scheduled_departure >= UPGRADE_DATE:
            return crossing_meta.upgrade_target
        return crossing_id

    # ------------------------------------------------------------------
    # Train and driver selection under constraints
    # ------------------------------------------------------------------

    def _select_train_for_snapshot(
        self,
        snapshot_name: str,
        schedule_start: datetime,
        trains_pool: List[int],
    ) -> int:
        candidate = self.rng.choice(trains_pool)

        if snapshot_name != "T2":
            return candidate

        if schedule_start < SWITCH_DATE:
            if candidate in self.train_switch_pairs.values():
                return self.train_switch_reverse.get(candidate, candidate)
            return candidate

        if candidate in self.train_switch_pairs:
            return self.train_switch_pairs[candidate]
        if candidate in self.train_switch_pairs.values():
            return candidate

        reverse_candidate = self.train_switch_reverse.get(candidate)
        if reverse_candidate and schedule_start >= SWITCH_DATE:
            if self.rng.random() < 0.7:
                return candidate
        return candidate

    def _select_driver_for_snapshot(
        self,
        schedule_start: datetime,
        drivers_pool: List[int],
    ) -> int:
        while True:
            candidate = self.rng.choice(drivers_pool)
            driver = self.drivers[candidate]
            employment_year = int(driver["employment_year"])
            if employment_year <= schedule_start.year:
                return candidate

    # ------------------------------------------------------------------
    # Weather sampling respecting seasonality and region effects
    # ------------------------------------------------------------------

    def _sample_weather(self, timestamp: datetime, station_id: int) -> Dict[str, object]:
        station = self._station_by_id(station_id)
        month = timestamp.month
        base_temp = self._base_temperature(month)
        region_offset = {"coastal": 1.5, "mountain": -3.0, "central": 0.0}
        mean_temp = base_temp + region_offset.get(station.region, 0.0)
        temperature = self.rng.gauss(mean_temp, 4.0)
        temperature = max(-30.0, min(temperature, 40.0))

        precipitation_amount = self._precipitation_amount(month, station.region)
        precipitation_type = self._precipitation_type(month, precipitation_amount)

        return {
            "temperature": temperature,
            "precipitation_amount": precipitation_amount,
            "precipitation_type": precipitation_type,
            "region": station.region,
        }

    def _base_temperature(self, month: int) -> float:
        month_means = {
            1: -2.0,
            2: 0.0,
            3: 4.0,
            4: 10.0,
            5: 16.0,
            6: 19.0,
            7: 21.0,
            8: 20.0,
            9: 15.0,
            10: 9.0,
            11: 3.0,
            12: -1.0,
        }
        return month_means[month]

    def _precipitation_amount(self, month: int, region: str) -> float:
        summer_boost = 1.2 if month in {6, 7, 8} else 1.0
        winter_snow = 0.8 if month in {12, 1, 2} else 1.0
        base = self.rng.gammavariate(2.0, 2.0) * summer_boost * winter_snow
        if region == "mountain":
            base *= 1.2
        if region == "coastal" and month in {10, 11, 12, 1, 2}:
            base *= 1.15
        base = min(base, 25.0)
        return round(base, 1)

    def _precipitation_type(self, month: int, amount: float) -> str:
        if month in {12, 1, 2}:
            if amount < 1.0:
                return "brak"
            if amount < 6.0:
                return "snieg"
            if self.rng.random() < 0.2:
                return "snieg"
            return "deszcz"
        if amount >= 10.0 and self.rng.random() < 0.05:
            return "grad"
        if amount < 1.0:
            return "brak"
        if month in {3, 4, 10, 11} and self.rng.random() < 0.2:
            return "snieg"
        return "deszcz"

    # ------------------------------------------------------------------
    # Utility helpers
    # ------------------------------------------------------------------

    def _random_datetime(self, start: datetime, end: datetime) -> datetime:
        delta_seconds = int((end - start).total_seconds())
        offset = self.rng.randint(0, delta_seconds)
        return start + timedelta(seconds=offset)

    def _station_by_id(self, station_id: int) -> StationMeta:
        return self.stations[station_id - 1]

    def _weighted_choice(self, weights: Dict[str, float]) -> str:
        total = sum(weights.values())
        threshold = self.rng.random() * total
        cumulative = 0.0
        for key, weight in weights.items():
            cumulative += weight
            if cumulative >= threshold:
                return key
        raise RuntimeError("Weighted choice failed")

    def _snapshot_dir(self, name: str) -> Path:
        return self.output_root / name

    def _prepare_t2_fact_files(self) -> None:
        for filename in ("Ride.csv", "Ride_Section.csv", "Event_On_Route.csv", "weather.csv"):
            src = self._snapshot_dir("T1") / filename
            dst = self._snapshot_dir("T2") / filename
            with src.open("r", encoding="utf-8") as s, dst.open("w", encoding="utf-8") as d:
                for line in s:
                    d.write(line)

    # ------------------------------------------------------------------
    # Entry point
    # ------------------------------------------------------------------


def run_generator() -> None:
    output_setting = os.getenv("RAILGEN_OUTPUT_DIR", "output")
    output_path = Path(output_setting)
    if not output_path.is_absolute():
        output_path = Path(__file__).resolve().parent / output_path
    seed = _env_int("RAILGEN_SEED", 42)
    generator = RailwayDataGenerator(output_path, seed=seed)
    generator.generate()


if __name__ == "__main__":
    run_generator()
