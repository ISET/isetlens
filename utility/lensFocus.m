function filmDistance = lensFocus( lensFileName, objDistance )
% Compute the film distance to bring a point at object distance into focus
%
% Syntax
%
% Inputs:
%   lensFileName - Either a dat or JSON file, I think
%   objDistance -  In millimeters, I think
%
% Optional
%
% Returns
%   filmDistance - for best focus, in millimeters, I think
%
% Refer to CISET t_autofocus.m
%
% See also
%   lensFocus,

%{
   
%}

%%  Initialize a point and a camera

point{1} = [0 0 -objDistance];

% This human eye model has a focal length of 16.5 mm, which we confirm when
% running ray trace in PBRT and ray trace in CISET. See -
lens = lensC('fileName',lensFileName);

film = filmC;

camera = psfCameraC('lens',lens,'film',film,'pointsource',point);

%%  Find the film focal length for this wavelength

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Return the adjusted position for focus
filmDistance = camera.film.position(3);


end

