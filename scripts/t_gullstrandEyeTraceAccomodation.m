%% t_gullstrandEyeTrace
%
% Here we demonstrate tracing through the gullstrand eye model. Using
% Navarro's equations, we can also model the chromatic aberration present
% in the eye.
%
% We play with Navarro's accommodation-dependent model in this script. As
% the eye accomodates at different distances in the scene, we, change the
% radius, thickenss, and refractive index of the lens. 

% TL/BW Vistasoft Team

% PROBLEMS: 
% The refractive power we measure of the Gullstrand eye (using CISET
% raytracing with a point far away) is short of the actual refractive power
% cited in the paper (e.g. 16.4 mm vs 16.7 mm)

% Is this because the incoming rays are not truly parallel?

% Similarly, if we try to replicate Fig 9 using the accommodation model,
% the slope of the line is much steeper than is cited. This means the
% refractive power increases too fast as the accommodation in diopters
% increases. Why? Is this an issue with our CISET version of raytracing, or
% are we modeling something incorrectly or missing something? 

%%
% ieInit

%% Read the lens file and create a lens

lensFileName = fullfile(cisetRootPath,'data', 'lens', 'gullstrand.dat');

apertureMiddleD = 2;   % (mm) a relatively narrow pupil

nSamples = 125; % Number of spatial samples in the aperture.
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD,...
    'name','Gullstrand',...
    'focalLength',16.5);    % For CISET, 16.5mm is about the focal distance.


% Set asphericity
% TODO: Set this in the lens file in the future

% [cornea anterior | cornear posterior | aperture | lens anterior | lens posterior]
% Q = [-0.26 0 0 -3.1316 -1];
% nSurfaces = lens.get('n surfaces');
% for ii=1:nSurfaces
%         lens.surfaceArray(ii).asphericity = Q(ii);
% end

% Draw the lens
lens.draw


%% Set index of refraction for the lens
% No chromatic aberration for now.
%{
% Set wavelength sampling for the lens
wave = 400:10:700;   
lens.set('wave', wave);

% Load index of refraction (n) of ocular mediums
% colums: [cornea aqueous lens vitreous]
ior = ieReadSpectra('IORofEye.mat',wave);

% Insert column of zeros for the aperture
% colums: [cornea aqueous aperture lens vitreous]
ior = [ior(:,1:2) zeros(length(wave),1) ior(:,3:4)];
% ior(:,end) = 1.28*ones(length(ior),1);

% Set the index of refraction for each medium
nSurfaces = lens.get('n surfaces');
nWave = lens.get('nwave');
for ii=1:nSurfaces
        lens.surfaceArray(ii).n = ior(:,ii)';
end
%}

%% Create a film (sensor), in this case this is the retina
% In the future we may want this to be curved.

% wavelength samples
wave = lens.get('wave');

% Let's only model the are around the fovea for now. The fovea is around
% 1.5 mm wide, so let's make the sensor 2 mm x 2 mm.
sensorSize = 2;
% Thre retina is around 16.5 mm away from the back of the lens
% filmPosition = 16.5;
filmPosition = 16.7; % Navarro's paper cites 16.7 mm

sensor = filmC('position', [0 0 filmPosition], ...
    'size', [sensorSize sensorSize], ...
    'resolution',[300 300],...
    'wave', wave);

%% Let's change the accommodation now. 

A = 0; % Accomodation in diopters, this is the change in diopters from the lens' normal refractive power. 

% These equations are from Table 4 in Navarro's paper.
anteriorRadius = 10.2 - 1.75*log(A+1);
posteriorRadius = -6 + 0.2294*log(A+1);
aqueousThickness = 3.05 - 0.05*log(A+1);
lensThickness = 4 + 0.1*log(A+1);
lensIOR = 1.42 + (9e-5)*(10*A+A^2);

% Write a new lens file (changing the surfaces directly is too complicated
% - I tried and failed.) Also, I can't use fileWrite (in the optics folder)
% here because the lens numbers aren't in the form of a lensC class. Let's
% just write it directly for now.

% ---- WRITE temp lens file -----

% TODO: What to do about wavelength dependent index of refraction?
% ANSWER: New equations in navarro need to be implemented

lensMatrix = [7.8	0.55	1.3771	11;
6.5	aqueousThickness	1.3374	10.5;
0	0	0	10.2;
anteriorRadius	lensThickness	lensIOR	10.632;
posteriorRadius	0	1.336	10.632];

focalLength = 1/(60.6061 + A)*10^3; % mm

newFileName = 'gullstrandAccomodated.dat';
fid = fopen(newFileName,'w');

str = sprintf('# Focal length (mm) \n');
fprintf(fid,'%s',str);
str = sprintf('%.3f\n',focalLength);
fprintf(fid,'%s',str);
str = sprintf('#    radius	 axpos	N	aperture\n');
fprintf(fid,'%s',str);
for ii=1:size(lensMatrix,1)
    fprintf(fid,'%f\t%f\t%f\t%f\n', lensMatrix(ii,1), lensMatrix(ii, 2), lensMatrix(ii,3), lensMatrix(ii,4));
end
fclose(fid);
% -------------------------------

nSamples = 125; % Number of spatial samples in the aperture.
% Load the new lens file
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', newFileName, ...
    'apertureMiddleD', apertureMiddleD,...
    'name',sprintf('Gullstrand - %0.2fD',A),...
    'focalLength',16.5);    % For CISET, 16.5mm is about the focal distance.

lens.draw


%% Trace

pointsVerticalPosition = [0];
pointDistance = -1e15; % 
point = psCreate(0,pointsVerticalPosition,pointDistance);

% Create the camera using the sensor and lens we defined above. 
camera = psfCameraC('lens',lens,'film',sensor,'point',point);

% Estimate the PSF and show the ray trace
nLines = 100;
jitter = true;
camera.estimatePSF(nLines,jitter);
set(gca,'xlim',[-5 20]); grid on

%% Clean up

% Delete the temp lens file
delete(newFileName);
