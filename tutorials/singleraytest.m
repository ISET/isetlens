%% Single ray trace example
% This is a minimal ray tracing example. 
% The script takes a given lens design and traces a single ray which can be
% chosen. However, the raytracer only visualizes. The function doesn't
% return the actual traced rays, so as such, it is not possible to
% calculate angles using this script.
%
% Thomas Goossens


clear;close all;
ieInit



%% Read a lens file and create a lens
lensFileName = fullfile(ilensRootPath,'data','lens','dgauss.22deg.50.0mm.dat');
%lensFileName = fullfile(ilensRootPath,'data','lens','petzval.12deg.50.0mm.dat')
%lensFileName = fullfile(ilensRootPath,'data','lens','fisheye.87deg.50.0mm.dat');

%thisLens.surfaceArray(12).sRadius=50;
exist(lensFileName,'file');


thisLens = lensC('fileName', lensFileName)

wave = thisLens.get('wave');



%% HACK: Lens add aperture surface for final ray trace
%The script as I found it only traces until the last
% surface. I added ony more nearly flat surface behind the lens. This is a hack such that the ray tracer continues until final surface
% for visualisation. 

radiusfinal=1e9; % large to make it nearly flat
finalsurface= surfaceC('sCenter', [0 0 radiusfinal+20], 'sRadius',radiusfinal,'wave',wave)
finalsurface.apertureD=200 ;                
        
thisLens.surfaceArray(numel(thisLens.surfaceArray)+1)=finalsurface;


%%  Trace ray

%%% Choose a ray origin and angle


thetas=-15; origin= [0 50 -200];
for t=1:numel(thetas)
    theta=thetas(t);
    direction = [0 sind(theta) cosd(theta)]
    rays = rayC('origin',origin,'direction', direction, 'waveIndex', 1, 'wave', wave)
    
    
    %%% Trace the ray
    
    
    thisLens.rtThroughLens(rays,1)
    

end
hold on;


