thisLens = lensC('filename','dgauss.22deg.100.0mm.dat');


thisLens.fileWrite('dgauss.22deg.100.0mm.dat.json');
edit(thisLens.fullFileName);

%{
opts.indent = ' ';
jsonwrite('dgauss.22deg.100.0mm.dat.json',thisLens,opts)
%}

thisLens.bbmCreate;
jsonwrite('thisLens.json',thisLens,opts)

edit thisLens.json


%% Read in the 2ELLens txt file and write it as a JSON file
thisLens = lensC;
fullFileName = fullfile(ilensRootPath,'data','lens',[thisLens.name,'.json'])
thisLens.fileWrite(fullFileName);

%% Add the full file path to the lens object so we know just which file was read in
%
% Extending to biconic
%
%   add radiusX, radiusY, for each surface.  These define the
%   curvature of the surface in the x and y dimensions (1/radiusX) is
%   the curvature in that dimension.
%
%   conicConstantX and conicConstanY
%
%   Surface types
%      diaphagm (could be aperture)
%      Maybe we separate refractive into
%       spherical
%       biconic
%     We have refractive default to spherical
%
%   Surface shift and tilt
%     For each surface there is a potential (x,y) shift
%       deltaX
%       deltaY
%
%     For tilt we add 
%       rotateX - Rotation around the x-axis is pitch
%       rotateY - Rotation around the y-axis is yaw
%
%
%   Microlens object slot
%
