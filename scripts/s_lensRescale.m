%% s_lensRescale
%
% Re-scaling lens lengths to a new focal length.
%
% Convert a lens design file to a new focal length from an existing lens
% design file. The lens parameters (# surfaces, materials) don't change,
% but their dimensions do, in order to accommodate the new focal length.
%
%  Copyright, VISTALAB 2017
%
% See also
%    lensC.scale

%%
ieInit

%%
referenceFLength = 100;

desiredFLengths = [3.0 6.0, 12.5, 50.0];    % Units:   millimeters

lenses = {'petzval.12deg'};

for d=1:length(desiredFLengths)
for l=1:length(lenses)
    
    baseLens = lenses{l};
 
    % Create an on-center, far-away point
    point = psCreate(0,0,-10000);
    
    % Read a lens file and create a lens
    % We assume that the base file describes a lens with 100mm focal
    % length.
    lensFileName = fullfile(ilensRootPath,'data','lens',sprintf('%s.%.1fmm.dat',baseLens,referenceFLength));
    
    % This is a small number of numerical samples in the aperture.  
    nSamples = 351;
    apertureMiddleD = 8;   % mm
    lens = lensC('apertureSample', [nSamples nSamples], ...
        'fileName', lensFileName, ...
        'apertureMiddleD', apertureMiddleD);
    
    lens.draw
    lens.bbmCreate();
    
    
    %% Create a scaled lens
    %  Scale all the parameters by the ratio of
    %  focal lengths (desired to reference)
    scaledLens = lensC('apertureSample', [nSamples nSamples], ...
        'fileName', lensFileName, ...
        'apertureMiddleD', apertureMiddleD);
    scaleFactor = desiredFLengths(d)/scaledLens.focalLength;
    
    for ii=1:length(scaledLens.surfaceArray)
        scaledLens.surfaceArray(ii).sRadius = scaledLens.surfaceArray(ii).sRadius * scaleFactor;
        scaledLens.surfaceArray(ii).sCenter = scaledLens.surfaceArray(ii).sCenter * scaleFactor;
        scaledLens.surfaceArray(ii).apertureD = scaledLens.surfaceArray(ii).apertureD * scaleFactor;
    end
    
    scaledLens.bbmCreate();
    scaledLens.focalLength = desiredFLengths(d);
    scaledLens.name = sprintf('%s.%.1fmm',baseLens,desiredFLengths(d));
    scaledLens.draw
    
    
    fLength = scaledLens.get('bbm','effectivefocallength');
    imageFocalPoint = scaledLens.get('bbm','imageFocalPoint');
    
    fprintf('Scaled lens focal length: %.2f mm\n',fLength(1));
    fprintf('Rays focus %.2f mm away from the sensor\n',imageFocalPoint(1));
    
    
    %% Ray trace the points to the film
    %  Check that the points converge at some distance in front of the
    %  sensor (to illustrate this convergence we place the sensor far away
    %  from the lens).
    
    wave = lens.get('wave');
    sensor = filmC('position', [0 0 154], ...
        'size', [5 5], ...
        'resolution',[300 300],...
        'wave', wave);
    camera = psfCameraC('lens',scaledLens,'film',sensor,'pointsource',point);
    camera.estimatePSF(true);
    
    fileWrite(scaledLens,fullfile(ilensRootPath,'data','lens',sprintf('%s.dat',scaledLens.name)));
    fileWrite(scaledLens,fullfile(ilensRootPath,'data','lens',sprintf('%s.json',scaledLens.name)));
end
end
