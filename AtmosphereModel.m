classdef AtmosphereModel
    % Class to represent the atmosphere of a central body. Mainly calculates the density based on current location and time.
    properties
        modelType
    end
    
    methods
        function obj = AtmosphereModel(modelType)
            obj.modelType = modelType;
        end
        
        function rho = density(obj, latitude, longitude, altitude, utcDateTime)
            % Return the atmospheric density at a given altitude
            switch obj.modelType
                case 'nrlmsise00'
                    % Convert UTC datetime to components required by atmosnrlmsise00
                    year = utcDateTime.Year;
                    dayOfYear = floor(days(utcDateTime - datetime(year, 1, 1) + 1)); % Day of year
                    secondOfDay = utcDateTime.Hour * 3600 + utcDateTime.Minute * 60 + utcDateTime.Second; % Second of day
                    
                    % Call atmosnrlmsise00 to get densities
                    [~, allDensities] = atmosnrlmsise00(altitude, latitude, longitude, year, dayOfYear, secondOfDay,'none');
                    
                    % Choose total mass density
                    rho = allDensities(6);

                case 'USSA76' % US Standard Atmosphere 1976
                    rho = densityUSSA76(altitude);

                case 'exponential'
                    rho0 = 1.225; % kg/m^3 at sea level
                    H = 8500; % Scale height in meters
                    rho = rho0 * exp(-altitude / H);

                case 'none'
                    % No atmosphere
                    rho = 0;

                otherwise
                    error('Unknown atmospheric model type');
            end

        function rho = densityUSSA76(altitude)
            % Geometric altitudes (m)
            h = ...
            [  0  25  30  40  50  60   70 ...
              80  90 100 110 120 130  140 ...
             150 180 200 250 300 350  400 ...
             450 500 600 700 800 900 1000]*1e3;
             
            % Corresponding densities (kg/m^3) from USSA76 
            r = ...
            [1.225     4.008e-2  1.841e-2  3.996e-3  1.027e-3  3.097e-4  8.283e-5 ...
             1.846e-5  3.416e-6  5.606e-7  9.708e-8  2.222e-8  8.152e-9  3.831e-9 ...
             2.076e-9  5.194e-10 2.541e-10 6.073e-11 1.916e-11 7.014e-12 2.803e-12 ...
             1.184e-12 5.215e-13 1.137e-13 3.070e-14 1.136e-14 5.759e-15 3.561e-15];     
              
            % Scale heights (m)
            H = ...
            [ 7.310  6.427  6.546   7.360   8.342   7.583   6.661 ...
              5.927  5.533  5.703   6.782   9.973  13.243  16.322 ...
             21.652 27.974 34.934  43.342  49.755  54.513  58.019 ...
             60.980 65.654 76.377 100.587 147.203 208.020]*1e3; 
             
            % Handle altitudes outside of the range
            if altitude > 1e6
                altitude = 1e6;
            elseif altitude < 0
                altitude = 0;
            end
             
            % Determine the interpolation interval
            for j = 1:27
                if altitude >= h(j) && altitude < h(j+1)
                    i = j;
                end
            end
            if altitude == 1e6
                i = 27;
            end
             
            % Exponential interpolation:
            rho = r(i) * exp(-(altitude - h(i))/H(i));
        end
        
        end
    end
end
