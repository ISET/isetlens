%% Single ray trace example
%
% Trace a single ray. Just to clarify the basic operation.
%
% Thomas Goossens

%%
ieInit

%% Read a lens file and create a lens

lensFileName = fullfile(piDirGet('lens'),'dgauss.22deg.50.0mm.json');
thisLens = lensC('fileName', lensFileName);
wave = thisLens.get('wave');

%% Lens add surface for final ray trace
%
% The script as TG found it only traces until the last surface. He added
% one more nearly flat surface behind the lens. This is a hack such that
% the ray tracer continues until final surface for visualisation.
%
% I think we have other ways, by adding film.  But for now, let's just use
% Thomas' method.

radiusfinal = 1e9;   % large to make it nearly flat
finalsurface = surfaceC('sCenter', [0 0 radiusfinal+20], 'sRadius',radiusfinal,'wave',wave);
finalsurface.apertureD = 1000;                

thisLens.surfaceArray(numel(thisLens.surfaceArray)+1)=finalsurface;


%%  Trace ray

%%% Choose a ray origin and angle
thetas=-15; 
origin= [0 12 -60];
for t=1:numel(thetas)
    theta=thetas(t);
    direction = [0 sind(theta) cosd(theta)];
    rays = rayC('origin',origin,'direction', direction, 'waveIndex', 1, 'wave', wave);
    
    % Trace the ray  
    thisLens.rtThroughLens(rays,1);
end
hold on;

%% Show the ray object

disp(rays)

%% END