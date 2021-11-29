%% Optics diffraction tests for ISETLens
%
% This script creates a point test input and then blurs it in 3 different
% ways. 
%
% The first way is to use the new ray tracing method which uses Heisenburg
% Uncertainty Ray Bending (HURB).
%
% The second way is Huygens method.
%
% The third way is the classical way using theoretical PSF's and formulae
% from ISET
%
% See also
%  s_psfDiffractionHURB (ISET3d)

%%
ieInit;

if isempty(which('ilensRootPath'))
    disp('No isetlens on the path.  Returning')
    return;
end

%% Set up a point and a lens file

% Make a point source (approximately infinity).
%
% Negative numbers are on the object side, and positive numbers on the
% image side.
point = psCreate(0,0,-1e+15);

%% Change the aperture to see when diffraction becomes significant

% Read a lens file and create a lens. The "diffraction" lens consists of a
% spehrical plane, an aperture, and a flat plane behind it.
lensFileName = fullfile(ilensRootPath,'data', 'lens', 'diffraction.dat');



% Lens comes back with 400:50:700
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', 2, ...
    'diffractionEnabled', true);
wave = lens.get('wave');
lens.draw;
% lens.set('wave', (400:10:700));

% The film position will later be overwritten by the autofocus calculation.
% However, the other values will remain the same for the rest of this
% script. We set the size of the sensor to be 100 um x 100 um.
film = filmC('position', [0 0 5], ...
    'resolution', [400 400], ...
    'size', [0.1 0.1], ...
    'wave', wave);
    
%% Compute linespread for different aperture sizes

% Choose how many ray samples
%{
% Big test - TG ran this case.
% We might try smaller number of rays but smooth the curves with a Gaussian
 nSamples = [401, 401, 601, 801, 3*801]*15;   
 apertures = [2, 1, 0.5, 0.25 0.1];   
%}

% {
% Small example
nSamples = [301, 401, 501 801]*5;  
apertures = [2, 1, 0.5 0.1]; 
%}

for ii=1:numel(apertures)
    
    % Adjust the lens aperture and name
    lens.set('middle aperture diameter',apertures(ii));
    lens.set('name',sprintf('Diffraction %.1f',apertures(ii)));
    lens.set('aperture sample',[nSamples(ii), nSamples(ii)]);
    lens.get('aperture diameter')

    %% Create a camera out of lens, film ,and point source    
    camera = psfCameraC('lens',lens,'film',film,'point source',point);
    
    % Automatically place the film at a distance where 550 nm will be in focus.
    camera.autofocus(550,'nm');
    
    % Estimate the PSF
    nLines = 0;      % Show lines
    jitter = true;   % Randomize position of lines
    
    % Limits the entrance aperture so this can run faster
    % But this is not reasonable for the diffraction calculation
    subsection = [];
    
    % Choose among the diffraction producing methods
    % This code in ISETLENS does not seem to be numerically accurate.  The PBRT
    % code should be, however.  Let's see what is going on here (BW, 2021).
    method = 'HURB';   % Randomized the direction of rays near the edges
    
    % TL: I believe an "ideal" rtType aims rays toward the aperture instead of
    % shooting them randomly over the lens. I'm not 100% positive though.
    rtType = 'ideal';
    
    % Produced the data for the PSF.
    camera.estimatePSF('n lines', nLines, 'jitter flag', jitter,...
        'subsection', subsection,...
        'diffraction method', method,...
        'rt type', rtType);
    
    % Scale the axes so we can see the film plane.
    set(gca,'xlim',[-5 20]); grid on
    
    oiHURB = camera.oiCreate();
    oiHURB = oiAdjustIlluminance(oiHURB,0.1);  % Makes the middle bright
    % oiWindow(oiHURB);
    
    sz = oiGet(oiHURB,'size');
    udata(ii) = oiPlot(oiHURB,'illuminance hline',round([1, sz(2)/2]),'no figure');
end

%% Plot the overlaid curves

% At larger apertures the limits are the lens aberrations.  At smaller
% apertures the HURB should come close to matching the diffraction limited
% case.  It is similar, but not that close.
maxnorm= @(x)(x/max(x));
ieNewGraphWin;
for ii=1:numel(apertures)
    % Smooth the curves a bit with a Gaussian
    % We could also run more rays, which smooths the data too.  I am a
    % little worried how much this might widen the curve, but hardly at
    % all, I think.
    y = imgaussfilt(udata(ii).data,2);
    y = maxnorm(y);

    plot(udata(ii).pos,y,'Linewidth',2);
    hold on; grid on;
    xlabel('Position (um)'); ylabel('Relative intensity');
    
    % This looks to be some formula from TG that measures the diffraction
    % limited spread?
    lambda_micron=0.55; 
    radius_micron = 0.5*apertures(ii)*1e3;
    distancetoaperture_micron=camera.film.position(3)*1e3;
    x= 2*pi/lambda_micron *(radius_micron) * udata(ii).pos/distancetoaperture_micron;
    plot(udata(ii).pos,maxnorm((2*besselj(1,x)./(x+eps)).^2),'k:','Linewidth',2);
end

return;

%% Theoretical results based on ISET formula

% Compare the PSF from HURB with ISET implementation

% Match the camera parameters with the ones we used above.
sensorWidth     = thisR.get('film width','m');
focalLength     = camera.film.position(3)*1e-3;
filmDistance    = thisR.get('film distance','m') 
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
optics = opticsSet(optics,'offaxis method','cos4th');
optics = opticsSet(optics,'focallength',focalLength);   % Meters
oiT = oiSet(oiT,'optics',optics);
oiT = oiCompute(scene,oiT);
oiWindow(oiT);

%% Plot mesh plots for all techniques

% Theoretical
oiPhotons = oiGet(oiT, 'photons');
PSFLineSpectral = sum(oiPhotons, 1);
PSFLineSpectral = reshape(PSFLineSpectral, [size(oiPhotons,1) size(oiPhotons, 3)]);
plotBound = sensorWidth/2 * 10^3;

[X, Y] = meshgrid(400:10:700, linspace(plotBound, -plotBound, size(PSFLineSpectral, 1)));
ieNewGraphWin;
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

[X, Y] = meshgrid(lens.get('wave'), linspace(plotBound, -plotBound, size(PSFLineSpectral, 1)));
ieNewGraphWin; mesh(X, Y, PSFLineSpectral./max(PSFLineSpectral(:)));
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
ieNewGraphWin; mesh(X, Y, PSFLineSpectral./max(PSFLineSpectral(:)));
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

midWave = round(lens.get('nwave')/2);
oiPhotonsTemp = oiGet(oiHURB, 'photons');
PSFLineHURB = sum(oiPhotonsTemp(:,:,midWave), 1);
PSFLineHURB = PSFLineHURB / max(PSFLineHURB);

positionT = linspace(-sensorWidth/2 *1000, sensorWidth/2 *1000, length(PSFLineT));
position = linspace(-sensorWidth/2 * 1000, sensorWidth/2 * 1000, length(PSFLineHURB));

ieNewGraphWin;
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

ieNewGraphWin;
% plot( positionT, PSFLineTS, position, PSFLineHURB, position, PSFLineHuygens);
plot( positionT, PSFLineTS, position, PSFLineHURB);

title(['PSF Slice Comparison at 550nm; ' num2str(focalLength) 'mm; f/' ...
    num2str(focalLength/apertureDiameter, 2)  ]);
xlabel('um')
%axis([-40 40 0 1]);  %don't show the bad part of the theoretical plot
ylabel('Relative radiance');
legend('Theoretical', 'HURB', 'Huygens-Fresnel');

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
camera.estimatePSF('n lines', nLines, 'jitter flag', jitter,...
                   'subsection', subsection,...
                   'diffraction method', method,...
                   'rt type',rtType);

oiHuygens = camera.oiCreate();
oiHuygens = oiSet(oiHuygens,'name','Huygens');
ieAddObject(oiHuygens); oiWindow;
%}

%% END