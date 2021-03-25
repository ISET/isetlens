function jsonPath = polyJsonGenerate(fPolyPath, varargin)
% Write json files for polynomial terms
%
% Json file structure:
% description:
% name:
% % x, y, u, v, w. Using x as an example, same to y, u, v, w
% p.description = 'test';
% p.name = 'polynomial';
% p.poly.outx.termr = [1 2 3;4 5 6];
% p.poly.outx.termu
% p.poly.outx.termv
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
p.addRequired('fPolyPath', @(x)exist(x, 'file'));
p.addParameter('description', 'equivalent lens poly', @ischar);
p.addParameter('name', 'polynomial', @ischar);
p.addParameter('outpath', fullfile(ilensRootPath, 'local', 'polyjson.json'), ...
                            @ischar);
p.parse(fPolyPath, varargin{:});
description = p.Results.description;
name = p.Results.name;
jsonPath = p.Results.outpath;
%% Load polynomial term file
poly = cell(1, 5);
load(fPolyPath);
js.description = description;
js.name = name;
%%
% x, y, u, v, w
outName = ['x', 'y', 'u', 'v', 'w'];
termName = ['r', 'u', 'v'];
for ii=1:5
    thisOut.outputname = strcat('out', outName(ii));
    
    % term
    for jj=1:3
        thisTermName = strcat('term', termName(jj));
        thisOut.(thisTermName) = poly{ii}.ModelTerms(:, jj)';
    end
    % coefficients
    thisOut.coeff = poly{ii}.Coefficients;
    
    js.poly(ii) = thisOut;
end

%% Write json file
opts.indent = ' ';
jsonwrite(jsonPath, js, opts);
end