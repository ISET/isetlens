function pass = doesRayPassCircles(ray_origins_oninputplane,ray_directions,circleRadii,circleSensitivities,circlePlaneZ)
% pass = checkRayPassLens(ray_origin,ray_direction, pupil_positions,pupil_radius)
%
% INPUTS
%  ray_origins_oninputplane -  Nx3 vector (x,y,z) stating the origin of the
%  ray on the input plane. 
%  ray_direction -  3D direction vector (x,y,z) stating the direction of the ray
%  circleRadii -  1xP array of radii of pupils (paired with pupil_positions)
%  would have a distance 0)
%  circleSensitivities     -
%
% OUTPUTS
%  pass  - true/false whether ray passes through lens system
% Given a set of circles positioned at a 

%%  circlePlaneZ with respect ton input plane
% OUTPUTS
%  pass  - true/false whether ray passes through lens system

% Project to circle plane
alpha = (circlePlaneZ)./(ray_directions(:,3));
pointOnCirclePlane = ray_origins_oninputplane+alpha.*ray_directions; 


% The off-axis distance (in the direction 'offaxis_unitdirection')
rho = sqrt(sum(ray_origins_oninputplane(:,1:2).^2,2));
% Circles move along the same direction as the off-axis direction. So we
% need to calculate the unit vector pointing in this direction
offaxis_unitdirection = ray_origins_oninputplane(:,1:2)./rho; % Unit vector


% All points need to be within the radius of each circle
for i=1:numel(circleSensitivities)
    passpupil(:,i)= sum( (pointOnCirclePlane(:,1:2)- circleSensitivities(i)*rho.*offaxis_unitdirection).^2,2) <=circleRadii(i).^2;
end
pass = prod(passpupil,2); % boolean AND operation, ray needs to pass through all
end

