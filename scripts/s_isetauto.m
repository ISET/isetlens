%% Images for a typical automotive lens
%
% Also includes some autofocusing calculation
%
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
pt{1}     = [0, 0, -10^6];          % For a point that is far away
film.size = [0.5 0.5];              % A small bit of film, in millimeters
film.resolution = film.size*1e3;    % 1 micron per sample, keeps the estimate constant

%% The film is put at the focal length
camera = psfCameraC('lens',lens,'point source',pt,'film',film);

% The auto focus puts the film at the focal length.
%{
camera.autofocus(550,'nm');
%}

% {
% You could set the value differently, if you like.
% 0  microns is the in focus plane for this distant point
% 50 microns blurs a bunch (0.05)
% 100 microns is much more than a bunch (0.10)
focalLength = lens.get('focal length');
camera.set('film position',[0 0 focalLength + 0.1]);
%}

fprintf('Film distance:\t%f\nFocal length:\t%f\n',...
    camera.get('film distance'),lens.get('focal length'));

%% Not sure how to control the quality here

nLines = 0;  % Do not draw the rays if 0.
jitter = true;
camera.estimatePSF(nLines,jitter);

%% The oi illuminance level is arbitrary

oi = camera.oiCreate('mean illuminance',5);
oiWindow(oi);

oiPlot(oi,'illuminance mesh linear');

%% Now ray trace just to have a look

% These are for a normalized position on the first aperture, 
% between [-1 1].  The function scales them to the position of the
% first aperture diameter.
nLines = 20;
jitterFlag = false;
yFan(1) =  0; yFan(3) = 0;
yFan(2) = -1; yFan(4) = 1;

% Re-write this as a new method, say showRayTrace
% Then figure out how to make it nicer by choosing the rays and
% following them more accurately.
camera.estimatePSF(nLines,jitterFlag, yFan);
xFilm     = camera.get('film distance');
thickness = lens.get('lens thickness');
height    = lens.get('lens height');

set(gca,'xlim',[-2*thickness xFilm+1]); 
set(gca,'ylim',[-1*height,height])
grid on

%% Approximate the size of the point image on the sensor

% This is the illuminance image
ill = oiGet(oi,'illuminance');

% Find all the points that are at least 10 percent the amplitude of the
% peak illuminance
mx = max(ill(:));
ill(ill < 0.1*mx)  = 0;
ill(ill >= 0.1*mx) = 1;

% Find the area of those points
sampleSpacing = oiGet(oi,'sample spacing','um');
psArea = sum(ill(:))*sampleSpacing(1);   % This is the pointspread area in meters

% If they are roughly circular, then we can estimate the diameter this way
%
% circleArea = pi*radiusSquared
%
% So, putting psArea into circleArea the diameter would be
%
psDiameter = 2*(psArea/pi)^0.5;   % Diameter in microns
fprintf('\nPoint spread diameter %f um\n',psDiameter);

%% Render for a sensor with big pixels

sensor = sensorCreate('MT9V024');       % This is a 6 um sensor
sensor = sensorSetSizeToFOV(sensor,2);  % Make it small
sensor = sensorCompute(sensor,oi);

% Bring up the window, with the display intensity scaled to max
sensorWindow(sensor,'scale',1);

%%


