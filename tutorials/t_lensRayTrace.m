%% Lens ray tracing illustrated
%
%  Create a point source
%  Read in a lens file
%  Create a film
%  Visualize Ray trace the point through the lens to the film
%  Create an optical image of the ray trace
%
% AL/BW VISTASOFT 2014  Edited by BW, AJ, 2017 June

%%
ieInit

%% Make a set  of points far away

% position - relative to center of final lens surface
%   Image is formed on the positive side
%   Objects are on the negative side
%   distances are 'mm' 

clear point

% A little bit off axis.  Pretty far away.
pZ_far = -1e4;
pX = 30;
pY = 30;
point{1} = [-pX -pY  pZ_far];   % Top right is -,-  
point{2} = [ pX,-pY, pZ_far]/2; % Top left is +, - 
point{3} = [ pX, pY, pZ_far]/4; % Bottom left is +,+ 
point{4} = [-pX  pY, pZ_far]/6; % Bottom right -,+

% point = psCreate(pX,pY,pZ);

%% Read a lens file and create a lens

%{
 lensFileName = fullfile(cisetRootPath,'data','lens','gullstrand.dat');
 lensFileName = fullfile(cisetRootPath,'data','lens','wide.22mm.dat');
 lensFileName = fullfile(cisetRootPath,'data','lens','2ElLens.dat');
 lensFileName = fullfile(cisetRootPath,'data','lens','2ElLens_16mm.dat');
 lensFileName = fullfile(cisetRootPath,'data','lens','2ElLens_35mm.dat');
 lensFileName = fullfile(cisetRootPath,'data','lens','fisheye.16mm.dat');
%}
lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.50.0mm.dat');
exist(lensFileName,'file');

% Small number of samples
nSamples = 501;   % Number of ray samples that we trace

% We select the size of the middle aperture radius. 
thisLens = lensC('fileName', lensFileName, 'aperture sample',[nSamples,nSamples]);

diameter = 8;   % mm
thisLens.set('Middle aperture diameter',diameter);

% This is the sketch of all the lens elements. Notice that the back of the
% lens is at 0 and the object space is negative and the sensor plane is
% positive.
thisLens.draw

%% Create a film (sensor)

% wavelength samples
wave = thisLens.get('wave');

% In focus for dgauss.50mm is about 38.5 mm
% A film size of 5 mm seems OK for this demo.
fSize = [1 1];
fRes =  [300 300];
film = filmC('position', [0 0 54], ...  
    'size', fSize, ...
    'resolution',fRes,...
    'wave', wave);

%% Ray trace the points to the film

% Create a point spread function camera
infinite_point{1} = [0 0 -1e5];
camera = psfCameraC('lens',thisLens,'film',film,'pointsource',infinite_point);

% Find the focus distance
fDistance = camera.autofocus(550,'nm');

% set the film at focus
camera.set('film position',[0 0 fDistance]);
camera.set('pointsource', point);

% Estimate the PSF and show the ray trace
nLines = 0;  % Do not draw the rays
jitter = true;
camera.estimatePSF(nLines,jitter);

% Show the point spread in the optical image window
oi = camera.oiCreate;
ieAddObject(oi); oiWindow;

%%