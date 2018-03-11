function [pts, lens, film] = ilInitPLF
% Create a default point, lens and film
%
% Description:
%   While developing, we often need a default point, lens, and film. This
%   script creates three simple variables.
%
% Inputs:
%  N/A
%
% Optional key/value pairs
%  N/A
%
% Outputs:
%   pts    a point 
%   lens   a lens object
%   film   a film object
%
% BW SCIEN STANFORD, 2018
%
% See also

%% pts

% Some day this will be a point source object
pts{1} = [0 1.7 -103];

%% Define the Lens 
lensFileName = fullfile(ilensRootPath,'data', 'lens', '2ElLens.dat');
nSamples = 151;
apertureMiddleD = 8;   % mm
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD);
wave = lens.get('wave');

%% Define the film (sensor) properties

% position - relative to center of final lens surface (mm)
% size - 'mm'
% wavelength samples (nm)
film = filmC('position', [0 0 10], ...
    'size', [1 1], ...
    'wave', wave);

%% End