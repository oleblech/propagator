classdef CentralBody
    % Represents a central body a spacecraft is orbiting
    properties
        mass
        radius
        gravitationalParameter
        J2
        atmosphereModel
    end
    
    methods
        function obj = CentralBody(mass, radius, J2, atmosphereModel)
            obj.mass = mass;
            obj.radius = radius;
            obj.gravitationalParameter = 6.674e-11 * mass; % G * mass
            obj.J2 = J2;
            obj.atmosphereModel = atmosphereModel;
        end
        
        function gravityAcc = getGravityAccel(obj, position)
            % Compute gravitational field at a given position
            r = norm(position);
            
            % Standard gravitational acceleration
            gravityAcc = -obj.gravitationalParameter / r^2 * (position / r);
            
            if ~isempty(obj.J2) && obj.J2 ~= 0
                % Add J2 perturbation effects
                gravityAcc = gravityAcc + computeJ2Perturbation(position);
            end
            
            function J2Acc = computeJ2Perturbation(position)
                % Compute J2 perturbation at a given position
                mu = obj.gravitationalParameter;
                R = obj.radius;
                j2 = obj.J2;
                r = norm(position);
                z = position(3);
                x = position(1);
                y = position(2);
                
                % Common factor
                factor = (3/2) * j2 * (mu / r^2) * (R / r)^2;
                
                % Components of the perturbation acceleration
                ax = factor * ((5 * (z^2 / r^2)) - 1) * (x / r);
                ay = factor * ((5 * (z^2 / r^2)) - 1) * (y / r);
                az = factor * ((5 * (z^2 / r^2)) - 3) * (z / r);
                
                % J2 perturbation acceleration
                J2Acc = [ax; ay; az];
            end
        end

        function plotCentralBody(obj)
            % Plot the central body as a sphere with Earth surface texture
            r = obj.radius;
            [X, Y, Z] = sphere(50); % Create a sphere with 50-by-50 faces
            load('topo.mat', 'topo');
            props.FaceColor= 'texture';
            props.EdgeColor = 'none';
            props.FaceLighting = 'phong';
            props.CData = topo;
            X = X * r;
            Y = Y * r;
            Z = Z * r;
            surf(X, Y, Z, props);
            alpha(0.8); % Make the sphere semi-transparent
            
            % Plot the equatorial plane
            x = -r:r/4:r;
            y = -r:r/4:r;
            [X,Y] = meshgrid(x,y);
            Z = zeros(length(x),length(y));
            surf(X,Y,Z,'FaceColor','none');
        end
    end
end
