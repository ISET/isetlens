classdef surfaceC <  handle
    % Create a lens surface object
    %
    %   lens = surfaceC(parameter, value, ....);
    %
    % Presently we only represent spherical surfaces and apertures.  Multi
    % element lenses (lens) consist of a set of these surfaces and
    % apertures.
    %
    % This object is meant to be a class within the multi-element lens
    % objects, not a meant to be a stand-alone object.  This object
    % contains basic properties common to almost all lenses.
    %
    % Parameter/vals:
    %    apertured, sradius, scenter, wave, zpos, n, asphericity
    %
    % Examples:
    %    s = surfaceC;
    %    s = surfaceC('sRadius',2,'sCenter',[0 0 -2]);
    %
    % AL Vistasoft Copyright 2014
    
    % TODO
    % Use the get. syntax, replacing what we have.  See ISETBIO.
    
    properties
        
        % These are spherical surface properties
        name    = 'default';
        type    = 'surface';
        subtype = 'refractive';  % Apparently diaphragm is another type.  I think that means aperture. (BW).
        
        sRadius = 1;                % Sphere's radius
        sCenter = [0 0 0];          % Sphere's center position
        wave = 400:50:700;          % nm
        apertureD = 1;              % mm diameter
        n =  ones(7,1);             % index of refraction
        asphericity = 0;            % asphericity parameter ("Q")
        
    end
    
    methods (Access = public)
        
        % Surface object constructor
        function obj = surfaceC(varargin)
            %zpos must be assigned AFTER sCenter is assigned (after sCenter
            %in parameter declaration order).  Zpos assumes that lenses are
            %centered on z-axis.
            
            %if isempty(varargin), return; end
            
            for ii=1:2:length(varargin)
                p = ieParamFormat(varargin{ii});
                switch p
                    case {'apertured','aperturediameter'}
                        % Units are mm
                        obj.apertureD = varargin{ii+1};
                        
                    case 'sradius'
                        obj.sRadius = varargin{ii+1};
                        
                    case 'scenter'
                        obj.sCenter = varargin{ii+1};
                        
                    case 'wave'
                        obj.wave = varargin{ii+1};
                        %obj.n =  ones(length(obj.wave),1);  % index of refraction
                        % There should be one index of refraction for each
                        % wavelength
                        if length(obj.n) ~= length(obj.wave)
                            warning('Index of refraction vector length does not match wavelength vector length');
                        end
                        
                    case {'zpos','zposition'}
                        % Sets the center of the sphere position from the
                        % position (z) of the surface and the surface
                        % radius.
                        % This can only be calculated after setting sRadius
                        % assumes that lenses are centered on z axis
                        zPos = varargin{ii+1};
                        obj.sCenter = [ 0 0 obj.sphereCenter(zPos)];
                        
                    case 'n' % Index of refraction
                        % There should be one index of refraction for each
                        % wavelength
                        obj.n = varargin{ii+1};
                        if length(obj.n) ~= length(obj.wave)
                            error('Index of refraction vector length does not match wavelength vector length');
                        end
                    case 'asphericity' 
                        obj.asphericity = varargin{ii+1};
                        
                    otherwise
                        error('Unknown parameter %s\n',varargin{ii});
                end
            end
            
        end
        
        function res = get(obj,pName,varargin)
            % Get various derived lens properties though this call
            pName = ieParamFormat(pName);
            switch pName
                case 'name'
                    res = obj.name;
                case 'type'
                    res = obj.type;
                case 'wave'
                    res = obj.wave;
                case 'n'
                    res = obj.n;
                case 'sRadius'
                    res = obj.sRadius;
                case {'zpos','zintercept'}
                    % The z-position of the surface.
                    % The surface is a sphere.  We know the position of the
                    % sphere center. We subtract the sphere radius to find
                    % the position of the surface, centered on the y = 0
                    % axis.
                    res = obj.sCenter(3) - obj.sRadius;
                case 'asphericity'
                    res = obj.asphericity;
                otherwise
                    error('Unknown parameter %s\n',pName);
            end
        end
        
        function set(obj,pName,val,varargin)
            pName = ieParamFormat(pName);
            switch pName
                
                case {'apertured','aperturediameter'}
                    % Units are mm
                    obj.apertureD = val;
                    
                case 'sradius'
                    obj.sRadius = val;
                    
                case 'scenter'
                    obj.sCenter = val;
                case {'zpos','zposition'}
                    %**MUST be assigned after sCenter is assigned
                    %assumes that lenses are centered on z axis
                    zPos = val;
                    obj.sCenter = [ 0 0 obj.sphereCenter(zPos)];
                    
                case 'wave'
                    % The wavelength is annoying.
                    prevWave = obj.wave;
                    obj.wave = val;
                    obj.n = interp1(prevWave, obj.n, obj.wave, 'linear', 'extrap');
                    
                case 'n' % Index of refraction
                    % There should be one index of refraction for each
                    % wavelength
                    obj.n = val;
                    if length(obj.n) ~= length(obj.wave)
                        error('Index of refraction vector length does not match wavelength vector length');
                    end
                
                case 'asphericity' % Asphericity parameter (i.e. "Q")
                    obj.asphericity = val;
                    
                case {'subtype'}
                    % Type of surface
                    obj.subtype = val;
                    
                otherwise
                    error('Unknown parameter %s\n',pName);
            end
        end
        
        
        
    end
end
