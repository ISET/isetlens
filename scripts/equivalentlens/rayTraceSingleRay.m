function [arrival_pos,arrival_dir] = rayTraceSingleRay(lens,origin,direction,varargin)
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


rays = rayC('origin',origin,'direction', direction);
[~, ~, arrival_pos, arrival_dir] = lens.rtThroughLens(rays, 1, 'visualize', vis);
end


