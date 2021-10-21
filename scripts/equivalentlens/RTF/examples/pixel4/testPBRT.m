%%  s_goMTF3D
%
% Questions:
%   * I am unsure whether the focal distance is in z or in distance from
%   the camera.  So if the camera is at 0, these are the same.  But if the
%   camera is at -0.5, these are not the same.
%
%  * There is trouble scaling the object size.  When the number gets small,
%  the object disappears.  This may be some numerical issue reading the
%  scale factor in the pbrt geometry file?
%

%%1+1

ieInit
if ~piDockerExists, piDockerConfig; end

%% The chess set with pieces



%% Set camera position


filmZPos_m=-1.5;
chessR.lookAt.from(3)=filmZPos_m;
distanceFromFilm_m=1.469+50/1000



% Render the scene
thisDocker = 'vistalab/pbrt-v3-spectral:raytransfer-spectral';


%%

%% Add a lens and render.

cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-frontcamera-filmtoscene-raytransfer.json')

cameraRTF.filmdistance.value=0.037959;
cameraRTF.aperturediameter.value=12
cameraRTF.aperturediameter.type='float'

chessR.set('pixel samples',1500)


thisR.set('film diagonal',20,'mm');
thisR.set('film resolution',[2000 2000])
    

chessR.integrator.subtype='path'

chessR.integrator.numCABands.type = 'integer';
chessR.integrator.numCABands.value =1


%% Change the focal distance

% This series sets the focal distance and leaves the slanted bar in place
% at 2.3m from the camera
%chessR.set('focal distance',0.2);   % Original distance z value of the slanted bar
% Omni
chessR.set('camera',cameraOmni);
oiOmni = piWRS(chessR,'render type','radiance','dockerimagename',thisDocker);


% 
% % RTF
chessR.set('camera',cameraRTF);
oiRTF = piWRS(chessR,'render type','radiance','dockerimagename',thisDocker);
 
 
 