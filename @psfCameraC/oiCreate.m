function oi = oiCreate(camera,varargin)
% Create an ISET optical image from the psfCamera object
%
% Syntax:
%  oi = camera.oiCreate(varargin);
%
% Inputs:
%  camera - psfCameraC object
%
% Optional Key/value pairs
%   mean illuminance  - Returned oi is set to this mean illuminance
%
% Outputs
%   oi - ISET Optical image structure
%
% Description:
%   Used to render various simple images, say the estimated point
%   spread function of a lens.
%
% AL/BW Vistasoft Team, Copyright 2014
%
% See also:
%   s_isetauto.m

%% Parse inputs
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('camera',@(x)(isa(x,'psfCameraC')));
p.addParameter('meanilluminance',10,@isscalar);

p.parse(camera,varargin{:});

%% Create an optical image from the camera (film) image data.

oi = oiCreate;
oi = initDefaultSpectrum(oi);
oi = oiSet(oi,'wave', camera.film.wave);

% The shift-invariant model does not require a focal length or an
% f-number.
oi = oiSet(oi,'optics model','shift invariant');

%% Normalize the  scale here

oi = oiSet(oi,'photons',camera.film.image);

%% Estimate the horizontal field of view

% Use the distance to the film/sensor from the back of the lens to
% compute the size of the sensor and the geometry.  N.B. The film
% distance is not necessarily at the focal length.
filmDistance = camera.get('film distance'); 
hfov = rad2deg(2*atan2(camera.film.size(1)/2,filmDistance));
oi = oiSet(oi,'hfov', hfov);

% oi = oiSet(oi, 'optics focal length', camera.lens.get('focal length') * 10^-3);

% Set the name based on the distance of the film (sensor) from the
% final lens surface.  This may not be the focal length of the lens.
oi = oiSet(oi, 'name', ['filmDistance: ' num2str(filmDistance)]);

% Scale the photons in the film image so that the mean illuminance is
% reasonable.  As set by the user or a default of 10 lux.
oi = oiSet(oi,'mean illuminance',p.Results.meanilluminance);

end
