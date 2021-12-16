function [filmPositions,filmDirections] = rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm)
% Ray transfer function for a collection of rays
%
% Syntax
%   [filmPositions,filmDirections] = rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm)
%
%Inputs
%   ISETLens convention:  Left is object side.  Right is image side.
%
%  rtf:   A struct (will become a class) of the ray transfer
%         function. The rtf fields look like this
%           
%               wavelength_nm: 550
%                   polyModel: {[1×1 struct]  [1×1 struct]  [1×1 struct]  [1×1 struct]  [1×1 struct]  [1×1 struct]}
%                 circleRadii: [5.4800 68.1000 7.8000 8.5000]
%         circleSensitivities: [0.6539 -4.4431 0.1072 0.9298]
%                circlePlaneZ: 17
%              diaphragmIndex: 0
%     diaphragmToCircleRadius: 18.2667
%                      planes: [1×1 struct]
%           
%  origins:  Ray origins, a location for each ray  (n x 3)
%        z must be negative and larger than the lens thickness so it
%        passes through the lens
%        
%  directions:       Ray directions a unit vector for each ray
%                    (n x 3).  The z value should be positive, pointing
%                    towards the film 
%  filmdistance_mm:  Distance from rightmost point on the lens surface
%                    to the film (mm) 
%
% Author: TG
%
% See also
%

% Examples:
%{
 load('rtf-dgauss.22deg.50mm.mat','fit');
 rtf = fit{1};
 filmdistance_mm = 36.959;
 origins = [0 0 -3032.04];
 directions = [0 0 1];
 [filmPositions,filmDirections] = rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm)
%}

% Trace origin to the input plane of the RTF lens (linear extrapolation)
inputplane_z = -rtf.thickness-rtf.planeoffsetinput;

alpha = abs(origins(:,3) - inputplane_z)./directions(:,3);
intersectionsOnInputPlane = origins + alpha.*directions;


% Initialize as NaNs, the remaining NaNs in the end will correspond to
% vignetted rays (not traced)
filmPositions = nan(size(origins));

% Add Vignetting: Ray should pass all vignetting circles
% Vectorized calculation for speed.
passnopass=rtf.polynomials.passnopass;


% Rotate rays
[rotatedOrigins,rotatedDirections]=rotateRays(intersectionsOnInputPlane,directions);

% Determine which rays pass and which dont
if(isequal(passnopass.method,'minimalellipse'))
    centers=[passnopass.centersX passnopass.centersY];
    radii=[passnopass.radiiX passnopass.radiiY];
    pass = doesRayPassEllipse(rotatedOrigins,rotatedDirections,passnopass.positions,radii,centers,passnopass.intersectPlaneDistance);
else
    % Make backwards compatible 
        pass = (doesRayPassCircles(intersectionsOnInputPlane,directions,rtf.circleRadii,rtf.circleSensitivities,rtf.circlePlaneZ));
end


%% Convert polynomials to readable format by polyvaln
polyvalnStruct={};
polynomials=rtf.polynomials.poly;
for i=1:numel(polynomials)
        poly=polynomials(i);
        temp = struct;
        temp.Coefficients = poly.coeff';
        temp.ModelTerms = [poly.termr'; poly.termdx'; poly.termdy']';
        polyvalnStruct{i}=temp;
end

%%
% Evaluate polynomial using parallel for loop
% I should to vectorize this computation. The main difficulty to do this
% will be in rtfTrace 
filmDirections = zeros(size(origins,1),3);
absolutePosition= zeros(size(origins,1),3);
parfor r=1:size(origins,1)

   % If the ray is vignetted, skip to the next candidate tray. This avoids
   % costly evaluation of the polynomial.
    if(~pass(r))
        continue; % vignetted
    end
    
    % arrivalPos is the position on the rtf output plane
    % arrivalDir is the direction it leaves the Pos
    [arrivalPosOnOutputPlane,arrivalDirection] = rtfTrace(intersectionsOnInputPlane(r,:),directions(r,:),polyvalnStruct);
    arrivalPosOnOutputPlane(3)=rtf.planeoffsetoutput;

    % Continue trace to film ( linear extrapolation)
    % Find the alpha such that the rtfOutput ray ends up on the film
    % plane.  
    % rtfOutput(3) + alpha * rtfDirection(3) = filmZposition(3)
    % alpha = (filmZPosition(3) - rtfOutput(3))/rtfDirection(3)
    %
    alpha = abs(rtf.planeoffsetoutput - filmdistance_mm) ./ arrivalDirection(3);  % Distance to film
    filmPositions(r,:) = arrivalPosOnOutputPlane + alpha*arrivalDirection;             % 
    filmDirections(r,:) = arrivalDirection;
    
end

end

