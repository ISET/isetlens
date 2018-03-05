function files = lensList(varargin)
% List and summarize the lenses in data/lens
%
% Syntax:
%   files = lensList(...)
%
% Description:
%   Print a list of the lens .dat files in the default directory.  You can
%   create a lens from one of the files with the lens constructor.
%
% Inputs:
%   N/A
%
% Outputs:
%   file - Cell array of file descriptors with a .dat extention
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
   thisLens = lens('filename',lensNames(18).name);
   thisLens.draw;
%}
%{
    lensNames = lensList('quiet',true);
%}

%%
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);
p.parse(varargin{:});

quiet = p.Results.quiet;

%%
files = dir(fullfile(ilensRootPath,'data','lens','*.dat'));
if quiet, return; end

for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end