FROM python:3.10-slim
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
RUN mkdir -p app
WORKDIR app
RUN echo "DB_HOST=localhost" > .env
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential libpq-dev make \
  && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm -rf /tmp/requirements.txt \
    && useradd -U app_user \
    && install -d -m 0755 -o app_user -g app_user /app/static
COPY --chown=app_user:app_user . .
EXPOSE 5000
CMD ["make", "runindev"]