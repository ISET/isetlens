%% Render using a lens plus a microlens
%
% Dependencies:
%    ISET3d, ISETCam, JSONio
%
% Check that you have the updated docker image by running
%
%    docker pull vistalab/pbrt-v3-spectral
%
% ZL, BW SCIEN 2018
%
% See also
%   t_piIntro_*
%   isetLens repository

% Generally
% https://www.pbrt.org/fileformat-v3.html#overview
% 
% And specifically
% https://www.pbrt.org/fileformat-v3.html#cameras
%

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end
if isempty(which('RdtClient'))
    error('You must have the remote data toolbox on your path'); 
end
%% Read the pbrt files

% sceneName = 'kitchen'; sceneFileName = 'scene.pbrt';
% sceneName = 'living-room'; sceneFileName = 'scene.pbrt';
sceneName = 'ChessSet'; sceneFileName = 'ChessSet.pbrt';

% The output directory will be written here to inFolder/sceneName
inFolder = fullfile(piRootPath,'local','scenes');

% This is the PBRT scene file inside the output directory
inFile = fullfile(inFolder,sceneName,sceneFileName);

if ~exist(inFile,'file')
    % Sometimes the user runs this many times and so they already have
    % the file.  We only fetch the file if it does not exist.
    fprintf('Downloading %s from RDT',sceneName);
    dest = piPBRTFetch(sceneName,'pbrtversion',3,...
        'destinationFolder',inFolder,...
        'delete zip',true);
end

thisR  = piRead(inFile);

% We will output the calculations to a temp directory.  
outFolder = fullfile(tempdir,sceneName);
outFile   = fullfile(outFolder,[sceneName,'.pbrt']);
thisR.set('outputFile',outFile);
%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([30 20]));  % Super small for speed
thisR.set('pixel samples',1);                 % Very few rays

%% Set output file

oiName = sceneName;
outFile = fullfile(piRootPath,'local',oiName,sprintf('%s.pbrt',oiName));
thisR.set('outputFile',outFile);
outputDir = fileparts(outFile);

%% Add camera with lens

% For the dgauss lenses 22deg is the half width of the field of view

allLenses = lensList;
thisLens = 15;
lensfile =  allLenses(thisLens).name;
filmwidth  = 2;
filmheight = 2;
fprintf('Using lens: %s\n',lensfile);
combinedlens = lensfile;

%%

thisR.camera = piCameraCreate('omni','lensFile',combinedlens);

% The FOV is not used for the 'realistic' camera.
% The FOV is determined by the lens. 

% This is the size of the film/sensor in millimeters 
thisR.set('film diagonal',sqrt(filmwidth^2 + filmheight^2));

% Pick out a bit of the image to look at.  Middle dimension is up.
% Third dimension is z.  I picked a from/to that put the ruler in the
% middle.  The in focus is about the pawn or rook.
thisR.set('from',[0 0.14 -0.7]);     % Get higher and back away than default
thisR.set('to',  [0.05 -0.07 0.5]);  % Look down default compared to default

% We can use bdpt if you are using the docker with the "test" tag (see
% header). Otherwise you must use 'path'
thisR.integrator.subtype = 'path';  
thisR.sampler.subtype    = 'sobol';

% This value determines the number of ray bounces.  If the scene has
% glass or mirrors, we need to have at least 2 or more.
% thisR.set('nbounces',4); 

%% Render and display

thisR.set('aperture diameter',2);   % thisR.summarize('all');

% Focal distance from 0.1 to 10 meters.  Six samples.  The last one is
% very far and thus is really the lens focal length.
setFocusDistance = [logspace(-0.3,1.5,5),100];
lensFilm = zeros(size(setFocusDistance));
infocusDistance = zeros(size(setFocusDistance));

for ii=1:numel(setFocusDistance)
    
    thisR.set('focus distance',setFocusDistance(ii));
    
    % Change this for depth of field effects.
    piWrite(thisR,'creatematerials',true);
    
    % PBRT estimates the distance.  It is not perfectly aligned to the depth
    % map, but it is close.
    
    [oi, result] = piRender(thisR,'render type','depth');
    
    % Parse the result for the lens to film distance and the in-focus
    % distance in the scene.
    [lensFilm(ii), infocusDistance(ii)] = piRenderResult(result);
end

ieNewGraphWin;
semilogx(infocusDistance,lensFilm,'ok--');
xlabel('In focus distance (m)');
ylabel('Film distance (m)');
grid on;

(infocusDistance - setFocusDistance) ./ setFocusDistance

%% END