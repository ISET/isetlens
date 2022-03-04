function files = list(~,varargin)
% List and summarize the lenses in data/lens
%
% ISETBIO Team, 2018

%%
p = inputParser;

% If you want the list returned without a print
p.addParameter('quiet',false,@islogical);
p.parse(varargin{:});

quiet = p.Results.quiet;

%%
files = dir(fullfile(ilensRootPath,'data','lens','*.json'));
if quiet, return; end

for ii=1:length(files)
    fprintf('%d - %s\n',ii,files(ii).name);
end

end