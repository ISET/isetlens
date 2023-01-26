%% Lens tutorial
%
% We draw the lens and find all the pre-defined lenses.
%
% See also
%   lensC

%% Find all the lenses

lenses = lensC.list;

%% Pick a lens and draw it and plot the focal distance

thisLens = lensC('filename',lenses(11).name);

thisLens.draw;

%% Draw the lens focal length as a function of object distance

thisLens.plot('focal distance');

%% Pick a lens and draw it and plot the focal distance

thisLens = lensC('filename',lenses(11).name);

thisLens.draw;
