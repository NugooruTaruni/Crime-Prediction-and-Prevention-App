# Crime Prediction & Prevention App

A smart city mobile application that uses real-time data, machine learning, and geographic information systems (GIS) to identify crime hotspots and empower citizens—especially women—with tools to make safer decisions in their environment.



## Overview

- In today’s urban landscape, safety has become an urgent concern. This app leverages SVM-based crime prediction and Google Maps for hotspot detection, integrating crime response, analysis, and prevention in one platform.

- Achieved 97% accuracy using Support Vector Machines (SVM) to classify and predict crime types in real-time.

- Built with Flutter, this cross-platform app provides alerts and safety insights through an intuitive interface and is deployable on Android.



## Features

- Real-time crime detection using historical data and user inputs
- Machine Learning (SVM) model trained on crime datasets
- Integration with Google Maps for hotspot visualization
- Law enforcement dashboard (expandable)
- Mobile-friendly UI using Flutter
- Focused on people's safety and social awareness


## Tech Stack

| Layer | Tools |
|------|-------|
| ML Model | Python, scikit-learn (SVM) |
| App Framework | Flutter |
| Backend | Firebase / Local storage (modify if used something else) |
| Maps Integration | Google Maps API |
| Platform | Android (via Android Studio) |



## How to Run

### ML Model

1. Clone the repository:
   git clone https://github.com/NugooruTaruni/Crime-Prediction-and-Prevention-App.git

2. Flutter App
i) Open Crime_Prevention_App in Android Studio.
ii) Run: flutter pub get
flutter run

Ensure that Flutter SDK and Android Studio are installed on your system.


## SVM Model Details
- Trained on a real-world crime dataset containing location, time, and type of crime.

- Used GridSearchCV for hyperparameter tuning.

- Predicts among three major crime types with approximately 97% accuracy.


## Future Enhancements
- Real-time GPS tracking

- Personalized risk scoring

- Integration with law enforcement alert systems

- Multi-language and accessibility features

License
This project is open-source and available under the MIT License.
