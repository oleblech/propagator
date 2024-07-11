classdef Propagator
    properties
        spacecraft % Spacecraft object
        startTime % Epoch when simulation starts
        sampleTime % Time step for recording output
        stopTime % Epoch when simulation ends
        altitudeLimit % below this altitude the propagation is aborted
    end
    
    methods
        function obj = Propagator(spacecraft, startTime, sampleTime, stopTime, altitudeLimit)
            obj.spacecraft = spacecraft;
            obj.startTime = startTime;
            obj.sampleTime = sampleTime;
            obj.stopTime = stopTime;
            obj.altitudeLimit = altitudeLimit;
        end
        
        function trajectory = propagate(obj)
            % Initial state vector
            initialState = [obj.spacecraft.state.position; obj.spacecraft.state.velocity];
            
            % Time span for integration
            duration = seconds(obj.stopTime - obj.startTime); % duration in seconds
            tspan = [0 duration];
            
            % Set error tolerances and event function
            options = odeset('reltol', 1.e-10, ...
                             'abstol', 1.e-10, ...
                             'events', @(t, state) altitudeEvent(t, state, obj.spacecraft.centralBody, obj.altitudeLimit));
            
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
                latitude = lla(1);
                longitude = lla(2);
                altitude = lla(3);
                
                % Compute gravitational acceleration
                gravityAcc = obj.spacecraft.centralBody.getGravityAccel(position);
                
                % Compute atmospheric drag if atmosphere model is present
                if ~isempty(obj.spacecraft.centralBody.atmosphereModel)
                    density = obj.spacecraft.centralBody.atmosphereModel.density(latitude, longitude, altitude, utcDateTime);
                    dragForce = obj.spacecraft.applyDrag(density, velocity);
                    dragAcc = dragForce / obj.spacecraft.mass;
                else
                    dragAcc = [0; 0; 0];
                end
                
                % Total acceleration
                totalAcc = gravityAcc + dragAcc;
                
                % Return derivatives
                dState = [velocity; totalAcc];
            end

            function [value, isTerminal, direction] = altitudeEvent(t, state, centralBody, altitudeLimit)
                position = state(1:3);
                altitude = norm(position) - centralBody.radius;
                
                % Event is detected when altitude falls below altitudeLimit
                value = altitude - altitudeLimit;
                isTerminal = 1; % Stop the integration
                direction = -1; % Negative direction (altitude decreasing)
            end

        end
    end
end
