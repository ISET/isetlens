function files = list(varargin)
% List and summarize the lenses in data/lens
%
% ISETBIO Team, 2018

%%
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);
p.addParameter('lensRoot','',@ischar);

p.parse(varargin{:});

quiet = p.Results.quiet;

if ~isempty(p.Results.lensRoot)
    lensDir = p.Results.lensRoot;
else
    lensDir = ilensRootPath; 
end

%%
files = dir(fullfile(lensDir,'data','lens','*.json'));
if quiet, return; end

for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end