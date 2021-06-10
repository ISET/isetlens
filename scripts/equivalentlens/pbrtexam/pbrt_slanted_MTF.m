%% PART1: Normal rendering from ISET3d
clear;
ieInit;
if ~piDockerExists, piDockerConfig; end

% This section has to be run at least once in order to use the second part
% of code below
thisR = piRecipeDefault('scene name', 'simple scene');
lensfile = 'lenses/dgauss.22deg.3.0mm.json';

fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('film distance', 0.002167);
thisR.set('film diagonal', 5); % mm
%%

% OPTIONAL: Only useful for actual normal PBRTrendering
% piWrite(thisR);
% [oi, result] = piRender(thisR, 'render type', 'radiance');
% oiWindow(oi);




%% Get all OI's of interest
paths={};
names = {'lens','lens defocus','Ray Transfer Function','Ray Transfer Function defocus'}
colors = {'r','r','k','k'};
style = {'-','-.','-','-.'};
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens.dat'
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/lens-further.dat'
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox.dat'
paths{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/slantedBar/renderings/blackbox-further.dat'



oiList={};
for i = 1:numel(paths)
    path=paths{i};
    oiList{i} = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
    oiList{i}.name =names{i};
end






%% Image through a sensor


% The pixel size is not the limit!
sensor = sensorCreate;
%sensor = sensorSet(sensor,'pixel size same fill factor',1.2e-6);
% How to set correct pixel size given PBRT recipe?
sensor = sensorSet(sensor,'size',[256 256]);
%sensor = sensorSet(sensor,'fov',5,oi); % what FOV should I use?


% These positions give numerically stable results
positions =  [ 35    15   206   228]

ip = ipCreate;

%% MTF loop

% Compare visually MTF's

for i=1:numel(oiList)
    sensor = sensorCompute(sensor,oiList{i});
    ip = ipCompute(ip,sensor);
    MTF{i} = ieISO12233(ip,sensor,'all',positions);
    close(gcf)
end
figure; hold on;
clear h
for i=1:numel(oiList)
    h(i)=plot(MTF{i}.freq,MTF{i}.mtf(:,1),'color',colors{i},'linestyle',style{i}); hold on;
end
legend(h,names);
ylim([0 1])
xlim([0 100])
title('MTF')
xlabel('Spatial frequency on the sensor (cy/mm)')
saveas(gcf,'./fig/mtf-slanted.pdf');


%%

