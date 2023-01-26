%% s_initPLF
%
% We often need a default point (P), lens (L) and film (F) for debuggin
% This script creates the variables
%
%   pts    a set of point locations (
%   lens   a lens object
%   film   a film object
% 
% Other scripts can adjust or overwrite, but many times we just need these
% things and this is a clean and automatic way for getting them into a
% script.
%
% AL Vistaosft 2014


%% pts

% Some day this will be a matrix of N x 3 or a class or something
pts     = [0 1.7 -103];

%% Define the Lens 
lensFileName = fullfile(s3dRootPath,'data', 'lens', '2ElLens.dat');
nSamples = 151;
apertureMiddleD = 8;   % mm
lens = lensC('apertureSample', [nSamples nSamples], ...
    'fileName', lensFileName, ...
    'apertureMiddleD', apertureMiddleD);
wave = lens.get('wave');

%% Define the film (sensor) properties

% position - relative to center of final lens surface
% size - 'mm'
% wavelength samples
film = filmC('position', [0 0 100 ], ...
    'size', [10 10], ...
    'wave', wave);

%% End