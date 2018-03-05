function hdl = plot(obj,pType,varargin)
%@lens.plot - Gateway routine for lens object plotting.
%
% Syntax
%    lens.plot(...)
%
% Description:
%   Interface to plot different lens characteristics. 
%
% Wandell, ISETBIO, Feb. 2018
%
% See also:  lens.draw
%

%%
p = inputParser;

% Squeeze out the spaces and force slower case
pType    = ieParamFormat(pType);
varargin = ieParamFormat(varargin);
p.addRequired('pType',@ischar)

p.parse(pType,varargin{:});

pType = p.Results.pType;

%%
switch(pType)
    case 'focaldistance'
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

