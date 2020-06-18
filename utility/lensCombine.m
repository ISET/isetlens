function [combinedLens,uLens, iLens, dockerCmd] = lensCombine(uLens,iLens,uLensHeight,nMicrolens)
% Combines the microlens and imaging lens into a single lens file
%
% Synopsis
%  [combinedLens,filmHeight,filmWidth,dockerCmd] = lensCombine(uLens,iLens,uLensHeight,nMicrolens)
%
% Brief description
%   
% Inputs:
%
% Optional key/value pairs
%
% Outputs:
%
% Description:
%  Choose an even number for nMicrolens.  
%  This assures that the sensor and ip data have the right integer relationships. 
%
% See also
%

%% Parse

%%
uLens     = lensC('filename',uLens);
uLens.adjustSize(uLensHeight);
%{
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f (mm)\nF-number %.3f\n',...
    uLens.focalLength,uLens.get('lens height'),...
    uLens.focalLength/uLens.get('lens height'));
%}

%% Choose the imaging lens 

% For the dgauss lenses 22deg is the half width of the field of view
iLens     = lensC('filename',iLens);
%{
fprintf('Focal length =  %.3f (mm)\nHeight = %.3f\n',...
    imagingLens.focalLength,imagingLens.get('lens height'))
%}

%% Set up the microlens array and film size
% 
filmheight = nMicrolens(1)*uLens.get('lens height');
filmwidth  = nMicrolens(2)*uLens.get('lens height');

% Array beneath each microlens

%% Build the combined lens file using the docker lenstool

[combinedLens,dockerCmd] = piCameraInsertMicrolens(uLens,iLens, ...
    'xdim',nMicrolens(1),  'ydim',nMicrolens(2),...
    'film width',filmwidth,'film height',filmheight);

end
