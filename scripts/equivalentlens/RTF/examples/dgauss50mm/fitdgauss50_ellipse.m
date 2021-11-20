clear; close all;


%% Lens name and propertievs
lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';

reverse = true; 
%% Generate ray pairs
maxRadius = 20;
minRadius = 0;
offset=0.1;
offset_sensorside=offset;
offset_objectside=offset; %%mm


[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset_objectside));

%% RTF generation options
polyDeg = 5
outputDir = fullfile(piRootPath, 'data/lens/');
outputDir='./'
visualize=true;

%% generateRTF
rtf=generateRTFfromIO(lensName,iRays,oRays,offset_sensorside,offset_objectside,lensThickness,'outputdir',outputDir,'visualize',visualize,'polynomialdegree',polyDeg)
