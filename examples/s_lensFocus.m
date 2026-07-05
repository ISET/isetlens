%% Render using a lens plus a microlens
%
% Dependencies:
%    ISET3d, ISETCam, Docker/PBRT
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

%% Read the pbrt files

sceneName = 'chessSet';
thisR = piRecipeDefault('scene name',sceneName);
thisR.set('render type',{'radiance','depth'});
thisR.set('skymap','room.exr');

%% Set render quality

% Set resolution for speed or quality.
thisR.set('film resolution',round([30 20]));  % Super small for speed
thisR.set('pixel samples',1);                 % Very few rays

%% Add camera with lens

% For the dgauss lenses 22deg is the half width of the field of view

lensfile = 'dgauss.22deg.3.0mm.json';
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

% Focal distance from 1 to 30 meters.  The last one is very far and thus is
% really the lens focal length.
setFocusDistance = [logspace(0,1.5,2),100];
lensFilm = zeros(size(setFocusDistance));
infocusDistance = zeros(size(setFocusDistance));

for ii=1:numel(setFocusDistance)
    
    thisR.set('focus distance',setFocusDistance(ii));
    
    % PBRT estimates the distance.  It is not perfectly aligned to the depth
    % map, but it is close.
    [~, result] = piWRS(thisR, ...
        'show',false, ...
        'render type',{'radiance','depth'}, ...
        'name',sprintf('%s focus %.2f m',sceneName,setFocusDistance(ii)));
    
    % Older PBRT output included parseable focus diagnostics.  PBRT v4 may
    % omit those strings, so use the recipe getters as the stable path.
    if (ischar(result) || isstring(result)) && ...
            contains(result,'film to back of lens:') && ...
            contains(result,'Focus distance in scene: ')
        [lensFilm(ii), infocusDistance(ii)] = piRenderResult(result);
    else
        lensFilm(ii) = thisR.get('film distance','m');
        infocusDistance(ii) = thisR.get('focus distance','m');
    end
end

ieFigure;
semilogx(infocusDistance,lensFilm,'ok--');
xlabel('In focus distance (m)');
ylabel('Film distance (m)');
grid on;

(infocusDistance - setFocusDistance) ./ setFocusDistance

%% END
