"""
Database connection module for SQL Server using SQLAlchemy and pyodbc.
"""

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


def create_mssql_engine(
    server: str,
    database: str,
    username: str,
    password: str,
    port: int = 1433,
) -> Engine:
    """
    Create a SQLAlchemy engine for SQL Server using pyodbc.

    Args:
        server: SQL Server hostname or IP address
        database: Database name
        username: SQL Server username
        password: SQL Server password
        port: SQL Server port (default: 1433)

    Returns:
        SQLAlchemy Engine object

    Example:
        >>> engine = create_mssql_engine(
        ...     server="localhost",
        ...     database="mydatabase",
        ...     username="sa",
        ...     password="YourPassword123"
        ... )
    """
    # Use URL encoding for special characters in password
    from urllib.parse import quote_plus

    encoded_password = quote_plus(password)
    connection_string = f"mssql+pyodbc://{username}:{encoded_password}@{server}:{port}/{database}?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes"
    engine = create_engine(connection_string, echo=False)
    return engine


def test_connection(engine: Engine) -> bool:
    """
    Test the database connection.

    Args:
        engine: SQLAlchemy Engine object

    Returns:
        True if connection is successful, False otherwise
    """
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            return result.fetchone() is not None
    except Exception as e:
        print(f"Connection test failed: {e}")
        return False


if __name__ == "__main__":
    # Example usage
    engine = create_mssql_engine(
        server="localhost",
        database="master",
        username="sa",
        password="Pass@word",
        port=5434,
    )

    if test_connection(engine):
        print("✓ Database connection successful!")
    else:
        print("✗ Database connection failed!")
