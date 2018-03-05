function rootPath = ilensRootPath()
% Return the path to the root isetlens directory
%
% This function must reside in the directory at the base of the
% ISETLENS.directory structure.  It is used to determine the location
% of various sub-directories.
% 
% Example:
%   fullfile(ilensRootPath,'data')
%
% Wandell, SCIEN STANFORD, 2018

fullPath = which('ilensRootPath');

rootPath=fileparts(fullPath);

end
