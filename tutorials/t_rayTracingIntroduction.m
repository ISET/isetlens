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
if piCamBio
    error('Use ISETBio, not ISETCam');
end
if ~piDockerExists, piDockerConfig; end

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
thisSE = sceneEye('letters at depth','eye model','arizona');

% The units are in meters
toA = [-0.0486     0.0100     0.5556];
toB = [  0         0.0100     0.8333];
toC = [ 0.1458     0.0100     1.6667];

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
thisSE

%% Set the scene rendering parameters
% Let's render a quick, low quality retinal image first. Let's name this

% Position the eye off to the side so we can see the 3D easily
from = [0.25,0.3,-0.2];
thisSE.set('from',from);

% Look at the position with the 'B'.  The values for each of the letters
% are included above.
thisSE.set('to',toB);

% Have a quick check with the pinhole
thisSE.set('use pinhole',true);

% Given the distance from the scene, this FOV captures everything we want
thisSE.set('fov',30);             % Degrees

thisSE.recipe.set('render type', {'radiance','depth'});

%% Render the scene with the GPU
thisDockerGPU = dockerWrapper;
thisSE.piWRS('docker wrapper',thisDockerGPU);
thisSE.summary;

%% Step through accommodation

% Now let's render a series of retinal images at different accommodations.
% This section renders roughly in 30 sec on a machine with 8 cores. 

thisSE.set('use pinhole',false);
accomm = [1 5 10]; % in diopters (1 meter, 0.2 meters, 0.1 meter)

thisDocker = dockerWrapper.humanEyeDocker;

opticalImages = cell(length(accomm),1);
for ii = 1:length(accomm)
    
    thisSE.set('accommodation',accomm(ii));
    thisSE.name = sprintf('accom_%0.2fdpt',thisSE.get('accommodation'));
    
    % When we change accommodation the lens geometry and dispersion curves
    % of the eye will change. ISETBIO automatically generates these new
    % files at rendering time and will output them in your working
    % directory. In general, you may want to periodically clear your
    % working directory to avoid a build up of files.
    oi = thisSE.piWRS('docker wrapper',thisDocker);
    % oi = piAIdenoise(oi);
    % oiWindow(oi);

    opticalImages{ii} = oi;
end

%%



