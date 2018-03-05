function obj = recordOnFilm(obj, film, varargin)
% Records the rays on the film surface
%
%  rays.recordOnFilm(obj, film, 'nLines',nLines,'fig',h)
%
% Inputs
%   obj:    Rays
%   film:   Sensor - can be either a plane or a spherical surface
%   nLines: number of lines to draw for the illustration
%           If 0, then no image is produced.
%   fig:    Matlab.ui.figure
%
% The rays are recorded on the film.image slot.
%
% AL Copyright Vistasoft Team, 2014

%%
p = inputParser;
p.addRequired('obj',@(x)(isa(x,'rayC')));
p.addRequired('film',@(x)(isa(x,'filmC')));
p.addParameter('nLines',0);
p.addParameter('fig',[],@(x)(isa(x,'matlab.ui.Figure')));

p.parse(obj,film,varargin{:});
nLines = p.Results.nLines;
h      = p.Results.fig;

% There are cases we don't want a figure to pop up.  Need to figure out how
% to suppress.  If we can do it without another parameter, that would be
% good.
if isempty(h), h = vcNewGraphWin; end

% We need to separate out the case of plenoptic rays and standard rays

%% Remove dead rays
liveRays = obj.get('live rays');

if isempty(liveRays), warning('No rays at exit aperture'); return; end

%% Calculate intersection point of the rays at the sensor z-plane

% Save original origin points for plotting.
oldOrigin  = liveRays.origin;

% Figure out the position of the rays on the film z-plane
liveRays.origin = rayIntersection(liveRays,film.position(3));


%% Plot ray-trace
if (nLines > 0)
    raysVisualize(oldOrigin,liveRays.origin,'nLines',nLines,'fig',h);
    film.draw;
    xlabel('mm'); ylabel('mm');
end

% This section calculates imagePixel.position  The computation is managed
% separately for the planar film (typical) and spherical case.
if(isa(film, 'filmSphericalC'))
    
    % Project spherical sensor
    sensorRadius = film.radius;
    sensorCenter = film.get('sphericalCenter');
    intersectPosition = liveRays.sphereIntersect(sensorCenter,sensorRadius);
    
    % Convert intersection point into spherical coordinate system...
    x = intersectPosition(:,1);
    y = intersectPosition(:,2);
    z = intersectPosition(:,3) - sensorCenter(3);
    r = sqrt(x.^2 + y.^2 + z.^2);
    theta = atan(x./z);
    phi = asin(y./r);
    
    imagePixel.position = [phi * abs(sensorRadius) theta * abs(sensorRadius) ];
    
    % Not sure why these are always shown.  Consider making an option.
    vcNewGraphWin; hist(theta);
    vcNewGraphWin; hist(phi);
    
elseif(isa(film, 'filmC'))
    
    % When it is the plane, this ....
    intersectPosition = liveRays.origin;
    
    %imagePixel is the pixel that will gain a photon due to the traced ray
    imagePixel.position = [intersectPosition(:,2) intersectPosition(:, 1)];
    imagePixel.position = real(imagePixel.position); %add error handling for this
else
    error('Invalid film type detected.');
end

% Count the photons incident on the film at different pixel positions

% MAKE THIS A FUNCTION WITH COMMENTS in utility.
% say rays2image
%
% This line takes a raw dimension and converts it to a position in
% terms of pixels
imagePixel.position = ...
    round(imagePixel.position * film.resolution(2)/film.size(2) + ...
    repmat(-film.position(2:-1:1)*film.resolution(2)/film.size(2)  + ...
    (film.resolution(2:-1:1) + 1)./2, [size(imagePixel.position,1) 1]));   %

imagePixel.wavelength = liveRays.get('wavelength');

convertChannel = liveRays.waveIndex;

%wantedPixel is the pixel that we wish to add 1 photon to
%pixel to update
wantedPixel = [imagePixel.position(:, 1) imagePixel.position(:,2) convertChannel];

recordablePixels =and(and(and(wantedPixel(:, 1) >= 1,  wantedPixel(:,1) <= film.resolution(1)), (wantedPixel(:, 2) > 1)), wantedPixel(:, 2) <= film.resolution(2));

%remove the nonrecordable pixels
wantedPixel = wantedPixel(recordablePixels, :);

%correct for y coordinates
wantedPixel(:, 1) =  film.resolution(1) + 1 - wantedPixel( :, 1);

%make a histogram of wantedPixel in anticipation of adding
%to film
%  [count bins] = hist(single(wantedPixel));
%  [count bins] = hist(single(wantedPixel), unique(single(wantedPixel), 'rows'));
uniqueEntries =  unique(single(wantedPixel), 'rows');

% Serializes the unique entries.
%
% I had an error here once where the wavelength in the uniqueEntries
% was 7 but there were only 4 wavelength dimensions in the film image.
% (BW).
serialUniqueIndex = sub2ind(size(film.image), uniqueEntries(:,1), uniqueEntries(:,2), uniqueEntries(:,3));
serialUniqueIndex = sort(serialUniqueIndex);

serialWantedPixel = sub2ind(size(film.image), single(wantedPixel(:,1)), single(wantedPixel(:,2)), single(wantedPixel(:,3)));

if (length(serialUniqueIndex(:)) == 1)
    % special case for length 1.  For some reason, hist has issues with
    % length 1.
    serializeFilm = film.image(:);
    %
    % When there is only 1 bin, it doesn't matter how many photons, so just add one
    serializeFilm(serialUniqueIndex) = serializeFilm(serialUniqueIndex) + 1;
    film.image = reshape(serializeFilm, size(film.image));
    
elseif(~isempty(serialUniqueIndex(:) > 0))
    
    % Make a histogram count of something.  Looks like AL counts the
    % number of rays using hist() and then adds that count to a
    % location in the film image.
    [countEntries] = hist(serialWantedPixel, serialUniqueIndex);
    
    %serialize the film, then the indices, then add by countEntries
    serializeFilm = film.image(:);
    
    % Add the count to the serialized film and then reshape and place
    % in the film image.
    serializeFilm(serialUniqueIndex) = serializeFilm(serialUniqueIndex) + countEntries';
    film.image = reshape(serializeFilm, size(film.image));
else
    warning('No photons collected on film!');
end


end