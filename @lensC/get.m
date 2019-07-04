function res = get(obj,pName,varargin)
% Get various derived lensC properties 
%
% Syntax:
%   lensC.get(parameter,varargin)
%
% Parameters:
%    'name'
%    'wave'
%      ...
%
% See also
%

pName = ieParamFormat(pName);
switch pName
    % Lens general parameters
    case 'name'
        res = obj.name;
    case 'wave'
        res = obj.wave;
    case 'nwave'
        res = length(obj.wave);
    case 'type'
        res = obj.type;
        
        % Surface parameters
    case {'nsurfaces','numels'}
        % Should be nsurfaces
        res = length(obj.surfaceArray);
    case {'lensheight'}
        % Total height (diameter) of the front surface element
        res = obj.surfaceArray(1).apertureD;
    case {'lensthickness','totaloffset'}
        % This is the size (in mm) from the front surface to
        % the back surface.  The last surface is at 0, so the
        % position of the first surface is the total size.
        sArray = obj.surfaceArray;
        res    = -1*sArray(1).get('zpos');
    case 'offsets'
        % Offsets format (like PBRT files) from center/zPos
        % data
        res = obj.offsetCompute();
    case 'surfacearray'
        % lens.get('surface array',[which surface])
        if isempty(varargin), res = obj.surfaceArray;
        else,                 res = obj.surfaceArray(varargin{1});
        end
    case {'indexofrefraction','narray'}
        nSurf = obj.get('nsurfaces');
        sWave = obj.surfaceArray(1).wave;
        res = zeros(length(sWave),nSurf);
        for ii=1:nSurf
            res(:,ii) = obj.surfaceArray(ii).n(:)';
        end
    case {'refractivesurfaces'}
        % logicalList = lens.get('refractive surfaces');
        % Returns
        %  1 at the positions of refractive surfaces, and
        %  0 at diaphgrams
        nSurf = obj.get('nsurfaces');
        res = ones(nSurf,1);
        for ii=1:nSurf
            if strcmp(obj.surfaceArray(ii).subtype,'diaphragm')
                res(ii) = 0;
            end
        end
        res = logical(res);
    case {'nrefractivesurfaces'}
        % nMatrix = lens.get('n refractive surfaces')
        %
        % The refractive indices for each wavelength of each
        % refractive surface.  The returned matrix has size
        % nWave x nSurface
        lst = find(obj.get('refractive surfaces'));
        nSurfaces = length(lst);
        nWave = obj.get('nwave');
        res = zeros(nWave,nSurfaces);
        for ii = 1:length(lst)
            res(:,ii) = obj.surfaceArray(lst(ii)).n(:);
        end
    case 'sradius'
        % spherical radius of curvature of this surface.
        % lens.get('sradius',whichSurface)
        if isempty(varargin), this = 1;
        else, this = varargin{1};
        end
        res = obj.surfaceArray(this).sRadius;
    case 'sdiameter'
        % lens.get('s diameter',nS);
        % Aperture diameter of this surface.
        % lens.get('sradius',whichSurface)
        if isempty(varargin), this = 1;
        else, this = varargin{1};
        end
        res = obj.surfaceArray(this).apertureD;
    case {'aperture','diaphragm'}
        % lens.get('aperture')
        % Returns the surface number of the aperture
        % (diaphragm)
        s = obj.surfaceArray;
        for ii=1:length(s)
            if strcmp(s(ii).subtype,'diaphragm')
                res = ii;
                return;
            end
        end
    case 'aperturesample'
        % Number of samples of the aperture?   Not sure.
        res =  obj.apertureSample ;
    case {'middleapertured','aperturemiddled','diaphragmdiameter'}
        % There is normally a middle aperture, called a diaphragm. This is
        % the diameter of that aperture (diaphragm). But this formulation
        % is not really consistent with the 'get' for the 'diaphragm' (see
        % above).  Here, we are assuming that the diagram is stored in this
        % slot.  Confusing to me.
        %
        % Possibly, we should find the diaphragm and return its diameter.
        %
        % units are mm
        res = obj.apertureMiddleD;
        
        % System properties
    case {'focallength'}
        % Film distance for a point at infinity.  
        % Units are millimeters.
        % lens.get('focal length')
        % lens.get('focal length',600)
        wave = 550;
        if ~isempty(varargin), wave = varargin{1}; end
        
        % A billion millimeters seems far enough for a focal length
        % We could run a billion and 10 billion and check for no
        % difference.
        res = lensFocus(obj,10^9,'wavelength',wave);
    case {'infocusdistance'}
        % Distances are in millimeters
        %
        % distance = 50; wave = 550;
        % lens.get('infocus distance',distance,wave)
        % 
        % Find the film distance to focus an object at a particular
        % distance and wavelength.  Defaults to returning focal length at
        % 550 nm if there are no varargin entries.
        %
        % The returned 
        objectDistance = 10^9; 
        wave = 550;
        if length(varargin) > 1
            wave = varargin{2}; objectDistance = varargin{1};
        elseif length(varargin) == 1
            objectDistance = varargin{1};
        end
        res = lensFocus(obj,objectDistance,'wavelength',wave);
        
    case {'blackboxmodel';'blackbox';'bbm'}
        % The BLACK BOX MODEL (bbm).
        % lens.get('bbm',param)
        param = varargin{1};  % Which field of the black box to get
        res = obj.bbmGetValue(param);
        
    case {'lightfieldtransformation';'lightfieldtransf';'lightfield'}
        % The light field parameters (ABCD) of the BLACK BOX MODEL
        % lens.get('light field transformation','2d');
        if nargin >2
            param = varargin{1};  %witch field of the black box to get
            param = ieParamFormat(param);
            switch param
                case {'2d'}
                    res = obj.bbmGetValue('abcd');
                case {'4d'}
                    abcd = obj.bbmGetValue('abcd');
                    nW = size(abcd,3);
                    dummy = eye(4);
                    abcd_out = zeros(2,2,nW);
                    for li=1:nW
                        abcd_out(:,:,li)=dummy;
                        abcd_out(1:2,1:2,li)=abcd(:,:,li);
                    end
                    res = abcd_out;
                otherwise
                    error('Unknown parameter: %s',param);
            end
        else
            res = obj.bbmGetValue('abcd');
        end
    case {'opticalsystem','optsyst','opticalsyst'}
        % The optical system structure generated by Michael Pieroni's
        % script.
        % lens.get('optical system',n_ob,n_im);
        % lens.get('optical system');   % In this case n_ob and n_im are 1
        if nargin >2
            n_ob=varargin{1};    n_im=varargin{2};
            OptSyst=obj.bbmComputeOptSyst(n_ob,n_im);
        else
            OptSyst=obj.bbmComputeOptSyst();
        end
        res = OptSyst;
        
    otherwise
        error('Unknown parameter %s\n',pName);
end

end