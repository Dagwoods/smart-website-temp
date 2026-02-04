# smart-parking-capstone

## Getting started - Quick guide
- Before getting started, ensure you have: Flutter, gunicorn, and a Python3 environment set up.
- To activate the live counter:
    - from smart_parking/APPAPI run "source .venv/bin/activate" to activate the Python Environment
    - run "gunicorn --bind 0.0.0.0:8000 appAPI:app". This establishes your connection to the API services that allow the application
    to pull the counters.
    - Start a new terminal.
    - Activate a new Python environment
    - run "python apiPopulator.py". This is what allows the application to update in live time.
- To run the application: 
    - Run "flutter devices" in the cmd and ensure that your web browser of choice appears.
    - In the smart_parking folder, run "flutter run -d {browser}"


### smart_parking
- The code in this project is for the Flutter app. The app allows users to view the live parking spot count, create an account, and navigate using google maps. Next semester the website will also host the predictions page to show the results of the Machine Learning algorithms. 
- The app's dart code can be found in smart_parking/lib.
    - main.dart, file that builds that app
    - firebase_options.dart, file that contains API keys for different platforms, in support of the account feature
    - src folder, premade code created when the flutter project was created
    - services folder, code outlining the functionality of the account feature
    - homepage folder, the folder containing the app pages in some case broken with 1 page broken into multiple files for readability
- To run this project,
    1. To run this code on any machine copy smart_parking onto a local computer and run main.dart. This will run the app in a selected web browser.
    2. To run this code in a simulator mode:
        1. Copy smart_parking on to a device running Mac OS
        2. Download Xcode
        3. Run "open -a simulator" in the terminal
        4. Run "run flutter" (Make sure you are in the "ios" folder when running command)
      
### APPAPI
- This folder contains 2 files.
    1. apiPopulator, this script populates the rest api with accurate parking data
    2. appAPI.py, this code defines the rest api and the related html methods
- To run this code:
    - apiPopulator, this code can be run sucussesfully using python 3 on any device as long as the appAPI is running.
    - appAPI.py, this code must be run in a flask environment, and uses gunicorn to bind the api to a port on the machine
