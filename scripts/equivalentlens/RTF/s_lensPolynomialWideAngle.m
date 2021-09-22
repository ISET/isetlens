%%
ieInit;

%%
lensName = 'wide.56deg.3.0mm.json'
%% Generate ray pairs
maxRadius = 6;
minRadius = 0;
offset=0.1;

[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 80,...
    'nAzSamp',250,'nElSamp',250,...
    'reverse', true,...
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset));


%% Poly fit
polyDeg = 5

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

pupilPos=pupilPos - planes.input;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'pupil radii', pupilRadii,'lensthickness',lensThickness,'planeOffset',offset);
