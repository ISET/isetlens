function dist0 = autofocus(obj, wave0, waveUnit,varargin)
% Set the camera film to the focus plane for the point and wavelength
%
%   psfCamera.autofocus(wave0, waveUnit, [n_ob], [n_im])
%
% The camera (obj) has a point source, lens, and film.
%
% INPUT
%   wave0
%   waveUnit = 'nm' or 'mm'or 'index'
%   n_ob  (default = 1)  Index of refraction of the object space
%   n_im  (default = 1)  Index of refraction of the image space
%
% The geometry is like this:
%
%    n_ob > BBM(lenses aperture lenses) -> n_im -> film
%
% The index of refraction (n) attached to the multiple surfaces that make
% up a lens. The index of refraction at each surface refers to the medium
% on the side closest to the film/sensor. You start with n_obj, and when
% you arrive at each surface you are informed by the index on the other
% side of the surface as the ray moves towards the film.
%
% OUTPUT
%   new film depth (distance from posterior exit plane).
%
%Examples
%   1:    psfCamera.autofocus(555, 'nm')
%   2:    psfCamera.autofocus(0.555, 'mm')
%   3:    psfCamera.autofocus(2, 'index') second value in the vector
%
% MP Vistasoft Team, Copyright 2014


%% Set up variables

if not(exist('wave0','var')) || not(exist('waveUnit','var'))
    error ('You must specify the wavelength and unit for the autofocus.')
end

wave = obj.get('wave');
switch waveUnit
    case {'nm'}
        % wave0=wave0;     %wave is in nm as well as wave0
    case {'um'}
        wave0=wave0*1e3; %wave is in nm, instead wave0 wan in um
    case {'mm'}
        wave0=wave0*1e6; %wave is in nm, instead wave0 wan in mm
    case {'m'}
        wave0=wave0*1e9; %wave is in nm, instead wave0 wan in m
    case {'index';'ind'}
        wave0=wave(wave0); % get the wave specified by the index
    otherwise
        error ('Specify a wavelength for the autofocus, example:  psfCamera.autofocus(555, "nm") ')
end

%index of the selected wavelength
ind0 = find(wave==wave0);

%check if the selceted wavelenght exist and is just one 
if (isempty(ind0)) || (length(ind0)>1)
    error (' Not found a "unique" wavelength matching to the selected ones!!!!')
end

% Set default or read the index of refraction in object and image space
% For the 
if nargin>3,  n_ob = varargin{1};    n_im = varargin{2};   
else          n_ob = 1;    n_im = 1;                    
end


%% SET the film position in focus 
% Get input
% lens=obj.lens;
lens = obj.get('lens');
% film=obj.film;
% film=obj.get('film');
% pSource=obj.pointSource;
pSource = obj.get('pointSource');


% Find Gaussian Image Point (wavelength dependence) Points are sometimes
% cells and sometimes vectors, sadly.  We handle it here but wew should
% make a uniform principle.
if iscell(pSource), pt = pSource{1};
else pt = pSource;
end
imagePoint = lens.findImagePoint(pt,n_ob,n_im);

%Right distance for the selected wavelength
dist0=imagePoint(ind0,3); % z position


%Get previous film position
oldPos=obj.get('film');

% Set new distance
newPos=oldPos;
newPos.position(3)=dist0;

% film=filmC('position', oldPos, 'size', filmSize, 'wave', wave, 'resolution', resolution);

%% SET THE NEW FILM
obj.set('film',newPos);

if nargout>0
    varargout{1}=dist0;
end
