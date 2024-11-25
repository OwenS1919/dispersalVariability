function autoCorrRes = autoCorr(timeSeries)
% autoCorr will calculate the autocorrelation for a single, or set of time
% series data

% author: Owen Stewart

% input:

% timeSeries - a vector or matrix of time series data - if specified as a
%     matrix, rows should correspond to individual time series, and columns
%     to timesteps

% output:

% autoCorrRes - the autocorrelation for the single or multiple time series

% compute the autocorrelation
autoCorrRes = zeros(size(timeSeries, 1), 1);
for i = 1:size(timeSeries, 1)
    autoCorrRes(i) = corr(timeSeries(i, 1:(end-1))', timeSeries(i, 2:end)');
end

end
