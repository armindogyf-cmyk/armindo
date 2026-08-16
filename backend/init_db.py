import os
from pathlib import Path

from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+pysqlite:////app/data/epa.db")
SCHEMA_PATH = Path(os.getenv("SCHEMA_PATH", Path(__file__).resolve().parent.parent / "sql" / "schema.sql"))


def main() -> None:
    engine = create_engine(DATABASE_URL, future=True)
    sql = SCHEMA_PATH.read_text(encoding="utf-8")
    with engine.begin() as conn:
        for statement in [s.strip() for s in sql.split(";") if s.strip()]:
            conn.execute(text(statement))
    print(f"Schema applied from {SCHEMA_PATH}")


if __name__ == "__main__":
    main()
