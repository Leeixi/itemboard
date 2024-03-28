#!/usr/bin/env bash
# Exit on error
set -o errexit

# Modify this line as needed for your package manager (pip, poetry, etc.)
pip install -r requirements.txt

# Convert static asset files
python itemboard/manage.py collectstatic --no-input

# Apply any outstanding database migrations
python itemboard/manage.py migrate

cd itemboard
gunicorn itemboard.asgi:application -k uvicorn.workers.UvicornWorker