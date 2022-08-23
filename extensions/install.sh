#!/bin/bash

# Install virtualenv
pip3 install virtualenv

# Create virtuel environement  `venv`
virtualenv venv
virtualenv -p /usr/bin/python3.7 venv

# Activate `venv`
source venv/bin/activate
# Install 'requirements.txt'
venv/bin/pip3 install -r requirements.txt
