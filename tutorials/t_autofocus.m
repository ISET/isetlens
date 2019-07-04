%% Illustrate the use of the black box model for autofocus
%
%  psfCamera.autofocus(wave0, waveUnit, [n_ob], [n_im])
%
% The numbers for autofocus here are always a little short compared to
% the file name.  Need to comment and understand
%
% BW SCIEN STANFORD

%%
ieInit

%%  Initialize a point and a camera

point{1} = [0 0 -1000];   % Negative is in object space

lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.12.5mm.dat');
lens = lensC('fileName',lensFileName);
lens.apertureSample = [301 301];          % Number of samples at first lens

film   = filmC;
film.size = [1 1];                  % A small bit of film, in millimeters
film.resolution = film.size*1e3;    % 1 micron per sample, keeps the estimate constant

camera = psfCameraC('lens',lens,'film',film,'point source',point);

%%  Find the film focal length for this wavelength

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Show adjusted position for focus
camera.film.position(3) = camera.film.position(3) + 0.3; 

%% Estimate the PSF and do not show the ray trace.  Faster.
jitterFlag = true;

% This is the whole point spread function
camera.estimatePSF(nLines,jitterFlag);

%% Create the OI - The film size does not seem right.

% Debug oiCreate because the film size does not seem right.
oi = camera.oiCreate;
oiWindow(oi);

%% Now, show the ray trace for the yFan case
nLines = 20;
camera.draw(nLines);

%% Next dgauss test case
lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.6.0mm.dat');
lens = lensC('fileName',lensFileName);

camera = psfCameraC('lens',lens,'film',film,'pointsource',point);

%%  Find the film focal length for this wavelength

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Show adjusted position for focus
camera.film.position(3) = camera.film.position(3) + 0.1; 

%% Estimate the PSF and do not show the ray trace.  Faster.

% This is the whole point spread function
camera.estimatePSF();

% Create the OI
oi = camera.oiCreate;
oiWindow(oi);

%%
camera.draw(nLines);

%% END

