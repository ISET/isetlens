function obj =  traceThroughLens(obj, lens)
% Deprecate?
% This seems like a duplicate of the lens function.
% If so, maybe we should get rid of it.  Or that one.
% AL : this is in fact a duplicate...
%
% Performs ray-trace of the lens, given an input bundle or rays
% outputs the rays that have been refracted by the lens
% TODO: consdier moving this to the lens - II think it was.
%       So, delete? (BW)
disp('** Calling traceThroughLens in ray Object. **')
prevN = 1;  %assume that we start off in air

% initialize newRays to be the old ray.  We will update it later.
% newRays = rays;

prevSurfaceZ = -lens.totalOffset;

for lensEl = lens.numEls:-1:1
    curEl = lens.elementArray(lensEl);
    
    %illustrations for debug
    zPlot = linspace(curEl.sphereCenter(3) - curEl.radius, curEl.sphereCenter(3) + curEl.radius, 10000);
    yPlot = sqrt(curEl.radius^2 - (zPlot - curEl.sphereCenter(3)) .^2);
    yPlotN = -sqrt(curEl.radius^2 - (zPlot - curEl.sphereCenter(3)) .^2);
    arcZone = 5;
    
    %TODO:find a better way to plot the arcs later - this one is prone to potential problem
    withinRange = and(and((yPlot < curEl.aperture),(zPlot < prevSurfaceZ + curEl.offset + arcZone)), (zPlot > prevSurfaceZ + curEl.offset - arcZone));
    line(zPlot(withinRange), yPlot(withinRange));
    line(zPlot(withinRange), yPlotN(withinRange));
    
    %vectorize this operation later
    for i = 1:size(obj.origin, 1)
        %get the current ray
        ray.direction = obj.direction(i,:);   %TODO: replace with real ray object
        ray.origin = obj.origin(i,:);
        ray.wavelength = obj.wavelength(i);
        
        %calculate intersection with spherical lens element
        radicand = dot(ray.direction, ray.origin - curEl.sphereCenter)^2 - ...
            ( dot(ray.origin -curEl.sphereCenter, ray.origin -curEl.sphereCenter)) + curEl.radius^2;
        if (curEl.radius < 0)
            intersectT = (-dot(ray.direction, ray.origin - curEl.sphereCenter) + sqrt(radicand));
        else
            intersectT = (-dot(ray.direction, ray.origin - curEl.sphereCenter) - sqrt(radicand));
        end
        
        %make sure that T is > 0
        if (intersectT < 0)
            disp('Warning: intersectT less than 0.  Something went wrong here...');
        end
        
        intersectPosition = ray.origin + intersectT * ray.direction;
        
        normalVec = intersectPosition - curEl.sphereCenter;  %does the polarity of this vector matter? YES
        normalVec = normalVec./norm(normalVec);
        if (curEl.radius < 0)  %which is the correct sign convention? This is correct
            normalVec = -normalVec;
        end
        
        %modify the index of refraction depending on wavelength
        %TODO: have this be one of the input parameters (N vs. wavelength)
        if (curEl.n ~= 1)
            curN = (ray.wavelength - 550) * -.04/(300) + curEl.n;
        else
            curN = 1;
        end
        
        
        ratio = prevN/curN;    %snell's law index of refraction
        
        %Vector form of Snell's Law
        c = -dot(normalVec, ray.direction);
        newVec = ratio *ray.direction + (ratio*c -sqrt(1 - ratio^2 * (1 - c^2)))  * normalVec;
        newVec = newVec./norm(newVec); %normalize
        
        %update the direction of the ray
        obj.origin(i, : ) = intersectPosition;
        obj.direction(i, : ) = newVec;
    end
    prevN = curN;
    
    prevSurfaceZ = prevSurfaceZ + curEl.offset;
end
end