clear; close all;



lensName='pxel4a-frontcamera'


offset=0.1;% mm

%Actual Z positions of the planes


thickness_filter=0.2616965582;
thickness_blackboxlens=3.0333179923;
lensThickness=thickness_filter+thickness_blackboxlens;
frontvertex_z=-(thickness_filter+thickness_blackboxlens)
planes.input=frontvertex_z-offset;
planes.output=offset;





%% Get ZEMAX rays
X=dlmread('Gout-P4Fa_20111018.txt','\s',1);


Xnonan=X(~isnan(X(:,1)),:);





iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);






%% Polynomial fit
polyDeg = 6

% Pupils for Double gaussian only. (At this moment estimating this takes a long time get
% high quality)

diaphragmIndex= 0; % which of the circles belongs to the diaphragm; (for C++ starting at zero)
circleRadii =[    7.5  125.3000   9.5]
circleSensitivities =[    0.9281 -11.5487   -0.0152]
circlePlaneZ =   2.3
pupilPos=[];
pupilRadii=[];


sparsitytolerance = 1e-4;

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
    'lensthickness',lensThickness,...
    'sparsitytolerance',sparsitytolerance);

%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength


apertureRadius_mm=1 %UNKONWN

fit{w}.wavelength_nm = 550;
fit{w}.polyModel = polyModel;
fit{w}.circleRadii = circleRadii;
fit{w}.circleSensitivities = circleSensitivities;
fit{w}.circlePlaneZ = circlePlaneZ;
fit{w}.diaphragmIndex=1;
fit{w}.diaphragmToCircleRadius=1
fit{w}.planes = planes;


%% Generate Spectral JSON file
fpath = fullfile(piRootPath, 'data/lens/',[lensName '-filmtoscene-raytransfer.json']);

lensinfo.name=lensName;
lensinfo.description='Pixel 4A front lens RTF'
lensinfo.apertureDiameter=2.8
lensinfo.focallength=0;

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness', lensThickness, 'planes', planes,'planeOffset',offset, 'outpath', fpath,...
        'polynomials',fit);

end