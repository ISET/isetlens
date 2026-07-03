%% Experiment with diffraction limited spherical lens
%
% Wandell, SCIEN Stanford, 2018

%%  Set up point, lens, film

[pt, ~, film] = ilInitPLF;
pt{1} = [0, 0,-100];      % Pretty far away
film.size = [0.05 0.05];    % 200 microns

%% A sphere and a planar surface for the diffraction
% This one has a radius of 8mm.
lens = lensC('filename','diffraction8.dat');
lens.draw;
lens.bbmCreate;

%%
camera = psfCameraC('lens',lens,'point source',pt,'film',film);
camera.get('film position')
camera.autofocus(500,'nm');
camera.get('film position')

%%
nLines = 0;  % Do not draw the rays
jitter = true;
camera.estimatePSF('n lines', nLines, 'jitter flag',jitter);
%%
oi = camera.oiCreate;
% ieAddObject(oi); oiWindow;
oiPlot(oi,'illuminance mesh linear');

%% 
