%% Illustrate the use of the black box model for autofocus
%
%  psfCamera.autofocus(wave0, waveUnit, [n_ob], [n_im])

%%
ieInit

%%  Initialize a point and a camera

point{1} = [0 0 -10000];

% This human eye model has a focal length of 16.5 mm, which we confirm when
% running ray trace in PBRT and ray trace in CISET. See -
lensFileName = fullfile(cisetRootPath,'data', 'lens', 'gullstrand.dat');
lensFileName = fullfile(rtbsRootPath,'SharedData','dgauss.20mm.dat');
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