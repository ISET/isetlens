function scale(thisLens,factor)
% Scale the lens surface size by a factor
%
% Syntax
%    lensC.scale(factor)
%
% Brief description
%  Change all of the spatial dimensions of the lens by the specified scale
%  factor. The surface radius of curvature, center position, and aperture
%  are all scaled.  The lens focal length is recalculated and the
%  apertureMiddleD parameter of the lensC object is updated.
%
% Inputs
%    thisLens - lensC object
%    factor   - scale factor
%
% Optional key/value inputs
%    N/A
% 
% Outputs
%    N/A
%
% Wandell
%
% See also
%   s_lensRescale

% Examples:
%{
 microLensName   = 'microlens.2um.Example.json';
 thisLens = lensC('filename',microLensName);
 fprintf('height: %f\n',microlens.get('lens height'));
 thisLens.scale(4);
 fprintf('height: %f\n',microlens.get('lens height'))
%}

%%
p = inputParser;
p.addRequired('thisLens',@(x)(isa(x,'lensC')));
p.addRequired('factor',@isscalar);
p.parse(thisLens,factor);

%% Scale all the surfaces by the specified scale factor

for ii=1:numel(thisLens.surfaceArray)
    thisLens.surfaceArray(ii).sRadius = thisLens.surfaceArray(ii).sRadius * factor;
    thisLens.surfaceArray(ii).sCenter = thisLens.surfaceArray(ii).sCenter * factor;
    thisLens.surfaceArray(ii).apertureD = thisLens.surfaceArray(ii).apertureD * factor;
end

% Adjust the focal length
thisLens.focalLength = lensFocus(thisLens,1e6);
thisLens.apertureMiddleD = thisLens.get('middle aperture d');

end