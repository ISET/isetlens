function [obj]=bbmSetField(obj,pName,val)

% Build the field to append to Black Box Model 
%
%  function val=bbmGetValue(BBoxModel,fileType)
%
%
%INPUT
% pName: field name
% val: value 
%             
% 
%fileType: specify which field {'all';'focallength';'focalradius';'imagefocalpoint';'imageprincipalpoint';'imagenodalpoint';'objectfocalpoint';'objectprincipalpoint';'objectnodalpoint';'abcd'}
%
% OUTPUT
% field:       "pName"            "field name"
%               
%              focal length->   .focal.length
%             focal plane radius->   .focal.radius
%             abcd equivalent matrix-> .abcdMatrix
%       IMAGE SPACE
%              n_im->   .obSpace.n_im  
%             focal point ->  .imSpace.focalPoint
%             principal point ->  .imSpace.principalPoint 
%             principal point ->  .imSpace.nodalPoint
%
%       OBJECT SPACE
%             n_ob->   .obSpace.n_ob
%             focal point -> .obSpace.focalPoint
%             principal point -> .obSpace.principalPoint 
%             principal point ->.obSpace.nodalPoint
%       PUPIL
%           
%        ALL struct
%                 OUTPUT=INPUTvalue
%
% MP Vistasoft 2014



    switch pName
        case {'effectivefocallength';'efl'}
            obj.BBoxModel.focal.length=val; %focal length
        case {'focalradius'}
            obj.BBoxModel.focal.radius=val; %focal plane radius
        case {'imagerefractiveindex';'imagerefind';'n_im'}
            obj.BBoxModel.imSpace.n_im=val; %refractive index in image space
        case {'objectrefractiveindex';'objectrefind';'n_ob'}
            obj.BBoxModel.imSpace.n_ob=val; %refractive index in image space
        case {'imagefocalpoint'}
            obj.BBoxModel.imSpace.focalPoint=val; %focal point in image space
        case {'objectfocalpoint'}
            obj.BBoxModel.obSpace.focalPoint=val; %focal point in object space
        case {'imageprincipalpoint'}
            obj.BBoxModel.imSpace.principalPoint=val; %principal point in image space
        case {'objectprincipalpoint';'objprincipalpoint'}
            obj.BBoxModel.obSpace.principalPoint=val; %principal point in object space
        case {'imagenodalpoint'}
            obj.BBoxModel.imSpace.nodalPoint=val; %principal point in image space
        case {'objectnodalpoint';'objnodalpoint'}
            obj.BBoxModel.obSpace.nodalPoint=val; %principal point in image space
        case {'abcd';'abcdmatrix';'abcdMatrix'}
            obj.BBoxModel.abcd=val; %abcd Matrix             
        case {'fnumber';'fnum';'effectivefnumber';'f-number'}
            obj.BBoxModel.imageFormation.Fnum=val; % effective F number
        case {'numericalaperture';'numapert';'NA';'na'}
            obj.BBoxModel.imageFormation.NA=val; % numerical aperure
        case {'fieldofview';'FoV';'fov'}
            obj.BBoxModel.imageFormation.FoV=val; % field of view
        case {'lateralmagnification';'latmagn';'latmagnification';'lat_magn'}
            obj.BBoxModel.imageFormation.magn_lat=val; % lateral magnification
        case {'exitpupil';'ExP';'ExitPupil'}
            obj.BBoxModel.imageFormation.Pupil.ExP=val; % exit pupil
        case {'entrancepupil';'EnP';'EntrancePupil'}
            obj.BBoxModel.imageFormation.Pupil.EnP=val; % entrance pupil
        case {'entrancepupil';'EnP';'EntrancePupil'}
            obj.BBoxModel.imageFormation.Pupil.EnP=val; % entrance pupil
        case {'gaussianimagepoint';'gaussianpoint';'gausspoint'}
            obj.BBoxModel.imageFormation.gaussPoint=val; % gaussian image point
        case {'primaryaberration';'seidelaberration';'4thorderwaveaberration'}
            obj.BBoxModel.aberration.paCoeff=val; % primary aberration
        case {'defocus'}
            obj.BBoxModel.aberration.defocusCoeff=val; % defocus coeff for aberration
        case {'all'}
            obj.BBoxModel=val; %all struct
        otherwise
            error (['Not valid: ',pName,' as field of Black Box Model'])
    end
end
