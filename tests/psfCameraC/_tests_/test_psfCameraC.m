function tests = test_psfCameraC()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
localAddDependencies();
testCase.TestData.lensFile = fullfile(piDirGet('lens'),'dgauss.22deg.3.0mm.json');
end

function testConstructorGetSetAndClearFilm(testCase)
lens = lensC('filename',testCase.TestData.lensFile,'aperture sample',[5 5]);
film = filmC('position',[0 0 2.2], ...
    'size',[2 2], ...
    'resolution',[11 11], ...
    'wave',lens.get('wave'));
film.image(:) = 1;
point = {[0 0 -1000]};

camera = psfCameraC('lens',lens,'film',film,'point source',point);

testCase.verifyEqual(camera.get('lens'),lens);
testCase.verifyEqual(camera.get('film'),film);
testCase.verifyEqual(camera.get('point source'),point);
testCase.verifyEqual(camera.get('spacing'),2/11,'AbsTol',1e-12);
testCase.verifyEqual(sum(camera.film.image(:)),0);

newPoint = {[0.1 0 -1000]};
camera.set('point source',newPoint);
testCase.verifyEqual(camera.get('point source'),newPoint);
end

function testClearFilmFalsePreservesImage(testCase)
lens = lensC('filename',testCase.TestData.lensFile,'aperture sample',[5 5]);
film = filmC('resolution',[3 3],'wave',lens.get('wave'));
film.image(:) = 2;

camera = psfCameraC('lens',lens,'film',film, ...
    'point source',{[0 0 -1000]}, ...
    'clear film',false);

testCase.verifyEqual(sum(camera.film.image(:)),2*numel(camera.film.image));
end

function testSyntheticImageCentroid(testCase)
lens = lensC('filename',testCase.TestData.lensFile,'aperture sample',[5 5]);
film = filmC('size',[2 2],'resolution',[5 5],'wave',lens.get('wave'));
camera = psfCameraC('lens',lens,'film',film,'point source',{[0 0 -1000]});
camera.film.image(3,4,:) = 1;

centroid = camera.get('image centroid');

testCase.verifyEqual(centroid.X,0.5,'AbsTol',1e-12);
testCase.verifyEqual(centroid.Y,0,'AbsTol',1e-12);
end

function testAutofocusMovesFilmToGoldenDistance(testCase)
lens = lensC('filename',testCase.TestData.lensFile,'aperture sample',[5 5]);
film = filmC('wave',lens.get('wave'));
camera = psfCameraC('lens',lens,'film',film,'point source',{[0 0 -1000]});

dist0 = camera.autofocus(550,'nm',1,1);

testCase.verifyEqual(dist0,2.17551665624,'RelTol',1e-9);
testCase.verifyEqual(camera.get('film distance'),dist0,'RelTol',1e-12);
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
