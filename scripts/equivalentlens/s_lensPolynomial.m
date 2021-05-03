%%
ieInit;

%%
lensName = 'dgauss.22deg.3.0mm.json';
%% Generate ray pairs
maxRadius = 0.6;
minRadius = 0;

[iRays, oRays, planes] = lensRayPairs(lensName, 'visualize', true,...
                                    'n radius samp', 20, 'elevation max', 40,...
                                    'reverse', true,...
                                    'max radius', maxRadius,...
                                    'min radius', minRadius);
%% Poly fit       
polyDeg = 6; 
fpath = fullfile(ilensRootPath, 'local', 'polyjson_test.json');
[polyModel, jsonPath] = lensPolyFit(iRays, oRays, 'planes', planes,...
                                    'visualize', true, 'fpath', fpath, 'maxdegree', polyDeg);
%% Plot relative error
ind = find(~isnan(oRays));
err = mean(abs(pred(ind) - oRays(ind)), 1);