classdef Spacecraft < handle
    % Spacecraft which orbits a central body. It experiences different kinds of accelerations.
    properties
        mass
        dragArea
        dragCoefficient
        state
        initialState
        centralBody
        poi % pointOfInterest object
        lastLatitude % Store last calculated latitude to avoid recomputation
        lastLongitude % Store last calculated longitude to avoid recomputation
        lastAltitude % Store last calculated altitude to avoid recomputation
    end
    
    methods
        function obj = Spacecraft(mass, dragArea, dragCoefficient, initialCondition, conditionType, centralBody,pointOfInterest)
            obj.mass = mass;
            obj.dragArea = dragArea;
            obj.dragCoefficient = dragCoefficient;
            obj.centralBody = centralBody;
            obj.poi = pointOfInterest;
            obj.lastLatitude = NaN;
            obj.lastLongitude = NaN;
            obj.lastAltitude = NaN;
            mu = obj.centralBody.gravitationalParameter;
            
            if strcmp(conditionType, 'stateVector')
                obj.state = initialCondition;
            else
                elements = OrbitalElements(initialCondition, conditionType, mu);
                stateVector = elements.toStateVector(mu);
                obj.state = State(stateVector(1:3), stateVector(4:6));
            end
            obj.initialState = obj.state;
        end
        
        function dragAcc = getDragAccel(obj, density, relativeVelocity)
            % Compute drag force based on current state and environment
            speed = norm(relativeVelocity);
            dragForce = -0.5 * density * speed^2 * obj.dragCoefficient * obj.dragArea * (relativeVelocity / speed);
            dragAcc = dragForce / obj.mass;
        end

        function obj = updateLastLLA(obj, lla)
            obj.lastLatitude = lla(1);
            obj.lastLongitude = lla(2);
            obj.lastAltitude = lla(3);
        end

        function isContact = checkContact(obj)
            % In its main part, this function calculates whether there is
            % contact between the spacecraft and the point of interest,
            % i.e. the spacecraft is able to see the point of interest.
            % isContact is 0 when there is no contact.
            % isContact is 1 when there is contact.
            % Modifications have been made to that such that a rising edge
            % is delayed by one time step. This is necessary because always
            % the first of two points making one egde is detected as the
            % relevant state. This ensures that all points detected by the
            % event function represent a state where contact is
            % established. Otherwise the detected 'start of contact' point
            % would be the last point without contact before contact is
            % established.
            
            persistent lastContactState;        % 

            if isempty(lastContactState)
                lastContactState = 1;
            end

            % Main park: check if the given latitude and longitude are within the point of interest bounds
            latWithinBounds = (obj.lastLatitude >= obj.poi.latitude - obj.poi.height / 2) && (obj.lastLatitude <= obj.poi.latitude + obj.poi.height / 2);
            lonWithinBounds = (obj.lastLongitude >= obj.poi.longitude - obj.poi.width / 2) && (obj.lastLongitude <= obj.poi.longitude + obj.poi.width / 2);
            currentContactState = latWithinBounds && lonWithinBounds;
            
            isContact = lastContactState && currentContactState;
            lastContactState = currentContactState;
        end
    end
end
