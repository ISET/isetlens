%%
clear;
ieInit;

%%
close all
%lensName = fullfile('../lenses/fisheye.87deg.3.0mm_semiaperture1.json');
lensName = fullfile('../lenses/fisheye.87deg.3.0mm.json');


radii = 6
i=1
    disp(['radius= ' num2str(radii(i))])
    addSphere=outputSphere(radii(i),radii(i)/2);
    
    newlens = addSphere(lensReverse(lensName));
    newlens.draw
    pause(1);
    
    
    
%% Trace single ray for test
lensR=newlens;
origin=[0 1 -8]
theta=-26.6
direction=[0 sind(theta) cosd(theta)]
direction = direction/norm(direction)
[arrival_pos,arrival_dir]=rayTraceSingleRay(lensR,origin,direction)
ylim([-6 6])

%%
    %% Generate ray pairs
    maxRadius = 2;
    minRadius = 0;
    offset=0.1;
    
    [iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
        'n radius samp', 50, 'elevation max', 80,...
        'nAzSamp',100,'nElSamp',100,...
        'reverse', true,...
        'max radius', maxRadius,...
        'min radius', minRadius,...
        'inputPlaneOffset',offset,...
        'outputSurface',addSphere);
    
    
% %% Spherical coordinates for output varibles
% 
% X=oRays(:,1);
% Y=oRays(:,2);
% Z=oRays(:,3);
% 
% R = sqrt(X.^2+Y.^2+Z.^2);
% theta = atan(Z./R);
% phi= atan2(Y,X);
%    
% 
% poly1 = polyfitn(iRays,R,5); 
% poly2 = polyfitn(iRays,theta,5); 
% poly3 = polyfitn(iRays,phi,5); 



    


    
    
    %% Poly fit
    polyDeg = 5
    
    
    
    % Pupils for Double gaussian only. (At this moment estimating this takes a long time get
    % high quality)
    
    pupilPos=pupilPos - planes.input;
    
    fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
    [polyModel, jsonPath] = lensPolyFit(iRays, oRays,'planes', planes,...
        'visualize', true, 'fpath', fpath,...
        'maxdegree', polyDeg,...
        'pupil pos', pupilPos,...
        'pupil radii', pupilRadii,'lensthickness',lensThickness,'planeOffset',offset);
    
    
    for j=1:numel(polyModel)
        error(j,i) = polyModel{j}.RMSE;
    end
    figure(5);clf;
    plot(error);
    title('Errors')
    

