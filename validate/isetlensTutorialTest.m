function run = isetlensTutorialTest(varargin)
% Run ISETLens tutorials through the shared ISETCam test engine.
%
% Syntax:
%   run = isetlensTutorialTest
%   run = isetlensTutorialTest('selection',scriptName)
%   run = isetlensTutorialTest('start',scriptName)
%
% With no arguments, all tutorials run. 'selection' runs only scriptName;
% 'start' runs scriptName and every tutorial after it.

[selector,start] = localParseSelection(varargin{:});

repoRoot = ilensRootPath;
localEnsureISETCam(repoRoot);

config = struct();
config.repositoryName = 'ISETLens';
config.repositoryRoot = repoRoot;
config.suiteKind = 'tutorials';
config.runnerName = mfilename;
config.selector = selector;
config.start = start;
config.skipPathPatterns = {};
config.conditionalSkipFcn = @localConditionalSkip;
config.setupFcn = @() localSetup(repoRoot);

run = ieRunTutorialExampleTests(config);

end

function [selector,start] = localParseSelection(varargin)
%% Parse the public selection options.

selector = '';
start = '';
if isempty(varargin), return; end
if numel(varargin) ~= 2
    error('isetlensTutorialTest:InvalidInput', ...
        'Use no arguments or one name-value pair: selection or start.');
end

option = lower(char(varargin{1}));
switch option
    case 'selection'
        selector = varargin{2};
    case 'start'
        start = varargin{2};
    otherwise
        error('isetlensTutorialTest:InvalidOption', ...
            'Unknown option "%s". Use selection or start.',option);
end

end

function localEnsureISETCam(repoRoot)
%% Add the sibling ISETCam dependency when the shared engine is unavailable.

if ~isempty(which('ieRunTutorialExampleTests')), return; end
dependencyRoot = fullfile(fileparts(repoRoot),'isetcam');
if ~isfolder(dependencyRoot)
    error('isetlensTutorialTest:MissingISETCam', ...
        'ISETCam dependency not found: %s',dependencyRoot);
end
addpath(genpath(dependencyRoot));

end

function localSetup(repoRoot)
%% Add ISETLens and known sibling dependencies needed by tutorials.

addpath(genpath(repoRoot));
repoParent = fileparts(repoRoot);
dependencyRoots = {'isetcam','iset3d'};
for ii = 1:numel(dependencyRoots)
    dependencyRoot = fullfile(repoParent,dependencyRoots{ii});
    if isfolder(dependencyRoot)
        addpath(genpath(dependencyRoot));
    end
end

end

function reason = localConditionalSkip(filePath)
%% Skip environment-dependent tutorials when prerequisites are absent.

reason = '';
[~,fileName] = fileparts(filePath);

switch fileName
    case 't_rayTracingIntroduction'
        if isempty(which('sceneEye')) || isempty(which('piCamBio')) || piCamBio
            reason = 'requires ISETBio sceneEye support';
            return;
        end
        if isempty(which('piDockerExists')) || ~piDockerExists
            reason = 'requires ISET3D Docker/PBRT rendering support';
        end
end

end
