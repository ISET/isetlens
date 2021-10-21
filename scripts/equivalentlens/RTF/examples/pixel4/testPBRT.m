%% Pixel 4 Front camera PBRT test

ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces


thisR=piRecipeDefault('scene','SimpleScene')

thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';


%% Set camera position


%filmZPos_m=-1.5;
%thisR.lookAt.from(3)=filmZPos_m;
%distanceFromFilm_m=1.469+50/1000




%%

%% Add a lens and render.

cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-frontcamera-filmtoscene-raytransfer.json')
cameraRTF.filmdistance.value=0.037959;

thisR.set('pixel samples',50)


thisR.set('film diagonal',5,'mm');
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
 
 
 
 %% openfile

%% Lens example



path='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/pixelfront.dat'


oiPoly = piDat2ISET(path, 'wave', 400:10:700, 'recipe', thisR);
oiPoly.name ='lens'

oiWindow(oiPoly);
oiSet(oiPoly,'gamma',0.5)
Dlens=oiPoly.data.photons;
pause(1);
ax = gca;


 