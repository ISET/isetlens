%% t_opticsTransverseCA
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
% This script creates an array of points.  Each point is comprised of three
% different wavelengths. The array of points is imaged through a simple two
% element lens that has a wavelength-dependent index of refraction.
%
% This calculation of transverse chromatic aberration is based on notes
% from DHB.
%
% AL/BW Vistasoft Team, Copyright 2014

%%
ieInit

%% Use the simple default lens with an aperture in the middle.
thisLens = lens;

%% Set index of refraction for the lens

wave = [450 550 650];        % Few wavelength samples
apertureSample = [301 301];  % Number of samples
thisLens.set('wave', wave);
thisLens.set('apertureSample', apertureSample);
nSurfaces = thisLens.get('n surfaces');
nWave = thisLens.get('nwave');
for ii=1:(nSurfaces-1)
    if thisLens.surfaceArray(ii).sRadius ~= 0  % Not an aperture
        thisLens.surfaceArray(ii).n = linspace(1.65 + .1, 1.65 - .1, nWave);
    end
end

%% Make the sensor surface

position = [0 0 101];   % Sensor is 101 mm behind the lens
size = [15 15];         % Size of what?
film = filmC ('position', position, 'size', size, 'wave', wave);

%% Make an array of point sources

pX = -5:5:5;
pY = -5:5:5;
pZ = -100.5;
ps = psCreate(pX,pY,pZ);
fprintf('Calculating for %d points\n',length(ps));


%% Show the lens and point geometry

thisLens.draw;
pause(2);

hold on;
for ii=1:length(ps)
    plot3(ps{ii}(3),ps{ii}(2),ps{ii}(3),'ro')
end

%%
% ps = [0 -5 -101.5];
% ps = psCreate([],-5:0:5,
% ps = [0 -5 -101.5; 0 5 -100.5]; 

psfCamera = psfCameraC('lens',thisLens,'film',film,'pointsource',ps);

%% Compute the point spread

% The estimated PSF is added to the current camera film.
% N.B. We must clear the film before recomputing, which we do below.
nLines = 0; jitterFlag = true;
psfCamera.estimatePSF(nLines,jitterFlag);

oi = psfCamera.oiCreate;
ieAddObject(oi); oiWindow;
oi = oiSet(oi,'gamma',0.5);  % Makes the red/blue visible
vcReplaceAndSelectObject(oi);

%% Shift the aperture position to create transverse CA

% The second element of the surface array is the aperture (diaphragm)
aSurface = thisLens.get('aperture');  % The surface with the aperture
s        = thisLens.get('surface array',aSurface);
pOrig    = s.get('zpos');     % Original position of the aperture


%% Show the changing magnification with aperture z position
d =-10;

for ii=1:length(d)
    aSurface = thisLens.get('aperture');  % The surface with the aperture
    s        = thisLens.get('surface array',aSurface);
    psfCamera.film.clear();    % Clear the film
    
    s.set('zpos',pOrig + d(ii));  % Change the z position of the aperture
    thisLens.sortSurfaceOrder;        % Make sure the s array is updated with the new position
    thisLens.draw;
    pause(2);
    
    % Should we add to the psf or should we start fresh?  We need to be
    % clearer.
    nLines = 100;        % No debug lines
    jitterFlag = true;
    psfCamera.estimatePSF(nLines,jitterFlag);
    
    % Show the array of points in ISET
    oi = psfCamera.oiCreate;
    oi = oiSet(oi,'name',sprintf('Aperture pos = %.1f',s.get('z pos')));
    oi = oiSet(oi,'gamma',0.5);  % Makes the red/blue visible
    ieAddObject(oi); oiWindow;
    
end

%% Show the points and the lens

thisLens.draw
hold on;
for ii=1:length(ps)
    plot3(ps{ii}(3),ps{ii}(2),ps{ii}(3),'ro')
end

%%
