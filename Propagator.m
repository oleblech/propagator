classdef Propagator
    properties
        spacecraft % Spacecraft object
        centralBody % CentralBody object
        timeStep % Time step for recording output
        totalTime % Total simulation time
        altitudeLimit % below this altitude the propagation is aborted
    end
    
    methods
        function obj = Propagator(spacecraft, centralBody, timeStep, totalTime, altitudeLimit)
            obj.spacecraft = spacecraft;
            obj.centralBody = centralBody;
            obj.timeStep = timeStep;
            obj.totalTime = totalTime;
            obj.altitudeLimit = altitudeLimit;
        end
        
        function trajectory = propagate(obj)
            % Initial state vector
            initialState = [obj.spacecraft.state.position; obj.spacecraft.state.velocity];
            
            % Time span for integration
            tspan = [0 obj.totalTime];
            
            % Set error tolerances and event function
            options = odeset('reltol', 1.e-10, ...
                             'abstol', 1.e-10, ...
                             'events', @(t, state) altitudeEvent(t, state, obj.centralBody, obj.altitudeLimit));
            
            % Use ode45 to integrate the equations of motion
            [T, Y, TE, YE, IE] = ode45(@odefun, tspan, initialState, options);
            
            % Interpolate results at specified time steps for output
            numSteps = floor(obj.totalTime / obj.timeStep) + 1;
            tOutput = linspace(0, obj.totalTime, numSteps);
            Y_interp = interp1(T, Y, tOutput);
            
            % Store trajectory as [x, y, z, vx, vy, vz] for each time step
            trajectory = Y_interp;

            % Define the differential equations
            function dState = odefun(t, state)
                % Extract position and velocity
                position = state(1:3);
                velocity = state(4:6);
                
                % Compute gravitational acceleration
                gravityAcc = obj.centralBody.getGravityAccel(position);
                
                % Compute atmospheric drag if atmosphere model is present
                if ~isempty(obj.centralBody.atmosphereModel)
                    altitude = norm(position) - obj.centralBody.radius;
                    density = obj.centralBody.atmosphereModel.density(altitude);
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
