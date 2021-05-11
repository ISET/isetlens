%% Calculate pupil from ray tracing
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.3.0mm.json');
%lensFileName = fullfile('tessar.22deg.3.0mm.json');
exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)
lens=lensReverse(lensFileName);


%% Modifcation of lens parameters if desired
diaphragm_diameter=0.6;
lens.surfaceArray(6).apertureD=diaphragm_diameter
lens.apertureMiddleD=diaphragm_diameter

% Note there seems to be a redundancy in the lens which can get out of
% sync: lens.apertureMiddleD en lens.surfaceArray{i}.apertureD (i= index of
% middle aperture)
% lens.surfaceArray(6).apertureD=0.4 seems to be only used for drawing
%   lens.apertureMiddleD seems to be used for actual calculations in
%   determining the exit and entrance pupil


%% Choose entrance pupil position w.r.t. input plane
% Ideally this distance is chosen in the plane in which the entrance pupil
% doesn't shift.  

pupil_distance =  1.1439;

%% Run ray trace, and log which rays can pass
clear p;

flag_runraytrace=false;

if(not(flag_runraytrace))
    % IF we don't want to redo all the ray trace, load a cached ray trace
    % file.
    load cache/dgauss-aperture0.6-sample250.mat;
else
    
    thetas = linspace(-40,40,250);
    phis = linspace(0,359,250);
    
    
    positions=[0 0.2 0.5 0.55 0.63 0.65 0.66 0.67]
    
    
    % Initiate the arrays as NaNs, else the zeros will be interpreted at a
    % position for which a ray passed
    pupilshape_trace = nan(3,numel(positions),numel(thetas),numel(phis));
    
    for p=1:numel(positions)
        p
        for ph=1:numel(phis)
            for t=1:numel(thetas)
                
                % Origin of ray
                origin = [0;positions(p);-2];
                
                
                % Direction vector of ray
                phi=phis(ph);
                theta=thetas(t);
                direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
                
                
                % Trace ray with isetlens
                wave = lens.get('wave');
                rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
                [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
                pass_trace = not(isnan(prod(out_point)));
                if(pass_trace)
                    alpha = pupil_distance/(direction(3));
                    pointOnPupil = origin+alpha*direction;
                    pupilshape_trace(:,p,t,ph)=  pointOnPupil;
                end
                
            end
        end
    end
    
end

%% Step 1 : Fit exit pupil on axis
% At the onaxis position (p=1), there is no vignetting, and by construciton
% the pupil you see is the entrance pupil. The radius is estimated by
% finding the minimally bounding circle (using the toolbox)

p=1
Ptrace=pupilshape_trace(1:2,p,:);
Ptrace=Ptrace(1:2,:);

NaNCols = any(isnan(Ptrace));
Pnan = Ptrace(:,~NaNCols);
ZeroCols = any(Pnan(:,:)==[0;0]);
Pnan = Pnan(:,~ZeroCols);

[center0,radius0] = minboundcircle(Pnan(1,:)',Pnan(2,:)')

figure(1);clf; hold on;
viscircles(center0,radius0)
scatter(Ptrace(1,:),Ptrace(2,:),'.')


%% Step 2: Automatic estimation of the vignetting pupils
% The automatic estimation algorithm tries to fit a circle that matches the
% curvature and position on opposite (vertical) sides of the pupil.

%% Estimation of the bottom circle
% Positions at which the bottom circle is actually cutting of part of the
% entrance pupil. 
position_sel=2:8;

% The algorithm will look for the radius 


offset_lowestpos=-0.01;
stopcondition=0;

% The circles have to be at least larger than the entrance pupil radius,
% else they would be the entrance pupil by definition.

minradius=radius0; 
Rest=minradius;
while(not(prod(stopcondition)))
    for i=1:numel(position_sel)
        
        p=position_sel(i);
        Ptrace=pupilshape_trace(1:2,p,:);
        Ptrace=Ptrace(1:2,:);
        
        NaNCols = any(isnan(Ptrace));
        Pnan = Ptrace(:,~NaNCols);
        ZeroCols = any(Pnan(:,:)==[0;0]);
        Pnan = Pnan(:,~ZeroCols);
        
        % Step 1: choose lowest point
        y_lowest = min(Pnan(2,:))+offset_lowestpos;
        
        
        Rest = Rest+0.001
       stopcondition(i)=sum((sum((Pnan-[0;(y_lowest+Rest)]).^2,1)<=Rest^2)==0)<1;
    end
end
Rbottom = Rest;

% Step 5: Estimate sensitivites
ycenter_bottom=y_lowest+Rbottom;
sensitivity_bottom=ycenter_bottom/positions(p)


%% Rtop estimation for multiple circles at the same time
% to enforce consistency (minimial redius that encloses all points for each
% off axis distance
stopcondition=0;
position_sel=5:8;
minradius=radius0;
Rest=minradius;
while(not(prod(stopcondition)))
    for i=1:numel(position_sel)
        
        p=position_sel(i);
        Ptrace=pupilshape_trace(1:2,p,:);
        Ptrace=Ptrace(1:2,:);
        
        NaNCols = any(isnan(Ptrace));
        Pnan = Ptrace(:,~NaNCols);
        ZeroCols = any(Pnan(:,:)==[0;0]);
        Pnan = Pnan(:,~ZeroCols);
        
        
        % Step 1: choose lowest point
        offset_highestpos=0.001;
        y_highest = max(Pnan(2,:))+offset_highestpos;
        
     
        
        
        Rest = Rest+0.01;
       stopcondition(i)=sum((sum((Pnan-[0;(y_highest-Rest)]).^2,1)<=Rest^2)==0)<1;
    end
end

%  Fitted radius for the top circle
Rtop = Rest;

% Step 5: Estimate sensitivites
ycenter_top=y_highest-Rtop;
sensitivity_top=ycenter_top/positions(p)

%% Verify automatic fits:

figure(1);clf; hold on;
for p=1:numel(positions)
    subplot(numel(positions)/2,numel(positions)/2,p); hold on;
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    
    offset2=sensitivity2*positions(p);
    offset1=sensitivity_bottom*positions(p);
    radius1=Rbottom
    radius2=Rtop
    
    center1=[0 offset1];
    center2=[0 offset2];
    
    
    viscircles(center0,radius0,'color','k')
    viscircles(center1,radius1,'color','r')
    viscircles(center2,radius2,'color','b')
    
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    xlim(0.5*[-1 1])
    ylim(0.5*[-1 1])
    pause(0.5);
    
    
end


%% Calculate pupil positions and radii
% To be used in 'checkRayPassLens'

hx= pupil_distance;

Rpupil_bottom = Rbottom/(1-sensitivity_bottom)
Rpupil_top = Rtop/(1-sensitivity_top)


hp_bottom=hx/(1-sensitivity_bottom)
hp_top=hx/(1-sensitivity_top)


radii = [radius0 Rpupil_bottom Rpupil_top]
pupil_distances = [hx, hp_bottom hp_top]


%% Verification
figure;

for p=1:numel(positions)    
    subplot(ceil(numel(positions)/2),ceil(numel(positions)/2),p); hold on;
    
    % Plot paraxial pupil shape
    P=pupilshape(1:2,p,:);
    P=P(1:2,:);
    
        
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
                   

    %area = convhull(Ptracenonan(1,:)',Ptracenonan(2,:)')
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    % Draw entrance pupil
    viscircles([0 0],pupil_radius(entrancepupil_nr),'color','k')
    
    % Draw Bottom circle
    sensitivity = (1-hx/hp_bottom);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(hx/hp_bottom)*Rpupil_bottom;
    viscircles([0 dvignet],projected_radius,'color','b')
    
    
    % Draw Top circle
    sensitivity = (1-hx/hp_top);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(hx/hp_top)*Rpupil_top;
    viscircles([0 dvignet],projected_radius,'color','r')
       
    %axis equal
    ylim([-1 1])
    xlim(0.5*[-1 1])
    title(['x = ' num2str(positions(p))])
end


