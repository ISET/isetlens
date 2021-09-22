function [arrivalPos,arrivalDirection] = rtfTrace(origin,direction,polyModel)
% Step 1: Define rotation matrix
alpha=atan2d(origin(2),origin(1));
a= 90 - alpha; 
rot = [cosd(a) -sind(a);
       sind(a)  cosd(a)]; 
irot= inv(rot); % inverse rotation for rotating back

% Step 2: Rotate such that y-coordinate is zero (i.e alpha=0)

rho =  sqrt(origin(1).^2+origin(2).^2); % radial coordinate (=x axis after rotation)
dir_rotated=  rot*direction(1:2)';

% Step 3: Evaluate the polynomials
poly=polyModel;
for i=1:numel(poly)
        in_rot = [sqrt(origin(1).^2+origin(2).^2) dir_rotated(1) dir_rotated(2)];
        output_rot(i,1)=polyvaln(poly{i},in_rot);
end
%output_rot=neural([rho dir_rotated']');

% Step 4: Rotate back (x,y) and (u,v)   
% Rotate back to original angle
output_rot(1:2,1) = irot*output_rot(1:2,1); %(x,y)
output_rot(3:4,1) = irot*output_rot(3:4,1); %(u,v)

%% Compare 3D trace and rotationally invariant trace
arrivalPos=output_rot(1:3);
arrivalDirection=output_rot(3:5);
end

