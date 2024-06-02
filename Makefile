# Create venv
env:
	python3 -m venv venv
	source venv/bin/activate
# Install dependencies 
install:
	pip3 install -r requirements.txt
	touch .env
# Migrate database
migrate:
	python3 itemboard/manage.py migrate
# Create superuser
createsuperuser:
	python3 itemboard/manage.py createsuperuser
# Run in develpment server
dev:
	python3 itemboard/manage.py runserver