#!/bin/bash

# Exit on any error
set -e

echo "Initializing database..."
cd /app
python -c "
from app.app import init_database
init_database()
"

echo "Starting Flask application..."
cd /app && FLASK_APP=app/app.py FLASK_DEBUG=1 FLASK_RUN_HOST=0.0.0.0 python -m flask run
