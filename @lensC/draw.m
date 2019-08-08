function obj =  draw(obj, fHdl, thisAxis)
% Draw the the multi-element lens surfaces and microlens in a graph window
%
% Syntax
%   lens.draw
%
% Brief description
%   Draw a set of curves showing the lens surfaces (cross section view).
%   If there is a microlens field, then the figure is drawn with two
%   panels, for the imaging lens and the microlens.
%
% Parameters
%  obj:  A lens object
% fHdl:  A figure handle.  If not passed, then ieNewGraphWin is
%        called and that figure handle is set in the lens object field fHdl
%
% AL/BW Vistasoft Team, Copyright 2014
%
% See also:  
%    psfCameraC.draw
%

%% Create the figure and set the parameters

if ~exist('fHdl','var'), fHdl = ieNewGraphWin; axis equal;
elseif isempty(fHdl)     % Do nothing
else,                    figure(fHdl); % Raise the figure
end
obj.fHdl = fHdl;

%% Draw one surface/aperture at a time

if ~isempty(obj.microlens)
    subplot(1,2,1);
end

nSurfaces = obj.get('n surfaces');
for lensEl = 1:nSurfaces    
    % Get each surface element and draw it
    curEl = obj.surfaceArray(lensEl);
    curEl.draw('fig',gcf);
end

% Make sure the surfaces are all shown within the range
%
% We believe that maxx and maxy are always positive, and minx and miny are
% always negative.  But maybe we should deal with the sign issue here for
% generality in the future.  If you have a bug, that might be.

% X axis limits
t = obj.get('total offset'); 
set(gca,'xlim',[-1.1,0.1]*t)

% Y axis limits should be from aperture
% Not yet set, but could be

% HACK: Set the window NAME to the lens name.  Setting the subplot stitle
% takes up too much space on the drawing.  We assume that the name of the
% microlens begins with 'microlens'.  If so, don't run this line.
if ~strncmp(obj.name,'microlens',9)
    set(gcf,'Name',sprintf('%s',obj.name))
end

axis image
xlabel('mm'); ylabel('mm');

%% Now the microlens
if isempty(obj.microlens)
    return;
else
    microlens = obj.microlens;
    subplot(1,2,2);
    microlens.draw('');
end

end
