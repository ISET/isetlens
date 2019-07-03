function draw(camera,nLines,apertureD)
% Draw the camera lens and rays, possibly to the film plane
%
%    psfCamera.draw(nLines,apertureD)
%
% nLines:    Number of rays to use for the drawing
%            Default is 20
% apertureD: Sets the size of the film, when toFilm is true.
%            Default is 10mm (really big)
%
% Show the ray trace lines to the film (sensor) plane
%
% AL/BW Vistasoft Team, Copyright 2014

if ieNotDefined('nLines'), nLines = 20; end

% Always true, for nicer picture, I guess.
jitterFlag = true;

% Not sure what to do here
% ppsfCFlag = false;

% If toFilm is true, add the film surface as if it is an
% aperture.  This will force the ray trace to continue to that
% plane
sArray = camera.lens.surfaceArray;  % Store the original

wave      = camera.lens.wave;

disp('Drawing to film surface')

% SHOULD BE Planar object.  But it won't draw to that
sRadius   = 1e5;  % Many millimeters
zPosition = camera.film.position(3);

% We need a principled way to set this.
if ieNotDefined('apertureD'), apertureD = 100; end

camera.lens.surfaceArray(end+1) = ...
    surfaceC('wave',wave,...
    'aperture diameter',apertureD,...
    'sRadius',sRadius,...
    'zPosition',zPosition);

yFan(1) =  0; yFan(3) = 0;
yFan(2) = -1; yFan(4) = 1;
camera.rays = camera.lens.rtSourceToEntrance(camera.pointSource{1},jitterFlag,'realistic',yFan);

% Duplicate the existing rays for each wavelength
% Note that both lens and film have a wave, sigh.
% obj.rays.expandWavelengths(obj.film.wave);
camera.rays.expandWavelengths(wave);

%lens intersection and raytrace
camera.lens.rtThroughLens(camera.rays, nLines);

% Put it back the way you found it.
camera.lens.surfaceArray = sArray;

xFilm     = camera.get('film distance');
lens      = camera.get('lens');
thickness = lens.get('lens thickness');
height    = lens.get('lens height');

set(gca,'xlim',[-2*thickness xFilm+1]); 
set(gca,'ylim',[-1*height,height])
grid on

end