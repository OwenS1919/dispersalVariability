function valMat = calcBiomass(popMat, classWeights)
% calcBiomass() will convert from a population matrix with abundances in
% age / size classes for each reef and time, to the biomass at each reef
% and time

% inputs:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep
% classWeights - a vector of the weight of each age class

% output:

% valMat - a 2d array where valMat(i, k) indicates the biomass on reef i at
    % time k

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