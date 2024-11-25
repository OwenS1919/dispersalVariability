function plotConMatSummary(conMat, centroids, subplotVar)
% plotConMatSummary will make a summary plot of the connectivity matrix
% conMat, and reproduce a plot similar to James et al., 2002

% input:

% conMat - a connectivity matrix
% centroids - the centroids of each node, with dimension nNodes x 2
%     with each coord in the form [long, lat]
% subplotVar - optional - if specified as "subplot", the markersizes will
%     be adjusted to better fit this layout - default is "no"

% use some for loops to populate some arrays for all of the points, use a 3
% column matrix where the first two colums are the coordinates, and the
% third is a the colour code with the following codes applying:

% 1: 0 < cij <= 0.005
% 2: 0.005 < cij <= 0.01
% 3: 0.01 < cij <= 0.02
% 4: 0.02 < cij

% set the defualt for subplotVar
if nargin < 3 || isempty(subplotVar)
    subplotVar = "no";
end

% if we are plotting in a subplot, apply a factor to reduce the size of the
% markers
if subplotVar == "subplot"
    mFact = 0.6;
else
    mFact = 1;
end

% setup a vector to hold these limits
limVec = [0.005, 0.01, 0.02, 1.1];

% find the nonzero values and initialise a coordsMat matrix
[row, col] = find(conMat);
coordsMat = zeros(length(row), 3);

% loop over the connectivity matrix
for r = 1:length(row)

    % determine which of the colour categories it falls in to
    colourCode = find(conMat(row(r), col(r)) < limVec, 1, 'first');

    % record the coordinates and the colour code into coordsMat
    coordsMat(r, :) = [centroids(col(r), 2), centroids(row(r), 2), ...
        colourCode];

end

% once the loop is complete, go though and plot the results
hold on
ind = coordsMat(:, 3) == 1;
plot(coordsMat(ind, 1), coordsMat(ind, 2), '.', 'Color', getColour('lb'), ...
    'MarkerSize', 1)
ind = coordsMat(:, 3) == 2;
plot(coordsMat(ind, 1), coordsMat(ind, 2), '.', 'Color', getColour('b'), ...
    'MarkerSize', mFact * 3)
ind = coordsMat(:, 3) == 3;
plot(coordsMat(ind, 1), coordsMat(ind, 2), '.', 'Color', getColour('y'), ...
    'MarkerSize', mFact * 5)
ind = coordsMat(:, 3) == 4;
plot(coordsMat(ind, 1), coordsMat(ind, 2), '.', 'Color', getColour('r'), ...
    'MarkerSize', mFact * 7.5)

% setup the axes (changed from the previous code which set them based on
% the GBR only)
set (gca, 'xdir', 'reverse')
axis square

% set the fontname to times because I'm not a godless savage
set(gca, 'FontName', 'Times')

end
