%% Normal rendering from ISET3d 
ieInit;
if ~piDockerExists, piDockerConfig; end

%
thisR = piRecipeDefault('scene name', 'simple scene');
lensfile = 'lenses/dgauss.22deg.3.0mm.json';

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('film distance', 0.00216675);
thisR.set('film diagonal', 5); % mm

piWrite(thisR);

%
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiWindow(oi);

%% Compare results after running seperately from PBRT
% This part needs to be run not within ISET3d but directly from PBRT. Later
% on we would make blackbox as a docker container that can be also called
% from ISET3d.
fname = fullfile(piRootPath, 'local', 'Copy_of_simpleScene', 'renderings', 'test.dat');
oiPoly = piDat2ISET(fname, 'wave', 400:10:700, 'recipe', thisR);
oiWindow(oiPoly);
