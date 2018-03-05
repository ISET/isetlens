classdef rayC < matlab.mixin.Copyable
    % Create a ray object
    %
    % ray = rayC('origin', origin,'direction', direction, 'waveIndex', waveIndex, 'wave', wavelength)
    %
    % Example:
    %   r = rayC
    %
    % Programming:
    %   A lot of these seem to overlap with other routines.  Delete one of
    %   them, either here or the lens version or ... (BW)
    %
    % AL Vistasoft Copyright 2014
    
    properties
        
        name = 'rays';

        % At each point in the ray tracing, the camera follows the rays
        % from some location to the next.  At first, it may be the point to
        % the frnot aperture.  Then the front aperture to the middle
        % limiting aperture, and finally the exit.
        % 
        % Through the process of calculating, we store the rays here.  The
        % meaning of what is stored here depends on where we are in the
        % computation.  After we are done with the computation, the
        % origin/direction fields contain the final set of rays from the
        % exit aperture to the sensor.
        
        origin;      % Starting point of ray
        direction;   % Direction of ray
        distance;    % Distance from origin to surface
        
        %wavelength; %no longer used.  use obj.get('wavelength')
        waveIndex;   
        wave;         %this is the same wave in the film, which gives a range of wavelengths used
        drawSamples;   
        plotHandle = [];
                 
        % For the plenoptic PSF models, we store intermediate results.  The
        % lens model we use in that case is
        %
        %   Front Lens group | Limiting Aperture | Exit lens group
        %
        % There will be simple (linear) relationships between these light
        % fields.  See VoLT.
        
        %location of the originating point source scene is -Z direction
        %apertureSamples - where rays intersect the front most aperture
        aEntranceInt;        % = struct('XY', [0 0], 'Z', 0);
        aEntranceDir;        % = struct('XY', [0 0], 'Z', 0);
        
        %apertureLocation - where rays intersect the limiting aperture
        %direction of rays at the middle aperture.  This is useful for
        %lightfield analysis later.
        aMiddleInt = struct('XY', [0 0], 'Z', 0);
        aMiddleDir;   %  = [0 0 1];
        
        % Exit positions and direction
        aExitInt;    % = struct('XY', [0 0], 'Z', 0);
        aExitDir;    % = 0;
        
        
    end
    
    methods (Access = private)
        function angles = toSphericalAngles(obj)
            %angles = toSphericalAngles(obj)
            %
            %Conversion of cartesian to spherical coordinates for
            %direction.
            %We will use official spherical coordinates as defined here: 
            %http://en.wikipedia.org/wiki/Spherical_coordinate_system
            %The first column will be the azimuth angle, and the second
            %column will be the polar angle.  All angles are in degrees.
            
            angles = zeros(size(obj.direction,1), 2);
            y = obj.direction(:, 2);
            x = obj.direction(:, 1);
            z = obj.direction(:, 3);
            azimuth = atan(y./x) * 180/pi;
            polar = acos(z./sqrt(x.^2 + y.^2 + z.^2));
            
            angles(:,1) = azimuth;
            angles(:,2) = polar;
        end
        
        function angles = toProjectedAngles(obj)
            %angles = toProjectedAngles(obj)
            
            %Conversion of cartesian to projected angles
            %
            %Let theta_x denote the angle cast by the vector, when
            %projected onto the z-x plane.
            %Similar, let theta_y denote the angle cast by the vector, when
            %projected onto the z-y plane
            %
            %The first column will be the theta_x angle, and the second
            %column will be the theta_y angle.  Angles are in degrees.
            
            angles = zeros(size(obj.direction,1), 2);
            y = obj.direction(:, 2);
            x = obj.direction(:, 1);
            z = obj.direction(:, 3);
            theta_x = atan(x./z) * 180/pi;
            theta_y = atan(y./z) * 180/pi;
            
            angles(:,1) = theta_x;
            angles(:,2) = theta_y;
        end       
        
    end
        
    methods (Access = public)
          
        function obj = rayC(varargin)
            % Constructor

           for ii=1:2:length(varargin)
                p = ieParamFormat(varargin{ii});
                switch p
                    case 'origin'
                        % Define, please
                        obj.origin = varargin{ii+1};
                    case 'direction'
                        % Must be a 2 element vector that represents ???
                        obj.direction = varargin{ii+1};  
                    case 'waveindex'
                        % The indexing that specifies the wavelength.  use
                        % obj.get('wavelength') to get a vector of
                        % wavelengths
                        obj.waveIndex = varargin{ii+1};
                    case 'wave'
                        % The wavelengths used for this ray object.
                        obj.wave = varargin{ii+1};
                    otherwise
                        error('Unknown parameter %s\n',varargin{ii});
                end
           end
        end
        
        function val = get(obj,param,varargin)
            % Get parameters about the rays
            % Available parameters:
            %   nRays, sphericalAngles, projectedAngles, wave, waveIndex,
            %   wavelength, liveindices
            
            p = ieParamFormat(param);
            switch p
                case 'nrays'
                    val = size(obj.origin,1);
                case 'sphericalangles'
                    val = obj.toSphericalAngles();
                case 'projectedangles'
                    val = obj.toProjectedAngles();
                case 'wave'
                    val = obj.wave;
                case 'waveindex'
                    
                    val = obj.waveIndex;
                    if (mod(length(varargin), 2) ~= 0)
                        error('Incorrect parameter request. \n');
                    end
                    if (~isempty(varargin))
                        % this part deals with customized gets for specific
                        % wave indices and survived rays
                        val = obj.waveIndex;
                        for ii=1:2:length(varargin)
                            p = ieParamFormat(varargin{ii});
                            switch p
                                case 'survivedraysonly'
                                    survivedFlag = varargin{ii+1};
                                    if(survivedFlag)
                                       survivedRays = ~isnan(val); 
                                       val =  val(survivedRays);
                                    end
                                otherwise
                                    error('Unknown parameter %s\n',varargin{ii});
                            end
                        end
                    end
                    
                case 'wavelength'
                    val = zeros(size(obj.waveIndex));
                    val(isnan(obj.waveIndex)) = NaN;
                    liveInd = obj.get('liveIndices');
                    val(~isnan(obj.waveIndex)) = obj.wave(obj.waveIndex(liveInd));
                    val = val';
                case 'liveindices'  
                    % Rays with a waveIndex made it through the tracing
                    % path. We return the indices of rays that are still
                    % alive. We aren't sure why waveIndex is the right slot
                    % to check ... but it appears to be (BW).
                    val = ~isnan(obj.waveIndex);
                case 'liverays'
                    % Set the rays without a wavelength to empty  These
                    % remaining rays are the live rays.
                    %                     val = rayC();
                    %                     val.copy(obj);
                    val = obj.copy;
                    liveIndices = val.get('live indices');
                    val.origin(~liveIndices, : ) = [];
                    val.direction(~liveIndices, : ) = [];
                    val.waveIndex(~liveIndices) = [];
                    
                case 'origin'

                    %if no additional parameters are given, return raw
                    %origin matrix
                    val = obj.origin;
                    if (mod(length(varargin), 2) ~= 0)
                        error('Incorrect parameter request. \n');
                    end
                    if (~isempty(varargin) )
                        % this part deals with customized gets for specific
                        % wave indices and survived rays
                        
                        for ii=1:2:length(varargin)
                            p = ieParamFormat(varargin{ii});
                            switch p
                                case 'waveindex'
                                    wantedWaveIndex = varargin{ii+1};
                                    wantedWave = obj.get('waveIndex');
                                    if(~notDefined('survivedFlag') && survivedFlag) %handles case if survivedrays called first
                                        wantedWave = wantedWave(survivedRays);
                                    end
                                    wantedWave = (wantedWave == wantedWaveIndex);
                                    val = val(:, wantedWave);
                                case 'survivedraysonly'
                                    survivedFlag = varargin{ii+1};
                                    if(survivedFlag)
                                       survivedRays = ~isnan(val(1,:)); %removes nans based off first coordinate
                                       val =  val(:, survivedRays);
                                    end
                                otherwise
                                    error('Unknown parameter %s\n',varargin{ii});
                            end
                        end
                    end
                    
                case 'direction'
                    
                    %if no additional parameters are given, return raw
                    %direction matrix
                    %consider putting this in a function so we don't need
                    %to define twice
                    val = obj.direction;
                    if (mod(length(varargin), 2) ~= 0)
                        error('Incorrect parameter request. \n');
                    end
                    if (~isempty(varargin))
                        % this part deals with customized gets for specific
                        % wave indices and survived rays
                        
                        for ii=1:2:length(varargin)
                            p = ieParamFormat(varargin{ii});

                            switch p
                                case 'waveindex'
                                    wantedWaveIndex = varargin{ii+1};
                                    wantedWave = obj.get('waveIndex');
                                    if(~notDefined('survivedFlag') && survivedFlag) %handles case if survivedrays called first
                                        wantedWave = wantedWave(survivedRays);
                                    end
                                    wantedWave = (wantedWave == wantedWaveIndex);
                                    val = val(:, wantedWave);
                                case 'survivedraysonly'
                                    survivedFlag = varargin{ii+1};
                                    if(survivedFlag)
                                       survivedRays = ~isnan(val(1,:)); %removes nans based off first coordinate
                                       val =  val(:, survivedRays);
                                    end
                                otherwise
                                    error('Unknown parameter %s\n',varargin{ii});
                            end
                        end
                    end
                otherwise
                    error('Unknown parameter %s\n',p);
            end
        end
        
        function set(obj,param,val)
            % set(param,val)
            %
            % sets various data members for the ray class
            %
            p = ieParamFormat(param);
            switch p
                case 'wave'
                    obj.wave = val;
                otherwise
                    error('Unknown parameter %s\n',p);
            end
        end
    end
end