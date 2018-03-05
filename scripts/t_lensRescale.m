%% Re-scaling lens recipe to a desited focal length
%
%  Generate a lens design file with a new focal length from an existing lens
%  design file. The lens parameters (# surfaces, materials) don't change,
%  but their dimensions do, in order to accommodate the new focal length.
%
%  Copyright, VISTALAB 2017

%%
ieInit

desiredFLength = 6;
lenses = {'wide.56deg','dgauss.22deg','fisheye.87deg','tessar.22deg','wide.40deg','2el.XXdeg'};

for l=1:length(lenses)
    
    baseLens = lenses{l};
 
    % Create an on-center, far-away point
    point = psCreate(0,0,-10000);
    
    % Read a lens file and create a lens
    % We assume that the base file describes a lens with 100mm focal
    % length.
    lensFileName = fullfile(rtbsRootPath,'SharedData',sprintf('%s.100.0mm.dat',baseLens));
    
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
    scaleFactor = desiredFLength/scaledLens.focalLength;
    
    for ii=1:length(scaledLens.surfaceArray);
        scaledLens.surfaceArray(ii).sRadius = scaledLens.surfaceArray(ii).sRadius * scaleFactor;
        scaledLens.surfaceArray(ii).sCenter = scaledLens.surfaceArray(ii).sCenter * scaleFactor;
        scaledLens.surfaceArray(ii).apertureD = scaledLens.surfaceArray(ii).apertureD * scaleFactor;
    end
    
    scaledLens.bbmCreate();
    scaledLens.focalLength = desiredFLength;
    scaledLens.name = sprintf('%s.%.1fmm',baseLens,desiredFLength);
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
    camera.estimatePSF(100,true);
    
    fileWrite(scaledLens,[scaledLens.name '.dat']);
end
