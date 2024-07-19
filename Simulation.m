classdef Simulation < handle
    % Simulates the orbit of a spacecraft around a central body and enables to plot several insights
    properties
        spacecraft
        startTime
        sampleTime
        stopTime
        altitudeLimit
        propagator
        plotTrajectory = false;
        plotOrbitalElements = false;
        plotGroundTrack = false;
    end
    
    methods
        function obj = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit)
            obj.spacecraft = spacecraft;
            obj.startTime = startTime;
            obj.sampleTime = sampleTime;
            obj.stopTime = stopTime;
            obj.altitudeLimit = altitudeLimit;
            obj.propagator = Propagator(spacecraft, startTime, sampleTime, stopTime, altitudeLimit);
        end
        
        function run(obj)
            trajectory = obj.propagator.propagate();
            

            if(obj.plotTrajectory)
                obj.plotTrajectoryFun(trajectory);
            end

            if(obj.plotOrbitalElements)
                elementsTrajectory = OrbitalElements.fromStateVector(trajectory, obj.spacecraft.centralBody.gravitationalParameter);
                obj.plotOrbitalElementsFun(elementsTrajectory);
            end

            if(obj.plotGroundTrack)
                position = trajectory(:,1:3);
                utcDateTime = obj.startTime:seconds(obj.sampleTime):obj.stopTime;
                utcDateTimeArray = [year(utcDateTime')...
                                    month(utcDateTime')...
                                    day(utcDateTime')...
                                    hour(utcDateTime')...
                                    minute(utcDateTime')...
                                    second(utcDateTime')];
                lla = eci2lla(position, utcDateTimeArray);
                latitude = lla(:,1);
                longitude = lla(:,2);

                obj.plotGroundTrackFun(latitude, longitude);
            end

        end
        
        function plotTrajectoryFun(obj, trajectory)
            figure;
            hold on;
            obj.spacecraft.centralBody.plotCentralBody();
            plot3(trajectory(:, 1), trajectory(:, 2), trajectory(:, 3), 'r', 'LineWidth', 0.5);
            xlabel('X (m)');
            ylabel('Y (m)');
            zlabel('Z (m)');
            title('Spacecraft Trajectory around Earth');
            grid on;
            axis equal;
            view(45, 30); % Set fixed 3D view angle
            hold off;
        end
        
        function plotOrbitalElementsFun(obj, elementsTrajectory)
            figure;
            duration = seconds(obj.stopTime - obj.startTime); % in seconds
            timeVec = linspace(0, duration, size(elementsTrajectory, 1));
            
            subplot(3, 2, 1);
            plot(timeVec, elementsTrajectory(:, 1));
            xlabel('Time (s)');
            ylabel('Semi-major axis (m)');
            title('Semi-major axis');
            
            subplot(3, 2, 2);
            plot(timeVec, elementsTrajectory(:, 2));
            xlabel('Time (s)');
            ylabel('Eccentricity');
            title('Eccentricity');
            
            subplot(3, 2, 3);
            plot(timeVec, elementsTrajectory(:, 3));
            xlabel('Time (s)');
            ylabel('Inclination (rad)');
            title('Inclination');
            
            subplot(3, 2, 4);
            plot(timeVec, elementsTrajectory(:, 4));
            xlabel('Time (s)');
            ylabel('RAAN (rad)');
            title('RAAN');
            
            subplot(3, 2, 5);
            plot(timeVec, elementsTrajectory(:, 5));
            xlabel('Time (s)');
            ylabel('Argument of Periapsis (rad)');
            title('Argument of Periapsis');
            
            subplot(3, 2, 6);
            plot(timeVec, elementsTrajectory(:, 6));
            xlabel('Time (s)');
            ylabel('True Anomaly (rad)');
            title('True Anomaly');
        end
        
        function plotGroundTrackFun(obj, latitude, longitude)
            geoplot(latitude,longitude,'.');
            hold on
            geoplot(latitude(1),longitude(1),'*');
            geobasemap topographic;
        end
    end
end
