%% Sensor image for an automotive lens and sensor
%
% Illustrates some exploration of a lens and sensor pair using basic
% isetlens tools.  We read a lens, create film and a point spread camera
% (psfCameraC), and we convert the whole result into an ISET OI.
%
% The example is set up with the wide.56deg.6.0mm.json lens and an ON
% Semiconductor MT9V024 sensor (6 um pixel).
%
% The script includes some autofocusing calculation
%
% Wandell, 2019
%
% See also
%  t_autofocus.m, lensFocus, lensC.get(), psfCameraC.autofocus, oiPSF
%

%%
ieInit

%% Create lens 
%
% Also set the number of sample rays to use for the calculation.

lens = lensC('filename','wide.56deg.6.0mm.json');
lens.apertureSample = [601 601];          % Number of samples at first lens

% lens.draw; grid on; title('')

%%  Set up point, lens, film

[pt, ~, film] = ilInitPLF;
pt{1}     = [0, 0, -1e2];          % For a point that is far away
film.size = [0.5 0.5];              % A small bit of film, in millimeters
film.resolution = film.size*1e3;    % 1 micron per sample, keeps the estimate constant

%% The film is put at the focal length
camera = psfCameraC('lens',lens,'point source',pt,'film',film);

%{
% The auto focus sets the film distance to the focal length.  This puts
% objects at a distance into good focus.
camera.autofocus(550,'nm');
%}

% We set the film distance beyond the focal length, to create a pointspread
% blur for the distance point.
%  0.000 mm is the in focus plane for this distant point
%  0.050 mm blurs some
%  0.100 mm is much more 

% Set the camera to be in focus for an object at 400 mm
camera.set('film position',[0 0 lens.get('infocus distance',10000)]);

% Then we 
fprintf('Film distance:\t%f\nFocal length:\t%f\n',...
    camera.get('film distance'),lens.get('focal length'));

%% Not sure how to control the quality here

nLines = 0;  % Do not draw the rays if 0.
jitter = true;
camera.estimatePSF('jitter flag', jitter);

%% The oi illuminance level is arbitrary

% The mean illuminance is low because most of the image is black.  Even
% with a 1 lux mean, the point is very bright.
oi = camera.oiCreate('mean illuminance',1);
oiWindow(oi);
oiPlot(oi,'illuminance mesh linear');

%% Approximate the size of the point image on the sensor

psDiameter = oiPSF(oi,'diameter','units','um');  % Diameter in microns
fprintf('\nPoint spread diameter %f um\n',psDiameter);

%% Render for a sensor with big pixels

sensor = sensorCreate('MT9V024');       % This is a 6 um sensor
sensor = sensorSetSizeToFOV(sensor,2);  % Make it small
sensor = sensorCompute(sensor,oi);

% Bring up the window, with the display intensity scaled to max
sensorWindow(sensor,'scale',1);

%%


