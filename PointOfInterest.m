classdef PointOfInterest < handle
    % Represents a point of interest on the surface of the central body

    properties
        latitude
        longitude
        height
        width
    end

    methods
        function obj = PointOfInterest(latitude,longitude,height,width)
            obj.latitude = latitude;
            obj.longitude = longitude;
            obj.height = height;
            obj.width = width;
        end

        function FOV = getFOV(obj)
            FOV(1,:) = [obj.latitude - obj.height/2, obj.longitude - obj.width/2];
            FOV(2,:) = [obj.latitude + obj.height/2, obj.longitude - obj.width/2];
            FOV(3,:) = [obj.latitude + obj.height/2, obj.longitude + obj.width/2];
            FOV(4,:) = [obj.latitude - obj.height/2, obj.longitude + obj.width/2];
            FOV(5,:) = [obj.latitude - obj.height/2, obj.longitude - obj.width/2];
        end
    end
end