% This example script uses existing code from Michael Pieroni to calculate
% the entrance pupils for a given lens design.
% It works projecting each lens element back to the object space (in
% paraxial limit)
% This means that there is an entrance pupil for each lens. 
%
% In practice it will usually be the projection of the diapgraphm that is
% the most limiting.
% However, at off-axis positions the other pupils also can start limiting
% the rays. This effectively corresponds to mechanical/optical vignetting.
%
% Thomas Goossens

%% Load lens file
clear;close all;

lensFileName = fullfile('dgauss.22deg.3.0mm.json');
exist(lensFileName,'file');


lens = lensC('fileName', lensFileName)



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

 
%% Find Pupils
% Optical system needs to be defined to be comptaible wich legacy code
% 'paraxFindPupils'.
opticalsystem = lens.get('optical system'); 
exit = paraxFindPupils(opticalsystem,'exit'); % exit pupils
entrance = paraxFindPupils(opticalsystem,'entrance'); % entrance pupils;


% TG: To check: As far as I can see now the entrance (exit) pupil positions are defined
% with respect to the first (last) surface.


%% Draw diagram Entrance pupils

lens.draw
for i=1:numel(entrance)
    
    %% entrance pupil (with respect to first surface)
    firstEle=lens.surfaceArray(1); % First lens element
    firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    pupil_radius(i)=entrance{i}.diam(1,1)
    pupil_position(i)=firstsurface_z+entrance{i}.z_pos(1)  +0.1697;
    
    
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    % Number each entrance pupil so it is easy to see to which surface it
    % belongs
    text(pupil_position(i),1.2*pupil_radius(i),num2str(i))
    
    
    
end
title('Entrance pupils ')
legh=legend('');
legh.Visible='off';




%% Check if ray can pass
clear p;






thetas = linspace(-40,40,150);
phis = linspace(0,359,150);

positions=[0 0.8 0.85 0.9]


% Initiate the arrays as NaNs, else the zeros will be interpreted at a
% position for which a ray passed
pupilshape = nan(3,numel(pupil_position),numel(thetas),numel(phis));
pupilshape_trace = nan(3,numel(pupil_position),numel(thetas),numel(phis));

for p=1:numel(positions)
    for ph=1:numel(phis)
    for t=1:numel(thetas)
        
        % Origin of ray
        origin = [0;positions(p);-2];
        
        
        % Direction vector of ray
        phi=phis(ph);
        theta=thetas(t);
        direction = [sind(theta).*cosd(phi);  sind(theta)*sind(phi) ; cosd(theta)];
        
        
        
        
        % Check whether ray goes through all pupils
        for i=1:numel(entrance)
            alpha = (pupil_position(i) - origin(3))/(direction(3));
            pointOnPupil(:,i) = origin+alpha*direction;
            
            passpupil(i)= norm(pointOnPupil(1:2,i))<=pupil_radius(i);
                        
        end
        pass = prod(passpupil); % boolean AND operation, ray needs to pass through all
        
        if(pass)
            pupilshape(:,p,t,ph)= pointOnPupil(:,6);
        end
        
        
        
        % Trace ray with isetlens
        wave = lens.get('wave');
        rays = rayC('origin',origin','direction', direction', 'waveIndex', 1, 'wave', wave);
        [~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',false);
        pass_trace = not(isnan(prod(out_point)));
        if(pass_trace)
            pupilshape_trace(:,p,t,ph)=  pointOnPupil(:,6);
        end
        
        compare(:,p,t,ph) = [pass_trace pass];
        
    end
    end
end

%% Plot pupil shapes
figure;
for p=1:numel(positions)
    subplot(1,numel(positions),p); hold on;
    
    % Plot paraxial pupil shape
    P=pupilshape(1:2,p,:);
    P=P(1:2,:);
  
    scatter(P(1,:),P(2,:),'.')
    
    % Plot traced pupil shape
    Ptrace=pupilshape_trace(1:2,p,:);
    Ptrace=Ptrace(1:2,:);
  
    scatter(Ptrace(1,:),Ptrace(2,:),'o')
    
    
    % Draw exit pupil
    viscircles([0 0],pupil_radius(6),'color','k')
    
    
    % Draw dominant vignetting circle pupil (last surface)
    hx=(pupil_position(6)-origin(3));
    hp=(pupil_position(end)-origin(3)); % h/l
    sensitivity = (1-hx/hp); 
    dvignet=sensitivity*positions(p);
    projected_radius = hx/hp*pupil_radius(end);
    viscircles([0 dvignet],projected_radius)
    
    % Draw dominant vignetting circle pupil (first surface)
    hx=(pupil_position(6)-origin(3));
    hp=(pupil_position(1)-origin(3)); % h/l
    sensitivity = (1-hx/hp); 
    dvignet=sensitivity*positions(p);
    projected_radius = hx/hp*pupil_radius(1);
    viscircles([0 dvignet],projected_radius,'color','b')
    
    axis equal
    ylim([-1 1])
    xlim(0.5*[-1 1])
    title(['x = ' num2str(positions(p))])
end


%%
th=-19;
origin=[0 ;0.5;-3];
dir= [0; sind(th) ;cosd(th)];
rays = rayC('origin',origin','direction',dir', 'waveIndex', 1, 'wave', wave);
[~,~,out_point,out_dir]=lens.rtThroughLens(rays,1,'visualize',true);
hold on;


% Draw diagram Entrance pupils
for i=1:numel(entrance)

    
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    line([1 1]*pupil_position(i),[pupil_radius(i) pupil_radius(i)*1.1],'linewidth',4)
    line([1 1]*pupil_position(i),[-pupil_radius(i) -pupil_radius(i)*1.1],'linewidth',4)
    
    % Number each entrance pupil so it is easy to see to which surface it
    % belongs
    text(pupil_position(i),1.2*pupil_radius(i),num2str(i))
    
    
    
    
    
    
end

% Draw condinued ray
r = origin + alpha .* dir;
alpha=linspace(0,10,100);
plot(r(3,:),r(2,:),'r--')


% Did they ray pass according to pupil intersections?

pass=checkRayPassLens(origin,dir,pupil_position,pupil_radius)