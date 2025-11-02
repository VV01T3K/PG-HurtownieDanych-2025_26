# Changes: T2 as Delta Extension on Top of T1

## Summary
Updated the data generator to implement the **delta-only approach** as specified in `plan.md` section 9:
- **T1**: Contains all T1 rows (baseline snapshot from 2023-01-01 to 2024-06-30)
- **T2**: Contains ONLY NEW rows generated for T2 period (2024-07-01 to 2025-10-31)
- **T2 Dimensions**: Include all T1 dimensions PLUS new/changed dimensions (upgraded crossings, new trains, new drivers)

## Problem Solved
**Before**: T2 was a full snapshot containing:
- All T1 fact rows (Ride, Ride_Section, Event_On_Route, weather)
- Plus T2 new fact rows
- This violated the "delta only" recommendation for speed and storage efficiency

**After**: T2 contains:
- ONLY NEW T2 fact rows (generated from 2024-07-01 to 2025-10-31)
- Complete T2 dimensions (T1 baseline + T2 incremental changes)
- Complies with `plan.md` section 9 "Deltas only (recommended for speed)"

## Code Changes

### File: `generator/main.py`

#### 1. Removed `_prepare_t2_fact_files()` method
This method was copying all T1 fact files to T2 before appending new ones. It is no longer needed.

**Before:**
```python
def _prepare_t2_fact_files(self) -> None:
    for filename in ("Ride.csv", "Ride_Section.csv", "Event_On_Route.csv", "weather.csv"):
        src = self._snapshot_dir("T1") / filename
        dst = self._snapshot_dir("T2") / filename
        with src.open("r", encoding="utf-8") as s, dst.open("w", encoding="utf-8") as d:
            for line in s:
                d.write(line)
```

**After**: Method removed entirely.

#### 2. Updated `generate()` method
Changed T2 fact generation to write fresh data instead of appending.

**Before:**
```python
def generate(self) -> None:
    self._prepare_output_dirs()
    self._build_dimensions()
    self._write_dimensions("T1")
    self._generate_facts(T1_CONFIG, snapshot_dir=self._snapshot_dir("T1"))
    self._augment_dimensions_for_t2()
    self._write_dimensions("T2")
    self._prepare_t2_fact_files()  # ← REMOVED
    self._generate_facts(T2_CONFIG, snapshot_dir=self._snapshot_dir("T2"), append=True)  # ← append=False
```

**After:**
```python
def generate(self) -> None:
    self._prepare_output_dirs()
    self._build_dimensions()
    self._write_dimensions("T1")
    self._generate_facts(T1_CONFIG, snapshot_dir=self._snapshot_dir("T1"))
    self._augment_dimensions_for_t2()
    self._write_dimensions("T2")
    self._generate_facts(T2_CONFIG, snapshot_dir=self._snapshot_dir("T2"), append=False)
```

#### 3. Impact on `_generate_facts()` method
The method already handles both `append=False` (write headers and rows) and `append=True` modes correctly, so no changes were needed there. Now T2 facts are written fresh with headers, containing only new rows.

## Behavior Verification

### Example with test data (100 rides per snapshot):

**T1 Output:**
```
Ride_Section.csv:  1,107 rows (1 header + ~1,100 sections from 100 rides × ~10 sections/ride)
Ride.csv:          101 rows (1 header + 100 rides)
Event_On_Route.csv: Contains only T1 events
weather.csv:       Only T1 weather rows
```

**T2 Output:**
```
Ride_Section.csv:  1,140 rows (1 header + ~1,100 NEW sections, NOT including T1)
Ride.csv:          101 rows (1 header + 100 NEW rides, NOT including T1)
Event_On_Route.csv: Contains only T2 events
weather.csv:       Only T2 weather rows
```

**T2 Dimensions:**
```
Train.csv:     1,465 rows (T1 trains + ~30-60 new operator switches)
Crossing.csv:  10,383 rows (T1 crossings + ~300-600 upgraded versions)
Driver.csv:    Includes T1 drivers + new hires for T2 period
Station.csv:   All unique stations (no changes in plan)
Event.csv:     Event catalog (static, shared between snapshots)
```

## Alignment with `plan.md`

✅ **Section 4** - Time windows:
- T1: 2023-01-01 to 2024-06-30
- T2: 2024-07-01 to 2025-10-31 (extending T1, not replaying it)

✅ **Section 9** - Data generation pipeline:
- "For T2 you can either deliver:
  - Full snapshot with all rows (T1 + new), or
  - **Deltas only (recommended for speed)**: facts added and new/changed dimension tuples." ← ✅ Implemented

✅ **Dimension changes in T2**:
- ✅ Crossing upgrades: new crossing rows with improved attributes (300-600 rows)
- ✅ Operator changes: new Train rows for PKP Cargo → DB Cargo Polska switches (30-60 rows)
- ✅ New drivers for T2 period (250-400 rows)
- ✅ New stations if any are added (none in current config)

## Benefits

1. **Faster execution**: No copying of T1 rows to T2, only generating new ones
2. **Reduced storage**: T2 file size is significantly smaller (delta only)
3. **Efficient loading**: Data warehousing systems can load T1 once, then apply T2 deltas
4. **Clear separation**: T1 and T2 represent distinct business snapshots with clear scope
5. **Follows best practices**: Aligns with recommended delta approach in `plan.md`

## Migration Notes

When loading data into the warehouse:
1. Load all T1 dimensions and facts first
2. Load T2 dimensions (which include enhanced versions of T1 dimensions)
3. Load T2 facts (which are incremental rows only)
4. The fact tables will naturally accumulate: T1 rows + T2 rows = complete history

This approach ensures efficient load processes and clear data lineage.
