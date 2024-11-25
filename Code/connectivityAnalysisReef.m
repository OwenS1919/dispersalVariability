function [meanConn, stdConn, minMaxConn, inds] = connectivityAnalysisReef( ...
    conMats, nonzeroProp, transposeInd)
% connectivityAnalysisReef() will conduct a simple exploratory analysis of
% a set of connectivity matrices at a whole-reef scale - i.e. on entire row
% sums of the connectivity matrices

% inputs:

% conMats - a cell array of connectivity matrices
% nonzeroProp - optional - the proportion of matrices for which a
    % connection must be nonzero for the value to be used in the analysis -
    % default is eps (i.e. must have at least one nonzero value)
% transInd - optional - specify as "transpose" if the matrices are to be
    % transposed, i.e. look at incoming connections rather than outgoing -
    % default is "no"

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
if nargin < 3 || isempty(transposeInd)
    transposeInd = "no";
end

% gather useful information about the system
nMats = length(conMats);
nReefs = size(conMats{1}, 1);

% if specified, transpose all the matrices
if transposeInd == "transpose"
    for m = 1:nMats
        conMats{m} = conMats{m}';
    end
end

% create a mask of the connections which meet the nonzeroProp threshold
suitConnsMask = sparse(zeros(nReefs, 1));
for i = 1:nMats
    suitConnsMask = suitConnsMask + 1 * (sum(conMats{i}, 2) > 0);
end
suitConnsMask = suitConnsMask >= (nonzeroProp * length(conMats));
inds = find(suitConnsMask);
nSuitConns = sum(suitConnsMask);

% create a 2d matrix to use for the comparisons
compMat = zeros(nReefs, nMats);
for k = 1:nMats
    compMat(:, k) = sum(conMats{k}, 2);
end
clear conMats

% loop over the row and column indices and calculate summary statistics
meanConn = zeros(nSuitConns, 1);
stdConn = zeros(nSuitConns, 1);
minMaxConn = zeros(nSuitConns, 2);
for i = 1:nSuitConns

    % calculate the correlation coefficients
    currConn = compMat(inds(i), :);

    % calculate descriptive statistics
    meanConn(i) = mean(currConn);
    stdConn(i) = std(currConn);
    minMaxConn(i, 1) = min(currConn);
    minMaxConn(i, 2) = max(currConn);

end

end