%% Images for a typical automotive lens
%
% Also includes some autofocusing calculation
%
%

%%
ieInit

%% Read and draw

lens = lensC('filename','wide.56deg.6.0mm.json');
lens.apertureSample = [901 901];
% lens.draw; grid on; title('')

%%  Set up point, lens, film

[pt, ~, film] = ilInitPLF;
pt{1} = [0, 0,-10^6];      % Far away
film.size = [0.03 0.03];   % In millimeters

%% Not sure why this is here

% lens.bbmCreate;

%% The film is put at the focal length
camera = psfCameraC('lens',lens,'point source',pt,'film',film);
camera.get('film position')

% This blurs the image
% camera.set('film position',[0 0 10]);

% The auto focus puts it at the focal length.
% You can check this with lens.get('focal length')
camera.autofocus(500,'nm');
camera.get('film position')

%% Not sure how to control the quality here

nLines = 100;  % Do not draw the rays if 0.
jitter = true;
camera.estimatePSF(nLines,jitter);
set(gca,'xlim',[-15 6]);
%% The oi is very dim

oi = camera.oiCreate;
oi = oiSet(oi,'mean illuminance',10);

oiWindow(oi);
oiPlot(oi,'illuminance mesh linear');
% set(gca,'xlim',[20 30],'ylim',[20 30]);

%% Approximate the size of the point
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

%% The sensor really sees just a single spot
%
% One super-pixel is covered

sensor = sensorCreate('MT9V024');       % This is a 6 um sensor
sensor = sensorSetSizeToFOV(sensor,2);  % Make it small
sensor = sensorCompute(sensor,oi);
sensorWindow(sensor);

%%


