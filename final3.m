clc;
clear;

function fallDetectionSystem
    % Your Twilio credentials (accountSid, authToken, to, from)
    % Replace with your accountSid
    % Replace with your authToken
    % Replace with your recipient's number
    % Replace with your Twilio phone number

    % Clear existing mobiledev object and timers if they exist
    if exist('m', 'var') && isa(m, 'mobiledev') && isvalid(m)
        clear m;
    end
    if ~isempty(timerfindall)
        delete(timerfindall);
    end

    % Create the UI figure window
    fig = uifigure('Position', [100, 100, 800, 600], 'Name', 'Fall Detection System');
    
    % Create Start/Stop button
    btn = uibutton(fig, 'push', 'Position', [50, 500, 100, 40], 'Text', 'Start', ...
        'ButtonPushedFcn', @(btn, event) toggleDetection(btn));
    
    % Create a status indicator lamp
    lamp = uilamp(fig, 'Position', [200, 510, 20, 20], 'Color', 'red');
    
    % Create plots for accelerometer data
    ax1 = uiaxes(fig, 'Position', [50, 300, 700, 150]);
    title(ax1, 'Accelerometer Data');
    xlabel(ax1, 'Time');
    ylabel(ax1, 'Acceleration');
    grid(ax1, 'on');
    hold(ax1, 'on');
    accX = plot(ax1, nan, nan, 'DisplayName', 'X');
    accY = plot(ax1, nan, nan, 'DisplayName', 'Y');
    accZ = plot(ax1, nan, nan, 'DisplayName', 'Z');
    legend(ax1, 'show');
    
    % Create plots for gyroscope data
    ax2 = uiaxes(fig, 'Position', [50, 100, 700, 150]);
    title(ax2, 'Gyroscope Data');
    xlabel(ax2, 'Time');
    ylabel(ax2, 'Angular Velocity');
    grid(ax2, 'on');
    hold(ax2, 'on');
    gyroX = plot(ax2, nan, nan, 'DisplayName', 'X');
    gyroY = plot(ax2, nan, nan, 'DisplayName', 'Y');
    gyroZ = plot(ax2, nan, nan, 'DisplayName', 'Z');
    legend(ax2, 'show');
    
    % Timer for updating data
    dataTimer = timer('ExecutionMode', 'fixedRate', 'Period', 5, ...
        'TimerFcn', @(~, ~) updateData());
    
    % Create a mobiledev object
    m = mobiledev;
    m.AccelerationSensorEnabled = true;
    m.AngularVelocitySensorEnabled = true;
    % m.LocationSensorEnabled = true; % Remove this line

    % Initialize flags and data
    accel_threshold = 19.6;  % 2 g in m/s²
    gyro_threshold = 100;    % 300 °/s
    fallDetected = false;
    
    % Nested function to toggle detection
    function toggleDetection(btn)
        if strcmp(btn.Text, 'Start')
            btn.Text = 'Stop';
            lamp.Color = 'green';
            m.Logging = true;
            start(dataTimer);
        else
            btn.Text = 'Start';
            lamp.Color = 'red';
            m.Logging = false;
            stop(dataTimer);
        end
    end

    % Nested function to update data
    function updateData()
        [fallDetected, maxAccelData, maxGyroData] = fetchData(m, accel_threshold, gyro_threshold);

        % Retrieve the logged data
        [accelData, accelTime] = accellog(m);
        [gyroData, gyroTime] = angvellog(m);

        % Update plots
        set(accX, 'XData', accelTime, 'YData', accelData(:, 1));
        set(accY, 'XData', accelTime, 'YData', accelData(:, 2));
        set(accZ, 'XData', accelTime, 'YData', accelData(:, 3));

        set(gyroX, 'XData', gyroTime, 'YData', gyroData(:, 1));
        set(gyroY, 'XData', gyroTime, 'YData', gyroData(:, 2));
        set(gyroZ, 'XData', gyroTime, 'YData', gyroData(:, 3));

        drawnow;

        % Check if a fall is detected
        if fallDetected
            disp('Fall detected. Sending SMS.');
            sendSMSWithLocation(to, from);  % Send SMS with location
            
            % You can choose to keep data collection running or stop it
            % m.Logging = false;  % Uncomment if you want to stop data collection
        end
    end

    % Function to fetch and process the maximum data point over the last 5 seconds
    function [fallDetected, maxAccelData, maxGyroData] = fetchData(m, accel_threshold, gyro_threshold)
        fallDetected = false;
        maxAccelData = [0, 0, 0];  % Default value for maximum accelerometer data
        maxGyroData = [0, 0, 0];   % Default value for maximum gyroscope data

        % Retrieve the logged data
        [accelData, accelTime] = accellog(m);
        [gyroData, gyroTime] = angvellog(m);

        % Ensure there is enough data to process
        if isempty(accelData) || isempty(gyroData)
            disp('No data available for processing.');
            return;
        end

        % Filter data from the last 5 seconds
        currentTime = max(max(accelTime), max(gyroTime));
        timeWindow = 5; % seconds
        accelIdx = find(accelTime >= (currentTime - timeWindow));
        gyroIdx = find(gyroTime >= (currentTime - timeWindow));

        % Extract data within the 5-second window
        accelDataWindow = accelData(accelIdx, :);
        gyroDataWindow = gyroData(gyroIdx, :);

        % Calculate the maximum values within the window
        if ~isempty(accelDataWindow)
            maxAccelData = max(accelDataWindow, [], 1);
        end
        if ~isempty(gyroDataWindow)
            maxGyroData = max(gyroDataWindow, [], 1);
        end

        % Display the maximum data points
        disp('Maximum Accelerometer Data:');
        disp(maxAccelData);
        disp('Maximum Gyroscope Data:');
        disp(maxGyroData);

        % Check if a fall is detected using the maximum data points
        isFall = detectFall(maxAccelData, maxGyroData, accel_threshold, gyro_threshold);
        if isFall
            disp('Fall detected!');
            fallDetected = true;
        else
            disp('No fall detected.');
        end
    end

    % Function to detect fall based on threshold values
    function isFall = detectFall(accelData, gyroData, accel_threshold, gyro_threshold)
        % Calculate magnitudes
        accel_magnitude = sqrt(sum(accelData.^2));
        gyro_magnitude = sqrt(sum(gyroData.^2));

        % Determine if the data exceeds the thresholds
        isFall = any(accel_magnitude > accel_threshold) || any(gyro_magnitude > gyro_threshold);
    end

    % Function to send SMS using Twilio
    function sendSMSWithLocation(to, from)
        % Start logging GPS data
        m.Logging = true;
        pause(15); % Wait for initial GPS data

        % Check if location data is available
        if isempty(m.Latitude) || isempty(m.Longitude)
            error('GPS data is not available. Ensure your mobile device has GPS enabled and is providing data to MATLAB Mobile.');
        end

        % Get the most recent location
        latitude = m.Latitude(end);
        longitude = m.Longitude(end);

        % Stop logging data
        m.Logging = false;

        % Create the message body with location
        body = sprintf('Fall detected! Location: https://www.google.com/maps?q=%f,%f', latitude, longitude);

        % Twilio API endpoint for sending SMS
        url = ['https://api.twilio.com/2010-04-01/Accounts/', accountSid, '/Messages.json'];

        % Message data
        data = [
            'To=' urlencode(to) '&' ...
            'From=' urlencode(from) '&' ...
            'Body=' urlencode(body)
        ];

        % Set up HTTP request options
        options = weboptions('RequestMethod', 'post', ...
                             'HeaderFields', {'Authorization', ['Basic ' matlab.net.base64encode([accountSid ':' authToken])]});

        % Send the HTTP POST request
        response = webwrite(url, data, options);

        % Display the response
        disp(response);
    end
end

fallDetectionSystem;  % Run the system
