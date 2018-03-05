%% t_rayTracingIntroduction.m
%
% This tutorial is an introduction to modeling the optics of the eye using
% ray-tracing in ISETBIO. 
% 
% To begin, you must have the Github repo pbrt2ISET on your MATLAB path.
% You can find it here: https://github.com/RenderToolbox/pbrt2ISET
% 
% You must also have docker installed and running on your machine. You can
% find general instructions on docker here: https://www.docker.com/
%
% In ISETBIO we can load up a virtual, 3D scene and render a retinal image
% by tracing the light passing from the scene through the optics of the
% human eye onto the retina. We use a modified version of PBRT (Physically
% Based Ray Tracer) to do this calculation. Our version of PBRT, which we
% call pbrt-v2-spectral, has the ability to render through the optics of
% the human eye and to trace rays spectrally. Pbrt-v2-spectral has also
% been dockerized so you do not need to compile or install the source code
% in order to render images. Instead, you must have docker installed and
% running on your computer and the scenes should automatically render
% through the docker container.
% 
% You can find the source code for pbrt-v2-spectral here:
% https://github.com/scienstanford/pbrt-v2-spectral
%
% Depends on: pbrt2ISET, ISETBIO, Docker
%
% TL ISETBIO Team, 2017
    

%% Initialize ISETBIO
ieInit;

%% Render a fast, low quality retinal image
% We have several scenes that have been modified and verified to work with
% ISETBIO and pbrt2ISET.
% These scenes include:
% 1. numbersAtDepth
% 2. texturedPlane
% 3. chessSet
% 4. slantedBar
% You can find a description and sample images of these scenes on the wiki
% page (https://github.com/isetbio/isetbio/wiki/3D-Image-Formation). 

% You can select a scene as follows:
myScene = sceneEye('numbersAtDepth');

% ISETBIO requires a "working directory." If one is not specified when
% creating a scene, the default is in isetbioRootPath/local. All data
% needed to render a specific scene will be copied to the working folder
% upon creation of the scene. All new data generated within ISETBIO will
% also be placed in the working directory. This folder will eventually be
% mounted onto the docker container to be rendered. You can specify a
% specific working folder as follows: 
% myScene = sceneEye('scene','numbersAtDepth','workingDirectory',[path to
% desired directory]);

% The sceneEye object contains information of the 3D scene as well as the
% parameters of the eye optics included in the raytracing. You can see a
% list of the parameters available in the object structure:
myScene

% Let's render a quick, low quality retinal image first. Let's name this
% render fastExample.
myScene.name = 'fastExample';

% Let's change the number of rays to render with. 
myScene.numRays = 64;

% Let's also change the resolution of the render. The retinal image is
% always square, so there is only one parameter for resolution.
myScene.resolution = 128;

% Now let's render. This may take a few seconds, depending on the number of
% cores on your machine. On a machine with 2 cores it takes ~15 seconds. 
oi = myScene.render;

% Now we have an optical image that we can use with the rest of ISETBIO. We
% can take a look at what it looks like right now:
ieAddObject(oi);
oiWindow;


%% Step through accommodation
% Now let's render a series of retinal images at different accommodations.
% This section renders roughly in 30 sec on a machine with 8 cores. 

accomm = [1 5 10]; % in diopters
opticalImages = cell(length(accomm),1);
for ii = 1:length(accomm)
    
    myScene.accommodation = accomm(ii);
    myScene.name = sprintf('accom_%0.2fdpt',myScene.accommodation);
    
    % When we change accommodation the lens geometry and dispersion curves
    % of the eye will change. ISETBIO automatically generates these new
    % files at rendering time and will output them in your working
    % directory. In general, you may want to periodically clear your
    % working directory to avoid a build up of files.
    oi = myScene.render;
    ieAddObject(oi);
    opticalImages{ii} = oi;
end

oiWindow;




