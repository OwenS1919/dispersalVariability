function [perf, perfTimed] = objFuncMPA(popMat, sizeWeights)
% objFuncMPA() will evaluate the performance of an MPA network based on a
% matrix of the population counts for each size class at each reef

% for now, the objective function is going to be simply a weighted by size
% class sum of all the populations across all reefs -> I will hopefully
% update the function later to add in more factors

% input:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep
% sizeWeights - optional - represents the weightings given to each of the
    % size classes for the obective function - defualt is just equal
    % weightings (all 1)

% output:

% perf - the objective function value for the population matrix supplied 
% perfTimed - the objective function values for each individual year for
    % the population matrix supplied

% determine the number of size classes
nSizes = size(popMat, 2);

% set a default for the sizeWeights variable
if nargin < 2 || isempty(sizeWeights)
    sizeWeights = ones(nSizes, 1);
else

    % transpose the sizeWeights argument into a column vector if necessary
    if size(sizeWeights, 2) > size(sizeWeights, 1)
        sizeWeights = sizeWeights';
    end

end

% calculate the yearly contributions to the objective function, then sum
% them to produce the objective function value itself
popMatTemp = squeeze(sum(popMat, 1))';
perfTimed = (popMatTemp * sizeWeights)';
perf = sum(perfTimed);

end
