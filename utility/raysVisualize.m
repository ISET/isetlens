function [samps,h] = raysVisualize(origin,endPoint,varargin)
% Draw rays from origin to endPoint
%
%  raysVisualize(origin,endPoint,nLines,surface)
%
% Origin points: (X,Y,Z) 
% End points:    (X,Y,Z)
% nLines:   Number of samples to draw (an integer), or
%           a structure.  This is not completely supported yet.  We don't
%           know if this is necessary though. Leave it here for now. If a
%           struct the fields are 'spacing' or and 'numLines'.  Spacing can
%           be either 'uniform' or 'random'
% lens:    Lens object
% threeD:  Show the rays in 3D (default is true)
% h:       Figure handle
% 
% Wandell, CISET, 2016

% TODO
% Let's try to make the lines 3D.  That would be cool!

%%
p = inputParser;

p.addRequired('origin',@ismatrix);
p.addRequired('endPoint',@ismatrix);
p.addParameter('nLines',[]);
p.addParameter('surface',[],@(x)(isa(x,'surfaceC')));
p.addParameter('fig',[],@(x)(isa(x,'matlab.ui.Figure')));
p.addParameter('samps',[],@isvector);
p.addParameter('threeD',true,@islogical);

p.parse(origin,endPoint,varargin{:});

origin   = p.Results.origin;
endPoint = p.Results.endPoint;
nLines   = p.Results.nLines;
surface  = p.Results.surface;
h        = p.Results.fig;
samps    = p.Results.samps;
threeD   = p.Results.threeD;

%% Draw the lines

if isempty(nLines), return; end

if isempty(h),  h = vcNewGraphWin; hold on; end
figure(h);

if ~isempty(surface), surface.draw('fig',h); end

% For the images produced, uses these parameters
lWidth = 0.1;       % Somewhat thin
lColor = [0 0.5 1]; % Blue color
lStyle = '-';       % Solid line

% Which sample rays to visualize
nRays = size(origin,1);
if ~isstruct(nLines),                     samps = randi(nRays,[nLines,1]);
elseif strcmp(nLines.spacing, 'uniform'), samps = round(linspace(1, nRays, nLines.numLines));
elseif strcmp(nLines.spacing,'random'),   samps = randi(nRays,[nLines.numLines,1]);
else   error('Unknown spacing parameter %s\n',nLines.spacing);
end

if threeD
    % The x,y coordinates are in the columns of the xImage, yImage matrices
    xImage = [origin(samps,3) endPoint(samps,3)]';
    yImage = [origin(samps,2) endPoint(samps,2)]';
    zImage = [origin(samps,1) endPoint(samps,1)]';
    
    % Plot and pause briefly
    line(xImage,yImage,zImage,'Color',lColor,'LineWidth',lWidth,'LineStyle',lStyle);
    pause(0.1);
    
else
    
    % The x,y coordinates are in the columns of the xImage, yImage matrices
    xImage = [origin(samps,3) endPoint(samps,3)]';
    yImage = [origin(samps,2) endPoint(samps,2)]';
    
    % Plot and pause briefly
    line(xImage,yImage,'Color',lColor,'LineWidth',lWidth,'LineStyle',lStyle);
    pause(0.1);
end

end