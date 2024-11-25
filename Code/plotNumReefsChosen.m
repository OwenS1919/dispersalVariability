function plotNumReefsChosen(decVecs, methodInds, modStrings, darkMode)
% plotNumReefsChosenDist() will calculate the number of reefs chosen for a
% set of decision making models over a number of repetitions

% inputs:

% decVecs - a cell array, where decVecs{n}{m} holds a binary vector of the
    % decisions made during the nth repetition, from the mth decision
    % making method
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % methods
% modStrings - optional - a string array holding the labels to be used for
    % each of the models - default will just assign numbers as labels
% darkMode - optional - a boolean, set as true to make the polygon outline
    % white rather than black - default is true

% assign defaults
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(decVecs{1});
end
if nargin < 3 || isempty(modStrings)
    modStrings = [];
    for i = 1:length(methodInds)
        modStrings = [modStrings, num2str(methodInds)];
    end
end
if nargin < 4 || isempty(darkMode)
    darkMode = true;
end

% calculate the number of reefs chosen for each method and each repetition
nChosenMat = calcNumReefsChosen(decVecs, methodInds);

% now, plot the results
hold on
myBoxPlot(nChosenMat, modStrings, "outliers", darkMode)
title("Number of Reefs Chosen (" + num2str(length(decVecs{1}{1})) ...
    + " Reefs Total)")
xlabel("Model")
ylabel("Num. Reefs Chosen")

end