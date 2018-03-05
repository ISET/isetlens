function endPoint = endPoint(obj,D)
% Given a distance, direction and origin, calculate the end
% point of the ray.

repD = repmat(D, [1 3]);
endPoint = obj.origin + repD .* obj.direction;

end
