classdef pointOfInterest < handle
    % Represents a point of interest on the surface of the central body

    properties
        latitude
        longitude
        width
        height
        contactCount
    end

    methods
        function obj = pointOfInterest(latitude,longitude,width,height)
            obj.latitude = latitude;
            obj.longitude = longitude;
            obj.width = width;
            obj.height = height;
            obj.contactCount = 0;
        end

        function FOV = getFOV(obj)
            FOV(1,:) = [obj.latitude - obj.height/2, obj.longitude - obj.width/2];
            FOV(2,:) = [obj.latitude + obj.height/2, obj.longitude - obj.width/2];
            FOV(3,:) = [obj.latitude + obj.height/2, obj.longitude + obj.width/2];
            FOV(4,:) = [obj.latitude - obj.height/2, obj.longitude + obj.width/2];
            FOV(5,:) = [obj.latitude - obj.height/2, obj.longitude - obj.width/2];
        end

        function obj = increaseCount(obj)
            obj.contactCount = obj.contactCount + 1;
        end
    end
end