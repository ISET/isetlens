function fileRead(obj, fullFileName, varargin)
% @lens method to reads a PBRT lens file
%
% Syntax:
%   lens.fileRead(fullFileName, varargin)
%
% Input:
%   The name of a PBRT lens file
%
% Outputs
% 
% Optional key/value pairs:
%   'units' - Set the spatial units
%       By default, lenses are specified in millimeters.  If 'm' or 'um' is
%       sent in, the numbers in the lens file are scaled to bring the units
%       into 'mm'.  Thus, if 'm' is sent in, the values are multiplied by
%       1000, and if 'um' are sent in the values are divided by 1000.
%
% Description: 
%
%  Data from a lens.dat file are read in and converted to the fields of a
%  lens object. The read is managed by fileRead, and the conversion from
%  the data stored in the lens.dat file to the values in the lens class are
%  managed by the method 'elementsSet'. This converts the vector of lens
%  and aperture values in the file into the lens.surfaceArray parameters.  
%
%  The lens class parameters are surface Offset (mm), sRadius (mm),
%  sAperture (mm), sN (index of refraction).
%
%  PBRT convention typically orders the data of the multi-element array
%  from the sensor to the scene, since that is the direction in which PBRT
%  traces the ray. However, because PBRT reads the file from bottom to top,
%  the data is written in reverse on the file.
%
%  With CISET the convention is to trace from the scene to the sensor. In
%  conclusion, we do NOT need to reverse any of the PBRT data because it is
%  written in reverse order already. However, we must be careful about
%  where the "0" is placed in the offset variable. See below for more
%  information.
%
% AL/TL VISTASOFT, Copyright 2014

%% Arrange parameters
p = inputParser;
p.addRequired('fullFileName',@(x)(exist(x,'file')));
p.addParameter('units','mm',@(x)(ismember(x,{'um','mm','m'})));
p.parse(fullFileName,varargin{:});

unitScale = p.Results.units;
switch unitScale
    case 'um'
        % Values are in microns, so divided by 1000 to bring to millimeters
        unitScale = 1e-3;
    case 'mm'
        unitScale = 1;
    case 'm'
        % Values are in meters, so x 1000 to bring to millimeters
        unitScale = 1e3;
    otherwise
        error('Unknown spatial scale');
end

%% Open the lens file
fid = fopen(fullFileName);
if fid < 0, error('File not found %s\n',fullFileName); end

% Read each of the lens and close the file
import = textscan(fid, '%s%s%s%s', 'delimiter' , '\t');
fclose(fid);

% Read the focal length of the lens. Search for the first non-commented 
% line in the first column.
id = find(isnan(str2double(import{1})) == false,1,'first');
obj.focalLength = str2double(import{1}(id))*unitScale;

% First find the start of the lens line, marked "#   radius"
firstColumn = import{1};
continueRead = true;
dStart = 1;   % Row where the data entries begin
while(continueRead && dStart <= length(firstColumn))
    compare = regexp(firstColumn(dStart), 'radius');
    if(~(isempty(compare{1})))
        continueRead = false;
    end
    dStart = dStart+1;
end

% Now that we know which line the numerical data begins at, we can read
% each column and save the data.
radius = str2double(import{1});
radius = radius(dStart:length(firstColumn)) * unitScale;

% Read in "Axpos," which is the distance from the current surface to the
% next surface. (We call this "offset.") The offset denotes the distance
% between the current surface and the previous one. In the PBRT file, there
% is a "0" at the end of the column because (1) PBRT reads the data in
% reverse and (2) there isn't a lens before the first one. For our CISET
% ray tracing convention, we go from the scene to the sensor, so we must
% move the zero to the beginning of the column but keep the rest of the
% data in the same order.
offset = str2double(import{2});
offset = offset(dStart:length(firstColumn));
offset = [0; offset(1:(end-1))]; % Shift to account for different convention
offset = offset*unitScale;

% Read in N, the index of refraction.
N = str2double(import{3});
N = N(dStart:length(firstColumn));

% Read in diameter of the aperture.
aperture = str2double(import{4});
aperture = aperture(dStart:length(firstColumn));
aperture = aperture*unitScale;

% Modify the object with the data we read
obj.elementsSet(offset, radius, aperture, N);

% Figure out which is the aperture/diaphragm by looking at the radius.
% When the spherical radius is 0, that means the object is an aperture.
lst = find(radius == 0);
if length(lst) > 1,         error('Multiple non-refractive elements %i\n',lst);
elseif length(lst) == 1,    obj.apertureIndex(lst);
else,                       error('No non-refractive (aperture/diaphragm) element found');
end


end


