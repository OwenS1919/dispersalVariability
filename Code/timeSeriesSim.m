function tSMat = timeSeriesSim(mu, sigma, tMax, autoCorrVec, corrMat, nReps)
% timeSeriesSim will simulate a set of time series data which have set
% averages, standard deviations and levels of autocorrelation

% the method in which these are created is arguably weird, however
% basically samples values from a normal distribution, then takes a linear
% combination of this newly sampled value and the previous value in the
% time series

% author: Owen Stewart

% inputs:

% mu - the mean value for the time series, can be a vector if multiple
%     populations with different means are desired
% sigma - the sigma value for the time series, can be a vector if multiple
%     populations with different standard deviations are desired
% tMax - the maximum time for each time series to run for
% autoCorrVec - optional - the amount of autocorrelation exhibited by each
%     time series, can be a vector or scalar - default is just zeros (i.e.
%     no autocorrelation for any of the populations)
% corrMat - optional - a correlation matrix, containing the desired
%     correlation coefficients between all pairs of time series - should
%     clearly be a square symmetric matrix with dimensions of either nReps
%     of the length of the mu or sigma vectors - default is just the
%     identity matrix
% nReps - optional - if corrMat is a single value, can use nReps to
%     repeat this time series multiple times - default is 1 (i.e. off)

% output:

% tSMat - a martix (or vector if only 1 time series is being simulated)
%     where the rows correspond to different time series, and the columns
%     correspond to the values at each timestep

% set the default values for autoCorrVec, corrMat and nReps
if nargin < 4 || isempty(autoCorrVec)
    autoCorrVec = 0;
end
if nargin < 5 || isempty(corrMat)
    corrMat = 1;
end
if nargin < 6 || isempty(nReps)
    nReps = 1;
end

% rotate autoCorrVec, mu and sigma if necessary
if size(autoCorrVec, 1) == 1
    autoCorrVec = autoCorrVec';
end
if size(mu, 1) == 1
    mu = mu';
end
if size(sigma, 1) == 1
    sigma = sigma';
end

% need to determine the dimensions of the correlation matrix, i.e. the
% number of time series we are simulating
nDims = max([length(mu), length(sigma), length(corrMat), ...
    length(autoCorrVec), nReps]);

% switch back to proper default for autoCorrVec and corrMat if necessary
if length(autoCorrVec) == 1
    autoCorrVec = repmat(autoCorrVec, nDims, 1);
end
if length(corrMat) == 1
    corrMat = eye(nDims);
end

% convert all variables into the correct dimensions if necessary
if length(mu) == 1
    mu = repmat(mu, nDims, 1);
end
if length(sigma) == 1
    sigma = repmat(sigma, nDims, 1);
end

% finally, need to convert the correlation matrix into a covariance matrix,
% by multiplying by the standard deviations of each variable pair
if size(sigma, 1) > 1
    sigma = sigma';
end
covMat = sigma * sigma' .* corrMat;

% simulate the time series data
tSMat = zeros(nDims, tMax);
tSMat(:, 1) = (1 - autoCorrVec) .* mvnrnd(mu, covMat, 1)' ...
    + autoCorrVec .* mu;
for t = 2:tMax
    tSMat(:, t) = (1 - autoCorrVec) .* mvnrnd(mu, covMat, 1)' + ...
        autoCorrVec .* tSMat(:, t - 1);
end

end
