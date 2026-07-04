function tests = test_lensC()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
localAddDependencies();
testCase.TestData.lensFile = fullfile(piDirGet('lens'),'dgauss.22deg.3.0mm.json');
end

function testListAndConstructorFromFileStruct(testCase)
files = lensC.list('quiet',true);
testCase.verifyGreaterThan(numel(files),0);

names = {files.name};
idx = find(strcmp(names,'dgauss.22deg.3.0mm.json'),1);
testCase.verifyNotEmpty(idx);

lens = lensC('filename',files(idx),'aperture sample',[5 5]);
testCase.verifyEqual(lens.get('name'),'dgauss.22deg.3.0mm');

nameOnly = lensC.list('quiet',true,'name only',true);
testCase.verifyTrue(iscell(nameOnly));
testCase.verifyTrue(any(strcmp(nameOnly,'dgauss.22deg.3.0mm.json')));
end

function testStandardLensAccessorsAndGoldens(testCase)
lens = localStandardLens(testCase);

testCase.verifyEqual(lens.get('name'),'dgauss.22deg.3.0mm');
testCase.verifyTrue(contains(lens.get('full file name'),'dgauss.22deg.3.0mm.json'));
testCase.verifyEqual(lens.get('wave'),400:50:700);
testCase.verifyEqual(lens.get('n wave'),7);
testCase.verifyEqual(lens.get('n surfaces'),11);
testCase.verifyEqual(lens.get('aperture index'),6);
testCase.verifyEqual(lens.get('lens diameter'),1.51199996471,'RelTol',1e-9);
testCase.verifyEqual(lens.get('lens thickness'),1.92240003310,'RelTol',1e-9);
testCase.verifySize(lens.get('offsets'),[1 11]);
testCase.verifySize(lens.get('index of refraction'),[7 11]);
testCase.verifyEqual(nnz(lens.get('refractive surfaces')),10);

testCase.verifyEqual(lensFocus(lens,1e6),2.16636385915,'RelTol',1e-9);
testCase.verifyEqual(lens.get('in focus distance',1e3),2.17551665624,'RelTol',1e-9);
end

function testBlackBoxModelAndFovHelpers(testCase)
lens = localStandardLens(testCase);
created = lens.bbmCreate();
testCase.verifyNotEmpty(created);

efl = lens.get('bbm','effective focal length');
testCase.verifyEqual(numel(efl),lens.get('n wave'));
testCase.verifyTrue(all(isfinite(efl)));

filmSize = lens.filmSizeFromFOV(60);
testCase.verifyEqual(numel(filmSize),lens.get('n wave'));
testCase.verifyTrue(all(filmSize > 0));

[scaleFactor,newFL] = lens.fovScale(60,3);
testCase.verifyEqual(newFL,3/2/tand(30),'AbsTol',1e-12);
testCase.verifyGreaterThan(scaleFactor,0);

fov = lens.get('fov',3);
testCase.verifyGreaterThan(fov,0);
testCase.verifyLessThan(fov,180);
end

function testSamplingGrids(testCase)
lens = localStandardLens(testCase);

fullGrid = lens.fullGrid(false,'realistic');
testCase.verifySize(fullGrid.X,[5 5]);
testCase.verifySize(fullGrid.Y,[5 5]);

apertureGrid = lens.apertureGrid('rand jitter',false);
testCase.verifyEqual(numel(apertureGrid.X),numel(apertureGrid.Y));
testCase.verifyEqual(numel(apertureGrid.X),numel(apertureGrid.Z));
testCase.verifyLessThanOrEqual(numel(apertureGrid.X),25);
testCase.verifyTrue(all(abs(apertureGrid.X) <= lens.get('lens diameter')/2 + eps));
end

function testFileWriteRoundTrips(testCase)
lens = localStandardLens(testCase);
tempJson = [tempname,'.json'];
tempDat = [tempname,'.dat'];
testCase.addTeardown(@() localDeleteFile(tempJson));
testCase.addTeardown(@() localDeleteFile(tempDat));

lens.fileWrite(tempJson);
lens.fileWrite(tempDat);

jsonLens = lensC('filename',tempJson,'aperture sample',[5 5]);
datLens = lensC('filename',tempDat,'aperture sample',[5 5]);

testCase.verifyEqual(jsonLens.get('n surfaces'),lens.get('n surfaces'));
testCase.verifyEqual(datLens.get('n surfaces'),lens.get('n surfaces'));
testCase.verifyEqual(lensMatrix(jsonLens),lensMatrix(lens),'AbsTol',1e-5);
testCase.verifyEqual(lensMatrix(datLens),lensMatrix(lens),'AbsTol',1e-5);
end

function lens = localStandardLens(testCase)
lens = lensC('filename',testCase.TestData.lensFile,'aperture sample',[5 5]);
end

function localAddDependencies()
rootPath = ilensRootPath();
repoParent = fileparts(rootPath);
addpath(genpath(rootPath));
for name = {'isetcam','iset3d'}
    dependencyRoot = fullfile(repoParent,name{1});
    if isfolder(dependencyRoot), addpath(genpath(dependencyRoot)); end
end
end

function localDeleteFile(fileName)
if exist(fileName,'file'), delete(fileName); end
end
