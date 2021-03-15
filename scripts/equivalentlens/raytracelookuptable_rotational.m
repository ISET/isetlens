function [input,output,planes] = raytracelookuptable_rotational(lens,spatial_nbSamples,theta_max,theta_nbSamples,phi_nbSamples,offset)


%% Lens add additional lens surface for final ray trace (HACK)
%The script as I found only traces until the last lens surface. 
% I added an additional flat surface behind the lens which acts as the "output plane".
% This is a hack such  that the ray tracer continues until final surface.

lens = lens_addfinalsurface(lens,offset); 

%% Sampling

% Spatial sampling on the x-axis
first=lens.surfaceArray(1);
entrance_radius=first.apertureD/2;
x = linspace(0,entrance_radius,spatial_nbSamples);

% Position of the input plane: an offset in front of first lens surface:
entrance_z = first.sCenter(3)-first.sRadius-offset;
for i=1:numel(x)
   entrance(1:3,i)=[x(i); 0 ; entrance_z];
end


% Sampling Range unit directions vectors (parameterized using spherical coordinates)
thetas=linspace(0,theta_max,theta_nbSamples); % polar angle
phis = linspace(0,350,phi_nbSamples); % Azimuth angle


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
            
            
            %                input(4,r,a,t,p)=start_direction(3); % ignore z- variable
            %                gives still good fit but nu problems with bad conditioning
            
            
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

