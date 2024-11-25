function corrMat = calcLarvalCorr(conMats)
% calcLarvalCorr() will calculate the correlation coefficients between
% total larval outputs across all reefs in the system

% input:

% conMats - a cell array containing connectivity matrices

% output:

% corrMat - a matrix containing pairwise correlations of total larval
    % output

% determine the number of matrices and reefs
nMats = length(conMats);
nReefs = size(conMats{1}, 1);

% initialise a matrix to hold the time series for total larval output at
% each reef
tSMat = zeros(nMats, nReefs);

% populate the matrix above
for t = 1:nMats
    tSMat(t, :) = sum(conMats{t}, 2)';
end

% remove any reefs that have zeros everywhere xd
totalLarv = sum(tSMat, 1);
zeroInds = totalLarv == 0;
tSMat = tSMat(:, ~zeroInds);

% calculate the correlations
corrMat = corr(tSMat);

% replace any of the correlations of 1 that occur from a reef being
% correlated with itself, with NaN
corrMat = corrMat + diag(diag(ones(size(corrMat, 1))) * NaN);

end