function nChosenMat = calcNumReefsChosen(decVecs, methodInds)
% calcNumReefsChosenDist() will calculate the number of reefs chosen for a
% set of decision making models over a number of repetitions

% inputs:

% decVecs - a cell array, where decVecs{n}{m} holds a binary vector of the
    % decisions made during the nth repetition, from the mth decision
    % making method
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % method

% output:

% nChosenMat - a matrix, where nChosenMat(r, m) holds the number of reefs
    % chosen by the mth decision making method on the rth repetition

% set default for methodInds
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(decVecs{1});
end

% determine the number of decision making methods, the number of
% repetitions, and the number of decisions to be made
nMethods = length(methodInds);
nReps = length(decVecs);

% initialise the output matrix
nChosenMat = zeros(nReps, nMethods);

% loop over each repetition
for r = 1:nReps

    % loop over the decision making method
    for m = 1:nMethods

        % calculate and store the number of reefs chosen
        nChosenMat(r, m) = sum(decVecs{r}{methodInds(m)});

    end

end

end