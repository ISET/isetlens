function [scaleFactor, newFL] = focalLengthCal(thisLens, newFOV, filmSz, varargin)
% Get new focal length and scale factor with new FOV and target film size
%
% Syntax
%   [scaleFactor, newFL] = lensC.focalLengthCal(newFOV, filmSz);
%
% Brief description
%   The relationship between new focal length, target FOV and film size is:
%       FOV = 2 * atand(filmSz/2/FL);
%   So the new FL can be calculated as:
%       newFL = filmSz/2/tand(newFOV/2);
%   Scaling factor is then:
%       scaleFactor = newFL / curFL
%
% Inputs
%   thisLens - lensC object
%   newFOV   - new field of view (FOV)
%   filmSz   - target film size
%
% Outputs
%   scaleFactor - lens scaling factor
%   newFL       - new effective focal length with new FOV and film size
%
% ZLY, 2020
%
% See also
%   
%%
p = inputParser;
p.addRequired('thisLens',@(x)(isa(x,'lensC')));
p.addRequired('newFOV', @isnumeric);
p.addRequired('filmSz', @isnumeric);

p.parse(thisLens, newFOV, filmSz);
thisLens = p.Results.thisLens;
newFOV = p.Results.newFOV;
filmSz = p.Results.filmSz;

%%
newFL = filmSz/2/tand(newFOV/2);

% Get current focal length
curFL = thisLens.get('bbm', 'effective focal length');

scaleFactor = newFL / mean(curFL);
end
