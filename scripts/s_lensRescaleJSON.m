%% s_lensRescaleJSON
%
%  Re-scaling lens lengths to a new focal length.
%
%  Convert a lens design file to a new focal length from an existing
%  lens design file. The lens parameters (# surfaces, materials) don't
%  change, but their dimensions do, in order to accommodate the new
%  focal length.

%%
ieInit

%% Read a  lens file
%

% Here is a list of all of them
lensFiles = lensC.list;

% Pick one 
this = 8;
baseLens = lensC('fileName', lensFiles(this).name);

baseLens.draw
baseLens.bbmCreate();


%% Create a scaled lens
%  Scale all the parameters by the ratio of
%  focal lengths (desired to reference)

scaledLens = baseLens;
desiredFlength = 5e-3;   % Microlens
scaleFactor = desiredFlength/scaledLens.focalLength;

for ii=1:length(scaledLens.surfaceArray)
    scaledLens.surfaceArray(ii).sRadius = scaledLens.surfaceArray(ii).sRadius * scaleFactor;
    scaledLens.surfaceArray(ii).sCenter = scaledLens.surfaceArray(ii).sCenter * scaleFactor;
    scaledLens.surfaceArray(ii).apertureD = scaledLens.surfaceArray(ii).apertureD * scaleFactor;
end
scaledLens.bbmCreate();
scaledLens.focalLength = desiredFlength;
scaledLens.name = sprintf('%s.%.1fmm','scaledLens',desiredFlength);
scaledLens.draw

fLength = scaledLens.get('bbm','effective focal length');
imageFocalPoint = scaledLens.get('bbm','imageFocalPoint');

fprintf('Scaled lens focal length: %.2f mm\n',fLength(1));
fprintf('Rays focus %.2f mm away from the sensor\n',imageFocalPoint(1));

scaledLens.fileWrite(fullfile(ilensRootPath,'data','microlens','microlens.json'));

%% Ray trace the points to the film
%
%  Check that the points converge at some distance in front of the
%  sensor (to illustrate this convergence we place the sensor far away
%  from the lens).

wave = lens.get('wave');
sensor = filmC('position', [0 0 154], ...
    'size', [5 5], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',scaledLens,'film',sensor,'pointsource',point);

nLines = 100;
jitterFlag = true;
camera.estimatePSF('nlines', nLines, 'jitter flag', jitterFlag);

% fileWrite(scaledLens,[scaledLens.name '.dat']);

%% Check the focus for this lens
[pt, ~, film] = ilInitPLF;

