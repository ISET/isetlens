%% Pixel 4 Front camera PBRT test
clear
ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


thisR=piRecipeDefault('scene','ChessSet')
%thisR=piRecipeDefault('scene','flatSurface'); thisR.set('light','#1_Light_type:point','type','distant')
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';


%% Set camera position


%filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
%distanceFromFilm_m=1.469+50/1000\

% Set camera and camera position
filmZPos_m           = -0.3;
thisR.lookAt.from(3)= filmZPos_m;





%% FIlm distance as provided by Google

filmdistance_mm=0.3616965582;

%% Add a lens and render.

cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-frontcamera-filmtoscene-raytransfer.json');
thisR.set('pixel samples',500); 


cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a_linear-frontcamera-filmtoscene-raytransfer.json')
thisR.set('pixel samples',100)
cameraRTF.filmdistance.value=filmdistance_mm/1000;





thisR.set('film diagonal',sqrt(2)*5,'mm');
thisR.set('film resolution',[300 300])
    

thisR.integrator.subtype='path'

thisR.integrator.numCABands.type = 'integer';
thisR.integrator.numCABands.value =1




%% Render

% % RTF
thisR.set('camera',cameraRTF);
piWrite(thisR);
return

%%

[oi,result] = piRender(thisR,'render type','radiance','dockerimagename',thisDocker);
 
 %%
oiWindow(oi)
 
 


%%
exportgraphics(gca,'chesset_pixel4a_front.png')

return
%% Vigne

figure(10);clf;hold on
profile=oi.data.photons(end/2,:,1);
profile=profile/max(profile);
x=linspace(-2.5,2.5,numel(profile)); 
plot(x,profile); 

exitpupil=2.4
plot(x,cosd(atand(x/exitpupil)).^4)
xlabel('Off axis distance on sensor (mm)')
legend('Simulated vignetting profile','Cosine fourth ')





%% Manual loading of dat file


label={};path={};

label{end+1}='linear';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront_linear.dat';
label{end+1}='nonlinearlargerpupil';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront_nonlinearlarge.dat';

for p=1:numel(path)
oi{p} = piDat2ISET(path{p}, 'wave', 400:10:700, 'recipe', thisR);
oi{p}.name =label{p}

oiWindow(oi{p});
oiSet(oi{p},'gamma',0.8)
data{p}=oi{p}.data.photons;

ax = gca;
end



return
%% Vignetting plot

figure(10);clf;hold on
for p=1:numel(path)
profile=oi{p}.data.photons(end/2,:,1);
profile=profile/max(profile);
x=linspace(-2.5,2.5,numel(profile)); 
plot(x,profile); 
end

exitpupil=2.2
plot(x,cosd(atand(x/exitpupil)).^4)
legend('linear','with pupilwalking','cosine fourth')

