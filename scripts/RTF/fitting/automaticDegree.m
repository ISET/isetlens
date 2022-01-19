clear

%% Lens
lensFileName = 'dgauss.22deg.12.5mm.json';
%lensFileName = 'fisheye.87deg.50.0mm.json';
%lensFileName = 'tessar.22deg.50.0mm.json';
lensFileName = 'wide.56deg.12.5mm.json';

% Set diaphragm size small enough, else PBRT might automatically
% adjust causing a mismatchin the comparison. 
lens=lensReverse(lensFileName);
radius_firstsurface=lens.surfaceArray(1).apertureD/2;
diaphragmDiameter_mm=lens.apertureMiddleD/2;

% Generate ray pairs
reverse = true; 
maxRadius = radius_firstsurface*3.5; % enough margin
minRadius = 0;
offset=0.01;
lens.get('infocusdistance')
offset_sensorside=offset;
offset_objectside=lens.get('infocusdistance'); %%mm
%% Dataset for fitting

[iRays, oRays] = lensRayPairs(lensFileName, 'visualize', false,...
    'n radius samp', 50, 'elevation max', 60,...
    'nAzSamp',50,'nElSamp',50,...
    'reverse', true,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset),'diaphragmdiameter',diaphragmDiameter_mm);

%% Dataset for validation

[iRays2, oRays2] = lensRayPairs(lensFileName, 'visualize', false,...
    'n radius samp', 70, 'elevation max', 60,...
    'nAzSamp',90,'nElSamp',80,...
    'reverse', true,... 
    'max radius', maxRadius,...
    'min radius', minRadius,...
    'inputPlaneOffset',offset,...
    'outputSurface',outputPlane(offset),'diaphragmdiameter',diaphragmDiameter_mm);


%% Pixel 4a



%% Fit polynomials
degrees = [1 2 3 4 5 6 7 8];

for i =1:numel(degrees)
    polyModel{i}= lensPolyFit(iRays, oRays,...
        'visualize', false,...
        'maxdegree', degrees(i),...
        'sparsitytolerance',0);
    
    poly = polyModel{i};
    nonanVals = ~isnan(oRays2(:,1));
    removeNans = @(x) x(nonanVals,:);
    for p=1:numel(poly)
        estimate(:,p)=polyvaln(poly{p},iRays2);
       relerror(i,p)=norm(removeNans(oRays2(:,p)-estimate(:,p)))/norm(removeNans(oRays2(:,p)))
       allrelerr(:,i,p)=abs((oRays2(:,p)-estimate(:,p)))./abs((oRays2(:,p)));
       allabserr(:,i,p)=abs((oRays2(:,p)-estimate(:,p)));
    end
    
end

%% Plot errors
figure;
subplot(211)
semilogy(degrees,relerror,'.-','markersize',10)
xlabel('Polynomialdegree')
title('Relative Error')
subplot(212)
title('Median Error')
%semilogy(degrees,medianerror,'.-','markersize',10)
all = permute(allrelerr,[1 3 2]);

group =kron(1:numel(degrees),[ 1 1 1 1 1 1]);
boxplot(all(:,:),group,'symbol','+')
set(gca,'YScale','log')
ylim([1e-6 10])


%% Plot all input rays rays that give large errors
%% Estimate Pass No Pass Function using the ellipse method
% Collect all rays per off-axis position
lensThickness=lens.get('lens thickness')
intersectionPlaneDistance=2.5893;
[pupilShapes,positions,intersectionplane] = vignettingIntersectionsWithPlanePerPosition(iRays,-lensThickness-offset_sensorside,'circleplanedistance',intersectionPlaneDistance);

[radii,centers] = vignettingFitEllipses(pupilShapes);

%% Subselection of large errors
clear planeIntersections

degree=4
outputvars=4
error_threshhold=10^-1;
subset=squeeze(allrelerr(:,degree,outputvars));
largeErrors=any(and(subset>error_threshhold  ,~isinf(subset)),2);
percentage=sum(largeErrors)/size(removeNans(iRays2),1)*100
iRays2LargeErr = iRays2(largeErrors,:);

directions = [iRays2LargeErr(:,2:3) sqrt(1-sum(iRays2LargeErr(:,2:3).^2,2))];
origins=[zeros(size(iRays2LargeErr,1),1) iRays2LargeErr(:,1) zeros(size(iRays2LargeErr,1),1)];

alpha = intersectionPlaneDistance./directions(:,3);
    
planeIntersections(:,1:3) = origins+alpha.*directions;

%%

figure(4);clf
hold on;
% Determine all unique positions 
positionsErr=unique(iRays(:,1));
 nbPos = numel(positionsErr);
% Draw a   subset of rays for visual effect
for p=1:size(positionsErr)
    subplot(round(sqrt(nbPos)),ceil(sqrt(nbPos)),p); hold on

    % Plot ray intersections
    indices=iRays2LargeErr(:,1)==positions(p);
     data=planeIntersections(indices,:);
     scatter(data(:,1),data(:,2),'.');
     
    % Plot ellipse on top
    radiiInterp = interp1(positions,radii',positionsErr(p));
    centerInterp = interp1(positions,centers',positionsErr(p));
    h = drawellipse('Center',centerInterp,'SemiAxes',radiiInterp,'color','r');
end 


%% Compare relative sizes of the output variables
figure;
labels={'x' 'y' 'z' 'dx' 'dy' 'dz'};

h=boxplot(oRays2,'Labels',labels)
set(gca,'YScale','log')
ylabel('')
