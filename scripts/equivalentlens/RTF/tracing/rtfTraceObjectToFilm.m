function [filmPositions,filmDirections] = rtfTraceObjectToFilm(rtf,origins,directions,filmdistance_mm)


% Trace origin to the input plane of the RTF lens (linear extrapolation)
alpha=abs(origins(1,3)-rtf.planes.input)./directions(:,3);
inputOrigins = origins + alpha.*directions;


% Initialize as NaNs, the remaining NaNs in the end will correspond to
% vignetted rays (not traced)
filmPositions= nan(size(origins));

% Add VIgnetting: Ray should pass all vignetting circles
% Vectorized calculation for speed.
pass = (doesRayPassCircles(inputOrigins,directions,rtf.circleRadii,rtf.circleSensitivities,rtf.circlePlaneZ));

% Evaluate polynomial using parallel for loop
% I should to vectorize this computation. The main difficulty to do this
% will be in rtfTrace 
parfor r=1:size(origins,1)

   % If the ray is vignetted, skip to the next candidate tray. This avoids
   % costly evaluation of the polynomial.
    if(~pass(r))
        continue; % vignetted
    end
    [arrivalPos,arrivalDirection] = rtfTrace(inputOrigins(r,:),directions(r,:),rtf.polyModel);
    
    % Continue trace to film ( linear extrapolation)
    alpha=abs(arrivalPos(3)-filmdistance_mm)./arrivalDirection(3);
    filmPositions(r,:) = arrivalPos + alpha*arrivalDirection;
    filmDirections(r,:)=arrivalDirection;
end
end

