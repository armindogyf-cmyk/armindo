FROM python:3.12-slim
WORKDIR /app
COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/app.py backend/init_db.py ./
COPY sql /sql
ENV DATABASE_URL=sqlite+pysqlite:////app/data/epa.db
ENV SCHEMA_PATH=/sql/schema.sql
EXPOSE 8090
CMD ["sh", "-c", "python init_db.py && uvicorn app:app --host 0.0.0.0 --port 8090"]
