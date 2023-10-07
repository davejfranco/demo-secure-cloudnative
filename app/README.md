# DEMO APP

This is a demo app to showcase a the hability to connect to aws secret manager and get database credentials.

## Requirements
- python >= 3.11
- pip >= 21.2.1
- virtualenv >= 20.17.1

## Installation
- Create the virtual environment
```bash
python -m virtualenv env
source .env/bin/activate
```
- Install the requirements
```bash
pip install -r requirements.txt
```
- Run the app
```bash
uvicorn main:app --reload
```

## Build docker image
```bash
docker build -t demo-app .
```
