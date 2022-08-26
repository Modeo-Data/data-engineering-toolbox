#!/bin/bash

# Install virtualenv
pip3 install virtualenv

# Create virtuel environement  `venv`
python3 -m virtualenv venv

# Activate `venv`
source venv/bin/activate

# Install 'requirements.txt'
venv/bin/pip3 install -r requirements.txt
