function val = bbmGetValue(obj,param)
% Get the corresponding field value for th given Black Box Model 
%
%  val = bbmGetValue(BBoxModel,param)
%
% Either copy or calculate values from the BBM structure
% Note that this should bbmGet for now and ultimately bbm should become and
% object and this should be bbm.get(param).
%
%INPUT
% 
%params: 
%     {'all';
%      'focallength';
%      'focalradius';
%      'imagefocalpoint';...
%      'imageprincipalpoint';
%      'imagenodalpoint';
%      'objectfocalpoint';...
%      'objectprincipalpoint';
%      'objectnodalpoint';
%      'abcd'}
%
% Required fields
% BBoxModel: struct
%              .focal.length: focal length; 
%              .focal.radius: focal plane radius;
%              .imSpace.focalPoint: focal point in image space
%              .imSpace.principalPoint: principal point in image space
%              .imSpace.nodalPoint: principal point in image space
%              .obSpace.focalPoint:     focal point in object space
%              .obSpace.principalPoint: principal point in object space
%              .obSpace.nodalPoint:     principal point in object space
%              .abcdMatrix:             abcd equivalent matrix; 
%
%
% OUTPUT
%   val : selected value
%
% Example:
%   lens.get('bbm','efl');
%
% MP Vistasoft 2014

% Get Black Box equivalente Model

BBoxModel = obj.BBoxModel;
if isempty (BBoxModel)
    error( 'The Black Box Model is empty! Please call lens.bbmCreate()')
end

param = ieParamFormat(param);
switch param
    case {'focal'}
        val.length  = BBoxModel.focal.length;       %focal length
        val.radius  = BBoxModel.focal.radius;       %focal plane radius
        val.imPoint = BBoxModel.imSpace.focalPoint; %focal point in image space
        val.obPoint = BBoxModel.obSpace.focalPoint; %focal point in object space
    case {'effectivefocallength';'efl'}
        % This can be calculated, and it should be rather than stored IMHO.
        % BW
        % The formula is
        % the distance between the focal point and the principal point
        val = obj.bbmGetValue('image focal point') - obj.bbmGetValue('image principal point');
        % val=BBoxModel.focal.length; %focal length
    case {'focalradius'}
        val=BBoxModel.focal.radius; %focal plane radius
    case {'focalpoint'}
        val.imPoint=BBoxModel.imSpace.focalPoint; %focal point in image space
        val.obPoint=BBoxModel.obSpace.focalPoint; %focal point in object space
    case {'imagefocalpoint'}
        val=BBoxModel.imSpace.focalPoint; %focal point in image space
    case {'objectfocalpoint'}
        val=BBoxModel.imSpace.focalPoint; %focal point in object space
    case {'principalpoint'}
        val.imSpace=BBoxModel.imSpace.principalPoint; %principal point in image space
        val.obSpace=BBoxModel.obSpace.principalPoint; %principal point in object space
    case {'imageprincipalpoint'}
        val=BBoxModel.imSpace.principalPoint; %principal point in image space
    case {'objectprincipalpoint';'objprincipalpoint'}
        val=BBoxModel.obSpace.principalPoint; %principal point in object space
    case {'nodalpoint'}
        val.imSpace=BBoxModel.imSpace.nodalPoint; %principal point in image space
        val.obSpace=BBoxModel.obSpace.nodalPoint; %principal point in image space
    case {'imagenodalpoint'}
        val=BBoxModel.imSpace.nodalPoint; %principal point in image space
    case {'objectnodalpoint';'objnodalpoint'}
        val=BBoxModel.imSpace.nodalPoint; %principal point in image space
    case {'abcd';'abcdmatrix';'abcdMatrix'}
        val=BBoxModel.abcd; %abcd Matrix 
    case {'all'}
        val=BBoxModel; %all struct
    otherwise
        error (['Not valid: ',param,' as field of Black Box Model'])
end
