function [radii,centers] = vignettingFitEllipses(pointcloudPerPosition,varargin)
%VIGNETTINGFITELLIPSES For each position, the minimally bounded ellipse
%parameters are found that fit the pointcloud.

varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('pointcloudperposition', @iscell);
p.addParameter('nbpointsonconvexhull',  0,@isnumeric);      
    
p.parse(pointcloudPerPosition,varargin{:});
numberPointsOnHull=p.Results.nbpointsonconvexhull;


%% Helper variables and iniatilization
nbPositions = numel(pointcloudPerPosition);

% Initializse as NaNs. It might be that for some positions there is no
% data
centers=NaN(2,nbPositions); % X,Y
radii=NaN(2,nbPositions); % Major, Minor axis
%rotations=zeros(1,nbPositions); % Rotated ellipse, assume zero for now

%% Loop over all positions  
for p=1:nbPositions
    points=pointcloudPerPosition{p};
    if(isempty(points))
     % At some point there are no more points because we are beyond the image circle    
     % Thats where we jump out of this loop
      break; 
    end

    % Prepare pointsdata for fitting algorithm
    points=points(1:2,:); % Only use XY
    points(:,isnan(points(1,:)))=[]; % Remove nans
    
    % Estimate convex hull, this makes ellipse fitting much faster
    [k,av]=convhull(points');
    

    if(numberPointsOnHull>0)
        % Prune if a nonnegative number is given: Only use a certain number of points        
        % This is a Speed Optimization step
        k=k(round(linspace(1,numel(k),numberPointsOnHull)));
        hull=points(1:2,k);
    else
        % Just use whatever number of points are on the boundary
        hull=points(1:2,k);
    end

   
   % Fit mimimally bounding ellipse using only points on the hull
   [A , c] =MinVolEllipse(hull, 0.01);
 
   % Extract radii and centers
   [U D V] = svd(A);
   radii(1,p) = 1/sqrt(D(1,1)); % Major axis
   radii(2,p) = 1/sqrt(D(2,2));  % Minor axis
   centers(:,p)=c; % XY
   
   
  % The SVD algorithm sorts the radii by major and minor and the matrix V
  % contains the rotation information. 
  % For our rotationally symmetric case we want to know which one belongs
  % to X axis or Y axis. This is necesary to get a smooth curve for the X
  % and Y radii.
  % The current implementation checks which extremal point on x axis is closests to the radius.
  xmax=max(points(1,:));  ymax=max(points(2,:));
  maxX=(xmax-centers(1,p));
  maxY=(ymax-centers(2,p));
  % Flip if the radius belonging to radii(1) matches Y axis radius better
  if(abs(maxX-radii(1,p))  > abs(maxY-radii(1,p)))
    radii(:,p)=flip(radii(:,p),1);
  end
end




end

