function aGrid = fullGrid(obj,randJitter, rtType)
% Build the full sampling grid, possibly adding a little jitter
% to avoid aliasing artifacts

if (notDefined('randJitter')), randJitter = false; end
if (notDefined('rtType')), rtType = 'realistic'; end

if (strcmp(rtType, 'ideal'))
    % If an ideal rtType, use the middle aperture as the front
    % aperture because there will really be only 1 aperture, the
    % middle one.
    frontApertureRadius = obj.apertureMiddleD/2;   % Middle aperture (diaphragm)
else
    % Realistic
    % There is a real aperture in the front.
    frontApertureRadius = obj.surfaceArray(1).apertureD/2;
end

% First make the rectangular samples.
xSamples = linspace(-frontApertureRadius, frontApertureRadius, obj.apertureSample(1));
ySamples = linspace(-frontApertureRadius, frontApertureRadius, obj.apertureSample(2));
[X, Y] = meshgrid(xSamples,ySamples);

%Add a random jitter.  Uniform distribution.  Scales to plus or
%minus half the sample width
if(randJitter)
    X = X + (rand(size(X)) - .5) * (xSamples(2) - xSamples(1));
    Y = Y + (rand(size(Y)) - .5) * (ySamples(2) - ySamples(1));
end
aGrid.X = X; aGrid.Y = Y;

end