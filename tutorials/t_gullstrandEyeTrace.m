%% t_gullstrandEyeTrace
%
%  Demonstrate tracing through the Gullstrand eye model.
%
% TL/BW Vistasoft Team

%%
ieInit;

%% Read the lens file and create a lens

lensFileName = fullfile(ilensRootPath,'data', 'lens', 'gullstrand.dat');

apertureMiddleD = 3;   % (mm) a relatively narrow pupil

nSamples = 1000; % Number of spatial samples in the aperture.

thisLens = lensC('aperture sample', [nSamples nSamples], ...
    'filename', lensFileName, ...
    'aperture Middle D', apertureMiddleD,...
    'name','Gullstrand',...
    'focalLength',16.5);    

% Draw the lens
thisLens.draw

%% Set index of refraction for the lens

% Set wavelength sampling for the lens
% 550 is a good choice to just see near the diffraction limit
% You can also choose polychromatic
% wave = 550;
wave = 550;
thisLens.set('wave', wave);

% Load index of refraction (n) of ocular mediums
% colums: [cornea aqueous pupile lens vitreous]
ior = ieReadSpectra('IORofEye.mat',wave);

% Insert column of zeros for the aperture
% colums: [cornea aqueous aperture lens vitreous]
ior = [ior(:,1:2) ior(:,2) ior(:,3:4)];
% ior(:,end) = 1.28*ones(length(ior),1);

% Set the index of refraction for each medium
nSurfaces = thisLens.get('n surfaces');
nWave = thisLens.get('nwave');
for ii=1:nSurfaces
    thisLens.surfaceArray(ii).n = ior(:,ii)';
end

%% Create a film (sensor), in this case this is the retina
% In the future we may want this to be curved.

% wavelength samples
wave = thisLens.get('wave');

% Let's only model the are around the fovea for now.
% I am not sure what these units are.  I think millimeters.
sensorSize = 0.026;    % mm?

% The retina is very close to 16.5 mm from the back of the lens
filmPosition = 16.7;

sensor = filmC('position', [0 0 filmPosition], ...
    'size', [sensorSize sensorSize], ...
    'resolution',[100 100],...
    'wave', wave);

%% Make points to view

pointsVerticalPosition = 0;
% pointDistance = -600; % 600 mm away from the eye (~2 ft)
pointDistance = -1e5; % Very far
point = psCreate(0,pointsVerticalPosition,pointDistance);

%% Ray trace the points to the film

%  We don't think the autofocus works properly with the Gullstrand
%  eye. We aren't sure why.  Figuring this out requires getting into
%  Michael Pieroni's black box model code.

% Create the camera using the sensor and lens we defined above.
camera = psfCameraC('lens',thisLens,'film',sensor,'point',point);

% Need to fix autofocus
iorObjSpace   = 1;
iorImageSpace = 1.336;
% iorImageSpace = 1;  % This makes the focal plane closer to right,
% but not quite right.
%  iorObjSpace = 1.105;
%  iorObjSpace = 1;
% camera.autofocus(550,'nm',iorObjSpace,iorImageSpace)

% Estimate the PSF and show the ray trace
nLines = 500;
jitter = true;
camera.estimatePSF(nLines,jitter);
set(gca,'xlim',[-5 20]); grid on

%% Show the point spread in the optical image window

oi = camera.oiCreate;
oi = oiAdjustIlluminance(oi,1e-3);
ieAddObject(oi); oiWindow;

% Plot the illuminance along a horizontal line through the middle
sz = oiGet(oi,'size');
oiPlot(oi,'illuminance hline',round([1,sz(1)/2]));
set(gca,'xlim',[-30 30],'xtick',-30:5:30)

%%  Show a mesh of the luminance of the point spread

illuminance = oiGet(oi,'illuminance');
s = oiGet(oi,'spatial support','um');

vcNewGraphWin;
mesh(s(:,:,1), s(:,:,2), illuminance);
xlabel('Position (um)'); ylabel('Position (um)');

%% psfTarget should be the normalized illuminance

%% This human eye model has a focal length of 16.5 mm

% We have some issue with it, though.  In CISET things seemed OK.  Now
% BW is confused
%{
lensFileName = fullfile(ilensRootPath,'data', 'lens', 'gullstrand.dat');
lens = lensC('fileName',lensFileName);
film = filmC;
camera = psfCameraC('lens',lens,'film',film,'pointsource',point);

%%
camera.film.position(3)
camera.autofocus(550,'nm',1,1.236);   % This gets us really close.
camera.film.position(3)

camera.estimatePSF(nLines,jitter);
oi = camera.oiCreate;
ieAddObject(oi); oiWindow;

%}