function oi = oiCreate(obj)
% Create an ISET optical image from the psfCamera object
%
% The PSF should be calculated prior to this if you would like to see the
% point spread in the oi, which is the typical usage
%
% AL/BW Vistasoft Team, Copyright 2014

%% Create an optical image from the camera (film) image data.
oi = oiCreate;
oi = initDefaultSpectrum(oi);
oi = oiSet(oi,'wave', obj.film.wave);

%% normalize PSF here - is this the right thing to do? AL
channelSum = sum(sum(obj.film.image, 2) , 1);
%photons = obj.film.image;

%this is experimental - make this normalize later
photons = obj.film.image ./ ...
    repmat(channelSum, [size(obj.film.image, 1) size(obj.film.image, 2)]);  
oi = oiSet(oi,'photons',photons);

filmDistance = obj.film.position(3);

% The photon numbers do not yet have meaning.  This is a hack,
% that should get removed some day, to give the photon numbers
% some reasonable level.

% This also uses a lot of valuable computation during the volt3dBlur
% function.  We should remove this and replace it with something more
% efficient/consistent!

%oi = oiAdjustIlluminance(oi,1);


% Set focal length in meters
% oi = oiSet(oi,'optics focal length',obj.lens.focalLength/1000);

% This isn't exactly the fnumber.  Do we have the aperture in
% there?  Ask MP what to use for the multicomponent system.
% This is just a hack to get something in there
% Maybe this should be obj.lens.apertureMiddleD?
% fN = obj.lens.focalLength/obj.lens.surfaceArray(1).apertureD;
% oi = oiSet(oi,'optics fnumber',fN);

% TL: I added this...I think this is right as long as the focal length is
% set correctly.  
% BW:  But, it may be way wrong for a multi-element lens.
% In that case we might want to get the effective focal length from
% the black box model.
fN = filmDistance / obj.lens.apertureMiddleD;
oi = oiSet(oi,'optics fnumber',fN);
 
%% Estimate the horizontal field of view

% Position of the film/sensor from the back of the lens.  This may not
% be the same as the focal length.
hfov = rad2deg(2*atan2(obj.film.size(1)/2,filmDistance));

oi = oiSet(oi,'hfov', hfov);
oi = oiSet(oi, 'optics focal length', obj.lens.get('focal length') * 10^-3);

% Set the name based on the distance of the film (sensor) from the
% final lens surface.  This may not be the focal length of the lens.
oi = oiSet(oi, 'name', ['filmDistance: ' num2str(filmDistance)]);

end
