function varargout=bbmSetAberration(obj,method,varargin)
% Set the film of the camera in focus for the specified wavelength
%
%Examples
%
% The camera has a point source, lens, and film.
%
% INPUT
% wave0
% method  = zero


% OUTPUT
%
%

% MP Vistasoft Team, Copyright 2014


%% GET wavelength vector & current aberration
wave=obj.get('wave');
paOLD=obj.get('bbm','primaryaberration');

 switch method
     case {'allzero'}
         value0=zeros(size(wave(:),1),1);
         paOLD.W40=value0;paOLD.W31=value0;paOLD.W22=value0;paOLD.W20=value0;
        paOLD.W11=value0;
     otherwise
         warning (['Nothing changed!', method,' is not valid'])
 end

 
obj.bbmSetField('primaryaberration',paOLD);