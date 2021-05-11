
%% 
e_n= @(theta,phi)    [sind(theta).*cosd(phi);    sind(theta).*sind(phi);    cosd(theta)];
e_theta= @(theta,phi)[cosd(theta).*cosd(phi);    cosd(theta)*sind(phi);    -sind(theta)];
e_phi= @(theta,phi)  [-sind(phi);    cosd(phi);    0];
  

T = @(theta,phi) [e_n(theta,phi) e_theta(theta,phi) e_phi(theta,phi)]
Tinv = @(theta,phi) inv(T(theta,phi));




direction = [0;0;1];


%%
Tinv(90,0)*direction


