function hdl = plot(obj,pType,varargin)
%@lens.plot - Gateway routine for lens object plotting.
%
% Syntax
%    lens.plot(...)
%
% Description:
%   Interface to plot different lens characteristics. 
%
% Plot types
%     'focal distance'
%
%   
% Wandell, ISETBIO, Feb. 2018
%
% See also:  lens.draw
%

%%

% Squeeze out the spaces and force slower case
pType    = ieParamFormat(pType);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('pType',@ischar)
p.parse(pType,varargin{:});

pType = p.Results.pType;

%%
switch(pType)
    case 'focaldistance'
        % How were these FL files constructed?
        % Should we be using PBRT for this, or was there another way?
        %   s_focusLensTable
        %
        FLname = fullfile(ilensRootPath,'data','lens',[obj.name,'.FL.mat']);
        load(FLname,'dist','focalDistance');
        hdl = vcNewGraphWin;
        semilogx(dist,focalDistance); grid on;
        xlabel('Obj dist (mm)');
        ylabel('Focal distance (mm)');
        title(sprintf('Lens name: %s',obj.name));
    otherwise
end

end

