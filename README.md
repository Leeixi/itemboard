# itemboard

Simple django app used for learning and as a playground.

## Instructions to run in dev mode

Make sure you have installed python3, pip3 and GNU make.

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

### Run app locally
```
make run
```
Go to  http://127.0.0.1:8000/

Access admin dashboard - create superuser first:
http://127.0.0.1:8000/admin

# Run as docker container
### Build image for development
``` 
sudo docker build -t itemboard-dev .
sudo docker run --network host -p 8080:8000 itemboard-dev
```

### Run with docker-compose
```
sudo docker-compose up --build
```

### Notes

Make sure you run make migrate and make createsuperuser only once during the initial setup.
The make run command will start the development server; for production, you should use Docker or Gunicorn.
To stop the app, use Ctrl+C or run docker-compose down to bring down the containers.

Docker will output that application is listening on 8000 port, ignore it and go to 80.

