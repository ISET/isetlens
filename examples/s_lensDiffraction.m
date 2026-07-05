%% Experiment with diffraction limited spherical lens
%
% Wandell, SCIEN Stanford, 2018

%%  Set up point, lens, film

[pt, ~, film] = ilInitPLF;
pt{1} = [0, 0,-100];      % Pretty far away
film.size = [0.05 0.05];    % 200 microns

%% A sphere and a planar surface for the diffraction
% This lens matches the old diffraction.dat file without requiring a DAT
% read.
lens = lensC('aperture sample',[21 21], ...
    'aperture middle d',2, ...
    'diffraction enabled',true);
lens.name = 'diffraction';
lens.focalLength = 6;
lens.elementsSet([0; 0.18; 0.03], [8.04; 0; -1000], [3; 3; 3], [1.65; 1; 1]);
lens.apertureMiddleD = 2;
lens.draw;
lens.bbmCreate;

%%
camera = psfCameraC('lens',lens,'point source',pt,'film',film);
camera.get('film position')
camera.autofocus(500,'nm');
camera.get('film position')

%%
nLines = 0;  % Do not draw the rays
jitter = false;
camera.estimatePSF('n lines', nLines, 'jitter flag',jitter);
%%
oi = camera.oiCreate;
% ieAddObject(oi); oiWindow;
oiPlot(oi,'illuminance mesh linear');

%% 
