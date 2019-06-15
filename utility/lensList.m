function files = lensList(varargin)
% List and summarize the lenses in data/lens with a json extension
%
% Syntax:
%   files = lensList(...)
%
% Description:
%   Print a list of the lens .json files in the default directory.  You can
%   create a lens from one of the files with the lens constructor.
%   These json files are the ones we use as lens information for
%   PBRT-V3-spectral.
%
%   The files should have a metadata slot that includes their focal
%   length and fnumber.
%
% Inputs:
%   N/A
%
% Outputs:
%   file - Cell array of file descriptors with a .json extention
%          The name is file(ii).name
%
% Optional key/value pairs:
%   'quiet'  - do not print to the command line
%
% Wandell, ISETBIO Team, 2018
%
% See also

% Examples:
%{
   lensNames = lensList;
   thisLens = lensC('filename',lensNames(18).name);
   thisLens.draw;
   thisLens.focalLength
   wave = thisLens.get('wave');
   point = psCreate(0,0,-10000);
   sensor = filmC('position', [0 0 154], ...
        'size', [5 5], ...
        'resolution',[300 300],...
        'wave', wave);
    camera = psfCameraC('lens',thisLens,'film',sensor,'pointsource',point);
    camera.autofocus(550,'nm')
    camera.estimatePSF(100,true);
%}
%{
    lensNames = lensList('quiet',true);
%}

%% Parse input
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);
p.parse(varargin{:});

quiet = p.Results.quiet;

%% List the json files

files = dir(fullfile(ilensRootPath,'data','lens','*.json'));
if quiet, return; end

% Not quiet, so print out the list
for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end