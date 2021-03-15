%% Example Fitting polynomials to a rotationally symmetric lens

%% Notational conventions
% A ray arriving or departing from a plane is described as (x,y,u,v,w) with
% (x,y) the coordinate in the plane and (u,v,w) the direction vector in 3D
% space.
% The coordinate system is succh that z lies on the optical axis. 
% y= is vertical, x=depth (into the screen). 

clear;close all;
ieInit

%% Read a lens file and create a lens
%lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm.json');
lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm-reverse.json');
exist(lensFileName,'file');
lens = lensC('fileName', lensFileName)
wave = lens.get('wave');

%% Sampling options 


spatial_nbSamples=10; % Spatial sampling of [0,radius] domain

phi_nbSamples=10; % Uniform sampling of the azimuth angle 

theta_max=10; % maximal polar angle of incident ray
theta_nbSamples=10; %uniform sampling polar angle range

%% Choose input output plane
% Offset describes the distance in front of the first lens surface and the
% distance behind the last lens surface
offset=0.1;


%% Fitting options
% A polynomial degree of 4 seems to be the minimum required to get a
% reasonable
% fit. TODO: find a physical reason for this.
polynomial_degree=4; 


%% Generate lookup table
% This generate a lookup table between (x,u,v) (input plane) and
% (x,y,u,v,w) in the output plane.
% Because of rotational symmetry we only sample points on the x-axis.
% A rotation matrix can always be used to rotate an arbitrary coordinate to
% the position such that the y coordinate is zero.

 [input,output,planes] = raytracelookuptable_rotational(lens,spatial_nbSamples,theta_max,theta_nbSamples,phi_nbSamples,offset);

%% Fit polynomial
% Each output variable will be  predicted
% by a multivariate polynomial with three variables: x,u,v.
% Each fitted polynomial is a struct containing all information about the quality of the fit, powers and coefficients.
%
% An analytical expression can be generated using 'polyn2sym(poly{i})'


clear poly
% Full sampling set
I = input(:,:)';
O = output(:,:)';

% Training set 
I_train = input(:,1:2:end)';
O_train = output(:,1:2:end)';

for i=1:size(O,2)
    poly{i} = polyfitn(I_train,O_train(:,i),polynomial_degree);
    poly{i}.VarNames={'x','u','v'};
    
    % save information about position of input output planes
    poly{i}.planes =planes
end

    
%% Save polynomial to file
save('poly.mat','poly')

%% Fit rational functions

%%  Visualize polynomial fit 
labels = {'x','y','u','v','w'};
fig=figure(6);clf;
fig.Position=[231 386 1419 311];
for i=1:5
    pred(i,:)= polyvaln(poly{i},I);
    
    subplot(1,5,i); hold on;
    h=scatter(pred(i,:),O(:,i),'Marker','.','MarkerEdgeColor','r')
    plot(max(abs(O(:,i)))*[-1 1],max(abs(O(:,i)))*[-1 1],'k','linewidth',1)
    xlim([min(O(:,i)) max(O(:,i))])
    title(labels{i})
    xlabel('Polynomial')
    ylabel('Ray trace')
end

%% Plot relative error
predneural=neural(I');
for i=1:size(pred,2)
   relerr(i)=norm([pred(:,i)-O(i,:)'])/norm(O(i,:)');
   
end
figure;
hist(relerr,100)




% out_dir =
% 
%    -0.2783         0    0.9605
