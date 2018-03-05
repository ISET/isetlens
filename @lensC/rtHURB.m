function obj = rtHURB(obj, rays, lensIntersectPosition, curApertureRadius)
%Performs the Heisenburg Uncertainty Ray Bending method on the
%rays, given a circular aperture radius, and lens intersection
%position 
%
% obj = rtHURB(obj, rays, lensIntersectPosition, curApertureRadius)
%
% This function accepts both vector forms of inputs, or individual inputs
%
% Look for cases when you can use: bsxfun ...
%
% This code is not readable yet.  Let's figure out the steps
% and write clarifying functions.
%
% AL Vistasoft Copyright 2014

ipLength = sqrt(sum(dot(lensIntersectPosition(:, (1:2)), lensIntersectPosition(:, (1:2)), 2), 2));

%calculate directionS which is ....
directionS = [lensIntersectPosition(:, 1) lensIntersectPosition(:,2) zeros(length(lensIntersectPosition), 1)];

% And the orthogonal directionL
directionL = [-lensIntersectPosition(:,2) lensIntersectPosition(:,1) zeros(length(lensIntersectPosition), 1)];

normS = repmat(sqrt(sum(dot(directionS, directionS, 2), 2)), [1 3]);
normL = repmat(sqrt(sum(dot(directionL, directionL, 2), 2)), [1 3]);
divideByZero = sum(normS,2) ==0;

directionS(~divideByZero, :) = directionS(~divideByZero, :)./normS(~divideByZero, :);
directionL(~divideByZero, :) = directionL(~divideByZero, :)./normL(~divideByZero, :);
directionS(divideByZero, :) = [ones(sum(divideByZero == 1), 1) zeros(sum(divideByZero == 1), 2)];
directionL(divideByZero, :) = [zeros(sum(divideByZero == 1), 1) ones(sum(divideByZero == 1), 1) zeros(sum(divideByZero == 1), 1)];

pointToEdgeS = curApertureRadius - ipLength;   %this is 'a' from paper  //pointToEdgeS stands for point to edge short
pointToEdgeL = sqrt((curApertureRadius* curApertureRadius) - ipLength .* ipLength);  %pointToEdgeS stands for point to edge long

lambda = rays.get('wavelength')' * 1e-9;  %this converts lambda to meters
%sigmaS = atan(1./(2 * pointToEdgeS *.001 * 2 * pi./lambda));  %the .001 converts mm to m
%sigmaL = atan(1./(2 * pointToEdgeL * .001 * 2 * pi./lambda));

sigmaS = atan(1./(sqrt(2) * pointToEdgeS *.001 * 2 * pi./lambda));  %the .001 converts mm to m   experimental
sigmaL = atan(1./(sqrt(2) * pointToEdgeL * .001 * 2 * pi./lambda));

%this function regenerates a 2D gaussian sample and
%returns it randOut
%gsl_ran_bivariate_gaussian (r, sigmaS, sigmaL, 0, noiseSPointer, noiseLPointer);    %experiment for now
[randOut] = randn(length(sigmaS),2) .* [sigmaS sigmaL];

%calculate component of these vectors based on 2 random degrees
%assign noise in the s and l directions according to data at these pointers
noiseS = randOut(:,1);
noiseL = randOut(:,2);

%project the original ray (in world coordinates) onto a new set of basis vectors in the s and l directions
projS = (rays.direction(: , 1) .* directionS(: ,1) + rays.direction(: , 2) .* directionS(:,2))./sqrt(directionS(:,1) .* directionS(:,1) + directionS(:,2) .* directionS(:,2));
projL = (rays.direction(: , 1) .* directionL(:, 1) + rays.direction(: , 2 ) .* directionL(:,2))./sqrt(directionL(:,1) .* directionL(:,1) + directionL(:,2) .* directionL(:,2));
thetaA = atan(projS./rays.direction(: , 3));   %azimuth - this corresponds to sigmaS
thetaE = atan(projL./sqrt(projS.*projS + rays.direction(:, 3).* rays.direction(: , 3)));   %elevation - this corresponds to sigmaL

%add uncertainty
thetaA = thetaA + noiseS;
thetaE = thetaE + noiseL;

%convert angles back into cartesian coordinates, but in s,l space
newprojL = sin(thetaE);
smallH = cos(thetaE);   %smallH corresponds to the projection of the ray onto the s-z plane
newprojS = smallH .* sin(thetaA);
rays.direction(:, 3) = smallH .* cos(thetaA);

%convert from s-l space back to x-y space
rays.direction(:, 1) = (directionS(:, 1) .* newprojS + directionL(:, 1) .* newprojL)./sqrt(directionS(:,1) .* directionS(:,1) + directionL(:,1) .* directionL(:,1));
rays.direction(:, 2) = (directionS(:, 2) .* newprojS + directionL(:, 2) .* newprojL)./sqrt(directionS(:,2) .* directionS(:,2) + directionL(:,2) .* directionL(:,2));
normDirection = repmat(sqrt(sum(dot(rays.direction, rays.direction, 2),2)), [1 3]);
rays.direction = rays.direction./normDirection;

%reassign ray
%                 rays.origin(i,:) = curRay.origin;
%                 rays.direction(i, :) = curRay.direction;
%                 rays.wavelength(i,:) = curRay.wavelength;
%             end
end