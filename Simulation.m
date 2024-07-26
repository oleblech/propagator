classdef Simulation < handle
    % Simulates the orbit of a spacecraft around a central body and enables to plot several insights
    properties
        spacecraft
        startTime
        sampleTime
        stopTime
        altitudeLimit
        propagator
        plotTrajectory
        plotOrbitalElements
        plotGroundTrack
    end
    
    methods
        function obj = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep)
            obj.spacecraft = spacecraft;
            obj.startTime = startTime;
            obj.sampleTime = sampleTime;
            obj.stopTime = stopTime;
            obj.altitudeLimit = altitudeLimit;
            obj.propagator = Propagator(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep);
            obj.plotTrajectory = false;
            obj.plotOrbitalElements = false;
            obj.plotGroundTrack = false;

        end
        
        function run(obj)
            [trajectory,TE,YE,IE] = obj.propagator.propagate();
            

            if(obj.plotTrajectory)
                obj.plotTrajectoryFun(trajectory);
            end

            if(obj.plotOrbitalElements)
                elementsTrajectory = OrbitalElements.fromStateVector(trajectory, obj.spacecraft.centralBody.gravitationalParameter);
                obj.plotOrbitalElementsFun(elementsTrajectory);
            end

            if(obj.plotGroundTrack)
                

                obj.plotGroundTrackFun(trajectory,TE,YE,IE);
            end

        end
        
        function plotTrajectoryFun(obj, trajectory)
            figure;
            obj.spacecraft.centralBody.plotCentralBody();
            hold on;
            plot3(trajectory(:, 1), trajectory(:, 2), trajectory(:, 3), 'r', 'LineWidth', 0.5);
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
        
        function plotGroundTrackFun(obj,trajectory,TE,YE,IE)
            % open figure
            figure;
            % plot ground track
            idx = ~isnan(trajectory);
            position = trajectory(find(sum(idx,2)),1:3);
            utcDateTime = obj.startTime:seconds(obj.sampleTime):obj.stopTime;
            utcDateTimeArray = [year(utcDateTime')...
                                month(utcDateTime')...
                                day(utcDateTime')...
                                hour(utcDateTime')...
                                minute(utcDateTime')...
                                second(utcDateTime')];
            utcDateTimeArray = utcDateTimeArray(find(sum(idx,2)),:);
            lla = eci2lla(position, utcDateTimeArray);
            latitude = lla(:,1);
            longitude = lla(:,2);
            geoplot(latitude,longitude,'.','LineWidth',2);
            hold on

            % plot initial condition
            geoplot(latitude(1),longitude(1),'*r','LineWidth',2);
            
            % plot Field of View of Point of Interest
            FOV = obj.spacecraft.poi.getFOV();
            geoplot(FOV(:,1),FOV(:,2),'r--','LineWidth',2);

            % plot contacts
            utcDateTimeContacs = obj.startTime + seconds(TE);
            utcDateTimeArrayContacts = [year(utcDateTimeContacs)...
                                        month(utcDateTimeContacs)...
                                        day(utcDateTimeContacs)...
                                        hour(utcDateTimeContacs)...
                                        minute(utcDateTimeContacs)...
                                        second(utcDateTimeContacs)];
            if ~isempty(utcDateTimeArrayContacts)
                llaContacts = eci2lla(YE(:,1:3),utcDateTimeArrayContacts);
                geoplot(llaContacts(:,1),llaContacts(:,2),'*g','LineWidth',2);
            end
            
            % set map type
            geobasemap topographic;
        end
    end
end
