classdef State
    properties
        position % 3x1 double
        velocity % 3x1 double
    end
    
    methods
        function obj = State(position, velocity)
            obj.position = position;
            obj.velocity = velocity;
        end
        
        function pos = getPosition(obj)
            pos = obj.position;
        end
        
        function vel = getVelocity(obj)
            vel = obj.velocity;
        end
        
        function updatePosition(obj, newPosition)
            obj.position = newPosition;
        end
        
        function updateVelocity(obj, newVelocity)
            obj.velocity = newVelocity;
        end
    end
end

