function [iPoint]=findImagePoint(obj,pSource,n_ob,n_im)
% Find the image point for a given object point 
%
%   [iPoint] = lens.findImagePoint(obj,pSource,n_ob,n_im)
%
% This method works when the imaging system specification has known
% principal points (in object space and image space).
%
% INPUT
%   pSource: point source coordinate [ x y z]
%   n_ob: refractive index in the object space
%   n_im: refractive index in the image space
%
%OUTPUT
%  Each row is a different wavelength
%
%   [iPoint (wave)]= [x y z] (wave)
%
%  MP Vistasoft 2014


%% CHECK IF BLACK BOX MODEL is EMPTY and (eventually) FILL THAT
if isempty(obj.BBoxModel), obj.bbmCreate(n_ob,n_im); end

%% GET POINT SOURCE POLAR COORDINATEs

% get image coordinate in polar coordinate
% Matlab has a cart2pol.  See the difference.  Maybe use theirs after
% verifying.
[ps_height,ps_angle,ps_zpos]=coordCart2Polar3D(pSource(1),pSource(2),pSource(3)); 

%% GET LENS PARAMETERs

%principal point in the object space
H_obj = obj.bbmGetValue('object principal point');
% Hobj=result2.cardinalPoint.ObjectSpace.principalPoint; 

%principal point in the image space
H_im = obj.bbmGetValue('image principal point'); 
% Him=result2.cardinalPoint.ImageSpace.principalPoint; 

%Focal length
focalLength = obj.bbmGetValue('effective focal length'); 
% focalLength=result2.focallength; %effective focal length


%% IMAGE FORMATION

% Object-principal plane distance
% This is the distance between object point and the principal point in
% object space (Hob) 
d_ob = H_obj - ps_zpos; 

% distance between image point and related principal point (H_im)
% equation    n_ob/d_ob  + n_im/d_im =1/efl
P    = 1./focalLength;   %optical power
T1   = P - (n_ob./d_ob);
d_im = n_im./T1; 

%Lateral magnification
%  m= -(d_im/d_ob) (n_ob/n_im)
m_lat = -(d_im./d_ob).*(n_ob./n_im);

%% Image point position
ip_zpos   = H_im + d_im;      %image point position along the optical axis
ip_height = ps_height.*m_lat; %image point distance from the optical axis

%% SET OUTPUT

% The image point is returned in cartesian coordinates.
% The image position should generally be positive.
% Anything else we could check on?
% Also, shouldn't we be position cart2pol?
[iPoint(:,1),iPoint(:,2),iPoint(:,3)] = coordPolar2Cart3D(ip_height,ps_angle,ip_zpos);

% iPoint=[ip_xpos ip_ypos ip_zpos]; 

end

