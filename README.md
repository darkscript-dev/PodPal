# PodPal - Your Robotic Gardening Companion

> A project by **[Darkscript](https://github.com/darkscript-dev)**

PodPal is a smart plant pod that automates the process of growing plants by monitoring and controlling their environment. This Flutter application serves as the dashboard for interacting with your PodPal, allowing you to monitor your plant's vitals, receive AI-powered care recommendations, and manually control the pod's hardware.

<table>
  <tr>
    <td><img src="./screenshots/loading_screen.png" alt="Home Screen" width="250"/></td>
    <td><img src="./screenshots/home_screen.png" alt="Charts Screen" width="250"/></td>
  </tr>
  <tr>
    <td><img src="./screenshots/charts_screen.png" alt="Profile Screen" width="250"/></td>
    <td><img src="./screenshots/settings_screen.png" alt="Settings Screen" width="250"/></td>
  </tr>
</table>

## Features

*   **Real-time Monitoring:** Keep track of your plant's temperature, humidity, soil moisture, and light levels.
*   **AI Guardian Angel:** Leverages the Gemini API to provide intelligent, adaptive care plans for your specific plant.
*   **Manual Control:** Adjust the settings for the water pump, fan, and grow light directly from the app.
*   **Historical Data:** View charts of historical sensor data to track your plant's progress over time.
*   **Onboarding and Setup:** A simple and intuitive process to connect the app to your PodPal device.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
*   Android Studio or Visual Studio Code
*   An Android or iOS device or emulator

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/PodPal.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd PodPal
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Set up your Gemini API Key:**
    *   Create a new file named `.env` in the root of the project.
    *   Add the following line to the `.env` file, replacing `YOUR_API_KEY` with your actual Gemini API key:
        ```
        GEMINI_API_KEY=YOUR_API_KEY
        ```
    *   **Important:** This file is included in the `.gitignore` to prevent your API key from being committed to the repository.

5.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

The project is organized into the following directories:

*   `lib/api`: Contains services for interacting with external APIs (Gemini, Pod hardware) and the local database.
*   `lib/models`: Defines the data models used throughout the application.
*   `lib/providers`: Manages the application's state using the Provider package.
*   `lib/screens`: Contains the UI for each screen of the application.
*   `lib/widgets`: Contains reusable UI components.

## Arduino Code

The Arduino code for the PodPal sensor hub can be found in the `/arduino` directory at the root of this repository. This code is responsible for reading sensor data, controlling the actuators, and communicating with the Flutter application.

### Hardware

*   Arduino Due (or compatible)
*   DHT11 Temperature and Humidity Sensor
*   Soil Moisture Sensor
*   Light Dependent Resistors (LDRs)
*   Servos
*   Water Pump
*   Fan
*   Grow Light

### Setup

1.  Open the `arduino/DVE_R3_The_Sensor_Hub/DVE_R3_The_Sensor_Hub.ino` file in the Arduino IDE.
2.  Install the required libraries:
    *   `DHT sensor library`
    *   `Servo`
    *   `LiquidCrystal_I2C`
    *   `ArduinoJson`
3.  Connect your Arduino to your computer.
4.  Select the correct board and port from the `Tools` menu.
5.  Upload the sketch to your Arduino.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## Acknowledgments

*   A huge thank you to **[MihirangaDissanayake](https://github.com/MihirangaDissanayake)** for developing and providing the complete Arduino code for the sensor hub.
* [Flutter](https://flutter.dev/)
*   [Google Gemini](https://ai.google.dev/)
*   [Arduino](https://www.arduino.cc/)

## License

Distributed under the MIT License. See `LICENSE` for more information.
