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

% Estimate the PSF and show the ray trace
nLines = 50;
jitter = true;
camera.estimatePSF(nLines,jitter);
set(gca,'xlim',[-5 20]); grid on

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
