classdef Spacecraft
    properties
        mass
        dragArea
        dragCoefficient
        state
        centralBody
    end
    
    methods
        function obj = Spacecraft(mass, dragArea, dragCoefficient, initialCondition, conditionType, centralBody)
            obj.mass = mass;
            obj.dragArea = dragArea;
            obj.dragCoefficient = dragCoefficient;
            obj.centralBody = centralBody;
            mu = obj.centralBody.gravitationalParameter;
            
            if strcmp(conditionType, 'stateVector')
                obj.state = initialCondition;
            else
                elements = OrbitalElements(initialCondition, conditionType, mu);
                stateVector = elements.toStateVector(mu);
                obj.state = State(stateVector(1:3), stateVector(4:6));
            end
        end
        
        function dragForce = applyDrag(obj, density, relativeVelocity)
            % Compute drag force based on current state and environment
            speed = norm(relativeVelocity);
            dragForce = -0.5 * density * speed^2 * obj.dragCoefficient * obj.dragArea * (relativeVelocity / speed);
        end
    end
end
