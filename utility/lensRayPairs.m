function [iRays, oRays, planes, nanIdx, pupilPos, pupilRadii] = lensRayPairs(lensfile, varargin)
%% Input/output ray pairs
% 
% Synopsis:
%   [iRays, oRays, planes] = lensRayPairs(lensfile, varargin)
%
% Inputs:
%   lensfile - name of the lens json file
%   
% Outputs:
%   iRays - input rays (radius, u, v)
%   oRays - output rays (x, y, u, v)
%   planes - coordinate of input and output planes on z axis
%   nanIdx - failed rays index (useful for determining exit pupil)
%   pupilPos - pupil positions
%   pupilRadii     - pupil radii
%
% Optional key/val pairs:
%   elevationMax - max elevation difference from normal in degrees
%   nRadiusSamp  - number of samples along radius
%   nAzSamp      - number of azumith samples 
%   nElSamp      - number of elevation samples
%   planeOffset  - offset from the front and rear surface of the lens
%   visualize    - whether visualize the ray tracing process

% Examples:
%{
lensName = 'lenses/dgauss.22deg.3.0mm.json';
[iRays, oRays, planes] = lensRayPairs(lensName, 'visualize', true, 'elevation max', 20);
%}

%{
lensName = 'wide.40deg.3.0mm.json';
[iRays, oRays, planes] = lensRayPairs(lensName, 'visualize', true,...
                                    'n radius samp', 10, 'elevation max', 40,...
                                    'reverse', true);
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('lensfile', @(x)(exist(x, 'file')));
p.addParameter('elevationmax', 10, @isnumeric);
p.addParameter('nradiussamp', 10, @isnumeric);
p.addParameter('nazsamp', 10, @isnumeric);
p.addParameter('nelsamp', 10, @isnumeric);
p.addParameter('planeoffset', 0.01, @isnumeric); % mm
p.addParameter('visualize', false, @islogical);
p.addParameter('reverse', true, @islogical);
p.addParameter('maxradius', 0, @isnumeric);
p.addParameter('minradius', 0, @isnumeric);
p.parse(lensfile, varargin{:});
%{
arguments
    lensName char {mustBeFile}
    options.thetamax (1, 1) {mustBeNumeric} = 20
    options.nradiussamp (1, 1) {mustBeNumeric} = 10
    options.nazsamp (1, 1) {mustBeNumeric} = 10
    options.nphisamp (1, 1)
end
%}

lensfile = p.Results.lensfile;
elevationMax = p.Results.elevationmax;
nRadiusSamp = p.Results.nradiussamp;
nAzSamp = p.Results.nazsamp;
nElSamp = p.Results.nelsamp;
planeOffset = p.Results.planeoffset;
visualize = p.Results.visualize;
reverse = p.Results.reverse;
maxradius = p.Results.maxradius;
minradius = p.Results.minradius;
%% Reverse the lens
if reverse
    lensR = lensReverse(lensfile);
else
    lensR = lensC('filename', which(lensfile));
end

%%
[iRays, oRays, planes] = raytraceLightField(lensR, nRadiusSamp,...
        elevationMax, nElSamp, nAzSamp, planeOffset, 'visualize', visualize,...
        'max radius', maxradius, 'min radius', minradius);
    
%% remove nan 
nanIdx = find(any(isnan(oRays), 2));

% Get rid of w
iRays = iRays(:, 1:3);
oRays = oRays(:, 1:4);

%% Generate entrance pupils
[pupilPos, pupilRadii] = lensGetEntrancePupils(lensR);
pupilPos = pupilPos - planeOffset;
end