classdef Propagator < handle
    % Integrates the trajectory of a spacecraft orbiting a central body.
    properties
        spacecraft % Spacecraft object
        startTime % Epoch when simulation starts
        sampleTime % Time step for recording output
        stopTime % Epoch when simulation ends
        altitudeLimit % below this altitude the propagation is aborted
        maxStep % maximum step size of the integration
    end
    
    methods
        function obj = Propagator(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep)
            obj.spacecraft = spacecraft;
            obj.startTime = startTime;
            obj.sampleTime = sampleTime;
            obj.stopTime = stopTime;
            obj.altitudeLimit = altitudeLimit;
            obj.maxStep = maxStep;
        end
        
        function [trajectory,TE,YE,IE] = propagate(obj)
            % Initial state vector
            initialState = [obj.spacecraft.state.position; obj.spacecraft.state.velocity];
            
            % Time span for integration
            duration = seconds(obj.stopTime - obj.startTime); % duration in seconds
            tspan = [0 duration];
            
            % Set error tolerances and event function
            options = odeset('MaxStep', obj.maxStep, ...
                             'events', @(t, state) eventFunction(t, state, obj.spacecraft, obj.altitudeLimit));
            
            % Use ode45 to integrate the equations of motion
            [T, Y, TE, YE, IE] = ode45(@odefun, tspan, initialState, options);
            
            % Interpolate results at specified time steps for output
            numSteps = floor(duration / obj.sampleTime) + 1;
            tOutput = linspace(0, duration, numSteps);
            Y_interp = interp1(T, Y, tOutput);
            
            % Store trajectory as [x, y, z, vx, vy, vz] for each time step
            trajectory = Y_interp;

            % Define the differential equations
            function dState = odefun(t, state)
                % Extract position and velocity
                position = state(1:3);
                velocity = state(4:6);

                % Convert ECI position to LLA (latitude, longitude, altitude)
                utcDateTime = obj.startTime + seconds(t);
                utcDateTimeArray = [year(utcDateTime)...
                                    month(utcDateTime)...
                                    day(utcDateTime)...
                                    hour(utcDateTime)...
                                    minute(utcDateTime)...
                                    second(utcDateTime)];
                lla = eci2lla(position', utcDateTimeArray);
                obj.spacecraft.updateLastLLA(lla);
                
                % Compute gravitational acceleration
                gravityAcc = obj.spacecraft.centralBody.getGravityAccel(position);
                
                % Compute atmospheric drag if atmosphere model is present
                if ~isempty(obj.spacecraft.centralBody.atmosphereModel)
                    density = obj.spacecraft.centralBody.atmosphereModel.density(lla(1), lla(2), lla(3), utcDateTime);
                    dragAcc = obj.spacecraft.getDragAccel(density, velocity);
                    dragAcc = dragAcc / obj.spacecraft.mass;
                else
                    dragAcc = [0; 0; 0];
                end
                
                % Total acceleration
                totalAcc = gravityAcc + dragAcc;
                
                % Return derivatives
                dState = [velocity; totalAcc];
            end

            function [value, isTerminal, direction] = eventFunction(t, state, spacecraft, altitudeLimit)
                % Detect if altitude is below altitude limit
                position = state(1:3);
                altitude = norm(position) - spacecraft.centralBody.radius;

                value(1) = altitude - altitudeLimit;
                isTerminal(1) = 1; % Stop the integration
                direction(1) = -1; % Negative direction (altitude decreasing)

                % Count contacts with point of interest
                value(2) = spacecraft.checkContact(); % event triggered if 0
                isTerminal(2) = 0; % Do not stop the integration
                direction(2) = 0; % Any direction
            end
        end
    end
end
