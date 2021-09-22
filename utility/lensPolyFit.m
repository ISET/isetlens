function [polyModel] = lensPolyFit(iRays, oRays,varargin)

% Example:
%{
lensName = 'wide.40deg.3.0mm.json';
[iRays, oRays, planes] = lensRayPairs(lensName, 'visualize', true,...
                                    'n radius samp', 10, 'elevation max', 40,...
                                    'reverse', true);
fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json')
[polyModel, jsonPath] = lensPolyFit(iRays, oRays, 'planes', planes,...
                                    'visualize', true, 'fpath', fpath);
%}
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('iRays', @isnumeric);
p.addRequired('oRays', @isnumeric);
p.addParameter('lensthickness',NaN,@isnumeric);
p.addParameter('maxdegree', 4, @isnumeric);
p.addParameter('visualize', false, @islogical);
p.addParameter('fpath', '', @ischar);
p.addParameter('planes', struct(), @isstruct);
p.addParameter('pupilpos', [],@isnumeric);
p.addParameter('pupilradii', [], @isnumeric);
p.addParameter('planeoffset', [], @isnumeric);
p.addParameter('circleradii', [], @isnumeric);                        
p.addParameter('circlesensitivities', [], @isnumeric);                        
p.addParameter('circleplanez', [], @isnumeric);      
p.addParameter('sparsitytolerance', 0, @isnumeric);      
p.parse(iRays,oRays,varargin{:});

maxDegree = p.Results.maxdegree;
visualize = p.Results.visualize;
fPath = p.Results.fpath;
planes = p.Results.planes;
pupilRadii = p.Results.pupilradii;
pupilPos = p.Results.pupilpos;
lensThickness = p.Results.lensthickness;
planeOffset= p.Results.planeoffset;
circlePlaneZ= p.Results.circleplanez;
circleRadii= p.Results.circleradii;
circleSensitivities= p.Results.circlesensitivities;
sparsityTolerance= p.Results.sparsitytolerance;


outputSelection = [1 2 3 4 5 6];
%% Fit polynomial
% Each output variable will be predicted
% by a multivariate polynomial with three variables: x,u,v.
% Each fitted polynomial is a struct containing all information about the quality of the fit, powers and coefficients.
%
% An analytical expression can be generated using 'polyn2sym(poly{i})'
polyModel = cell(1, size(oRays, 2));
for i=1:numel(outputSelection)
    polyModel{i} = polyfitn(iRays, oRays(:,outputSelection(i)),maxDegree);
    %polyModel{i}.VarNames={'x','u','v'};
    polyModel{i}.VarNames={'x','u','v'};
    
    %     % save information about position of input output planes
    %     polyModel{i}.planes =planes;
end

%% Make sparse
for i=1:numel(outputSelection)
    indexKeep = abs(polyModel{i}.Coefficients) > sparsityTolerance;
    % Refit using pruned model terms
    newModelTerms=polyModel{i}.ModelTerms(indexKeep,:);
    polyModel{i} = polyfitn(iRays, oRays(:,outputSelection(i)),newModelTerms);
end





%%
if visualize
    %%  Visualize polynomial fit
    labels = {'x','y','z','u','v','w'};
%     fig=figure(6);clf;
%     fig.Position=[231 386 1419 311];
    pred = zeros(size(iRays, 1), 6);
    ieNewGraphWin;
    
    for i=1:numel(outputSelection)
        pred(:,i)= polyvaln(polyModel{i},iRays(:,:));
        out = oRays(:,outputSelection(i));
        subplot(1,numel(outputSelection),i); hold on;
        h = scatter(pred(:,i),out,'Marker','.','MarkerEdgeColor','r');
        plot(max(abs(out))*[-1 1],max(abs(out))*[-1 1],'k','linewidth',1)
        xlim([min(out) max(out)])
        title(labels{i})
        xlabel('Polynomial')
        ylabel('Ray trace')
    end
    
    
%     ieNewGraphWin;
%     
%     for i=1:numel(outputSelection)
%         pred(:,i)= polyvaln(polyModel{i},iRays(:,:));
%         out = oRays(:,outputSelection(i));
%         subplot(1,numel(outputSelection),i); hold on;
%         relerr = (out-pred)./abs(out);
%         boxplot(relerr(:));
%         ylim(1e-2*[-1 1])
%         title(labels{i})
%         xlabel('Relative error')
%         
%     end
%     
end

% %%  SHoudl be decouploed from this function
% if ~isempty(fPath)
%     jsonPath = polyJsonGenerate(polyModel, 'lensthickness', lensThickness, 'planes', planes, 'outpath', fPath,...
%         'pupil pos', pupilPos,...
%         'pupil radii', pupilRadii,'plane offset',planeOffset,...
%         'circle radii',circleRadii,...
%         'circle sensitivities',circleSensitivities,...
%         'circle plane z',circlePlaneZ);
% 
% end
end