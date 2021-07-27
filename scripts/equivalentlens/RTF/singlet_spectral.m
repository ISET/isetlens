%%
clear;
ieInit;

%% Crown glass 

n= @(l) sqrt(2.24187488 -0.00891932146*l.^2 +0.0126251741./l.^2 -0.000298598739./l.^4+5.95648836e-5*1./l.^6-2.58633231E-6*1./l.^8);

wavelengths_micron=linspace(0.4,0.9,10);
lensName = '2el.XXdeg.6.0mm.dat'

lens=lensC('file',lensName)

for w = 1:numel(wavelengths_micron)
    wavelength=wavelengths_micron(w);
    % Update all refractive indices
    for i=1:numel(lens.surfaceArray)
        if(lens.surfaceArray(i).n>1.04)
            lens.surfaceArray(i).n = n(wavelength);
        end
    end
    lens.fileWrite('temporarylens.json')




%% Generate ray pairs
maxRadius = 0.6;
minRadius = 0;
offset=0.1;

[iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs('temporarylens.json', 'visualize', false,...
    'n radius samp', 50, 'elevation max', 40,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', true,...
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

outputs = oRays;




%% Polynomial fit
polyDeg = 5

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

circleRadii =[    1.2700    1.3500   10.0000]
circleSensitivities =[   -1.6628    0.8298  -15.6821]
circlePlaneZ = 3;

fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');

fpath = fullfile(['polyjson_test' num2str(wavelength) '.json']);
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


close all;

fit{w}=struct;
fit{w}.wavelength_nm = wavelengths_micron(w)*1e3;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivities;
fit{w}.circlePlaneZ = circlePlaneZ;



end

%% Generate Spectral JSON file
fpath = fullfile(ilensRootPath, 'local',[lensName '-raytransfer.json']);
if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness', lensThickness, 'planes', planes,'planeOffset',offset, 'outpath', fpath,...
        'polynomials',fit);

end

