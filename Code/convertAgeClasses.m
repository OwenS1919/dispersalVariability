function valMat = convertAgeClasses(popMat, classWeights)
% convertAgeClasses() will convert from a population matrix with abundances
% in age / size classes for each reef and time, to an aggregated version of
% a total weighted sum of the age / size classes for each of the reefs and
% timesteps

% inputs:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep
% classWeights - optional - a vector of the weightings to be used in the
    % summation across age / size classes - defualt is just ones, i.e.
    % takes an unweighted sum, should be a row vector

% output:

% valMat - a 2d array where valMat(i, k) indicates the weighted sum across
    % age classes on reef i at time k

% set a default for classWeights if necessary
if nargin < 2 || isempty(classWeights)
    classWeights = ones(1, size(popMat, 2));
end

% transpose classWeights if necessary
if size(classWeights, 1) > size(classWeights, 2)
    classWeights = classWeights';
end

% compute the sum
valMat = zeros(size(popMat, 1), size(popMat, 3));
for i = 1:size(popMat, 3)
    valMat(:, i) = squeeze(popMat(:, :, i)) * classWeights';
end

end
