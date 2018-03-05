function draw(obj,toFilm,nLines,apertureD)
% Draw the camera lens and rays, possibly to the film plane
%
%    psfCamera.draw(toFilm,nLines,apertureD)
%
% toFilm:    Logical that specifies whether to draw to film
%            surface.  If true, then a very low curvature surface is added
%            in the film plane to force the draw. Default is false. 
% nLines:    Number of rays to use for the drawing
%            Default is 200
% apertureD: Sets the size of the film, when toFilm is true.
%            Default is 100mm (really big)
%
% Show the ray trace lines to the film (sensor) plane
%
% AL/BW Vistasoft Team, Copyright 2014

if ieNotDefined('toFilm'), toFilm = false; end
if ieNotDefined('nLines'), nLines = 200; end

% Always true, for nicer picture, I guess.
jitterFlag = true;

% Not sure what to do here
ppsfCFlag = false;

% If toFilm is true, add the film surface as if it is an
% aperture.  This will force the ray trace to continue to that
% plane
sArray = obj.lens.surfaceArray;  % Store the original

wave      = obj.lens.wave;

if toFilm
    disp('Drawing to film surface')
    
    % SHOULD BE Planar object.  But it won't draw to that
    sRadius   = 1e5;  % Many millimeters
    zPosition = obj.film.position(3);
    
    % We need a principled way to set this.
    if ieNotDefined('apertureD'), apertureD = 100; end
    
    obj.lens.surfaceArray(end+1) = ...
        surfaceC('wave',wave,...
        'aperture diameter',apertureD,...
        'sRadius',sRadius,...
        'zPosition',zPosition);
end

% Not sure why we need the ppsfCFlag (BW)
obj.rays = obj.lens.rtSourceToEntrance(obj.pointSource, ppsfCFlag, jitterFlag);

% Duplicate the existing rays for each wavelength
% Note that both lens and film have a wave, sigh.
% obj.rays.expandWavelengths(obj.film.wave);
obj.rays.expandWavelengths(wave);

%lens intersection and raytrace
obj.lens.rtThroughLens(obj.rays, nLines);

% Put it back the way you found it.
if toFilm
    obj.lens.surfaceArray = sArray;
end

end