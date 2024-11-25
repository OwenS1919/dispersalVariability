function spatSpread = calcSpatialSpread(decisionVec, centroids, ...
    pDistMat, latLongInd)
% calcSpatialSpread() will calculate a metric based on the level of spatial
% spread of the actions made in decisionVec

% inputs:

% decisionVec - a binary vector indicating where actions were taken, of
    % length nDecs
% centroids - an nDecs x 2 matrix containing the coordinates of the reefs
    % for which the decisions are being based on
% pDistMat - optional - a matrix containing the pairwise distances between
    % the centroids, should be of dimension nDecs x nDecs - if not
    % provided, pDistMat will be calculated internally\
% latLongInd - optional - specify as "latLong" if centroids are in lat long
    % form - default is "no"

% output:

% spatialSpread - a metric I have made up lmao, which is the average of the
    % smallest pairwise distance for each reef indicated in decisionVec

% set default for latLongInd
if nargin < 4 || isempty(latLongInd)
    latLongInd = "no";
end

% determine whether pDistMat has been specified
if nargin < 3 || isempty(pDistMat)

    % in this case, pDistMat has not been provided - first, let's reduce
    % centroids to just the reefs we care about
    centroids = centroids(decisionVec > 0);

    % now, calculate the pairwise distances
    if latLongInd ~= "latLong"
        pDistMat = squareform(pdist(centroids));
    else
        pDistMat = squareform(pdistLatLon(centroids));
    end

else

    % otherwise, pDistMat has been supplied, so we just need to remove any
    % values which don't correspond to the decisions made
    pDistMat = pDistMat(decisionVec > 0, decisionVec > 0);

end

% to avoid issues later with the diagonals, set them here
pDistMat = pDistMat + eye(size(pDistMat)) * 10^200;

% now, loop over the matrix and determine the minimum distances for each
% reef
nPoints = size(pDistMat, 1);
minDists = zeros(nPoints, 1);
for i = 1:nPoints
    minDists(i) = min(pDistMat(i, :));
end

% take the mean of these minimum pairwise distances, and return this as our
% metric
spatSpread = mean(minDists);

end