function estimatePSF(obj,nLines, jitterFlag, subsection, diffractionMethod, rtType)
% Estimate the psfCamera point spread function (PSF)
%
%   psfCamera.estimatePSF(obj)
%
% The psf camera has a cell array of point sources, a lens, and a film
% surface.  This calculates the images from each of the points in the
% psfCamera object and then saves the result by calling 'recordOnFilm',
% which is part of the ray object.
%
%
%  obj:          psfCamera
%  nLines:       Show an image of the ray trace lines (0 is none).
%  jitterFlag:   Jitter position of rays, not regularly sample
%  subsection:   Only allow rays through a subsection of the front aperture
%  diffractionMethod: Two methods are implemented, Huygens and HURB
%  rtType:            Realistic or ideal
%
% You can visualize it using the optical image derived from the psfCamera
%
%   psfCamera.oiCreate();
%
% Examples:
%
% AL/BW Vistasoft Team, Copyright 2014

if notDefined('nLines'),     nLines = false;     end
if notDefined('jitterFlag'), jitterFlag = false; end
if notDefined('subsection'), subsection = []; end
if notDefined('diffractionMethod'), diffractionMethod = 'HURB'; end
if notDefined('rtType'), rtType = 'realistic'; end

if (isequal(diffractionMethod, 'huygens') && obj.lens.diffractionEnabled)
    % Trace from the point source to the entrance aperture of the
    % multi-element lens
    wbar = waitbar(0,'Huygens wavelength and job');

    lensMode = true;  %set false if ideal lens focused at infinity
    
    % Get up to the entrance aperture
    ppsfCFlag = false;
    obj.lens.diffractionEnabled = false;
    obj.rays = obj.lens.rtSourceToEntrance(obj.pointSource,ppsfCFlag,jitterFlag,rtType,subsection);
    
    % Duplicate the existing rays for each wavelength
    % Note that both lens and film have a wave, sigh.
    % obj.rays.expandWavelengths(obj.film.wave);
    obj.rays.expandWavelengths(obj.lens.wave);
    
    %lens intersection and raytrace
    obj.lens.rtThroughLens(obj.rays, nLines, rtType);
    
    % Something like this?  Extend the rays to the film plane?
    % if nLines > 0; obj.rays.draw(obj.film); end
    
    % intersect with "film" and add to film
    %obj.rays.recordOnFilm(obj.film, nLines);
        
    % Huygens ray-trace portion (PUT THIS IN A FUNCTION)
    % use a preset sensor size and pitch for now... somehow integrate this
    % with PSF camera later
    binSize = [obj.film.size(1)/obj.film.resolution(1) obj.film.size(2)/obj.film.resolution(2)] .* 1e6;
    numPixels = [obj.film.resolution(1) obj.film.resolution(2)];
    imagePlaneDist = obj.film.position(3) * 10^6;
   
    % For each wavelength...
    nWave = length(obj.lens.wave);
    for wIndex = 1:nWave
        %estimated that the width of the 1st zero of airy disk will be .0336
        apXGridFlat = obj.rays.origin(:,1) * 10^6; %convert to nm
        apYGridFlat = obj.rays.origin(:,2) * 10^6;
        
        apXGridFlat = apXGridFlat(obj.rays.waveIndex == wIndex);
        apYGridFlat = apYGridFlat(obj.rays.waveIndex == wIndex);
        
        apXGridFlat = apXGridFlat(~isnan(apXGridFlat));
        apYGridFlat = apYGridFlat(~isnan(apYGridFlat));
        
        lambda = obj.lens.wave(wIndex);
        
        numApertureSamplesTot = length(apXGridFlat);
        
        % vcNewGraphWin; 
        % plot(apXGridFlat, apYGridFlat, 'o');  %plot the aperture samples
        
        % Create sensor grid
        % These are the locations on the sensor
        endLocations1DX = linspace(-numPixels(1)/2 * binSize(1), numPixels(1)/2 * binSize(1), numPixels(1));
        endLocations1DY = linspace(-numPixels(2)/2 * binSize(2), numPixels(2)/2 * binSize(2), numPixels(2));
        [endLGridX, endLGridY] = meshgrid(endLocations1DX, endLocations1DY);
        endLGridXFlat = endLGridX(:);    %flatten the meshgrid
        endLGridYFlat = endLGridY(:);
        endLGridZFlat = ones(size(endLGridYFlat)) * imagePlaneDist;
        
        intensity = zeros(numPixels(1), numPixels(2), length(obj.lens.get('wave')));       
        
        % lensMode is set true above.  So ... this needs to be fixed.
        if (lensMode)
            initialD = obj.rays.distance(~isnan(obj.rays.distance));
        else
            initialD = zeros(numApertureSamplesTot, 1);
        end
        
        intensityFlat = zeros(numPixels);
        intensityFlat = intensityFlat(:);
        jobInterval = 10000;
        nJobs = ceil(numApertureSamplesTot/jobInterval);
        
        % I think AL proposes dividing the calculation into independent
        % jobs for parallel computing.  This is preparation for that.
        %
        % Split aperture into segments and do bsxfun on that, then combine later.
        % This can be parallelized later (AL)
        for job = 1:nJobs
            waitbar((((wIndex-1)*nJobs) + job)/(nWave*nJobs),wbar);

            fprintf('job %i of %i total\n',job,nJobs)
            apXGridFlatCur = apXGridFlat((job-1) * jobInterval + 1:min(job * jobInterval, numApertureSamplesTot));
            apYGridFlatCur = apYGridFlat((job-1) * jobInterval + 1:min(job * jobInterval, numApertureSamplesTot));
            
            
            xDiffMat = bsxfun(@minus, endLGridXFlat, apXGridFlatCur');
            yDiffMat = bsxfun(@minus, endLGridYFlat, apYGridFlatCur');
            zDiffMat = repmat(endLGridZFlat, [1, length(apXGridFlatCur)]);
            
            initialDCur = initialD(((job-1) * jobInterval + 1:min(job * jobInterval, numApertureSamplesTot)));
            initialDMat = repmat(initialDCur', [length(endLGridXFlat), 1]);
            
            expD = exp(2 * pi * 1i .* ((sqrt(xDiffMat.^2 + yDiffMat.^2 + zDiffMat.^2) + initialDMat * 1e6)/lambda));
            intensityFlat = sum(expD, 2) + intensityFlat;
        end
        
        intensityFlat = 1/lambda .* abs(intensityFlat).^2;
        
        % plot results
        intensity1Wave = reshape(intensityFlat, size(intensity, 1), size(intensity, 2));
        obj.film.image(:,:,wIndex) = intensity1Wave;
        
    end
    
    obj.lens.diffractionEnabled = true;
    close(wbar);
    %End Huygens ray-trace
else
    
    % There may be more than one point in the camera structure.
    for ii=1:length(obj.pointSource)
        
        % (pointSource, ppsfCFlag, jitterFlag, rtType, subSection, depthTriangles)
        obj.rays = obj.lens.rtSourceToEntrance(obj.pointSource{ii}, jitterFlag, rtType, subsection);
        
        % Duplicate the existing rays for each wavelength
        % Note that both lens and film have a wave, sigh.
        % obj.rays.expandWavelengths(obj.film.wave);
        obj.rays.expandWavelengths(obj.lens.wave);
        
        %lens intersection and raytrace
        obj.lens.rtThroughLens(obj.rays, nLines);
        % title('Point source to final surface')
        %         obj.lens.rays.aExitInt.XY = origin
        %         obj.lens.rays.aExitInt.XY = direction
        
        % intersect with "film" and add to film
        obj.rays.recordOnFilm(obj.film, 'nLines',nLines,'fig',gcf);
        % title('Final surface to film');
    end
    
end

end