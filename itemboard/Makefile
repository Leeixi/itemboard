# Create venv
env:
	python3 -m venv venv
	source venv/bin/activate
# Install dependencies 
install:
	pip3 install -r requirements.txt
# Migrate database
migrate:
	python3 manage.py migrate
# Create superuser
createsuperuser:
	python3 manage.py createsuperuser
# Run in develpment server
dev:
	export ENV=dev && python3 manage.py runserver
# Run in prod
prod:
	export ENV=prod && gunicorn --bind 0.0.0.0:8000 itemboard.wsgi