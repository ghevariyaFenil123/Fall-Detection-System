The Fall Detection System is a MATLAB-based project that leverages mobile device sensors (accelerometer and gyroscope) to detect falls. Upon detecting a fall, the system sends an SMS alert containing the fall's location using Twilio's API. It integrates with the MATLAB Mobile app to collect sensor data from the device.

### Features
- **Real-Time Fall Detection:** Monitors accelerometer and gyroscope data continuously, triggering fall detection based on preset thresholds.
- **SMS Alerts:** Sends an SMS to a designated number when a fall is detected, including a Google Maps link with the location.
- **Graphical Interface:** Includes a simple GUI to start/stop detection and visualize sensor data.

### Requirements
- **Software:** MATLAB with Mobile Sensor Connectivity and the MATLAB Mobile app installed.
- **Twilio Account:** Needed for sending SMS notifications.
- **Hardware:** A mobile device equipped with accelerometer, gyroscope, and GPS.

### Installation
1. **Clone the Repository:** `git clone https://github.com/Savani-Manvi/Fall-Detection-System-Simulation-on-MATLAB.git`
2. **Twilio Setup:**
   - Create a Twilio account and obtain your accountSid, authToken, and a Twilio phone number.
   - Update the fallDetectionSystem function with these credentials and the recipient's phone number.
3. **MATLAB Setup:**
   - Ensure MATLAB is installed.
   - Open the `fallDetectionSystem.m` script in MATLAB.
   - Set up and connect the MATLAB Mobile app on your device.

### Usage
- **Run the Script:** Start MATLAB and execute `fallDetectionSystem.m`. A GUI will appear showing real-time accelerometer and gyroscope data.
- **Start Detection:** Press "Start" to begin monitoring sensor data.
- **Fall Detection:** If a fall is detected based on threshold values, a message will be shown in MATLAB, and an SMS will be sent with the location.
- **Stop Detection:** Press "Stop" to end the monitoring.

### Configuration
- **Thresholds:** Default thresholds are set for fall detection (19.6 m/s² for acceleration, 100 °/s for the gyroscope). These can be adjusted in the fallDetectionSystem function.
- **SMS Notifications:** GPS data is required for the SMS to include the location.

### Limitations
The system relies on the mobile device's sensor quality and GPS signal, which can affect accuracy. The detection method uses basic thresholding, and more sophisticated algorithms could improve performance.

### License
This project is licensed under the MIT License. For more details, refer to the LICENSE file.

### Contributions
Contributions are encouraged! Fork the repository and submit pull requests for enhancements or bug fixes.

### Contact
For inquiries, email fenilghevariya5577@gmail.com.
