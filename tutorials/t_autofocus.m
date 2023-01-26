%% Illustrate psfCameraC, autofocus, and PSF 
%
%  * Creates a psfCameraC based on a point source, lens, and film.
%  * Sets the film position using autofocus method
%  * Renders the point and converts it to an ISETCam optical image
%  * Calls oiPSF to estimate the size of the point spread
%  * Plots a ray trace through the lens
%
% BW, SCIEN, 2019
% 
% See also
%   psfCameraC.autofocus

%%
ieInit

%%  Initialize a point and a camera

point{1} = [0 0 -1000];   % Negative is in object space
lenses = lensC.list('quiet',true);
lensFileName = lenses(7).name;

% lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.12.5mm.dat');
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
camera.estimatePSF('jitter flag', jitterFlag);
camera.rays.plot('entrance pupil');

%% Create the OI - The film size does not seem right.

% Debug oiCreate because the film size does not seem right.
oi = camera.oiCreate;
oiWindow(oi);
fprintf('PSF diameter: %.2f um\n',oiPSF(oi,'diameter','units','um'));

%% Now, show the ray trace for the yFan case
nLines = 50;
camera.draw(nLines);

%% Notice that we now have the entrance pupil in the yFan sample points
camera.rays.plot('entrance pupil');

%% Next dgauss test case
lensFileName = 'dgauss.22deg.6.0mm.json';
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
camera.rays.plot('entrance pupil');

%% Create the OI
oi = camera.oiCreate;
oiWindow(oi);
fprintf('PSF diameter: %.2f um\n',oiPSF(oi,'diameter','units','um'));

%%
camera.rays.plot('entrance pupil');

%%
camera.draw(nLines);


%% END

