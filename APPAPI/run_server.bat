@echo off
cd /d "%~dp0"
echo Installing dependencies...
pip install -r requirements.txt

echo Starting Flask app with Waitress...
python -m waitress --port=5000 appAPI:app

pause
