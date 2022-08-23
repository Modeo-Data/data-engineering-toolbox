#!/bin/bash

# Install virtualenv
pip install virtualenv

# Create virtuel environement  `venv`
virtualenv venv
virtualenv -p /usr/bin/python3.7 venv

# Activate `venv`
source venv/bin/activa
# Install 'requirements.txt'
venv/bin/pip instal -r requirements.txt
