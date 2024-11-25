function overlapMat = calcOverlapProps(decVecs, methodInds)
% calcOverlapProps() will take as an input a number of decision vectors
% from multiple repetitions and multiple decision making techniques, and
% compare outcomes from the decision making techniques

% inputs:

% decVecs - a cell array, where decVecs{n}{m} holds a binary vector of the
    % decisions made during the nth repetition, from the mth decision
    % making method
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % methods

% output:

% overlapMat - a matrix, where overlapMat(m1, m2, n) holds the proportional
    % overlap between decision vectors from decision methods m1 and m2 on
    % the nth repetition

% set default for methodInds
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(decVecs{1});
end

% determine the number of decision making methods, the number of
% repetitions, and the number of decisions to be made
nMethods = length(methodInds);
nReps = length(decVecs);
nDecs = length(decVecs{1}{1});

% initialise the output matrix
overlapMat = zeros(nMethods, nMethods, nReps);

% loop over each repetition
for r = 1:nReps

    % loop over the first method
    for m1 = 1:nMethods

        % loop over the second method
        for m2 = (m1 + 1):nMethods

            % calculate and store the number of decisions with the same
            % outcomes
            overlapMat(m1, m2, r) = sum(decVecs{r}{methodInds(m1)} ...
                == decVecs{r}{methodInds(m2)});

        end

    end

    % mirror the matrix along the diagonal 
    overlapMat(:, :, r) = overlapMat(:, :, r) + overlapMat(:, :, r)';

end

% scale by the number of decisions to calculate proportions
overlapMat = overlapMat / nDecs;

end