%% Lens tutorial
%
% Wandell
%
% See also

%% Find the lenses
thisLens = lensC;
lenses = thisLens.list;

%% Pick a lens and draw it and plot the focal distance

thisLens = lensC('filename',lenses(21).name);

thisLens.draw;

%% Draw the lens focal length as a function of object distance

thisLens.plot('focal distance');

%% Show a point ray traced through the lens

% Put the lens diagram in a subplot specified by (row,col,panel)
thisLens.draw([2,2,2]);
