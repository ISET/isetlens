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

% This just loads the scene.
load('ChessSetPieces-recipe','thisR');
chessR = thisR;

% The EIA chart
sbar = piAssetLoad('slantedbar');


% Adjust the input slot in the recipe for the local user
[~,n,e] = fileparts(chessR.get('input file'));
inFile = which([n,e]);
if isempty(inFile), error('Cannot find the PBRT input file %s\n',chessR.inputFile); end
chessR.set('input file',inFile);

% Adjust the input slot in the recipe for the local user
[p,n,e] = fileparts(chessR.get('output file'));
temp=split(p,'/');
outFile=fullfile(piRootPath,'local',temp{end});
chessR.set('output file',outFile);


%% Set camera position


filmZPos_m=-1.5;
chessR.lookAt.from(3)=filmZPos_m;
distanceFromFilm_m=1.469+50/1000

%% Merge chart and chessset
piRecipeMerge(chessR,sbar.thisR,'node name',sbar.mergeNode);

% Position and scale the chart
piAssetSet(chessR,sbar.mergeNode,'translate',[0.1 0.15 distanceFromFilm_m+filmZPos_m]);
thisScale = chessR.get('asset',sbar.mergeNode,'scale');

piAssetSet(chessR,sbar.mergeNode,'scale',thisScale.*[0.1 0.1 0.01]);  % scale should always do this
%initialScale = chessR.get('asset',sbar.mergeNode,'scale');

   
%piAssetSet(thisR,sbar.mergeNode,'translate',[0 0 800]);

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
 
 
 