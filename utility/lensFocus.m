function [filmDistance, lens] = lensFocus( lensFileName, objDistance )
% Compute the film distance to bring a point at object distance into focus
%
% Syntax
%
% Inputs:
%   lensFileName - A dat file.  Testing for JSON file
%   objDistance -  Object distance (millimeters)
%
% Optional
%
% Returns
%   filmDistance - Film distance for best focus (millimeters)
%   lens         - lens object created from the name

% Refer to CISET t_autofocus.m
%
% See also
%   lensFocus,

%{
  lensFileName = '2ElLens.json';
  objDistance = 100;
  [filmDistJ, lensJ] = lensFocus(lensFileName,objDistance);
%}
%{
  lensFileName = '2ElLens.dat';
  objDistance = 100;
  [filmDistD, lensD] = lensFocus(lensFileName,objDistance);
%}

%%  Initialize a point and a camera

point{1} = [0 0 -objDistance];

lens = lensC('fileName',lensFileName);

film = filmC;

camera = psfCameraC('lens',lens,'film',film,'pointsource',point);

%%  Find the film focal length for this wavelength

% Call autofocus, setting the indices of refraction of air and water
camera.autofocus(550,'nm',1,1);

% Return the adjusted position for focus
filmDistance = camera.film.position(3);


end

