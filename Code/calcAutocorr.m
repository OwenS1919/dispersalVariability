function [autocorrVec, inds] = calcAutocorr(conMats, propNonzeroConn, ...
    compInds, randInd)
% calcAutocorr() will calculate the autocorrelations over individual
% connections for a set of connectivity matrices

% inputs:

% conMats - a cell array containing connectivity matrices
% propNonzeroConn - optional - the proportion of matrices for which a
    % connection must be nonzero for the value to be used in the analysis -
    % default is eps (i.e. must have at least one nonzero value)
% compInds - optional - contain the indices for which sequential
    % comparisons are to be made, used in the case of monthly comparisons
    % across a set of yearly spawning seasons - default will just make all
    % possible comparisons, i.e. 1:(length(conMats) - 1)
% randInd - optional - if specified as "rand", will take random
    % permutations of the connectivity time series data, then average the
    % autocorrelation - default is "no"

% outputs:

% autoCorrVec - a vector containing the autocorrelation values for each of
    % the suitable connections
% inds - an n x 2 matrix containing the indices corresponding to the
    % connections which make up the above autocorrelation vectors

% used to do the rank autocorrelation aswell but what the fuck is the point
% xd so I commented all that stuff out
% autoCorrRankVec - as above, but containing Spearman's rho rank
    % correlation coefficients

% set defaults
if nargin < 3 || isempty(compInds)
    compInds = 1:(length(conMats) - 1);
end
if nargin < 4 || isempty(randInd)
    randInd = "no";
end

% determine the number of comparisons to be made and the number of matrices
nComps = length(compInds);
nMats = length(conMats);

% create a mask of the connections which are suitable
nReefs = size(conMats{1}, 1);
suitConnsMask = sparse(zeros(nReefs, nReefs));
for i = 1:nMats
    suitConnsMask = suitConnsMask + 1 * (conMats{i} > 0);
end
suitConnsMask = suitConnsMask >= (propNonzeroConn * length(conMats));
[r, c] = find(suitConnsMask);
inds = [r, c];
nSuitConns = sum(sum(suitConnsMask));

% create 3d matrices to use for the comparisons
compMat1 = zeros(nReefs, nReefs, nComps);
compMat2 = zeros(nReefs, nReefs, nComps);
for k = 1:length(compInds)
    compMat1(:, :, k) = conMats{compInds(k)};
    compMat2(:, :, k) = conMats{compInds(k) + 1};
end
clear conMats

% loop over the row and column indices and calculate autocorrelation
% coefficients
autocorrVec = zeros(nSuitConns, 1);
% autocorrRankVec = zeros(nSuitConns, 1);

% switch cases based on whether or not we are randomly permuting the
% results
if randInd ~= "rand"

    % calculate the correlation coefficients
    for i = 1:nSuitConns
    
        % calculate the correlation coefficients
        autocorrVec(i) = corr(squeeze(compMat1(inds(i, 1), inds(i, 2), :)), ...
            squeeze(compMat2(inds(i, 1), inds(i, 2), :)));
        % autocorrRankVec(i) = corr(squeeze(compMat1(inds(i, 1), ...
        %     inds(i, 2), :)), squeeze(compMat2(inds(i, 1), inds(i, 2), :)), ...
        %     "type", "spearman");    
    end

else

    % randomly permute the time series 10 times, and record the average
    % autocorrelation
    for i = 1:nSuitConns
   
        % loop over the stochastic repetitions
        for j = 1:5

            % calculate the correlation coefficients
            randPermVec1 = randperm(nComps);
            randPermVec2 = randperm(nComps);
            autocorrVec(i) = corr(squeeze(compMat1(inds(i, 1), inds(i, 2), ...
                randPermVec1)), squeeze(compMat2(inds(i, 1), ...
                inds(i, 2), randPermVec2))) / 5 + autocorrVec(i);
            % autocorrRankVec(i) = corr(squeeze(compMat1(inds(i, 1), ...
            %     inds(i, 2), randPermVec1)), squeeze(compMat2(inds(i, 1), ...
            %     inds(i, 2), randPermVec2)), "type", "spearman") / 5 ...
            %     + autocorrRankVec(i);

        end
        
    end

end

% remove any NaN values which have occured
autocorrVec = autocorrVec(~isnan(autocorrVec));
% autocorrRankVec = autocorrRankVec(~isnan(autocorrRankVec));

end