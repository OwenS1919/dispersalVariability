function [meanConn, stdConn, minMaxConn, inds] = connectivityAnalysis( ...
    conMats, nonzeroProp)
% connectivityAnalysis() will conduct a simple exploratory analysis of a
% set of connectivity matrices

% inputs:

% conMats - a cell array of connectivity matrices
% nonzeroProp - optional - the proportion of matrices for which a
    % connection must be nonzero for the value to be used in the analysis -
    % default is eps (i.e. must have at least one nonzero value)

% outputs:

% meanConn - an n x 1 vector containing the mean connectivity value for
    % each connection above the nonzeroProp threshold
% stdConn - as above, but holding the standard deviations
% minMaxConn - as above, but of dimension n x 2 holding the minimum and
    % maximum connection values in that order
% inds - an n x 2 matrix containing the indices corresponding to the
    % connections which make up the above autocorrelation vectors

% set defaults
if nargin < 2 || isempty(nonzeroProp)
    nonzeroProp = eps;
end

% gather useful information about the system
nMats = length(conMats);
nReefs = size(conMats{1}, 1);

% create a mask of the connections which meet the nonzeroProp threshold
suitConnsMask = sparse(zeros(nReefs, nReefs));
for i = 1:nMats
    suitConnsMask = suitConnsMask + 1 * (conMats{i} > 0);
end
suitConnsMask = suitConnsMask >= (nonzeroProp * length(conMats));
[r, c] = find(suitConnsMask);
inds = [r, c];
nSuitConns = sum(sum(suitConnsMask));

% create a 3d matrix to use for the comparisons
compMat = zeros(nReefs, nReefs, nMats);
for k = 1:nMats
    compMat(:, :, k) = conMats{k};
end
clear conMats

% loop over the row and column indices and calculate summary statistics
meanConn = zeros(nSuitConns, 1);
stdConn = zeros(nSuitConns, 1);
minMaxConn = zeros(nSuitConns, 2);
for i = 1:nSuitConns

    % calculate the correlation coefficients
    currConn = squeeze(compMat(inds(i, 1), inds(i, 2), :));

    % calculate descriptive statistics
    meanConn(i) = mean(currConn);
    stdConn(i) = std(currConn);
    minMaxConn(i, 1) = min(currConn);
    minMaxConn(i, 2) = max(currConn);

end

end