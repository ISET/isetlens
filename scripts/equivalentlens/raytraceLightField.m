function [input,output,planes] = raytraceLightField(lens,spatial_nbSamples,theta_max,theta_nbSamples,phi_nbSamples,offset, varargin)
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
%% Parse inputs
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('maxradius', 0, @isnumeric);
p.addParameter('minradius', 0, @isnumeric);
p.addParameter('visualize', true, @islogical);

p.parse(varargin{:});
vis = p.Results.visualize;
maxradius = p.Results.maxradius;
minradius = p.Results.minradius;
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
if isequal(maxradius, 0)
    maxradius =firstEle.apertureD/2; % Radius of enter pupil radius
end

if spatial_nbSamples == 1
    y = 0;
else
    y = linspace(minradius, maxradius,spatial_nbSamples); % Using y axis for a better ray tracing visualization
end
% Position of the input plane: an offset in front of first lens surface:
% Offset can be treated as the film distance (?)
% ZLY: Is this in mm?
%
firstVertex = firstEle.sCenter(3)-firstEle.sRadius;
entrance_z = firstVertex-offset; % Offset the distance by certain number in front of the surface

% Initialize input ray start position
entrance = zeros(3, numel(y));
for i=1:numel(y)
   entrance(:,i)=[0; y(i); entrance_z];
end

% Sampling Range unit directions vectors (parameterized using spherical coordinates)
thetas=linspace(0,theta_max,theta_nbSamples); % polar angle
phis = linspace(0,round(360 - 360/phi_nbSamples),phi_nbSamples); % Azimuth angle

% Initialize input and output samples
input = zeros(numel(y) * numel(thetas) * numel(phis), 4);
output = zeros(numel(y) * numel(thetas) * numel(phis), 5);

% Initialize origin and direction for ray tracing visualization
origins = zeros(numel(y) * numel(thetas) * numel(phis), 3);
dirs = zeros(numel(y) * numel(thetas) * numel(phis), 3);

% 
cnt = 0;
for i=1:numel(y)
    % Starting point of the ray
    origin= entrance(:,i)';
    for t=1:numel(thetas)
        for p=1:numel(phis)
            cnt = cnt + 1;
            % Direction vector of the input ray (using spherical parameterization)
            theta=thetas(t); phi=phis(p);
            start_direction = [sind(theta).*cosd(phi)  sind(theta)*sind(phi)  cosd(theta)];
            
            input(cnt, 1) = sqrt(origin(1).^2+origin(2).^2); % radius
            input(cnt, 2) = start_direction(1);
            input(cnt, 3) = start_direction(2);
            input(cnt, 4) = start_direction(3);
            
            origins(cnt, :) = origin;
            dirs(cnt, :) = start_direction;
            %
            %[point,direction] = trace_io(lens,origin,start_direction);
        end
    end
end

rays = rayC('origin',origins,'direction', dirs, 'waveIndex', ones(1, size(origins, 1)), 'wave', lens.wave);
[~, ~, pOut, pOutDir] = lens.rtThroughLens(rays, rays.get('n rays'), 'visualize', vis);
% Output variable
output(:, 1)=pOut(:, 1);
output(:, 2)=pOut(:, 2);
output(:, 3) = pOutDir(:, 1); % theta
output(:, 4) = pOutDir(:, 2);
output(:, 5) = pOutDir(:, 3);

%% Specify the chosen Input output planes
planes.input=entrance_z;
planes.output=offset;
end
