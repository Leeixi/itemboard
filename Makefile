#Create venv
env:
	python3 -m venv venv
#Install dependencies 
install:
	pip3 install -r requirements.txt
	touch .env
#Run in develpment server
dev:
	python3 itemboard/manage.py runserver
#Migrate database
migrate:
	python3 itemboard/manage.py migrate
#Create superuser
createsuperuser:
	python3 itemboard/manage.py createsuperuser
