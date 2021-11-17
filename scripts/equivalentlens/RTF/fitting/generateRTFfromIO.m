function [rtf] =generateRTFfromIO(lensName,inputrays,outputrays,offsetinput,offsetoutput,lensThickness_mm,varargin)
%generateRTFfromIO Give the inputoutput information, generate a full RTF
%function, including vignetting and ouput the JSON file.
%%%%%%%%%%%%%%%%%%%% AUTOMATIC BELOW %%%%%%%%%%%%%%%%%%%%%%% 
%% Fit Pass/NoPass function
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lensname', @ischar);
p.addRequired('inputrays', @isnumeric);
p.addRequired('outputrays', @isnumeric);
p.addRequired('offsetinput', @isnumeric);      
p.addRequired('offsetoutput', @isnumeric);  
p.addRequired('lensthickness', @isnumeric);  
p.addParameter('polynomialdegree', 4, @isnumeric);
p.addParameter('visualize', false, @islogical);
p.addParameter('fpath', '', @ischar);
p.addParameter('sparsitytolerance', 0, @ischar);      
p.addParameter('outputdir',  './',@ischar);      
p.addParameter('lensdescription',  '',@ischar);      
    
p.parse(lensName,inputrays,outputrays,offsetinput,offsetoutput,lensThickness_mm,varargin{:});


polyDegree = p.Results.polynomialdegree;
visualize = p.Results.visualize;
sparsitytolerance= p.Results.sparsitytolerance;
fpath= p.Results.fpath;
outputdir= p.Results.outputdir;
lensdescription= p.Results.lensdescription;

%% Prepare distances for inputoutputplane Z position calculation
% By convention z=0 at the output side vertex of the lens
frontvertex_z=-lensThickness_mm;  % By convention
planes.input=frontvertex_z-offsetinput;
planes.output=offsetoutput;


%% Preprocess input output rays

% Only keep the rays that passed the lens (output ray is not NAN)
passedRays=~isnan(outputrays(:,1));
inputrays=inputrays(passedRays,:);
outputrays=outputrays(passedRays,:);

%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(inputrays,planes.input);
[radii,centers] = vignettingFitEllipses(pupilShapes);
  
if(visualize)
    figure;
    subplot(211)
    plot(positions,radii','.-','markersize',10,'linewidth',2)
    title('Ellipse Radii')
    legend('X','Y')
    subplot(212)
    plot(positions,centers','.-','markersize',10,'linewidth',2)
    title('Ellipse Centers')
    legend('X','Y')
end


%% Polynomial fit
fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel] = lensPolyFit(inputrays, outputrays,...
    'visualize', visualize,...
    'maxdegree', polyDegree,...
   'sparsitytolerance',sparsitytolerance);

%% Add meta data to polymodel sepearte struct
w=1 % only one wavelength
rtf{w}.wavelength_nm = 550;
rtf{w}.polyModel = polyModel;
rtf{w}.passnopass.method='minimalellipse'
rtf{w}.passnopass.positions=positions;
rtf{w}.passnopass.radiiX=radii(1,:);
rtf{w}.passnopass.radiiY=radii(2,:);
rtf{w}.passnopass.centersX=centers(1,:);
rtf{w}.passnopass.centersY=centers(2,:);
rtf{w}.passnopass.intersectPlaneDistance=intersectionplane;

%% Generate Spectral JSON file


fpath = fullfile(outputdir,[lensName '-raytransfer.json']);

if ~isempty(fpath)
    jsonPath = spectralJsonGenerate(polyModel, 'lensthickness',...
        lensThickness_mm, 'planes',...
        planes,'planeOffset input',offsetinput,...
        'plane offset output',offsetoutput,...
        'outpath', fpath,...
        'polynomials',rtf,'name',lensName,'description',lensdescription);

end



end
