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
    %addSphere=outputSphere(radii(i),0.1*radii(i)/10);
    addSphere=outputSphere(radii(i),radii(i)/2);
    
    newlens = addSphere(lensReverse(lensName));
    newlens.draw
    pause(1);
    
    
    
%% Trace single ray for test
lensR=newlens;


origin=[0 1 -9];thetas=70:-0.1:-70;
%origin=[0 0.5 -9];thetas=30:-0.1:-50;%thetas=10:-0.1:-10;
%origin=[0 0.5 -9];thetas=-40:0.1:40;
origin = repmat(origin,[numel(thetas) 1]);
phi=0;
u=sind(thetas');
direction=[sind(thetas').*sind(phi) sind(thetas')*cosd(phi) cosd(thetas')]

[arrival_pos,arrival_dir]=rayTraceSingleRay(lensR,origin,direction)
ylim([-radii radii])




outputs = [arrival_pos arrival_dir]
x =outputs(:,1)
y =outputs(:,2)
z =outputs(:,3)
dy =outputs(:,5)
dz =outputs(:,6)
%% fdf
clear fpoly fsym fpad pred;
degree=8
fig=figure(2);clf; hold on;

sel = [2 3  5 6]
labels = {'x', 'y','z','dx','dy','dz'}

for o=1:numel(sel)
subplot(1,numel(sel),o);hold on;
out=outputs(:,sel(o));
plot(u,out,'k.')

fpoly{o}=polyfitn(u,outputs(:,sel(o)),degree)
fsym{o}=polyn2sym(fpoly{o})
pred=polyvaln(fpoly{o},u);
%pred=myNeuralNetworkFunction(u)
%fpad{o}=pade(fsym{o},'Order',[3 3])
plot(u,pred,'r')

%fplot(fpad)
xlim(1.5*[min(u) max(u)])
ylim([min(out) max(out)])
title(labels{sel(o)})
end


%%
    %% Generate ray pairs
    maxRadius = 2;
    minRadius = 0;
    offset=0.1;
    
    [iRays, oRays, planes, nanIdx, pupilPos, pupilRadii,lensThickness] = lensRayPairs(lensName, 'visualize', false,...
        'n radius samp', 50, 'elevation max', 60,...
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



    


   %%
   x =oRays(:,1);
y =oRays(:,2);
z =oRays(:,3);
dy =oRays(:,5);
dz =oRays(:,6);
    
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
    
    
    for j=1:(numel(polyModel)-1)
        error(j,i) = polyModel{j}.RMSE;
    end
    figure(5);clf;
    plot(error);
    title('Errors')
    


    
%%
figure;clf;scatter(oRays(:,1),neuralX(iRays))
figure;clf;scatter(oRays(:,2),neuralY(iRays))
figure;clf;scatter(oRays(:,3),neuralZ(iRays))
figure;clf;scatter(oRays(:,4),neuralDX(iRays))
figure;clf;scatter(oRays(:,5),neuralDY(iRays))
figure;clf;scatter(oRays(:,6),neuralDZ(iRays))
    