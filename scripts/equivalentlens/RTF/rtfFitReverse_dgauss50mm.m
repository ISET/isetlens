%%
ieInit;

%%
lensName = 'dgauss.22deg.50.0mm_aperture6.0.json';
reverse = true; 
%% Generate ray pairs
maxRadius = 15;
minRadius = 0;
offset=0.01;

[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', reverse,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset));


%% Save dataset for google
clear inputs
inputs(:,2) = iRays(:,1);
inputs(:,1) = 0;
inputs(:,3) = -offset;
inputs(:,4) = iRays(:,2); % dx
inputs(:,5) = iRays(:,3); % dy
inputs(:,6) = sqrt(1-iRays(:,2).^2-iRays(:,3).^2);

% csvwrite('inputrays-dgauss.csv',inputs)
% 
% outputs = oRays;
% csvwrite('outputrays-dgauss.csv',outputs)
% 


%% Polynomial fit
polyDeg = 8

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[    7.5  125.3000   9.5]
circleSensitivities =[    0.9281 -11.5487   -0.0152]
circlePlaneZ =   17

% Four circles

circleRadii =[  7.2291  125.3000    9.5000    8.2000]
circleSensitivities =[    0.7991  -11.5487   -0.0152    1.0060]
circlePlaneZ =[    17]

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(iRays, oRays,'planes', planes,...
    'visualize', true, 'fpath', fpath,...
    'maxdegree', polyDeg,...
    'pupil pos', pupilPos,...
    'plane offset',offset,...
    'pupil radii', pupilRadii,...
    'circle radii',circleRadii,...
    'circle sensitivities',circleSensitivities,...
    'circle plane z',circlePlaneZ,...
    'lensthickness',lensThickness);

%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength


fit{w}.wavelength_nm = 550;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivities;
fit{w}.circlePlaneZ = circlePlaneZ;
fit{w}.diaphragmIndex=diaphragmIndex;
fit{w}.diaphragmToCircleRadius=(2*circleRadii(diaphragmIndex+1))/0.6;
fit{w}.planes = planes;

%% Generate Spectral JSON file
fpath = fullfile(ilensRootPath, 'local',[lensName '-raytransfer.json']);
lens  = lensC('file',lensName);
lensinfo.name=lensName;
lensinfo.description=lens.description;
lensinfo.apertureDiameter=lens.apertureMiddleD;
lensinfo.focallength=lens.focalLength;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness', lensThickness, 'planes', planes,'planeOffset',offset, 'outpath', fpath,...
        'polynomials',fit);

end

%% For use in matlab
save('rtf-dgauss.22deg.50mm-reverse.mat','fit')
