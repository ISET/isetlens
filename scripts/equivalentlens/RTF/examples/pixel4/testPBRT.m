%% Pixel 4 Front camera PBRT test

ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


thisR=piRecipeDefault('scene','ChessSet')
thisR=piRecipeDefault('scene','flatSurface'); thisR.set('light','#1_Light_type:point','type','distant')
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

cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-frontcamera-filmtoscene-raytransfer.json')
cameraRTF.filmdistance.value=filmdistance_mm/1000;


thisR.set('pixel samples',30)


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

exitpupil=2.4planeOffsetOutput = (Float) j[""] * 0.001f; 
plot(x,cosd(atand(x/exitpupil)).^4)
xlabel('Off axis distance on sensor (mm)')
legend('Simulated vignetting profile','Cosine fourth ')





%% Manual loading of dat file




path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront.dat'


oi = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oi.name ='lens'

oiWindow(oi);
oiSet(oi,'gamma',0.8)
Dlens=oi.data.photons;
pause(1);
ax = gca;
exportgraphics(gca,'pixel4a_front_relativeillumination.png')
