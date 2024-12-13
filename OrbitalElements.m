classdef OrbitalElements
    % A set of six classical orbital elements. Allows conversion to and from state vector.
    properties
        % Orbital elements
        semiMajorAxis
        eccentricity
        inclination
        raan % Right Ascension of Ascending Node
        argOfPeriapsis % Argument of Periapsis
        trueAnomaly
    end
    
    methods
        function obj = OrbitalElements(elements, elementType, mu)
            % Constructor that takes different sets of orbital elements
            % and converts them to the standard set (a, e, i, RAAN, w, TA)
            if nargin == 0
                return; % Allow creating an empty object
            end
            switch elementType
                case 'classical'
                    obj.semiMajorAxis = elements(1);
                    obj.eccentricity = elements(2);
                    obj.inclination = elements(3);
                    obj.raan = elements(4);
                    obj.argOfPeriapsis = elements(5);
                    obj.trueAnomaly = elements(6);
                case 'r_peri_r_apo'
                    r_peri = elements(1);
                    r_apo = elements(2);
                    obj.eccentricity = (r_apo - r_peri) / (r_apo + r_peri); % 
                    obj.semiMajorAxis = (r_peri + r_apo) / 2;
                    obj.inclination = elements(3);
                    obj.raan = elements(4);
                    obj.argOfPeriapsis = elements(5);
                    obj.trueAnomaly = elements(6);
                case 'h_e'
                    h = elements(1);
                    obj.eccentricity = elements(2);
                    obj.inclination = elements(3);
                    obj.raan = elements(4);
                    obj.argOfPeriapsis = elements(5);
                    obj.trueAnomaly = elements(6);
                    obj.semiMajorAxis = h^2 / (mu * (1 - obj.eccentricity^2));
                otherwise
                    error('Unknown element type');
            end
        end
        
        function state = toStateVector(obj, mu)
            % Convert orbital elements to state vector [r; v]
            % Conversion according to chapter 4.6 of book "Orbital
            % Mechanics for Engineering Students" by Howard D. Cutis

            % Get classical orbital elements
            a = obj.semiMajorAxis;
            e = obj.eccentricity;
            i = obj.inclination;
            RAAN = obj.raan;
            w = obj.argOfPeriapsis;
            TA = obj.trueAnomaly;
            
            % Compute the position and velocity in the perifocal coordinate system
            p = a * (1 - e^2);
            r_perifocal = (p / (1 + e * cos(TA))) * [cos(TA); sin(TA); 0];
            v_perifocal = sqrt(mu / p) * [-sin(TA); e + cos(TA); 0];

            % Rotation matrices
            R3_W = [cos(RAAN) sin(RAAN) 0; -sin(RAAN) cos(RAAN) 0; 0 0 1];
            R1_i = [1 0 0; 0 cos(i) sin(i); 0 -sin(i) cos(i)];
            R3_w = [cos(w) sin(w) 0; -sin(w) cos(w) 0; 0 0 1];

            % Combined rotation matrix
            Q = R3_w * R1_i * R3_W;

            % Convert to inertial frame
            r_inertial = Q' * r_perifocal;
            v_inertial = Q' * v_perifocal;

            state = [r_inertial; v_inertial];
        end
    end
    
    methods (Static)
        function elementsTrajectory = fromStateVector(stateTrajectory, mu)
            % Convert state vector trajectory [r; v] to orbital elements trajectory
            numPoints = size(stateTrajectory, 1);
            elementsTrajectory = zeros(numPoints, 6);
            for k = 1:numPoints
                state = stateTrajectory(k, :)';
                elementsTrajectory(k, :) = singleStateToElements(state, mu);
            end
            
            function elements = singleStateToElements(state, mu)
                % Convert single state vector [r; v] to classical orbital elements
                if isobject(state)
                    r = state.position;
                    v = state.velocity;
                else
                    r = state(1:3);
                    v = state(4:6);
                end
                h = cross(r, v);
                n = cross([0; 0; 1], h);
                
                % Eccentricity vector
                e_vec = (cross(v, h) / mu) - (r / norm(r));
                e = norm(e_vec);
                
                % Semi-major axis
                a = 1 / (2 / norm(r) - norm(v)^2 / mu);
                
                % Inclination
                i = acos(h(3) / norm(h));
                
                % Right ascension of ascending node
                RAAN = acos(n(1) / norm(n));
                if n(2) < 0
                    RAAN = 2 * pi - RAAN;
                end
                
                % Argument of periapsis
                w = acos(dot(n, e_vec) / (norm(n) * norm(e_vec)));
                if e_vec(3) < 0
                    w = 2 * pi - w;
                end
                
                % True anomaly
                TA = acos(dot(e_vec, r) / (norm(e_vec) * norm(r)));
                if dot(r, v) < 0
                    TA = 2 * pi - TA;
                end
                
                elements = [a, e, i, RAAN, w, TA];
            end
        end
        
        function orbitalElements = fromMixedSpherical(mixedSpherical, centralBody, utc_epoch)
            % Mixed spherical coordinates:
            % 1. Latitude lat - measured from -90° to +90°
            % 2. Longitude lon - measured from -180° to +180°
            % 3. Altitude h - The object's position above or below the reference
            % ellipsoid. Altitude is measured along a normal to the surface
            % of the reference ellipsoid in meters
            % 4. Horizontal Flight Path Angle gamma - The angle between the
            % inertial velocity vector and the local horizontal plane,
            % which is perpendicular to the radius vector
            % 5. Velocity Azimuth chi - The angle in the satellite local
            % horizontal plane between the projection of the inertial
            % velocity vector onto this plane and the local north direction
            % measured as positive in the clockwise direction
            % 6. Velocity Magnitude v_mag - The magnitude of the inertial
            % velocity vector in m/s

            % [lat lon h gamma chi v_mag]
            % Input dimensions:
            % [deg deg m deg deg m/s]

            % Rename variables
            lat = mixedSpherical(1);
            lon = mixedSpherical(2);
            h = mixedSpherical(3);
            gamma = deg2rad(mixedSpherical(4));
            chi = deg2rad(mixedSpherical(5));
            v_mag = mixedSpherical(6);
            
            % Velocity vector in north, east, down frame (NED)
            vx_north = cos(gamma) * cos(chi) * v_mag;
            vy_east = cos(gamma) * sin(chi) * v_mag;
            vz_down = -sin(gamma) * v_mag;

            % Converting velocity vector from NED frame to ECEF
            [vx_ecef,vy_ecef,vz_ecef] = ned2ecefv(vx_north,vy_east,vz_down,lat,lon);

            % Converting velocity vector from ECEF to ECI
            v_eci = ecef2eci(utc_epoch,[vx_ecef,vy_ecef,vz_ecef]);

            % Converting position vector from LLA to ECI
            r_eci = lla2eci([lat lon h],datevec(utc_epoch));

            % Converting ECI state vector to orbital elements
            orbitalElements = OrbitalElements.fromStateVector([r_eci v_eci'], centralBody.gravitationalParameter);
        end
    end
end
