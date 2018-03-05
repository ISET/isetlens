function obj = traceSourceToLens(obj, curPointSource, lens)
% Deprecate?
% Traces rays from a point source to a sampling function on the
% lens
% Is this old code that was moved to the lens object?

obj.origin = repmat(curPointSource, [size(lens.apertureSample.Y(:), 1) 1] );   %the new origin will just be the position of the current light source
obj.direction = [(lens.apertureSample.X(:) -  obj.origin(:,1)) (lens.apertureSample.Y(:) -  obj.origin(:,2)) (lens.centerPosition(3) - obj.origin (:,3)) .* ones(size(lens.apertureSample.Y(:)))];
obj.direction = obj.direction./repmat( sqrt(obj.direction(:, 1).^2 + obj.direction(:, 2).^2 + obj.direction(:,3).^2), [1 3]); %normalize direction

end
