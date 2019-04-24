%% Images for ISETAuto ICCV lens
%

%% Read and draw

lens = lensC('filename','wide.56deg.6.0mm.dat');
lens.draw;
grid on
title('')

%%  Set up point, lens, film

[pt, ~, film] = ilInitPLF;
pt{1} = [0, 0,-500];      % Pretty far away
film.size = [0.05 0.05];  % In millimeters

%% A sphere and a planar surface for the diffraction

lens.bbmCreate;

%%
camera = psfCameraC('lens',lens,'point source',pt,'film',film);
camera.get('film position')
camera.autofocus(500,'nm');
camera.get('film position')

%%
nLines = 0;  % Do not draw the rays
jitter = true;
camera.estimatePSF(nLines,jitter);
set(gca,'xlim',[-15 6]);
%%
oi = camera.oiCreate;
% ieAddObject(oi); oiWindow;
oiPlot(oi,'illuminance mesh linear');
% set(gca,'xlim',[20 30],'ylim',[20 30]);

%% 
oiWindow(oi);

%%

sensor = sensorCreate('MT9V024');
sensorWindow(sensor);



