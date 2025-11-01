"""
Parallel database operations module for SQL Server.
Supports concurrent inserts and queries using ThreadPoolExecutor.
"""

from concurrent.futures import ThreadPoolExecutor, as_completed
from sqlalchemy import text
from sqlalchemy.engine import Engine
from typing import List, Dict, Any, Callable
import time


class ParallelDatabaseOperations:
    """Handles parallel database operations with thread pooling."""

    def __init__(self, engine: Engine, max_workers: int = 4):
        """
        Initialize parallel operations handler.

        Args:
            engine: SQLAlchemy Engine object
            max_workers: Maximum number of worker threads (default: 4)
        """
        self.engine = engine
        self.max_workers = max_workers

    def parallel_execute(
        self, queries: List[str], operation_name: str = "operations"
    ) -> Dict[int, Any]:
        """
        Execute multiple SQL queries in parallel.

        Args:
            queries: List of SQL query strings to execute
            operation_name: Name of the operation for logging

        Returns:
            Dictionary mapping query index to result
        """
        results = {}
        failed_queries = []

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # Submit all tasks
            future_to_index = {
                executor.submit(self._execute_query, query): idx
                for idx, query in enumerate(queries)
            }

            # Collect results as they complete
            for future in as_completed(future_to_index):
                idx = future_to_index[future]
                try:
                    result = future.result()
                    results[idx] = result
                    print(f"✓ {operation_name} [{idx}] completed successfully")
                except Exception as e:
                    failed_queries.append((idx, str(e)))
                    print(f"✗ {operation_name} [{idx}] failed: {e}")

        if failed_queries:
            print(f"\n⚠️  {len(failed_queries)} queries failed:")
            for idx, error in failed_queries:
                print(f"   Query {idx}: {error}")

        return results

    def parallel_insert_batches(
        self,
        table_name: str,
        data_batches: List[List[Dict[str, Any]]],
        column_names: List[str],
    ) -> Dict[int, int]:
        """
        Insert data into table from multiple batches in parallel.

        Args:
            table_name: Name of the table to insert into
            data_batches: List of batches, each containing list of dictionaries
            column_names: List of column names

        Returns:
            Dictionary mapping batch index to number of rows inserted
        """
        insert_queries = [
            self._build_insert_query(table_name, batch, column_names)
            for batch in data_batches
        ]

        results = {}
        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_index = {
                executor.submit(self._execute_insert, query): idx
                for idx, query in enumerate(insert_queries)
            }

            for future in as_completed(future_to_index):
                idx = future_to_index[future]
                try:
                    row_count = future.result()
                    results[idx] = row_count
                    print(f"✓ Batch {idx} inserted {row_count} rows into {table_name}")
                except Exception as e:
                    print(f"✗ Batch {idx} failed: {e}")
                    results[idx] = 0

        return results

    def parallel_table_inserts(
        self,
        table_operations: Dict[str, List[Dict[str, Any]]],
        column_mapping: Dict[str, List[str]],
    ) -> Dict[str, int]:
        """
        Insert data into multiple tables in parallel.

        Args:
            table_operations: Dict mapping table names to list of rows to insert
            column_mapping: Dict mapping table names to column names

        Returns:
            Dictionary mapping table name to number of rows inserted
        """
        results = {}

        with ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_table = {
                executor.submit(
                    self._insert_table,
                    table_name,
                    rows,
                    column_mapping.get(
                        table_name, list(rows[0].keys()) if rows else []
                    ),
                ): table_name
                for table_name, rows in table_operations.items()
            }

            for future in as_completed(future_to_table):
                table_name = future_to_table[future]
                try:
                    row_count = future.result()
                    results[table_name] = row_count
                    print(f"✓ {table_name}: {row_count} rows inserted")
                except Exception as e:
                    print(f"✗ {table_name} failed: {e}")
                    results[table_name] = 0

        return results

    def _execute_query(self, query: str) -> Any:
        """Execute a single query."""
        with self.engine.connect() as connection:
            result = connection.execute(text(query))
            return result.fetchall()

    def _execute_insert(self, query: str) -> int:
        """Execute a single insert query and return row count."""
        with self.engine.begin() as connection:
            result = connection.execute(text(query))
            return result.rowcount

    def _insert_table(
        self, table_name: str, rows: List[Dict[str, Any]], columns: List[str]
    ) -> int:
        """Insert rows into a specific table."""
        if not rows:
            return 0

        query = self._build_insert_query(table_name, rows, columns)
        return self._execute_insert(query)

    @staticmethod
    def _build_insert_query(
        table_name: str, rows: List[Dict[str, Any]], columns: List[str]
    ) -> str:
        """Build an INSERT query from rows."""
        if not rows:
            return ""

        # Build column list
        column_str = ", ".join(columns)

        # Build values
        values_parts = []
        for row in rows:
            values = [
                f"'{str(row.get(col, '')).replace(chr(39), chr(39) + chr(39))}'"
                if isinstance(row.get(col), str)
                else str(row.get(col, "NULL"))
                for col in columns
            ]
            values_parts.append(f"({', '.join(values)})")

        values_str = ", ".join(values_parts)
        return f"INSERT INTO {table_name} ({column_str}) VALUES {values_str};"

    def benchmark_operation(
        self, operation_func: Callable, *args, **kwargs
    ) -> tuple[Any, float]:
        """
        Benchmark an operation and return result with execution time.

        Args:
            operation_func: Function to benchmark
            *args, **kwargs: Arguments to pass to the function

        Returns:
            Tuple of (result, execution_time_in_seconds)
        """
        start_time = time.time()
        result = operation_func(*args, **kwargs)
        execution_time = time.time() - start_time
        return result, execution_time


if __name__ == "__main__":
    from db import create_mssql_engine, test_connection

    # Create engine
    engine = create_mssql_engine(
        server="localhost",
        database="master",
        username="sa",
        password="Pass@word",
        port=5434,
    )

    if not test_connection(engine):
        print("Cannot connect to database!")
        exit(1)

    # Example: Parallel SELECT queries
    print("=" * 60)
    print("Example 1: Parallel SELECT Queries")
    print("=" * 60)

    parallel_ops = ParallelDatabaseOperations(engine, max_workers=4)

    test_queries = [
        "SELECT 1 AS result",
        "SELECT 2 AS result",
        "SELECT 3 AS result",
        "SELECT 4 AS result",
    ]

    results, exec_time = parallel_ops.benchmark_operation(
        parallel_ops.parallel_execute, test_queries, "Test Query"
    )
    print(f"\n⏱️  Execution time: {exec_time:.2f} seconds")
    print(f"Results: {results}\n")
