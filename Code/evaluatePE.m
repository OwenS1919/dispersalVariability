function [PE, z] = evaluatePE(xCell, methodInd, weights)
% evaluatePE() will evaluate the strength of the portfolio effect for a set
% of time - series data stored in xCell, each of which corresponds to a
% separate asset

% author: Owen Stewart (QUT)

% need to mention the ecological prophets paper somewhere as a reference
% for the methods

% inputs:

% xCell - a cell array containing a set of vectors of equal length (may
%     expand the method later to deal with unequal) which each correspond
%     to a time series dataset for a single asset (i.e. subpopulation),
%     cell array must be size n x 1 where n is the number of subpopulations
% methodInd - the method to use to evaluate the portfolio effect - "aveCV"
%     indicates the average - coefficient of variation method should be
%     used, and "meanVar" indicates the mean - variance method should be
%     used - default is "aveCV"
% weights - the weights for each of the portfolio

% outputs:

% PE - the portfolio effect metric evaluation
% z - the z value asscoiated with the mean - variance method

% assign defaults to methodInd and weights
if nargin < 2 || isempty(methodInd)
    methodInd = "aveCV";
end
if nargin < 3 || isempty(weights)
    weights = ones(1, length(xCell));
end

% determine the number of subpopulations
nSubp = length(xCell);

% calculate the mean and standard deviation for each of the subpopulations
muVec = zeros(1, length(xCell));
sigmaVec = zeros(1, length(xCell));
for i = 1:nSubp
    muVec(i) = mean(xCell{i});
    sigmaVec(i) = sd(xCell{i});
end

% calculate the observed mean and standard deviation of the entire
% metapopulation
metaVec = zeros(1, length(xCell{1}));
for i = 1:nSubp
    metaVec = metaVec + xCell{i};
end
muObs = mean(metaVec);
sigmaObs = sd(metaVec);

% switch between methods
if methodInd == "aveCV"

    % calculate the coefficient of variation for each of the
    % subpopulations
    subCV = sigmaVec ./ muVec;

    % calculate the PE
    PE = subCV / (sigmaObs / muObs);

elseif methodInd == "meanVar"

    % fit a linear model to the data, and extract the z paramter
    fitModel = fitlm(log(muVec), log(sigmaVec));
    z = fitModel.Coefficients{1, "Estimate"};

    % extrapolate out to the mean of the total population
    sigmaPredict = predict(fitModel, muObs);

    % calculate the PE
    PE = sigmaObs / sigmaPredict;

else

    % if methods do not match, send back and error
    error("Method not correctly satisfied, exiting");

end

end
