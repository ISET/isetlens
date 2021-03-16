function [input,output,planes] = raytracelookuptable_rotational(lens,spatial_nbSamples,theta_max,theta_nbSamples,phi_nbSamples,offset)
% Coordinate defination
%{
^ (y axis)
|
|
| ---> (z axis)
|
|
(inside plane - x axis)
%}

%% Lens add additional lens surface for final ray trace (HACK)
% The script as I found only traces until the last lens surface. 
% I added an additional flat surface behind the lens which acts as the "output plane".
% This is a hack such  that the ray tracer continues until final surface.

lens = lens_addfinalsurface(lens,offset); 
%{
% Visualize the structure
lens.draw 
%}
%% Sampling

% Spatial sampling on the x-axis
firstEle=lens.surfaceArray(1); % First lens element surface
entrance_radius=firstEle.apertureD/2; % Radius of enter pupil radius
x = linspace(0,entrance_radius,spatial_nbSamples);

% Position of the input plane: an offset in front of first lens surface:
% Offset can be treated as the film distance (?)
entrance_z = firstEle.sCenter(3)-firstEle.sRadius-offset; % Seems working, but why

% Initialize input ray start position
entrance = zeros(3, numel(x));
for i=1:numel(x)
   entrance(:,i)=[x(i); 0 ; entrance_z];
end

% Sampling Range unit directions vectors (parameterized using spherical coordinates)
thetas=linspace(0,theta_max,theta_nbSamples); % polar angle
phis = linspace(0,350,phi_nbSamples); % Azimuth angle

% Initialize input ray: (r, u, v, w)
input = zeros(4, numel(x), numel(thetas), numel(phis)); 
% Initialize output ray: (x, y, u, v, w)
output = zeros(5, numel(x), numel(thetas), numel(phis));

for i=1:numel(x)
    % Starting point of the ray
    origin= entrance(:,i)';
    for t=1:numel(thetas)
        for p=1:numel(phis)
            % Direction vector of the input ray (using spherical parameterization)
            theta=thetas(t); phi=phis(p);
            start_direction = [sind(theta).*cosd(phi)  sind(theta)*sind(phi)  cosd(theta)];
            
            % Calculate input variable
            input(1,i,t,p)=sqrt(origin(1).^2+origin(2).^2); % radius
            input(2,i,t,p)=start_direction(1);
            input(3,i,t,p)=start_direction(2);
            % In principle z axis can be ignored indeed. Bring it back for
            % now just in case it will be used in future.
            % Ignoring z gives still good fit but nu problems with bad conditioning
            input(4,i,t,p)=start_direction(3); 
            
            [point,direction] = trace_io(lens,origin,start_direction);
            
            % Output variable
            output(1,i,t,p)=point(1);
            output(2,i,t,p)=point(2);
            output(3,i,t,p)=direction(1); % theta
            output(4,i,t,p)=direction(2);
            output(5,i,t,p)=direction(3);
        end
    end
end

%% Specify the chosen Input output planes
planes.input=entrance_z;
planes.output=offset;
end

