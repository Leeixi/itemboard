# Base image
FROM python:3.10-slim
# Python's output is not buffered. This is useful for logging, especially when you're running the app in Docker and want to see logs in real time.
ENV PYTHONUNBUFFERED 1
# Prevents Python from writing .pyc files (
ENV PYTHONDONTWRITEBYTECODE 1
# Create app dir
RUN mkdir -p app
WORKDIR app
# Keep things up to date
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential libpq-dev make \
  && rm -rf /var/lib/apt/lists/*
# And install things to run app, also setup users
COPY itemboard/requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt \
    && useradd -U itemboard-user \
    && install -d -m 0755 -o itemboard-user -g itemboard-user /app/static
# Set ownership
COPY --chown=itemboard-user:itemboard-user itemboard .
# Just for reminder
EXPOSE 80
RUN python3 manage.py migrate
# Run app
CMD ["make", "dev"]