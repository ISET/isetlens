%% s_lensFocusTable
%
% For each lens file, create a look-up table from object dist (in mm)
% to proper film distance from the lens (mm). 
%
% A typical application is from iset3d.  In that case, we often want
% to look up the film distance when we a scene has an object at a
% known distance from the camera and we want to set the film distance
% from the camera to object distance. The camera to object distance is
% calculated using the 'lookat' values in the PBRT file.
%
% First, we build the whole table, T, that has the different *.dat files in the
% data/lens directory as the rows and the distance to object as the columns. The
% entries are the focalDistance (all distances are millimeters, mm).
%
%   T(whichLens,dist) = focalDistance
%
% When a focus cannot be obtained the returned film distance value is
% negative.  In that case we set the entry to NaN.
%
% We plot the focal distance vs. the object distance.  
%
% Finally, we write out file (lensFile.FL.mat) that contains the values 'dist'
% and focalDistance as parameters that can be used to interpolate for any
% distance in a scene.
%
%   focalLength = load(fullfile(p,[flname,'.FL.mat']));
%   focalDistance = interp1(focalLength.dist,focalLength.focalDistance,objDist);
%
% BW SCIEN Stanford, 2017

%%  All the lenses in the pbrt2ISET directory

lensDir = fullfile(ilensRootPath,'data','lens');

% wide, tessar, fisheye, dgauss, telephoto, 2el, 2EL
lensFiles = dir(fullfile(lensDir,'*.json'));   

% Range of distances in millimeters
% From about 1 mm to 10 m.  There are thirty sample distances
objDistance = logspace(0.1,4,30);

%% Calculate the focal distances

nFiles = numel(lensFiles);
fprintf('Processing %d lens files\n',nFiles);
allFilmDistance  = zeros(nFiles,length(objDistance));
allFocalLengths  = zeros(nFiles,1);

for ii=1:nFiles
    fname = fullfile(lensDir,lensFiles(ii).name);
    for jj=1:length(objDistance)
        allFilmDistance(ii,jj) = lensFocus(lensFiles(ii).name,objDistance(jj));
    end
    % We should probably store this, too.
    allFocalLengths(ii) = lensFocus(lensFiles(ii).name,max(objDistance)*10^6);
end


%%  When the distance is too small, we can't get a good focus.
%
%   The negative values could not be focused, so we set to NaN
%
allFilmDistance(allFilmDistance < 0) = NaN;

%%  Write out the film distance as a function of object distance
%
% We write this out for each of the lenses.  We clean up the outputs
% so that only object distances that can be in good focus are there.
%
% We should probably add extra slots for the minimum object distance
% and the lens focal length, which would be derived by using a very
% far distance

hdl = ieNewGraphWin; 
xlabel('Object distance (mm)'); ylabel('Film distance (mm)');
grid on; hold on;

saveObjDistance   = objDistance;

for ii=1:nFiles
    
    filmDistance = allFilmDistance(ii,:);   % This lens distance
    
    % If there is a NaN, find the index right after it.  Otherwise,
    % the returned index is 1.
    idx = find(isnan(filmDistance),1,'last'); 
    if idx < length(filmDistance), idx = idx+1;
    else, idx = 1;
    end
    
    closestDistance = saveObjDistance(idx);    
    
    filmDistance = filmDistance(idx:end);
    objDistance  = saveObjDistance(idx:end);
    focalLength  = allFocalLengths(ii);
    
    % This plots the object and film distances for all of the lenses
    loglog(objDistance,filmDistance);

    [p,n,~] = fileparts(lensFiles(ii).name);
    flFile = fullfile(lensDir,[n,'.FL.mat']);
    save(flFile,'objDistance','filmDistance','focalLength','closestDistance');
end
set(gca,'xscale','log','yscale','log');

%%
