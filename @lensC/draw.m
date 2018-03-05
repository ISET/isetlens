function obj =  draw(obj, fHdl)
% Draw the the multi-element lens surfaces in a graph window
%
%   lens.draw
%
% fHdl:  A figure handle to use.  If not passed, then vcNewGraphWin is
%        called and that figure handle is set in the lens object field fHdl
%
% See also:  psfCamera.draw
%            That calls this lens draw and also draws the rays for the
%            point spread. 
%
% AL/BW Vistasoft Team, Copyright 2014

%% Create the figure and set the parameters

if notDefined('figureHandle'), fHdl = vcNewGraphWin; axis equal;
else                             figure(fHdl);
end
obj.fHdl = fHdl;



%% We draw one surface/aperture at a time

nSurfaces = obj.get('n surfaces');
for lensEl = 1:nSurfaces
    
    % Get each surface element and draw it
    curEl = obj.surfaceArray(lensEl);
    curEl.draw('fig',fHdl);
    
end

% Make sure the surfaces are all shown within the range
%
% We believe that maxx and maxy are always positive, and minx and miny are
% always negative.  But maybe we should deal with the sign issue here for
% generality in the future.  If you have a bug, that might be.

% X axis limits
t = obj.get('total offset'); set(gca,'xlim',[-1.1,0.1]*t)

% Y axis limits should be from aperture
% Not yet set, but could be

% Let's give the figure the lens title
% set(gcf,'Name',sprintf('%s',obj.name));
title(sprintf('%s',obj.name));
axis image
xlabel('mm'); ylabel('mm');

end
