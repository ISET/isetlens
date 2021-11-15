
%% Calculate pupil from ray tracing
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName ='pixel4a-rear';

%% INput plane




lensThickness=4.827;

firstsurface_z=-lensThickness;

offset_output=1.48002192;%mm
offset_input=0.464135918;% mm
inputplane_z= firstsurface_z-offset_input


%% Choose entrance pupil position w.r.t. input plane

%% Best guess
exitpupil_distance_guess =  2.5893;





%% Get ZEMAX rays
X=dlmread('Gout-P4Ra_20111103.txt','\s',1);

Xnonan=X(~isnan(X(:,1)),:);

iRays=Xnonan(:,[3 5 6]);
oRays=Xnonan(:,[8 9 10 11 12 13]);


%% Run ray trace, and log which rays can pass
clear p;

positions=unique(iRays(:,1));



pupilshape_trace = nan(3,numel(positions),1);
       
for p=1:numel(positions)
        disp(['positions: ' num2str(p)])
        
        iRaysAtPos=iRays((iRays(:,1)==positions(p)),:);
        count=1;
        z=0; %????
        origin=[0 iRaysAtPos(1,1) inputplane_z];
        for i=1:size(iRaysAtPos,1)
            directions=iRaysAtPos(i,2:3);
            directions(3)=sqrt(1-sum(directions(1:2).^2));
            pointOnPupil = origin+(exitpupil_distance_guess/(directions(3))).*directions;
                    
            pupilshape_trace(:,p,count)=  pointOnPupil;
            count=count+1;
        end
        count

end
    
   

%% Calculate Pass/Fail accuracy
% Depending on sampling it gets about 99 % correct  Realize this is heavily
% skewed if you are sampling far from the edges of the aperture anyway. But
% as long we consistently compare different passray functions we should be
% fine.


%% Convex hull for each position

figure(1);clf;

numberPointsOnHull=100;

for p=1:numel(positions)
    subplot(5,ceil(numel(positions)/5),p); hold on;
    points=squeeze(pupilshape_trace(1:2,p,:));
    points(:,isnan(points(1,:)))=[];
    [k,av]=convhull(points')
    
    % Prune
    k=k(round(linspace(1,numel(k),numberPointsOnHull)));
    
    hull{p}=points(1:2,k);
    % Plot hull
    scatter(points(1,k),points(2,k),'.')

    axis equal
        
    % random points check
    X=0.2*randn(2,100); 
    h1=hull{p};
     in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');
    plot(X(1,in),X(2,in),'g.') % points inside
    plot(X(1,~in),X(2,~in),'r.') % points outside
    
    ylim([-2 2])
    xlim([-2 2])
    
end

%% Plot evolution of convex hull points
figure; hold on
clear points
    for a=1:numberPointsOnHull
    for p=1:numel(positions)
    temp=hull{p};
        points(p,:,a)=temp(:,a);
    end
    plot(points(:,:,a))
end

return
%% Whcih method of evaluation of hull is faster?
h1=hull{1}
for t=1:1000
x_test=rand(1);y_test=rand(1);
tic; in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)'); time_inpolygon(t)=toc;
tic; IN = inhull(X',h1');time_inhull(t)=toc;
end
figure
boxplot([time_inpolygon; time_inhull]')



  %% Minbound ellipse
figure;  

% compare with hull for comparison
for p=1:numel(positions)
p

    subplot(5,ceil(numel(positions)/5),p); hold on;

   
   axis equal
        
    % random points check using convex heull
    X=1.2*randn(2,1000); 
    h1=hull{p};
     in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');
    plot(X(1,in),X(2,in),'g.') % points inside
    plot(X(1,~in),X(2,~in),'r.') % points outside
     
    
    % Plot fitted Ellipse
    [A , c] =MinVolEllipse(hull{p}, 0.01);
    Ellipse_plot(A,c)
    
    [U D V] = svd(A);
    radius_major(p) = 1/sqrt(D(1,1));
    radius_minor(p) = 1/sqrt(D(2,2));
    centers(:,p)=c;
    
        
    ylim([-2 2.5])
    xlim([-2 2])
    
end

%%
    figure;
    subplot(211)
    plot(positions,radius_major,positions,radius_minor)
    title('Ellipse Radii')
    subplot(212)
    plot(positions,centers)
    title('Ellipse centers')