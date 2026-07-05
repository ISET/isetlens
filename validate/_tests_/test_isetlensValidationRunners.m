function tests = test_isetlensValidationRunners()
tests = functiontests(localfunctions);
end

function setupOnce(~)
rootPath = ilensRootPath();
repoParent = fileparts(rootPath);
addpath(genpath(rootPath));
for name = {'isetcam','iset3d'}
    dependencyRoot = fullfile(repoParent,name{1});
    if isfolder(dependencyRoot), addpath(genpath(dependencyRoot)); end
end
end

function testRunnerEntryPointsExist(testCase)
runnerNames = {'isetlensUnitTest','isetlensTutorialTest', ...
    'lensUnitTest','lensUtilityUnitTest', ...
    'rayUnitTest','filmUnitTest','surfaceUnitTest','psfCameraUnitTest', ...
    'paraxialUnitTest','bbmUtilityUnitTest'};

for ii = 1:numel(runnerNames)
    testCase.verifyNotEmpty(which(runnerNames{ii}), ...
        sprintf('Missing runner %s',runnerNames{ii}));
end
end

function testLocalRunnerReturnsTestResults(testCase)
results = filmUnitTest('core');

testCase.verifyClass(results,'matlab.unittest.TestResult');
testCase.verifyGreaterThan(numel(results),0);
testCase.verifyTrue(all([results.Passed]));
end

function testMasterRunnerModeValidation(testCase)
testCase.verifyTrue(localThrows(@() isetlensUnitTest('unknownMode')));
end

function testTutorialRunnerSelection(testCase)
run = isetlensTutorialTest('selection','t_lens');

testCase.verifyEqual(run.repositoryName,'ISETLens');
testCase.verifyEqual(run.suiteKind,'tutorials');
testCase.verifyEqual(run.selector,'t_lens');
testCase.verifyEqual(numel(run.results),1);
testCase.verifyEqual(run.results.status,'Passed');
end

function tf = localThrows(fcn)
try
    fcn();
    tf = false;
catch
    tf = true;
end
end
