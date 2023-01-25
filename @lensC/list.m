function files = list(varargin)
% List and summarize the lenses in data/lens
%
% Synopsis
%   files = lensC.list;
%
% Inputs
%   N/A
%
% Key/val pairs
%   quiet - DO not print, just return the list
%
% Output
%   files - Array of file information
%
% See also
%   lensC

%% Parse inputs
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);

p.parse(varargin{:});

quiet = p.Results.quiet;

lensDir = piDirGet('lens');

%%
files = dir(fullfile(lensDir,'*.json'));
if quiet, return; end

for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end