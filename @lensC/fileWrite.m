function fileWrite(obj, fullFileName, varargin)
% Writes PBRT lens file
%
% Syntax:
%
%   lens.fileWrite(fullFileName, varargun)
%
% Description:
%
%  The PBRT file has focal length information added to the header. This
%  function converts the PBRT matrix of data into the format that Scene3d
%  uses for a multi-element lens.
%
%  The PBRT lens file looks like this:
%
% # Name: 2ElLens
% # Description: foobar
% # units are mm
% # Focal length 
% 50.000
% 
% # Each row is a surface.
% # They are ordered from the image to the sensor.
% # Zero is the position of the first lens surface.
% # Positive is towards the sensor (right).
% # Negative is towards the scene (left).
% #  radius	    axpos		N		    aperture
% 67.000000	    1.500000	1.650000	25.000000
% 0.000000	    1.500000	1.650000	25.000000
% -67.000000	0.000000	1.000000	25.000000
%
% The bottom row is the rightmost surface; its z-axis position (axpos) is
% always 0. The radius of curvature is the (directional) distance to the
% center of sphere. Because it is negative, the center is 67 mm towards the
% scene. Thus, the surface is curved like a backwards 'C'. The index of
% refraction is to the right of the surface; for the first surface it will
% generally be air (1), assuming that there is air between the lens and
% sensor.  Of course, for the human eye, that is not the case.
%
% The 2nd row has an axpos of 1.5 mm, which means it is shifted 1.5mm
% towards the scene. Its radius is 0, which means it's an aperture. The
% material between this position and the previous surface is glass (N =
% 1.65).
%
% The first row axpos is 1.5 mm from the previous surface. It has a center
% to the right, so the shape is a 'C'.  The material is still glass.
%
% The lens class stores parameters in a different format. We don't use
% offsets; instead, we store the sphere centers (sCenters) and radii (units
% of mm).  The fileRead and fileWrite code convert between these
% representations.  In fileWrite the conversion is managed by the
% lensMatrix routine.
%
% AL/BW VISTASOFT, Copyright 2014
%
% See also:
%   lensMatrix, lensHeader

% Examples:
%{
  % Read and write a lens all in millimeters
  l = lens;
  l.fileWrite('deleteme.dat','description','foobar','units','mm');
%}
%{
  % Read a lens in millimeters.  Write it in meters
  l = lens;
  l.fileWrite('deleteme.dat','description','foobar','units','m');
%}

%%
p = inputParser;

p.addRequired('fullFileName',@ischar);
p.addParameter('description',obj.type,@ischar);
p.addParameter('units','mm',@(x)(ismember(x,{'um','mm','m'})));

p.parse(fullFileName,varargin{:});

unitScale = p.Results.units;
description = sprintf('# Description: %s\n',p.Results.description);
description = addText(description,sprintf('# units are %s',unitScale));

switch unitScale
    case 'um'
        % Values are in microns, so multiply by 1000 to bring to millimeters
        unitScale = 1e3;
    case 'mm'
        unitScale = 1;
    case 'm'
        % Values are in meters, so divide by 1000 to bring to millimeters
        unitScale = 1e-3;
    otherwise
        error('Unknown spatial scale');
end

%% Open the lens file for writing
% fid = fopen(fullfile(dataPath, 'rayTrace', 'dgauss.50mm.dat'));
if ~exist(fullFileName,'file')
else,  fprintf('Overwriting %s\n',fullFileName)
end
fid = fopen(fullFileName,'w');

%% Write the header
hdr = lensHeader(obj,description,unitScale);
fprintf(fid,'%s',hdr);

%% Write the data matrix
d  = lensMatrix(obj);

% Columns 1 2 and 4 are corrected for spatial scale
d(:,1) = d(:,1)*unitScale;
d(:,2) = d(:,2)*unitScale;
d(:,4) = d(:,4)*unitScale;

% Column 3 is 
for ii=1:size(d,1)
    fprintf(fid,'%f\t%f\t%f\t%f\n', d(ii,1), d(ii, 2), d(ii,3), d(ii,4));
end

%ftr = lensFooter(obj);
%fprintf(fid,'%s',ftr);
fclose(fid);
end


%% The header
function hdr = lensHeader(obj, description, unitScale)

hdr = sprintf('# Name: %s\n',obj.name);

str = sprintf('%s\n',description);
hdr = addText(hdr,str);

str = sprintf('# Focal length \n');
hdr = addText(hdr,str);

str = sprintf('%.3f\n',obj.focalLength*unitScale);
hdr = addText(hdr,str);

str = sprintf('\n# Each row is a surface.\n');
hdr = addText(hdr,str);

str = sprintf('# They are ordered from the image to the sensor.\n');
hdr = addText(hdr,str);

str = sprintf('# Zero is the position of the first lens surface.\n');
hdr = addText(hdr,str);

str = sprintf('# Positive is towards the sensor (right).\n# Negative is towards the scene (left).\n');
hdr = addText(hdr,str);

str = sprintf('#  radius	axpos	\tN	\taperture\n');
hdr = addText(hdr, str);

end


%% Convert the surface array data to the PBRT matrix we want to write
function d = lensMatrix(lens)
% In the lens class, we don't use offsets. Instead, we store the sphere
% centers (sCenters) and radii (units of mm).  So here we go through the
% surfaceArray and produce the radius and offset needed for the PBRT matrix
% from the surfaceArray object sCenters and radius.

nSurfaces = lens.get('n surfaces');

% The PBRT data matrix
d = zeros(nSurfaces,4);
offsets = lens.get('offsets');
nArray = lens.get('index of refraction');
nArray = nArray(round((size(nArray,1) + 1)/2), :);
for ii=1:nSurfaces
    d(ii,1) = lens.get('s radius',ii);
    d(ii,2) = offsets(ii);
    
    % Pbrt does not yet support custom specified index of refractions. 
    % Thus, we will take the middle one 
    d(ii,3) = nArray(ii);
    d(ii,4) = lens.get('sdiameter', ii);
end




end
