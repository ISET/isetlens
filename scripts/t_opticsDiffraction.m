%% 2014 OSA Conference
%
% This script uses the point test file, blur it in 3 different ways.  
%
% The first way is to use the new ray tracing method which uses Heisenburg
% Uncertainty Ray Bending (HURB).  
% The second way is Huygens method.
% The third way is the classical way using theoretical PSF's and formulae
% from ISE
%
%  NEEDS TO BE FIXED FOR FINDING THE DATA
%
% AL, Vistasoft Team, Copyright 2014

%
ieInit;

%% Specify HURB ray tracing location and specification
% chdir(fullfile(s3dRootPath, 'papers', '2014-OSA'));
% sampleArray = cell(1, 1);
% 
% sampleArray{1}.rayTraceFile = 'PSFCenter_50mm_2m_f22_n401.mat'%'25mm_1m_65res.pbrt.mat' %'rayTrace25mm32res.mat' 
% sampleArray{1}.focalLength = 50
% sampleArray{1}.apertureDiameter = 2.2727
% sampleArray{1}.filmDistance = 51.2821	
% sampleArray{1}.targetDistance = 2
% 

%% Produce HURB results
% Make a point source (approximately infinity)
point = psCreate(0,0,-1e+15);

% Read a lens file and create a lens
%lensFileName = fullfile(cisetRootPath,'data', 'lens', 'dgauss.50mm.dat');
lensFileName = fullfile(cisetRootPath,'data', 'lens', '2ElLens.dat');

nSamples = 2001; 

% apertureMiddleD = .11;  %.5;   % mm    %WORKS BRILLIANTLY.  For what (BW)?  For scene?
apertureMiddleD = 2;  %.5;   % mm    %WORKS BRILLIANTLY.  For what (BW)?  For scene?

lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD, ...
    'diffractionEnabled', true);

% Create a film (sensor) 
% position - relative to center of final lens surface
% size - 'mm'
% wavelength samples
lens.set('wave', (400:10:700));

wave = lens.get('wave');

lens.draw;

%% Create the film

% Put it 50 mm away for the 2E lens and, I guess, for the dgauss 50mm.
% We need an autofocus here.  I think MP wrote one.
% film = filmC('position', [0 0 50], ...
%     'resolution', [300 300 1], ...
%     'size', [2/sqrt(2) 2/sqrt(2)], ...
%     'wave', wave);
film = filmC('position', [0 0 50], ...
    'resolution', [300 300 1], ...
    'size', [0.5/sqrt(2) 0.5/sqrt(2)], ...
    'wave', wave);

%% Create a camera out of lens, film ,and point source

camera = psfCameraC('lens',lens,'film',film,'point source',point);

% Estimate the PSF
nLines = 100;    % Show 100 lines
jitter = false;  % Randomizing position of lines?

% Limits the entrance aperture so this can run faster
% But this is not reasonable for the diffraction calculation
subsection = [];

% Choose among the diffraction producing methods
method = 'HURB';      % Randomized the direction of rays near the edges
%method = 'huygens';  % This method ...

% Ray trace type ... not sure about this ...
rtType = 'ideal';
% rtType = 'realistic';

% Produced the data for the PSF.  Needs more comments
camera.estimatePSF(nLines,jitter,subsection, method, rtType);

oiHURB = camera.oiCreate(); 
ieAddObject(oiHURB); oiWindow;
    

%% Produce Huygens-Fresnel results 

% This section takes a long time to run - and you should only do it on
% after parallelization!

% Make a point source (approximately infinity mm)
point = psCreate(0,0,-1e+15);

% Read a lens file and create a lens
%lensFileName = fullfile(cisetRootPath,'data', 'lens', 'dgauss.50mm.dat');
lensFileName = fullfile(cisetRootPath,'data', 'lens', '2ElLens.dat');

nSamples = 401; %501; %151;
apertureMiddleD = .11;  %.5;   % mm    %WORKS BRILLIANTLY

lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD, ...
    'diffractionEnabled', true);

% Create a film (sensor) 
% position - relative to center of final lens surface
% size - 'mm'
% wavelength samples
lens.set('wave', (400:10:700));

wave = lens.get('wave');

%put it 16 mm away
film = filmC('position', [0 0 50], ...
    'resolution', [300 300 1], ...
    'size', [.5/sqrt(2) 0.5/sqrt(2)], ...
    'wave', wave);

% Create a camera out of lens, film ,and point source
camera = psfCameraC('lens',lens,'film',film,'point source',point{1});

% Sequence of events for estimating the PSF, 
nLines = 100;
jitter = false;
%camera.estimatePSF(nLines,jitter);

%limits the entrance aperture so this can run faster
subsection = [];

%method = 'HURB';
method = 'huygens';
rtType = 'ideal';
camera.estimatePSF(nLines,jitter,subsection, method, rtType);

oiHuygens = camera.oiCreate(); 
oiHuygens = oiSet(oiHuygens,'name','Huygens');
ieAddObject(oiHuygens); oiWindow;
    

%% Theoretical results based on ISET formulae

%assign parameters from above
sensorWidth = film.size(1);
focalLength = film.position(3)*1e-3;
apertureDiameter = 2e-3;     % 2 mm

%load scene file
d = displayCreate('equal energy');

% This is an annoying way to make a single point scene.
% I should add a single point sceneCreate.  There is a 'point array', and
% we should just make a 'single point' version.  The point could always
% have a single point in the middle, and then just set the spacing very
% large so there is only one point.  Right now, the point array doesn't put
% a point in the middle!
pFile = fullfile(cisetRootPath,'data','pointTest.png');
scene = sceneFromFile(pFile, 'rgb', [], d);
wave = sceneGet(scene, 'wave');
onesPhotons = ones(size(wave)) * 1e+15;
equalPhotonsEnergy = Quanta2Energy(wave, onesPhotons);
scene = sceneAdjustIlluminant(scene, equalPhotonsEnergy);

horFieldofView = 2 * atan(sensorWidth/(2 * filmDistance)) * 180/pi * .8;
scene = sceneSet(scene,'fov',horFieldofView);
scene = sceneSet(scene, 'distance', 100000001);   %scene = sceneSet(scene, 'distance', 2001);
ieAddObject(scene); sceneWindow;

%create optical image
oiT = oiCreate;
optics = oiGet(oiT,'optics'); 
fNumber = focalLength/apertureDiameter;
optics = opticsSet(optics,'fnumber',fNumber);

% In this example we set the properties of the optics to include cos4th
% falloff for the off axis vignetting of the imaging lens
optics = opticsSet(optics,'offaxis','cos4th');
optics = opticsSet(optics,'focallength',focalLength);   % Meters 
oiT = oiSet(oiT,'optics',optics);
oiT = oiCompute(scene,oiT);
ieAddObject(oiT); oiWindow;

%% Plot mesh plots for all 3 techniques

%Theoretical
oiPhotons = oiGet(oiT, 'photons');
PSFLineSpectral = sum(oiPhotons, 1);
PSFLineSpectral = reshape(PSFLineSpectral, [size(oiPhotons,1) size(oiPhotons, 3)]);
plotBound = sensorWidth/2 * 10^3;

[X, Y] = meshgrid(400:10:700, linspace(plotBound, -plotBound, size(PSFLineSpectral, 1)));
vcNewGraphWin;
mesh(X, Y, PSFLineSpectral./max(PSFLineSpectral(:)));
xlabel('Wavelength (nm)')
ylabel('Position (um)')
zlabel('Intensity (rel.)');
title('Theoretical Linespread');


%HURB
oiPhotons = oiGet(oiHURB, 'photons');
PSFLineSpectral = sum(oiPhotons, 1);
PSFLineSpectral = reshape(PSFLineSpectral, [size(oiPhotons,1) size(oiPhotons, 3)]);
plotBound = sensorWidth/2 * 10^3;

[X, Y] = meshgrid(400:10:700, linspace(plotBound, -plotBound, size(PSFLineSpectral, 1)));
vcNewGraphWin; mesh(X, Y, PSFLineSpectral./max(PSFLineSpectral(:)));
xlabel('Wavelength (nm)')
ylabel('Position (um)')
zlabel('Intensity (rel.)');
title('HURB Linespread');

%% Huygens
oiPhotons = oiGet(oiHuygens, 'photons');
PSFLineSpectral = sum(oiPhotons, 1);
PSFLineSpectral = reshape(PSFLineSpectral, [size(oiPhotons,1) size(oiPhotons, 3)]);
plotBound = sensorWidth/2 * 10^3;

[X, Y] = meshgrid(400:10:700, linspace(plotBound, -plotBound, size(PSFLineSpectral, 1)));
vcNewGraphWin; mesh(X, Y, PSFLineSpectral./max(PSFLineSpectral(:)));
xlabel('Wavelength (nm)')
ylabel('Position (um)')
zlabel('Intensity (rel.)');  
title('Huygens-Fresnel Linespread');

%% plot line vs. wavelength plots (linespread) plot PSFs on 1 figure

% Until the Huygens speed up, we just to the HURB and Theoretical
oiPhotonsTemp = oiGet(oiT, 'photons');
PSFLineT = sum( oiPhotonsTemp(:,:,16), 1);
PSFLineTS = PSFLineT /max(PSFLineT(:));

% oiPhotonsTemp = oiGet(oiHuygens, 'photons');
% PSFLineHuygens = sum(oiPhotonsTemp(:,:, 16) , 1);
% PSFLineHuygens = PSFLineHuygens / max(PSFLineHuygens(:));

% oiPhotonsTemp = oiGet(oiHURBTuned, 'photons');
% PSFLineHURBTuned = sum(oiPhotonsTemp(:,:,16), 1);
% PSFLineHURBTuned = PSFLineHURBTuned / max(PSFLineHURBTuned);

oiPhotonsTemp = oiGet(oiHURB, 'photons');
PSFLineHURB = sum(oiPhotonsTemp(:,:,16), 1);
PSFLineHURB = PSFLineHURB / max(PSFLineHURB);

positionT = linspace(-sensorWidth/2 *1000, sensorWidth/2 *1000, length(PSFLineT));
position = linspace(-sensorWidth/2 * 1000, sensorWidth/2 * 1000, length(PSFLineHURB));

vcNewGraphWin;
plot( positionT, PSFLineTS, position, PSFLineHURB);
%plot( positionT, PSFLineTS, position, PSFLineHURB, position, PSFLineHuygens);

title(['Linespread Comparison at 550nm;' num2str(focalLength) 'mm;f/' ...
    num2str(focalLength/apertureDiameter, 2)  ]);
xlabel('um')
%axis([-40 40 0 1]);  %don't show the bad part of the theoretical plot
ylabel('Relative radiance');
legend('Theoretical', 'HURB');
% 
% 
% %save figure as a tiff file
% fileName = ['PSFC_' num2str(sampleArray{index}.focalLength) 'mm_f' ...
%     num2str(focalLength/(apertureDiameter))];
% hgexport(gcf, [fileName '.tif'], hgexport('factorystyle'), 'Format', 'tiff');

%% plot line vs. wavelength plots (PSF slice) plot 3 PSFs on 1 figure
oiPhotonsTemp = oiGet(oiT, 'illuminance');
PSFLineT = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineTS = PSFLineT /max(PSFLineT(:));

oiPhotonsTemp = oiGet(oiHuygens, 'illuminance');
PSFLineHuygens = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineHuygens = PSFLineHuygens / max(PSFLineHuygens(:));

oiPhotonsTemp = oiGet(oiHURB, 'illuminance');
PSFLineHURB = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineHURB = PSFLineHURB / max(PSFLineHURB);

positionT = linspace(-sensorWidth/2 *1000, sensorWidth/2 *1000, length(PSFLineT));
position = linspace(-sensorWidth/2 * 1000, sensorWidth/2 * 1000, length(PSFLineHURB));

vcNewGraphWin;
plot( positionT, PSFLineTS, position, PSFLineHURB, position, PSFLineHuygens);


title(['PSF Slice Comparison at 550nm;' num2str(focalLength) 'mm;f/' ...
    num2str(focalLength/apertureDiameter, 2)  ]);
xlabel('um')
%axis([-40 40 0 1]);  %don't show the bad part of the theoretical plot
ylabel('Relative radiance');
legend('Theoretical', 'HURB', 'Huygens-Fresnel');

%%