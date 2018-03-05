function res = get(obj,pName,varargin)
% Get various derived lens properties though this call
pName = ieParamFormat(pName);
switch pName
    case 'name'
        res = obj.name;
    case 'wave'
        res = obj.wave;
    case 'nwave'
        res = length(obj.wave);
    case 'type'
        res = obj.type;
    case {'nsurfaces','numels'}
        % Should be nsurfaces
        res = length(obj.surfaceArray);
    case {'lensthickness','totaloffset'}
        % This is the size (in mm) from the front surface to
        % the back surface.  The last surface is at 0, so the
        % position of the first surface is the total size.
        sArray = obj.surfaceArray;
        res    = -1*sArray(1).get('zpos');
        % We have a special case when rt is the ideal.
        % Not handled properly yet.  Need a validation for the
        % 'ideal' case.
        %
        %                     if strcmp(rtType,'ideal')
        %                         % The 'ideal'thin lens has a front surface at
        %                         res = 0;
        %                     end
        
        
    case 'offsets'
        % Offsets format (like PBRT files) from center/zPos
        % data
        res = obj.offsetCompute();
    case 'surfacearray'
        % lens.get('surface array',[which surface])
        if isempty(varargin), res = obj.surfaceArray;
        else                  res = obj.surfaceArray(varargin{1});
        end
        
    case {'indexofrefraction','narray'}
        nSurf = obj.get('nsurfaces');
        sWave  = obj.surfaceArray(1).wave;
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
        else this = varargin{1};
        end
        res = obj.surfaceArray(this).sRadius;
    case 'sdiameter'
        % lens.get('s diameter',nS);
        % Aperture diameter of this surface.
        % lens.get('sradius',whichSurface)
        if isempty(varargin), this = 1;
        else this = varargin{1};
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
        res =  obj.apertureSample ;
    case {'middleapertured','aperturemiddled'}
        % The middle aperture is the diameter of the diaphragm,
        % which is normally the middle aperture.  We should
        % change this somehow for clarity.  Or we should find
        % the diaphragm and return its diameter.
        %
        % The diameter of the middle aperture
        % units are mm
        res = obj.apertureMiddleD;
        
    case {'blackboxmodel';'blackbox';'bbm'} % equivalent BLACK BOX MODEL
        param=varargin{1};  %witch field of the black box to get
        res = obj.bbmGetValue(param);
        
    case {'lightfieldtransformation';'lightfieldtransf';'lightfield'} % equivalent BLACK BOX MODEL
        if nargin >2
            param = varargin{1};  %witch field of the black box to get
            param = ieParamFormat(param);
            switch param
                case {'2d'}
                    res = obj.bbmGetValue('abcd');
                case {'4d'}
                    abcd = obj.bbmGetValue('abcd');
                    nW=size(abcd,3);
                    dummy=eye(4);
                    abcd_out = zeros(2,2,nW);
                    for li=1:nW
                        abcd_out(:,:,li)=dummy;
                        abcd_out(1:2,1:2,li)=abcd(:,:,li);
                    end
                    res=abcd_out;
                otherwise
                    error(['Not valid :',param ,' as type for  Light Field tranformation']);
            end
        else
            res = obj.bbmGetValue('abcd');
        end
        
    case {'opticalsystem'; 'optsyst';'opticalsyst';'optical system structure'}
        % Get the equivalent optical system structure generated
        % by Michael's script
        % Can be specify refractive indices for object and
        % image space as varargin {1} and {2}
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