classdef lensC <  handle
    % Create a multiple element lens object
    %
    %   lens = lensC(varargin);
    %
    % Inputs:
    %   N/A
    % Outputs:
    %   lens object
    % Optional key/value pairs
    %   'filename',...,
    %   'name', string
    %   'type', string
    %   'units', {'um','mm','m'}
    %   'wave', vector
    %   'surface array'
    %   'aperture sample'
    %   'aperture middle d'   - Maximum aperture size
    %   'diffraction enabled' - 
    %   'figure handle'
    %   'blackbox model'
    %
    % Distance units are millimeters, unless otherwise specified.
    %
    % We represent multi-element lenses as a sequence of spherical surfaces
    % and circular apertures. Each surface has a curvature, position, and
    % index of refraction (as a function of wavelength).
    %
    % The surface position of each surface is specified with respect to the
    % final component of the lens. Rays travel from left (the scene) to
    % right (the image). The zero position is the right-most spherical
    % surface. The film (sensor) is at a positive position.
    %
    %     Scene ->  | Lens Surfaces ->|   Film
    %                    -            0     +
    %
    % Apertures are circular and their center is in the (0,0) position.
    % Hence, apertures are specified by a single parameter (diameter in
    % mm).
    %
    % The index of refraction (n) attached to a surface defines the
    % material to the left of the surface.
    %
    % Lens files and surface arrays are specified from the left most
    % element (closest to the scene), to the right-most element (closest to
    % the sensor). Hence, surface arrays are listed from negative positions
    % to positive positions.
    %
    % The lens object works with the 'realistic' camera class. The
    % 'pinhole' cameras has simpler properties.
    %
    % We aim to be consistent with the PBRT lens files, and the Zemax as
    % far possible.
    %
    % AL/BW Vistasoft Copyright 2014
    %
    % See also:
    %    lens.draw, lens.plot, lens.set, lens.get

    % Examples:
    %{
      % Create a lens object
      thislens = lensC('filename','dgauss.22deg.3.0mm.dat');
      thislens.draw;
      thislens.plot('focal distance');
    %}
    %{
      % Read in under the assumption that the file contains meters 
      thislens = lens('filename','dgauss.22deg.3.0mm.dat','units','m');
      thislens.draw;
    %}
    %{
      % Read in explicitly stating that the file contains 'mm'
      thislens = lens('filename','2ElLens.dat','units','mm');
      thislens.draw;
    %}
    %{
      % To convert a file in millimeters to meters
       thislens = lensC('filename','2ElLens.dat','units','mm');
       thislens.fileWrite('2ElLensMeters.dat','units','m')
       type '2ElLens.dat'
       type '2ElLensMeters.dat'
       delete('2ElLensMeters.dat');
    %}
    %{
        lens = lensC('filename','dgauss.22deg.100.0mm.json')
    %}
    
    properties
        name = 'default';
        type = 'multi element lens';
        description = 'description';   % Patents or related
        fullFileName = '';             % If read from a file
        surfaceArray = surfaceC();     % Set of spherical surfaces and apertures
        % diffractionEnabled = false;    % Not implemented yet
        wave = 400:50:700;             % nm
        focalLength = 50;              % mm, focal length of multi-element lens
        apertureMiddleD = 8;           % mm, diameter of the middle aperture
        apertureSample = [151 151];    % Number of spatial samples in the aperture.  Use odd number
        centerZ = 0;                   % Theoretical center of lens (length-wise) in the z coordinate
        
        % When we read a lens from a JSON file, we store the struct
        % here
        lensData = [];
        
        % When we draw the lens we store the figure handle here
        fHdl = [];
        
        % Spatial units defined in the input file
        units = 'mm';

        % Black Box Model - Used for certain efficient analyses and
        % computations, largely in Matlab
        BBoxModel=[]; % Empty
        
        % Microlens Model - Will be used extensively for camera development
        % and testing, largely in PBRT
        MLensModel = []; % Empty
        
    end
    
    properties (SetAccess = private)
        centerRay = [];                 % for use for ideal Lens
        inFocusPosition = [0 0 0];
    end
    
    methods (Access = public)
        
        %Multiple element lens constructor
        function obj = lensC(varargin)
            % thisLens = lens(varargin)
            %   
            % Optional key/value pairs
            %   'filename',...,
            %   'name', string
            %   'type', string
            %   'units', {'um','mm','m'}
            %   'wave', vector
            %   'surface array'
            %   'aperture sample'
            %   'figure handle'
            %   'blackbox model'
            %
            
            %{
            
            %}
            p = inputParser;
            varargin = ieParamFormat(varargin);
            
            % Set defaults to empty.  Only fill in if not empty.
            p.addParameter('name','',@ischar);
            p.addParameter('type','',@ischar);
            p.addParameter('units','mm',@(x)(ismember(x,{'um','mm','m'})));
            p.addParameter('aperturesample',[],@isvector);
            p.addParameter('aperturemiddled',[],@isscalar);
            p.addParameter('focallength',[],@isnumeric);
            % p.addParameter('diffractionenabled',[],@islogical);
            p.addParameter('wave',[],@isvector)
            p.addParameter('figurehandle',[],@isgraphics);
            p.addParameter('blackboxmodel',[])
            
            fullFileName = which('2ElLens.dat');
            p.addParameter('filename',fullFileName,@(x)(exist(x,'file')));
            
            p.parse(varargin{:});
            
            % Initialize with the lens file and default name
            obj.fileRead(p.Results.filename,'units',p.Results.units);
            [~,obj.name,~] = fileparts(p.Results.filename);
            obj.fullFileName = which(p.Results.filename);
            
            % Basics
            if ~isempty(p.Results.name), obj.name = p.Results.name; end
            if ~isempty(p.Results.type), obj.name = p.Results.type; end
            if ~isempty(p.Results.units),obj.units = p.Results.units; end

            % Parameters
            if ~isempty(p.Results.aperturesample)
                obj.apertureSample = p.Results.aperturesample;
            end
            if ~isempty(p.Results.aperturemiddled)
                obj.apertureMiddleD = p.Results.aperturemiddled;
            end
            if ~isempty(p.Results.focallength)
                obj.focalLength = p.Results.focallength;
            end
            if ~isempty(p.Results.wave), obj.set('wave',wave);  end
            % if ~isempty(p.Results.diffractionenabled)
            %     obj.diffractionEnabled = p.Results.diffractionenabled;
            % end
            
            % Window
            if ~isempty(p.Results.figurehandle)
                obj.fHdl = p.Results.figurehandle;
            end
            
            % Advanced
            if ~isempty(p.Results.blackboxmodel)
                obj.BBoxModel = p.Results.blackboxmodel;
            end
            
        end
    end
    
    %% Not sure why these are private. (BW).
    methods (Access = private)
        
        % These values should be obtained using the 'get' function, which
        % is public.  So, obj.get('aperture mask') would be the way to call
        % this function.  Similarly for the others.
        
        function apertureMask = apertureMask(obj)
            % Identify the grid points on the circular aperture.
            %
            
            % Here is the full sampling grid for the resolution and
            % aperture radius
            aGrid = obj.fullGrid;
            
            % We assume a circular aperture. This mask is 1 for the sample
            % points within a circle of the aperture radius
            firstApertureRadius = obj.surfaceArray(1).apertureD/2;
            apertureMask = (aGrid.X.^2 + aGrid.Y.^2) <= firstApertureRadius^2;
            % vcNewGraphWin;  mesh(double(apertureMask))
            
        end        
    end
end


