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

point{1} = [0 0 -10000];   % Negative is in object space

lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.12.5mm.dat');
lens = lensC('fileName',lensFileName);

film   = filmC;
camera = psfCameraC('lens',lens,'film',film,'point source',point);

%%  Find the film focal length for this wavelength

% Current film position
camera.film.position(3)

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Show adjusted position for focus
camera.film.position(3)

%% Estimate the PSF and show the ray trace
nLines = 50;
jitterFlag = true;

% This is the whole point spread function
camera.estimatePSF(nLines,jitterFlag);
set(gca,'xlim',[-15 20]); grid on

%%
% These are for a normalized position on the first aperture, 
% between [-1 1].  The function scales them to the position of the
% first aperture diameter.

nLines = 10;
jitterFlag = false;
yFan(1) = 0; yFan(3) = 0;
yFan(2) = -1; yFan(4) = 1;
camera.estimatePSF(nLines,jitterFlag, yFan);
set(gca,'xlim',[-15 20]); grid on

%% Next dgauss test case
lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.6.0mm.dat');
lens = lensC('fileName',lensFileName);

film = filmC;
camera = psfCameraC('lens',lens,'film',film,'pointsource',point);

%%  Find the film focal length for this wavelength

% Current film position
camera.film.position(3)

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Show adjusted position for focus
camera.film.position(3)

%%
