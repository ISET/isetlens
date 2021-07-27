function jsonPath = spectralJsonGenerate(fPolyPath, varargin)
% Write json files for polynomial terms for multiple wavelengths.
%
% Json file structure:
% description:
% name:
% % x, y, u, v, w. Using x as an example, same to y, u, v, w
% p.description = 'test';
% p.name = 'polynomial';
% p.polynomials: cell array
% p.polynomials{i}.poly.outx.termr = [1 2 3;4 5 6];
% p.polynomials{i}.poly.outx.termu
% p.polynomials{i}.poly.outx.termv
% % p.poly.outx.termw (not used for now)
% p.poly.outx.coeff

% Example:
%{
fname = fullfile(ilensRootPath, 'local', 'poly.mat');
jPath = polyJsonGenerate(fname);
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('fPolyPath', @(x)(iscell(x)) || exist(x, 'file'));
p.addParameter('planes', struct(), @isstruct);
p.addParameter('planeoffset', [], @isnumeric);       
p.addParameter('lensthickness',[], @isnumeric);

p.addParameter('description', 'equivalent lens poly', @ischar);
p.addParameter('name', 'polynomial', @ischar);
p.addParameter('outpath', fullfile(ilensRootPath, 'local', 'polyjson.json'), ...
                            @ischar);
p.addParameter('polynomials', []);
                  


p.parse(fPolyPath, varargin{:});
description = p.Results.description;
name = p.Results.name;
jsonPath = p.Results.outpath;
planes = p.Results.planes;
planeOffset= p.Results.planeoffset;
polynomials = p.Results.polynomials;
lensThickness= p.Results.lensthickness;


%% Load polynomial term file
if ischar(fPolyPath)
    polyModel = cell(1, 5);
    load(fPolyPath);
elseif iscell(fPolyPath)
    polyModel = fPolyPath;
end
js.description = description;
js.name = name;
if ~isempty(planes)
    js.thickness = lensThickness
    js.planeoffset= planeOffset;
else
    warning('No plane info!')
    js.thickness = 0;
end
% 

%%
for p =1:numel(polynomials)
    % x, y, u, v, w
    outName = ['x', 'y', 'u', 'v'];
    termName = ['r', 'u', 'v'];
    
    % Calculated and add pupil information
    polynomials{p}.pupil_distances=polynomials{p}.circlePlaneZ./(1-polynomials{p}.circleSensitivities);
    polynomials{p}.pupilpos = polynomials{p}.pupil_distances;
    polynomials{p}.pupilradii = abs(polynomials{p}.pupil_distances./polynomials{p}.circlePlaneZ).*polynomials{p}.circleRadii;
    
    
    for ii=1:4
        
        
        thisOut.outputname = strcat('out', outName(ii));
        
        
        

        
        % coefficients
        thisOut.coeff = polynomials{p}.polyModel{ii}.Coefficients;
        
  
        % term
        for jj=1:3
            thisTermName = strcat('term', termName(jj));
            thisOut.(thisTermName) = polynomials{p}.polyModel{ii}.ModelTerms(:, jj)';
        end
   
        polynomials{p}.poly(ii) = thisOut;
    end
    % Remove unneeded fields
    polynomials{p}=rmfield(polynomials{p},'polyModel');
    
end

js.polynomials = polynomials;


%% Write json file
opts.indent = ' ';
jsonwrite(jsonPath, js, opts);


end