%% t_opticsTransverseCADetail
%
% The main tutorial is t_opticsTransverseCA
%
% This tutorial expands on that one only by adding some graphs that show
% the ray trace.  This one is not complete in that I would like to make
% color the rays according to their wavelength.
%
% *** Notes from t_opticsTransverseCA
%
% Transverse chromatic aberration is the different image magnification as a
% function of wavelength.  The physical basis for transverse chromatic
% aberration is entirely different from longitudinal chromatic aberration.
%
% For transverse chromatic abberation, the magnification differences arise
% from the geometry of the aperture position with respect to the lens. When
% the aperture is centered in the middle of the lens or placed in front of
% the lense, the magnification differs with respect to wavelength. When the
% aperture is in the middle of the lens, there is no significant transverse
% scaling.  When the aperture is well in front of the lens, there is a
% substantial amount of transverse chromatic aberration (magnification).
%
% Longitudinal chromatic aberration arises from the wavelength dependent
% differences in the focal length of the lens.
%
% This script draws the rays that illustrate why the transverse aberration
% differs as the aperture changes position.
%
% This calculation of transverse chromatic aberration is based on notes
% from DHB.
%
% ***
%
% See also:  t_opticsTransverseCA.m
%
% AL/BW Vistasoft Team, Copyright 2014

%%
ieInit

%% Start with the simple default lens with an aperture in the middle.
lens = lensC;
lens.draw;

%% Set index of refraction for the lens

wave = [450 650];        % Few wavelength samples
apertureSample = [301 301];  % Number of samples
lens.set('wave', wave);
lens.set('apertureSample', apertureSample);
nSurfaces = lens.get('n surfaces');
nWave = lens.get('nwave');
for ii=1:(nSurfaces-1)
    if lens.surfaceArray(ii).sRadius ~= 0  % Not an aperture
        lens.surfaceArray(ii).n = linspace(1.65 + .1, 1.65 - .1, nWave);
    end
end

%% Make the sensor surface

position = [0 0 101];   % Sensor is 101 mm behind the lens
size = [15 15];         % Size of what?
film = filmC ('position', position, 'size', size, 'wave', wave);

%% Make an array of point sources

pX = 0;
pY = -5;
pZ = -100.5;
ps = psCreate(pX,pY,pZ);
% fprintf('Calculating for %d points\n',length(ps));

psfCamera = psfCameraC('lens',lens,'film',film,'pointsource',ps);

%% Compute the point spread and show the lens

% The estimated PSF is added to the current camera film.
% N.B. We must clear the film before recomputing, which we do below.
nLines = 100; jitterFlag = true;
psfCamera.estimatePSF(nLines,jitterFlag);

oi = psfCamera.oiCreate;
ieAddObject(oi); oiWindow;
oi = oiSet(oi,'gamma',0.5);  % Makes the red/blue visible
vcReplaceAndSelectObject(oi);

%% Shift the aperture position to create transverse CA

% The second element of the surface array is the aperture (diaphragm)
aSurface = lens.get('aperture');  % The surface with the aperture
s        = lens.get('surface array',aSurface);
pOrig    = s.get('zpos');     % Original position of the aperture
s.set('zpos',pOrig - 20); lens.sortSurfaceOrder; 
lens.draw;

%% Show the changing magnification with aperture z position
psfCamera.film.clear();    % Clear the film

nLines = 100;        % No debug lines
jitterFlag = true;
psfCamera.estimatePSF(nLines,jitterFlag);

% Show the array of points in ISET
oi = psfCamera.oiCreate;
oi = oiSet(oi,'name',sprintf('Aperture pos = %.1f',s.get('z pos')));
oi = oiSet(oi,'gamma',0.5);  % Makes the red/blue visible
ieAddObject(oi); oiWindow;
    

%%