function aGrid = apertureGrid(obj,varargin)
% Find the full grid, mask it and return only the (X,Y) positions inside
% the masked region.
%
% This is the usual set of positions that we use for calculating light
% fields.
%
% Parameters
%  randJitter
%  rtType
%  subSection
%
% HB/BW

%%
p = inputParser;
p.addRequired('obj',@(x)(isa(obj,'lensC')));
p.addParameter('randJitter',false,@islogical);
vFunc = @(x)(isempty(x) || isvector(x));
p.addParameter('subSection',[],vFunc);
p.addParameter('rtType',[],@ischar);

p.parse(obj,varargin{:});

randJitter = p.Results.randJitter;
subSection = p.Results.subSection;
rtType = p.Results.rtType;

if isempty(subSection)
    % Realistic or ideal ray trace type (rtType)
    aGrid = fullGrid(obj,randJitter, rtType);
    
    aMask   = apertureMask(obj);
    aGrid.X = aGrid.X(aMask);
    aGrid.Y = aGrid.Y(aMask);
    
else
    % Define the grid on the subsection
    leftX  = subSection(1); lowerY = subSection(2);
    rightX = subSection(3); upperY = subSection(4);
    
    % Make the rectangular samples
    firstApertureRadius = obj.surfaceArray(1).apertureD/2;
    xSamples = linspace(firstApertureRadius *leftX, firstApertureRadius*rightX, obj.apertureSample(1));
    ySamples = linspace(firstApertureRadius *lowerY, firstApertureRadius*upperY, obj.apertureSample(2));
    [X, Y] = meshgrid(xSamples,ySamples);
    
    if(randJitter)
        % Add random jitter to the positions (x,y) on the front surface.
        % Uniform distribution.  Scales to plus or minus half the sample width
        X = X + (rand(size(X)) - .5) * (xSamples(2) - xSamples(1));
        Y = Y + (rand(size(Y)) - .5) * (ySamples(2) - ySamples(1));
    end
    aGrid.X = X(:); aGrid.Y = Y(:);
end

% Set Z to the position of the front surface
nPts    = numel(aGrid.X(:));
aGrid.Z = repmat(obj.get('lens thickness'),[nPts,1]);

%debug check
%
% vcNewGraphWin; plot(aGrid.X, aGrid.Y, 'o');

end