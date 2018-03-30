%% Optics diffraction tutorial
%
% Edited by TL (3/2018)
%
% This script uses the point test file, blurs it in 3 different ways.  
%
% The first way is to use the new ray tracing method which uses Heisenburg
% Uncertainty Ray Bending (HURB).
%
% The second way is Huygens method.
%
% The third way is the classical way using theoretical PSF's and formulae
% from ISET
%
% AL, Vistasoft Team, Copyright 2014

%%
ieInit;

%% Set up a point and a lens file

% Make a point source (approximately infinity)
point = psCreate(0,0,-1e+15);

% Read a lens file and create a lens. The "diffraction" lens consists of a
% spehrical plane, an aperture, and a flat plane behind it. 
lensFileName = fullfile(ilensRootPath,'data', 'lens', 'diffraction.dat');

nSamples = 401; 

% Set the aperture size (this lens seems to be diffraction-limited for
% aperture sizes of less than 2 mm)
apertureMiddleD = 0.5;   % mm   

lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD, ...
    'diffractionEnabled', true);
lens.set('wave', (400:10:700));
lens.draw;

%% Create the film

% The film position will later be overwritten by the autofocus calculation.
% However, the other values will remain the same for the rest of this
% script. We set the size of the sensor to be 100 um x 100 um.
wave = lens.get('wave');
film = filmC('position', [0 0 5], ...
    'resolution', [400 400], ...
    'size', [0.1 0.1], ...
    'wave', wave);

%% Create a camera out of lens, film ,and point source

camera = psfCameraC('lens',lens,'film',film,'point source',point);

% Automatically place the film at a distance where 550 nm will be in focus. 
camera.autofocus(550,'nm'); 

% Estimate the PSF
nLines = 50;     % Show lines
jitter = true;  % Randomize position of lines

% Limits the entrance aperture so this can run faster
% But this is not reasonable for the diffraction calculation
subsection = [];

% Choose among the diffraction producing methods
method = 'HURB';   % Randomized the direction of rays near the edges

% TL: I believe an "ideal" rtType aims rays toward the aperture instead of
% shooting them randomly over the lens. I'm not 100% positive though.
rtType = 'ideal';

% Produced the data for the PSF.
camera.estimatePSF(nLines,jitter,subsection, method, rtType);

% Scale the axes so we can see the film plane. 
set(gca,'xlim',[-5 20]); grid on

oiHURB = camera.oiCreate();
oiHURB = oiAdjustIlluminance(oiHURB,0.1);  %Makes the middle bright
ieAddObject(oiHURB); oiWindow;
    

%% Produce Huygens-Fresnel results 
% This does not work at the moment. 
%{
% This section takes a long time to run - and you should only do it on
% after parallelization!

% Use all the same parameters as before (TL)
%{
% Make a point source (approximately infinity mm)
point = psCreate(0,0,-1e+15);

% Read a lens file and create a lens
%lensFileName = fullfile(cisetRootPath,'data', 'lens', 'dgauss.50mm.dat');
lensFileName = fullfile(ilensRootPath,'data', 'lens', '2ElLens.dat');

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
camera.autofocus(550,'nm');
%}

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
 %} 

%% Theoretical results based on ISET formula
% Compare the PSF from HURB with ISET implementation

% Match the camera parameters with the ones we used above. 
sensorWidth = camera.film.size(1)*1e-3;
focalLength = camera.film.position(3)*1e-3;
filmDistance = camera.film.position(3)*1e-3;
apertureDiameter = camera.lens.apertureMiddleD*1e-3;

% BW(?): This is an annoying way to make a single point scene.
% I should add a single point sceneCreate.  There is a 'point array', and
% we should just make a 'single point' version.  The point could always
% have a single point in the middle, and then just set the spacing very
% large so there is only one point.  Right now, the point array doesn't put
% a point in the middle!
d = displayCreate('equal energy');
pFile = fullfile(ilensRootPath,'data','images','pointTest.png');
scene = sceneFromFile(pFile, 'rgb', [], d);
wave = sceneGet(scene, 'wave');
onesPhotons = ones(size(wave)) * 1e+15;
equalPhotonsEnergy = Quanta2Energy(wave, onesPhotons);
scene = sceneAdjustIlluminant(scene, equalPhotonsEnergy);

horFieldofView = 2 * atand(sensorWidth/(2 * filmDistance))*0.8; 
scene = sceneSet(scene,'fov',horFieldofView);
scene = sceneSet(scene, 'distance', 100000001);   
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

%% Plot mesh plots for all techniques

% Theoretical
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

% HURB
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
% Not working at the moment. 
%{
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
%}

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

title(['Linespread Comparison at 550nm; ' num2str(focalLength) 'mm; f/' ...
    num2str(focalLength/apertureDiameter, 2)  ]);
xlabel('um')
%axis([-40 40 0 1]);  %don't show the bad part of the theoretical plot
ylabel('Relative radiance');
legend('Theoretical', 'HURB');

% %save figure as a tiff file
% fileName = ['PSFC_' num2str(sampleArray{index}.focalLength) 'mm_f' ...
%     num2str(focalLength/(apertureDiameter))];
% hgexport(gcf, [fileName '.tif'], hgexport('factorystyle'), 'Format', 'tiff');

%% plot line vs. wavelength plots (PSF slice) plot 3 PSFs on 1 figure
oiPhotonsTemp = oiGet(oiT, 'illuminance');
PSFLineT = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineTS = PSFLineT /max(PSFLineT(:));

%{
oiPhotonsTemp = oiGet(oiHuygens, 'illuminance');
PSFLineHuygens = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineHuygens = PSFLineHuygens / max(PSFLineHuygens(:));
%}

oiPhotonsTemp = oiGet(oiHURB, 'illuminance');
PSFLineHURB = oiPhotonsTemp((size(oiPhotonsTemp, 1))/2,:);
PSFLineHURB = PSFLineHURB / max(PSFLineHURB);

positionT = linspace(-sensorWidth/2 *1000, sensorWidth/2 *1000, length(PSFLineT));
position = linspace(-sensorWidth/2 * 1000, sensorWidth/2 * 1000, length(PSFLineHURB));

vcNewGraphWin;
% plot( positionT, PSFLineTS, position, PSFLineHURB, position, PSFLineHuygens);
plot( positionT, PSFLineTS, position, PSFLineHURB);

title(['PSF Slice Comparison at 550nm; ' num2str(focalLength) 'mm; f/' ...
    num2str(focalLength/apertureDiameter, 2)  ]);
xlabel('um')
%axis([-40 40 0 1]);  %don't show the bad part of the theoretical plot
ylabel('Relative radiance');
legend('Theoretical', 'HURB', 'Huygens-Fresnel');
