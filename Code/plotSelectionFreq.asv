function plotSelectionFreq(decVecs, methodInds, modStrings)
% plotSelectionFreq() will calculate the frequencies with which each
% decision is made, across a set of decisions along a number of
% repetitions, and the plot their distributions

% inputs:

% decVecs - a cell array, where decVecs{n}{m} holds a binary vector of the
    % decisions made during the nth repetition, from the mth decision
    % making method
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % method
% modStrings - optional - a string array holding the labels to be used for
    % each of the models - default will just assign numbers as labels

% set defaults
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(decVecs{1});
end
if nargin < 3 || isempty(modStrings)
    modStrings = [];
    for i = 1:length(methodInds)
        modStrings = [modStrings, num2str(methodInds)];
    end
end

% calculate the selection frequencies
selFreqMat = calcSelectionFreq(decVecs, methodInds);

% plot the results
hold on
legendArr = [];
for m = 1:length(methodInds)
    plot(sort(selFreqMat(m, :)))
    legendArr = [legendArr, modStrings(m)];
end
title("Selection Frequency Distribution")
xlabel("Reef Index (Sorted)")
ylabel("Selection Frequency")
legend(legendArr, 'Location', 'Best')

end