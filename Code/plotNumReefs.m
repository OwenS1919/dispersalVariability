function plotNumReefs(solCell, regionString, darkMode)
% plotNumReefsChosenDist() will calculate the number of reefs chosen for a
% set of decision making models over a number of repetitions

% inputs:

% solCell - a cell array, where each element is a simOutStruct, as
% described in runMPASimulation()
% regionString - a string holding the region the values correspond to
% darkMode - optional - a boolean, set as true to make the polygon outline
% white rather than black - default is true

% set defaults
if nargin < 3 || isempty(darkMode)
    darkMode = true;
end

% determine the number of different methods used and simulation repetitions
nMethods = length(solCell);
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

% need to convert the values stored in the cell array to a method which
% can be used by my box plot method
plotMat = zeros(nSims, nMethods);
for i = 1:nMethods
    for j = 1:nSims
        plotMat(j, i) = sum(solCell{i}.mpaSel{j});
    end
end

% now plot the results
myBoxPlot(plotMat, namesVec, [], darkMode, "horizontal", coloursCell)

% throw some ylines around to split between the cases
yline(5.5, '--k')
yline(10.5, '--k')
yline(12.5, '--k')

% set up text
title("Number of Reefs Selected")
subtitle(regionString + " Region")
xlabel("Number of Reefs Selected")

end