function pass = checkRayPassLens(ray_origin,ray_direction, pupil_positions,pupil_radii)
% pass = checkRayPassLens(ray_origin,ray_direction, pupil_positions,pupil_radius)
%
% INPUTS
%  ray_origin -  3D vector (x,y,z) stating the origin of the ray
%  ray_direction -  3D direction vector (x,y,z) stating the direction of the ray
%  pupil_positions - 1xP array of positions of pupils
%  pupil_radii     - 1xP array of radii of pupils (paired with
%                     pupil_positions)
%
% OUTPUTS
%  pass  - true/false whether ray passes through lens system
for i=1:numel(pupil_positions)
    alpha = (pupil_positions(i) - ray_origin(3))/(ray_direction(3));
    pointOnPupil = ray_origin+alpha*ray_direction;
    passpupil(i)= norm(pointOnPupil(1:2))<=pupil_radii(i);
end
pass = prod(passpupil); % boolean AND operation, ray needs to pass through all
end

