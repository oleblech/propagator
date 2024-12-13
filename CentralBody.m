classdef CentralBody < handle
    % Represents a central body a spacecraft is orbiting
    properties
        radius
        gravitationalParameter
        J2
        atmosphereModel
        angularVelocity
    end
    
    methods
        function obj = CentralBody(radius, mu, J2, atmosphereModel,angularVelocity)
            obj.radius = radius;
            obj.gravitationalParameter = mu; % G * mass
            obj.J2 = J2;
            obj.atmosphereModel = atmosphereModel;
            obj.angularVelocity = angularVelocity;
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
                x = position(1);
                z = position(3);
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
            hold on
            % Plot the central body as a sphere with Earth surface texture
            r = obj.radius;
            [X, Y, Z] = sphere(50); % Create a sphere with 50-by-50 faces
            load('topo.mat', 'topo');

            % Rotate texture by 90 degrees eastward
            rotatedTopo = circshift(topo, [0, size(topo, 2)/4]);

            props.FaceColor= 'texture';
            props.EdgeColor = 'none';
            props.FaceLighting = 'phong';
            props.CData = rotatedTopo;
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

            xlabel('X (m)');
            ylabel('Y (m)');
            zlabel('Z (m)');
            title('Spacecraft Trajectory around Earth');
            grid on;
            axis equal;
            view(45, 30); % Set fixed 3D view angle

            hold off
        end
    end
end
