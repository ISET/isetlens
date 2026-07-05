function results = isetlensUnitTest(mode)
% ISETLENSUNITTEST - Master runner for all ISETLens unit tests.
%
% Syntax:
%   results = isetlensUnitTest
%   results = isetlensUnitTest('full')
%
% Returns:
%   results - matlab.unittest.TestResult array

if nargin < 1 || isempty(mode), mode = 'core'; end
mode = lower(char(mode));

rootPath = ilensRootPath();
localAddDependencies(rootPath);

fprintf('Searching for tests in ISETLens...\n');
testFiles = dir(fullfile(rootPath, '**', '_tests_', 'test_*.m'));

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;

existingFigures = findall(groot,'Type','figure');
cleanupFigures = onCleanup(@() localCloseTestFigures(existingFigures));
if exist('ieUnitTestSetup','file')
    cleanupPrefs = ieUnitTestSetup(); %#ok<NASGU>
end

masterSuite = [];
for ii = 1:length(testFiles)
    testFile = fullfile(testFiles(ii).folder,testFiles(ii).name);
    fileSuite = TestSuite.fromFile(testFile);
    masterSuite = [masterSuite, fileSuite]; %#ok<AGROW>
end

masterSuite = localSelectMode(masterSuite, mode);

if isempty(masterSuite)
    fprintf('No ISETLens tests found for mode ''%s''.\n', mode);
    results = [];
    return;
end

testDirs = unique({testFiles.folder});
fprintf('Found %d tests across %d directories.\n', length(masterSuite), length(testDirs));
fprintf('Starting ISETLens master test runner for mode ''%s''...\n\n', mode);

runner = TestRunner.withTextOutput;
results = runner.run(masterSuite);

if exist('ieTestReport','file')
    ieTestReport(results,'isetlensUnitTest');
end

end

function suite = localSelectMode(suite, mode)
switch mode
    case {'core','fast','quantitative'}
        names = {suite.Name};
        suite = suite(~contains(names,'FullOnly') & ~contains(names,'_remote'));
    case {'full','all'}
        % Keep the complete suite.
    otherwise
        error('Unknown isetlensUnitTest mode %s. Use ''core'' or ''full''.',mode);
end
end

function localAddDependencies(rootPath)
addpath(genpath(rootPath));
repoParent = fileparts(rootPath);
dependencyRoots = {'isetcam','iset3d'};
for ii = 1:numel(dependencyRoots)
    dependencyRoot = fullfile(repoParent,dependencyRoots{ii});
    if isfolder(dependencyRoot)
        addpath(genpath(dependencyRoot));
    end
end
end

function localCloseTestFigures(existingFigures)
allFigures = findall(groot,'Type','figure');
testFigures = setdiff(allFigures,existingFigures);
testFigures = testFigures(ishghandle(testFigures));
if ~isempty(testFigures), close(testFigures); end
end
