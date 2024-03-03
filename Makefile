#Create venv
env:
	python3 -m venv venv
#Install dependencies 
install:
	pip3 install -r requirements.txt
#Run in develpment server
run:
	python3 itemboard/manage.py runserver
#Migrate database
migrate:
	python3 itemboard/manage.py migrate
#Create superuser
createsuperuser:
	python3 itemboard/manage.py createsuperuser
# Run for production
runinprod:
	bash itemboard/runinprod.sh