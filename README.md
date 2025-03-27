# AuraBloom

AuraBloom is a comprehensive mobile application designed to assist women in managing period pain and improving menstrual health. This README provides an overview of the project, its structure, and instructions for setting up and running the application.

## Table of contents

* Project structure
* Backend setup
* Frontend setup
* Running the application
* Continuous integration and deployment
* Contributing

## Project structure

The project is organized into the following main directories:

* `backend/`: Contains the backend code for the application, including the Flask server and chatbot logic.
* `frontend/`: Contains the frontend code for the application, built using Flutter.
* `models/`: Contains machine learning models and related code for period prediction.
* `.github/workflows/`: Contains GitHub Actions workflows for continuous integration and deployment.

## Backend setup

The backend is built using Flask and provides APIs for the chatbot and period management features.

### Prerequisites

* Python 3.7 or higher
* Flask
* Flask-CORS
* OpenAI Python library

### Installation

1. Clone the repository and navigate to the `backend/` directory.
2. Install the required Python packages:
   ```bash
   pip install -r requirements.txt
   ```

### Running the backend

1. Set the OpenAI API key in the `backend/PeriodPainChatbot.py` file.
2. Start the Flask server:
   ```bash
   python app.py
   ```

The backend server will be running at `http://localhost:8080`.

## Frontend setup

The frontend is built using Flutter and provides the user interface for the application.

### Prerequisites

* Flutter SDK
* Android Studio or Visual Studio Code with Flutter and Dart plugins

### Installation

1. Clone the repository and navigate to the `frontend/` directory.
2. Install the required Flutter packages:
   ```bash
   flutter pub get
   ```

### Running the frontend

1. Connect a physical device or start an emulator.
2. Run the Flutter application:
   ```bash
   flutter run
   ```

## Running the application

To run the complete application, follow these steps:

1. Start the backend server as described in the Backend setup section.
2. Run the frontend application as described in the Frontend setup section.

## Continuous integration and deployment

The project uses GitHub Actions for continuous integration and deployment. The workflows are defined in the `.github/workflows/` directory.

* `.github/workflows/ci.yml`: Defines the continuous integration workflow for the development and main branches.
* `.github/workflows/cd.yml`: Defines the continuous deployment workflow for the main branch.

## Contributing

We welcome contributions to AuraBloom! If you would like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Make your changes and commit them with descriptive commit messages.
4. Push your changes to your fork.
5. Create a pull request to the main repository.
