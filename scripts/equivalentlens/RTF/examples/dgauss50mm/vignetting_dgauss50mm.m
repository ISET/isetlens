
%% Calculate pupil from ray tracing
%
% The lens is samples for multiple off-axis positions. At each off
% axis-position the domain of rays that pass (entrance pupil) will vary and
% be described by the intersection of 3 circles. This script aims to
% automatically estimate the 3 circles.


% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.50.0mm_aperture6.0.json');

exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)


lens=lensReverse(lensFileName);
disp('CHeck whether using reverse or forward lens')
lens.draw


    
%Set diaphraghm diameter. Should be smaller than 9  to find the exit pupil
%in this case
diaphragm_diameter= 2;
lens.surfaceArray(6).apertureD=diaphragm_diameter;
lens.apertureMiddleD=diaphragm_diameter;

%% INput plane

firstEle=lens.surfaceArray(1); % First lens element
firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    
offset_inputplane=0.01;%mm
inputplane_z= firstsurface_z-offset_inputplane

%% Choose entrance pupil position w.r.t. input plane
% Ideally this distance is chosen in the plane in which the entrance pupil
% doesn't shift.  
% This is the best guess. In principle the algorithm can handle  an unknown
% entrancepupil distance


exitpupil_distance_guess =  17;

%% Run ray trace, and log which rays can pass
clear p;

flag_runraytrace=true;

if(not(flag_runraytrace))
    % IF we don't want to redo all the ray trace, load a cached ray trace
    % file. This file was generated by just using save('./cache/...')
        
    %load('./cache/dgauss.22deg.50.0mm_aperture6.0.json-offset0.01-September-29-2021_ 3-28PM.mat') % Forward lens
    load('./cache/dgauss.22deg.50.0mm_aperture6.0.json-offset0.01-October-06-2021_2-30PM.mat')
else
     
 
 % Lens reverse
positions =[0    1.0000    2.0000    3.0000    4.0000    5.0000    6.0000    7.0000    8.0000    9.0000   10.0000   10.1000   10.2000 10.3000   10.4000   10.5000];


positions =[0.1    1.0000    2.0000    3.0000    4.0000    5.0000    6.0000    7.0000    8.0000    9.0000   10.0000   10.1000   10.2000 10.3000   10.4000   10.5000 11 12 13 14 15 16];

 
 

    
    % Initiate the arrays as NaNs, else the zeros will be interpreted at a
    % position for which a ray passed
    nbThetas=600;
    nbPhis=600;
    pupilshape_trace = nan(3,numel(positions),nbThetas,nbPhis);
    pupilshape_vignetted= nan(3,numel(positions),nbThetas,nbPhis);
    
    
    
    for p=1:numel(positions)
        disp(['positions: ' num2str(p)])
        maxTheta=40;
        nbPhis=nbThetas;
        thetas = linspace(-maxTheta,maxTheta,nbThetas);
        phis = linspace(0,359,nbPhis);

        
        count=1;
        for ph=1:numel(phis)
                        
            for t=1:numel(thetas)
                
                % Origin of ray
                origins(count,:) = [0;positions(p);inputplane_z];
                
                
                % Direction vector of ray
                phi=phis(ph);
                theta=thetas(t);
                
                
                directions(count,:) = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
                
                count=count+1;
            end
        end
        
        
                % Trace ray with isetlens
                
                 waveIndices=1*ones(1, size(origins, 1));
                rays = rayC('origin',origins,'direction', directions, 'waveIndex', waveIndices, 'wave', lens.wave);
                [~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', false);
                
                pass_trace = not(isnan(prod(pOut,2)));    
    
                % If the ray passes the lens, save at which coordinate it
                % intersected with the chosen pupil plane.
                
                count=1;
                countVignetted=1;
                for i=1:numel(pass_trace)
                    if(pass_trace(i))
                    % Linear extrapolation from origin to find intersection
                    % with entrance_pupil plane
                    pointOnPupil = origins(i,:)+(exitpupil_distance_guess/(directions(i,3)))*directions(i,:);
                    
                    pupilshape_trace(:,p,count)=  pointOnPupil;
                    count=count+1;
                    else
                      pointOnPupil = origins(i,:)+(exitpupil_distance_guess/(directions(i,3)))*directions(i,:);
                      pupilshape_vignetted(:,p,countVignetted)=  pointOnPupil;
                      countVignetted=countVignetted+1;
                    end
                end
                
            end
        end
    
    
    % Save the ray trace, because hey, it takes a long time!
    close all;
    save(['./cache/' lensFileName '-offset' num2str(offset_inputplane) 'scenetofilm-' datestr(now,'mmmm-dd-yyyy_HH-MMAM') '.mat'])



    


 
 
%% Step 1 : Fit exit pupil on-axis.   
% At the onaxis position (p=1), there is no vignetting, and by construciton
% the pupil you see is the entrance pupil. The radius is estimated by
% finding the minimally bounding circle (using the toolbox)

p=5
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



%% Step 1: Automatic entrance puil
% When the exit pupil distance is not exactly known, we also need to
% estimate a sensitivity for the entrance pupil as it will not remaind
% stationairy.
% The top part is used because (at least for dgauss) this is the last
% surface to be cut off

% Top
position_selection=[3]; % Choose the positions for which the top circle is unaffected by vignetting.
offaxis_distances=positions(position_selection);


offset=0.01;
stepsize_radius=0.01;
[radius_entrance,sensitivity_entrance]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'offset',offset,'stepsizeradius',stepsize_radius)


%radius_entrance=radius0
%sensitivity_entrance=0.7991
%% Step 2: Automatic estimation of the vignetting circles
% The automatic estimation algorithm tries to fit a circle that matches the
% curvature and position on opposite (vertical) sides of the pupil.

% Circle 2
position_selection=[7];
offaxis_distances=positions(position_selection);
offset=0.01;
stepsize_radius=0.1;
[radius_bottom,sensitivity_bottom]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"bottom",'offset',offset,'stepsizeradius',stepsize_radius)

% Circle 1
position_selection=[14];
offaxis_distances=positions(position_selection);
offset=0.01;
stepsize_radius=0.1;
[radius_top,sensitivity_top]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"top",'offset',offset,'stepsize radius',stepsize_radius)


%% Circle 3 bottom
position_selection=7
offaxis_distances=positions(position_selection);
offset=0.01;
stepsize_radius=0.1;
[radius_3,sensitivity_3]=findCuttingCircleEdge(pupilshape_trace(1:2,position_selection,:),offaxis_distances,"bottom",'offset',offset,'stepsize radius',stepsize_radius)





%% Circle information for PBRT RTF

circleRadii = [radius_entrance radius_bottom radius_top ]
circleSensitivities = [sensitivity_entrance sensitivity_bottom sensitivity_top ]
circlePlaneZ=exitpupil_distance_guess

circleRadii =[5.2300/7*2    8.1000  107.3000  ,  7.2291  125.3000    9.5000  ]
circleSensitivities =[ 0.0652    1.0075   -9.8241,    0.7991  -11.5487   -0.0152 ]




%%  Show nonlinearity
clear centers radii
for p=1:(numel(positions))
    p
Ptrace=pupilshape_trace(1:2,p,:);
Ptrace=Ptrace(1:2,:);

NaNCols = any(isnan(Ptrace));
Pnan = Ptrace(:,~NaNCols);
ZeroCols = any(Pnan(:,:)==[0;0]);
Pnan = Pnan(:,~ZeroCols);

[center0,radius0] = minboundcircle(Pnan(1,:)',Pnan(2,:)')

offaxis_distances=positions(p);
ytop(p)=max(pupilshape_trace(2,p,:));

offset=0.1;
stepsize_radius=0.1;
%[radius0,~]=findCuttingCircleEdge(pupilshape_trace(1:2,p,:),offaxis_distances,"left",'offset',offset,'stepsizeradius',stepsize_radius)
radius0 = abs(min(pupilshape_trace(1,p,:)))
i=find(pupilshape_trace(1,p,:)==(min(pupilshape_trace(1,p,:))))
center0=[0 pupilshape_trace(2,p,i)]


if(isempty(radius0) || isempty(center0))
    p=p-1;
    break;
end
radii(p)=radius0;
centers(:,p)=center0;

end
maxindex= p;
subsel=1:maxindex;

%% Fit polynomials
subsel=1:10;

figure(2);clf
subplot(211); hold on;
plot(positions(subsel),radii(subsel))
normalized_radii=radii(subsel)/radii(1)-1;
polyradius=polyfitn(positions(subsel),normalized_radii,'x^2')
plot(positions,radii(1)*(1+polyvaln(polyradius,positions)),'r--')
legend('Simulated','Polynomial fit','location','best')
title('Radius')
subplot(212); hold on;
plot(positions(subsel),centers(2,subsel))
plot(positions(subsel),sensitivity_entrance*positions(subsel),'k--')

polycenterY=polyfitn(positions(subsel),centers(2,subsel),'x,x^2')

plot(positions,polyvaln(polycenterY,positions),'r--')
legend('Center Y position','Linear approximation','Polynomial approx','location','best')

title('Center')


%% Verify automatic fits:
colors={'k' 'r' 'g' 'b' 'm' [0.9 0.5 0.9] [1 0 1] };

figure(1);clf; hold on;
for p=1:numel(positions)
    subplot(2,round(numel(positions)/2),p); hold on;
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    for c=1:numel(circleRadii)
        % Calculate offset of each circle
         offset=circleSensitivities(c)*positions(p);
          
         % Draw circles
         viscircles([0 offset],circleRadii(c),'color',colors{c},'linewidth',1)
    end
    
      
     % Nonlinear circle change
     radius_nonlin=1+polyvaln(polyradius,positions(p)); 
     offset_nonlin=polyvaln(polycenterY,positions(p)); 
     viscircles([0 offset_nonlin],radius_nonlin*radii(1),'color','m','linewidth',1)
     
    
     % Draw off axis position
     scatter(0,positions(p))
     
    xlim(2*radius_entrance*[-1 1])
    ylim(3*radius_entrance*[-1 1])
    title(positions(p))
    %axis equal
    %pause(0.5);
    
    
end



return
%% Calculate pupil positions and radii
% To be used in 'checkRayPassLens'
% All circle intersections where done in the entrance pupil plane.
% Each circle is a projection of an actual pupil. Here I project the
% corresponding circles back to their respective plane where they are
% centered on the optical axis.

% Distance to entrance pupil is already known by construction unless a
% wrong guess was taken. When the guess was good sensitivity_entrance
% should be basically zero.
hx= exitpupil_distance_guess/(1-(sensitivity_entrance))
Rpupil_entrance = radius_entrance/(1-sensitivity_entrance)

% Calculate radius of a pupil by projecting it back to its actual plane
% (where it is cented on the optical axis)
Rpupil_bottom = radius_bottom/(1-sensitivity_bottom)
Rpupil_top = radius_top/(1-sensitivity_top)


% Calculate positions of pupils relative to the input plane
hp_bottom=exitpupil_distance_guess/(1-sensitivity_bottom)
hp_top=exitpupil_distance_guess/(1-sensitivity_top)


% Information to be used for PBRT domain evaluation (FOR ZHENG)
radii = [Rpupil_entrance Rpupil_bottom Rpupil_top]
pupil_distances = [hx, hp_bottom hp_top]

%
% %%
% radii =
%
%     0.4698    4.3275    0.5991
% 
% 
% pupil_distances =
% 
% 1.1480   10.3072    0.1570
% 

%% Second Verification (to check the ebove equations)
fig=figure(10);clf

fig.Position(3:4)=[938 362]

for p=1:numel(positions)    
    subplot(2,ceil(numel(positions)/2),p); hold on;
    
        
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
    scatter(Ptrace(1,:),Ptrace(2,:),'.')
    
    
    lw=2; %Linewidth
    
    % Draw entrance pupil
    sensitivity = (1-exitpupil_distance_guess/hx);
    dentrance=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hx)*Rpupil_entrance;
    viscircles([0 dentrance],projected_radius,'color','k','linewidth',lw)
    
    % Draw Bottom circle
    sensitivity = (1-exitpupil_distance_guess/hp_bottom);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hp_bottom)*Rpupil_bottom;
    viscircles([0 dvignet],projected_radius,'color',[0 0 0.8],'linewidth',lw)
    
    
    % Draw Top circle
    sensitivity = (1-exitpupil_distance_guess/hp_top);
    dvignet=sensitivity*positions(p);
    projected_radius = abs(exitpupil_distance_guess/hp_top)*Rpupil_top;
    viscircles([0 dvignet],projected_radius,'color',[0.8 0 0 ],'linewidth',lw)
    
    
    %axis equal
    ylim(20*[-1 1])
    xlim(20*[-1 1])
    
   
    ax=gca;
    ax.XAxis.Visible='off';
    ax.YAxis.Visible='off'; 
    
    
    title(['p = ' num2str(positions(p)) ' mm'])
end

saveas(gcf,'dgauss_threecircles.eps','epsc')



%%%

%% Check pass
% Ray trace sampling parameters
nbThetas=40;
nbPhis=nbThetas;
thetas = linspace(-40,40,nbThetas);
phis = linspace(0,359,nbPhis);

counter=1;
for p=1:numel(positions)
    p
    for ph=1:numel(phis)
        for t=1:numel(thetas)
            
            % Origin of ray
            origin = [0;positions(p);inputplane_z];
            
            
            % Direction vector of ray
            phi=phis(ph);
            theta=thetas(t);
            direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
            
            % Trace ray with isetlens
            wave = lens.get('wave');
            rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
            [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
            pass_trace = not(isnan(prod(out_point)));
            pass_circle =checkRayPassLens(origin,direction, pupil_distances,radii);
            
            comparison(counter,1:2) = [pass_trace pass_circle];
            
            counter=counter+1;
        end
    end
end


%% Calculate Pass/Fail accuracy
% Depending on sampling it gets about 99 % correct  Realize this is heavily
% skewed if you are sampling far from the edges of the aperture anyway. But
% as long we consistently compare different passray functions we should be
% fine.

passratio=sum((comparison(:,1)==comparison(:,2)))/size(comparison,1)


%% Convex hull for each position

figure(1);clf;

for p=1:numel(positions)
    subplot(2,numel(positions)/2,p); hold on;
    points=squeeze(pupilshape_trace(1:2,p,:));
    points(:,isnan(points(1,:)))=[];
    [k,av]=convhull(points')
    hull{p}=points(:,k);
    
    
    plot(points(1,k),points(2,k))

    axis equal
        
    % random points check
    X=randn(2,100); 
    h1=hull{p};
     in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');
    plot(X(1,in),X(2,in),'g+') % points inside
    plot(X(1,~in),X(2,~in),'r+') % points outside
    
    ylim([-2 2])
    xlim([-2 2])
    
end
%%
h1=hull{1}
x_test=0;
y_test=0;
tic; in = inpolygon(X(1,:)',X(2,:)',h1(1,:)',h1(2,:)');toc
tic; IN = inhull(X',h1');toc
