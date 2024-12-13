classdef Simulation < handle
    % Simulates the orbit of a spacecraft around a central body and enables to plot several insights
    properties
        spacecraft
        startTime
        sampleTime
        stopTime
        altitudeLimit
        propagator
        plotTrajectoryFlag
        plotOrbitalElementsFlag
        plotGroundTrackFlag
    end
    
    methods
        function obj = Simulation(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep)
            obj.spacecraft = spacecraft;
            obj.startTime = startTime;
            obj.sampleTime = sampleTime;
            obj.stopTime = stopTime;
            obj.altitudeLimit = altitudeLimit;
            obj.propagator = Propagator(spacecraft, startTime, sampleTime, stopTime, altitudeLimit, maxStep);
            obj.plotTrajectoryFlag = false;
            obj.plotOrbitalElementsFlag = false;
            obj.plotGroundTrackFlag = false;

        end
        
        function [trajectory,trajLat,trajLon,TE,YE,IE] = run(obj)
            [trajectory,TE,YE,IE] = obj.propagator.propagate();
            
            % trajectory to latitude and longitude
            idx = ~isnan(trajectory);
            position = trajectory(find(sum(idx,2)),1:3);
            utcDateTime = obj.startTime:seconds(obj.sampleTime):obj.stopTime;
            utcDateTimeArray = datevec(utcDateTime);
            utcDateTimeArray = utcDateTimeArray(find(sum(idx,2)),:);
            lla = eci2lla(position, utcDateTimeArray);
            trajLat = lla(:,1);
            trajLon = lla(:,2);
            
            % plot Trajectory
            if(obj.plotTrajectoryFlag)
                obj.plotTrajectory(trajectory);
            end
            
            % plot orbital elements
            if(obj.plotOrbitalElementsFlag)
                elementsTrajectory = OrbitalElements.fromStateVector(trajectory, obj.spacecraft.centralBody.gravitationalParameter);
                obj.plotOrbitalElements(elementsTrajectory);
            end
            
            % plot ground track
            if(obj.plotGroundTrackFlag)
                obj.plotGroundTrack(trajLat,trajLon,"poi",TE,YE);
            end

        end
        
        function plotTrajectory(obj, trajectory)
            figure;
            obj.spacecraft.centralBody.plotCentralBody();
            hold on;
            plot3(trajectory(:, 1), trajectory(:, 2), trajectory(:, 3), 'r', 'LineWidth', 0.5);
            hold off;
        end
        
        function plotOrbitalElements(obj, elementsTrajectory)
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
        
        function plotGroundTrack(obj, trajLat, trajLon, varargin)
            % Open figure
            figure;
        
            % Plot ground track
            geoplot(trajLat, trajLon, '.m', 'MarkerSize', 10);
            hold on;
        
            % Check for optional flags in varargin
            plotFOV = false;
            plotPOI = false;
            plotInit = false;
            plotContacts = false;
            TE = [];
            YE = [];
            
            % Parse varargin to set flags and extract additional data if needed
            for i = 1:length(varargin)
                if ischar(varargin{i}) || isstring(varargin{i})
                    switch varargin{i}
                        case 'fov'
                            plotFOV = true;
                        case 'poi'
                            plotPOI = true;
                        case 'init'
                            plotInit = true;
                        case 'contacts'
                            plotContacts = true;
                    end
                elseif isnumeric(varargin{i}) && isempty(TE) && isempty(YE)
                    % Assign TE and YE if 'contacts' flag is specified and they are provided
                    TE = varargin{i};
                    if i < length(varargin) && isnumeric(varargin{i+1})
                        YE = varargin{i+1};
                    end
                end
            end
        
            % Plot initial condition if specified
            if plotInit
                geoplot(trajLat(1), trajLon(1), '*r', 'LineWidth', 2);
            end
        
            % Plot Point of Interest if specified
            if plotPOI
                poiLat = obj.spacecraft.poi.latitude;
                poiLon = obj.spacecraft.poi.longitude;
                geoplot(poiLat, poiLon, '*k', 'LineWidth', 2);
            end
        
            % Plot Field of View of Point of Interest if specified
            if plotFOV
                FOV = obj.spacecraft.poi.getFOV();
                geoplot(FOV(:, 1), FOV(:, 2), 'b--', 'LineWidth', 2);
            end
        
            % Plot contacts if specified and TE and YE data are provided
            if plotContacts && ~isempty(TE) && ~isempty(YE)
                utcDateTimeContacts = obj.startTime + seconds(TE);
                utcDateTimeArrayContacts = datevec(utcDateTimeContacts);
                if ~isempty(utcDateTimeArrayContacts)
                    llaContacts = eci2lla(YE(:, 1:3), utcDateTimeArrayContacts);
                    geoplot(llaContacts(:, 1), llaContacts(:, 2), '*y', 'LineWidth', 2);
                end
            end
        
            % Set map type
            geobasemap topographic;
        
            % Legend
            legendEntries = {'Trajectory'};
            if plotInit, legendEntries{end+1} = 'Initial Condition'; end
            if plotPOI, legendEntries{end+1} = 'Point of Interest'; end
            if plotFOV, legendEntries{end+1} = 'Field of View'; end
            if plotContacts, legendEntries{end+1} = 'Begin/End of Contact'; end
            legend(legendEntries, 'FontSize', 16);
        end
    end
end
