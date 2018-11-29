thisLens = lensC;
opts.indent = ' ';
jsonwrite('thisLens.json',thisLens,opts)
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
%   Lens shift and tilt
%     For each surface there is a potential (x,y) shift
%     For tilt we add a yaw and pitch
%
%   Microlens object slot
%
