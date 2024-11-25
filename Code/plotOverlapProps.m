function plotOverlapProps(solCell, methodInds, regionString, typeString, ...
    darkMode)
% calcOverlapProps() will take as an input a number of decision vectors
% from multiple repetitions and multiple decision making techniques, and
% plot the average proportional overlap between methods

% inputs:

% solCell - a cell array containing simOutStruct objects as described in
    % runMPASimulation
% methodInds - optional - a vector of indices indicating which of the
    % decision methods to compare - default will compare all availaible
    % methods
% regionString - a string holding the region the values correspond to
% typeString - a string, indicating the type of plot to make, either
    % "inter" to compare between different decision making methods, or
    % "intra" to compare internal to each method across varying simulations
    % - default is "inter"
% darkMode - optional - a boolean, set as true to make the polygon outline
    % white rather than black - default is true

% set a defaults
if nargin < 2 || isempty(methodInds)
    methodInds = 1:length(solCell);
end
if nargin < 4 || isempty(typeString)
    typeString = "inter";
end
if nargin < 5 || isempty(darkMode)
    darkMode = true;
end

% determine the number of methods and simulations
nMethodsTot = length(solCell);
nMethods = length(methodInds);
nSims = length(solCell{1}.mpaSel);

% extract the names of each of the simulations
namesVec = strings(1, nMethods);
for i = 1:nMethods
    if solCell{i}.methodStruct.methodInd == "MPTBiom"
        namesVec(i) = "MPT B. (k = " ...
            + num2str(solCell{i}.methodStruct.meanVarWeight) + ")";
    elseif solCell{i}.methodStruct.methodInd == "MPTLarvCont"
        namesVec(i) = "MPT LC. (k = " ...
            + num2str(solCell{i}.methodStruct.meanVarWeight) + ")";
    elseif solCell{i}.methodStruct.methodInd == "none"
        namesVec(i) = "None";
        noneInd = i;
    elseif solCell{i}.methodStruct.methodInd == "random"
        namesVec(i) = "Random";
    elseif solCell{i}.methodStruct.methodInd == "finalBiom"
        randInd = i;
        namesVec(i) = "Final B.";
    elseif solCell{i}.methodStruct.methodInd == "finalLarvCont"
        namesVec(i) = "Final LC.";
    else
        namesVec(i) = solCell{i}.methodStruct.methodInd;
    end
end

% remove the none case
solCell = solCell([1:(noneInd - 1), (noneInd + 1):end]);
namesVec = namesVec([1:(noneInd - 1), (noneInd + 1):end]);
nMethods = nMethods - 1;

% reverse the positions of all my shit because I'm stupid
solCell = solCell(length(solCell):-1:1);
namesVec = namesVec(length(namesVec):-1:1);

% create colours to use for each of the boxplots
coloursCell = cell(1, nMethods);
coloursCell{1} = getColour('lb');
coloursCell{2} = getColour('o');
coloursCell{3} = getColour('y');
for i = 1:5
    coloursCell{3 + i} = getColour(i + 2, 7, 'p');
end
for i = 1:5
    coloursCell{8 + i} = getColour(i + 2, 7, 'g');
end

% instantly reverse this because I'm too lazy to reverse the numbers
coloursCell = coloursCell(length(coloursCell):-1:1);

% treat the inter case first, and return inside the if statement
if typeString == "intra"

    % create storage to pass into myBoxPlot
    boxPlotData = zeros(nchoosek(nSims, 2), nMethods);

    % first, need to loop over each of the methods
    for m = 1:nMethods

        % shit ok probably need to arrange shit so that the good old
        % comparison method can run

        % convert the entries from solCell into the format used by
        % calcOverlapProps
        decVecs = {};
        decVecs{1} = cell(nSims, 1);
        for j = 1:nSims
            decVecs{1}{j} = solCell{m}.mpaSel{j};
        end

        % calculate the overlap props for this method
        currData = calcOverlapProps(decVecs);

        % take and store the average, taking care to remove the diagonal
        currDataVec = zeros(1, nSims * (nSims - 1) / 2);
        ctr = 0;
        for i = 1:nSims
            for j = (i + 1):nSims
                ctr = ctr + 1;
                currDataVec(ctr) = currData(i, j);
            end
        end
        boxPlotData(:, m) = currDataVec;

    end

    % plot using a boxplot
    myBoxPlot(boxPlotData, namesVec, [], darkMode, "horizontal", ...
        coloursCell)

    % throw some ylines around to split between the cases
    yline(5.5, '--k')
    yline(10.5, '--k')
    yline(12.5, '--k')

    % set up text
    title("Proportional Overlap Across Simulation Runs")
    subtitle(regionString + " Region")
    xlabel("Proportional Overlap")

    % exit the function
    return

end

% convert the entries from solCell into the format used by calcOverlapProps
decVecs = cell(nSims, 1);
for i = 1:nSims
    decVecs{i} = cell(nMethods, 1);
    for j = 1:nMethods
        decVecs{i}{j} = solCell{j}.mpaSel{i};
    end
end

% calculate the proportional overlaps
overlapMat = calcOverlapProps(decVecs, 1:nMethods);

% remove the entries below the diagonal
for i = 1:size(overlapMat, 3)
    overlapMat(:, :, i) = overlapMat(:, :, i) - tril(overlapMat(:, :, i), ...
        -1);
end

% take the average across all repetitions
overlapMat = mean(overlapMat, 3);

% plot the overlaps
imagesc(overlapMat')
colormap(myColourMap())
colorbar()
clim([0, 1])
xticks(1:length(methodInds))
yticks(1:length(methodInds))
xticklabels(namesVec)
yticklabels(namesVec)
set(gca, 'YDir', 'Normal')

% put in the actual proportions as text
for i = 1:nMethods
    for j = i:nMethods
        if j == i
            continue
        end
        text(j, i, num2str(round(overlapMat(i, j), 2)), ...
            "HorizontalAlignment", "center", "Color", [1, 1, 1])
    end
end

% draw lines to help with viewing stuff
for i = 1:length(methodInds)
    yline(i - 0.5)
    xline(i - 0.5)
end

% title shit
title("Mean Proportional Overlap Between Methods")
subtitle(regionString + " Region")

end