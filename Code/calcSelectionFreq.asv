function selFreqMat = calcSelectionFreq(decVecs, methodInds)
% calcSelectionFreq() will calculate the frequencies with which each
% decision is made, across a set of decisions along a number of repetitions

% inputs:

% decVecs - a cell array, where decVecs{n}{m} holds a binary vector of the
    % decisions made during the nth repetition, from the mth decision
    % making method
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % method

% output:

% selFreqMat - a matrix, where selFreqMat(r, m) holds proportion of
    % repetitions in which each decision is made

% set default for methodInds
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(decVecs{1});
end

% intialise an output
nMethods = length(methodInds);
nDecs = length(decVecs{1}{1});
nReps = length(decVecs);
selFreqMat = zeros(nMethods, nDecs);

% calculate the selection frequencies, and scale by the number of
% repetitions
for m = 1:nMethods
    for r = 1:nReps
        selFreqMat(m, :) = selFreqMat(m, :) + decVecs{r}{m};
    end
end
selFreqMat = selFreqMat / nReps;

end