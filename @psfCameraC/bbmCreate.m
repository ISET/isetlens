function ImagSyst = bbmCreate(obj,varargin)
% Create the black box model and add it to the psfCamera structure 
%
% The BBM is a simplification of the lens is used to make various
% calculations about the paraxial approximation (first order optics)
%
%   ImagSyst = psfCamera.bbmCreate (varargin)
%
%INPUT
%   obj:          lens object 
%   varargin {1}: n_ob refractive index in object space
%   varargin {2}: n_im refractive index in image space
%
%OUTPUT (optional)
%   ImagSyst: Optical System structure.
%
% MP Vistasoft 2014

%% Get inputs
% lens=obj.lens; %NOT NEEDED in this function
% film=obj.film;  %NOT NEEDED in this function
pSource = obj.pointSource;

%%  CHECK number of INPUTs and set refractive indices of the medium
if nargin>1
    n_ob = varargin{1}; %refractive index in object space
    n_im = varargin{2}; %n_im refractive index in image space
else
    n_ob=1; n_im=1;
end

%% GET (by compute) the IMAGING SYSTEM
ImagSyst=obj.get('imaging system',n_ob,n_im);

%get image coordinate in polar coordinate
[ps_heigth,ps_angle,ps_zpos] = coordCart2Polar3D(pSource(1),pSource(2),pSource(3)); 

% The functional below was swapped in at some point, but I don't think it
% does the same calculation (BW). So I put back the previous one.
% Get image coordinate in polar coordinate
% [ps_heigth,ps_angle,ps_zpos] = cart2pol(pSource(1),pSource(2),pSource(3)); 

pSpolar(1) = ps_heigth;
pSpolar(2) = ps_angle;
pSpolar(3) = ps_zpos;

%  Equivalent Black Box Model of Imaging System
obj.set('black box model',ImagSyst,pSpolar);

%%    SET OUTPUT
if nargout > 0, ImagSyst=obj.get('black box model','all'); end

end

