%% Lens ray tracing of a single point using the endoscope lens file
%
%  Read in a lens file
%  Create a point source
%  Create a film
%  Visualize Ray trace the point through the lens to the film
%  Create an optical image of the ray trace
%
% AL/BW VISTASOFT 2014

% We could also do this for a couple of film distances and point distances
%
ieInit

%% Make a point far away.  A little off center and 100 mm from the back surface

pY = (0:10:30);
point = psCreate(0,pY,-1000);

%% Read a lens file and create a lens

lensFileName = fullfile(cisetRootPath,'data', 'lens', 'endoscope.dat');

nSamples = 251;
apertureMiddleD = 8;   % mm
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD);

lens.draw

%% Create a film (sensor)

% wavelength samples
wave = lens.get('wave');

% position - relative to center of final lens surface
%   Image is formed on the positive side
%   Objects are on the negative side
%   distances are 'mm' 

% In focus for dgauss.50mm is about 38.5 mm
sensor = filmC('position', [0 0 38.5], ...
    'size', [10 10], ...
    'wave', wave);

%% Ray trace the point to the film

camera = psfCameraC('lens',lens,'film',sensor,'point source',point);

% Estimate the PSF and show the ray trace
nLines = 0;
jitter = true;
camera.estimatePSF(nLines,jitter);

%% Show the point spread in the optical image window

oi = camera.oiCreate;
vcAddObject(oi); oiWindow;

%% Move the sensor to different distances from the lens

% Sensor distances from the lens
dist = (36:1:40);
for dd = dist
    % In focus for dgauss.50mm is about 38.5 mm
    sensor = filmC('position', [0 0 dd], ...
        'size', [10 10], ...
        'wave', wave);
    camera = psfCameraC('lens',lens,'film',sensor,'point source',point);
    
    % Sequence of events for estimating the PSF,
    nLines = 0;
    jitter = true;
    camera.estimatePSF(nLines,jitter);
    
    % Show the point spread in the optical image window
    oi = camera.oiCreate;
    oi = oiSet(oi,'name',sprintf('Sensor dist %.1f',dd));
    
    ieAddObject(oi); oiWindow;
end


%% Fix the sensor, but move the point position further and nearer

sensor = filmC('position', [0 0 38.5], ...
    'size', [10 10], ...
    'wave', wave);
    
% Point distances in mm from the lens
pDist = [-5000, -1000, -500, -300];
for dd = pDist
    point = psCreate(0,2,dd);
    
    % In focus for dgauss.50mm is about 38.5 mm
    camera = psfCameraC('lens',lens,'film',sensor,'point source',point);
    camera.estimatePSF;
    
    %% Show the point spread in the optical image window
    oi = camera.oiCreate;
    oi = oiSet(oi,'name',sprintf('Sensor dist %.1f',dd));
    ieAddObject(oi); oiWindow;
end


%% 
