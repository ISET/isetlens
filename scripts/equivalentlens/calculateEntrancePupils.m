% This example script uses existing code from Michael Pieroni to calculate
% the entrance pupils for a given lens design.
% It works projecting each lens element back to the object space (in
% paraxial limit)
% This means that there is an entrance pupil for each lens. 
%
% In practice it will usually be the projection of the diapgraphm that is
% the most limiting.
% However, at off-axis positions the other pupils also can start limiting
% the rays. This effectively corresponds to mechanical/optical vignetting.
%
% Thomas Goossens

%% Load lens file
clear;
lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm-reverse.json');
exist(lensFileName,'file');
lensFileName='telephoto.250mm.json'

lens = lensC('fileName', lensFileName)


%% Modifcation of lens parameters if desired
diaphragm_diameter=0.6;
%lens.surfaceArray(6).apertureD=diaphragm_diameter
%lens.apertureMiddleD=diaphragm_diameter

% Note there seems to be a redundancy in the lens which can get out of
% sync: lens.apertureMiddleD en lens.surfaceArray{i}.apertureD (i= index of
% middle aperture)
% lens.surfaceArray(6).apertureD=0.4 seems to be only used for drawing
%   lens.apertureMiddleD seems to be used for actual calculations in
%   determining the exit and entrance pupil

 
%% Find Pupils
% Optical system needs to be defined to be comptaible wich legacy code
% 'paraxFindPupils'.
opticalsystem = lens.get('optical system'); 
exit = paraxFindPupils(opticalsystem,'exit'); % exit pupils
entrance = paraxFindPupils(opticalsystem,'entrance'); % entrance pupils;


% TG: To check: As far as I can see now the entrance (exit) pupil positions are defined
% with respect to the first (last) surface.


%% Draw diagram Entrance pupils

lens.draw
for i=1:numel(entrance)
    
    %% entrance pupil (with respect to first surface)
    firstEle=lens.surfaceArray(1); % First lens element
    firstsurface_z = firstEle.sCenter(3)-firstEle.sRadius; % Seems working, but why
    radius(i)=entrance{i}.diam(1,1)
    position(i)=firstsurface_z+entrance{i}.z_pos(1)
    

    
    line([1 1]*position(i),[radius(i) radius(i)*1.1],'linewidth',4)
    line([1 1]*position(i),[-radius(i) -radius(i)*1.1],'linewidth',4)
    
    line([1 1]*position(i),[radius(i) radius(i)*1.1],'linewidth',4)
    line([1 1]*position(i),[-radius(i) -radius(i)*1.1],'linewidth',4)
    
    % Number each entrance pupil so it is easy to see to which surface it
    % belongs
    text(position(i),1.2*radius(i),num2str(i))
    
   
    
end
title('Entrance pupils ')
legh=legend('');
legh.Visible='off';
