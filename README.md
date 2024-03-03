# itemboard

Simple django app used for learning and as a playground.

## Instructions to run in dev mode

Make sure you have installed python3, pip3. GNU make is optional.

### Start in development mode
Create and use virtual environment 
```
make env
source venv/bin/activate
```

Install depedencies
```
make install
```
### Run only during initial run
Run db migration
```
make migrate
```
Create admin/super user
```
make createsuperuser
```

# Run app locally
```
make run
```
Go to  http://127.0.0.1:8000/

Access admin dashboard - create superuser first:
http://127.0.0.1:8000/admin

# Run as docker container
### Build image
``` 
docker build -t itemboard.$(date +"%Y-%m-%d") .
```