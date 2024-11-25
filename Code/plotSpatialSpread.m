function plotSpatialSpread(solCell, centroids, regionString, darkMode)
% calcSpatialSpread() will calculate a metric based on the level of spatial
% spread of the actions made in decisionVec

% inputs:

% solCell - a cell array containing simOutStruct objects as described in
    % runMPASimulation
% centroids - an nDecs x 2 matrix containing the coordinates of the reefs
    % for which the decisions are being based on
% regionString - a string holding the region the values correspond to
% darkMode - optional - a boolean, set as true to make the polygon outline
    % white rather than black - default is true

% set defaults
if nargin < 4 || isempty(darkMode)
    darkMode = true;
end

% if centroids are passed in as a shapeStruct, convert to a centroids
% thingy
if class(centroids) == "struct"
    nReefs = length(centroids);
    structVar = centroids;
    centroids = zeros(nReefs, 2);
    for i = 1:nReefs
        centroids(i, :) = structVar(i).Centroid;
    end
end

% convert the solCell stuff into decVecs form because I'm too lazy to
% bother rewriting this whole thing

% determine the number of methods and simulations
nMethodsTot = length(solCell);
nSims = length(solCell{1}.mpaSel);

% extract the names of each of the simulations
namesVec = strings(1, nMethodsTot);
for i = 1:nMethodsTot
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
nMethods = nMethodsTot - 1;

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

% initialise storage for the outputs, and calculate the pairwise distances
% for efficiency
spreadMat = zeros(nSims, nMethods);
pDistMat = pdistLatLon(centroids);

% convert the entries from solCell into the format used by
% calcOverlapProps
decVecs = cell(1, nMethods);
for m = 1:nMethods
    decVecs{m} = cell(nSims, 1);
    for j = 1:nSims
        decVecs{m}{j} = solCell{m}.mpaSel{j};
    end
end

% loop over the repetitions and models, and calculate the spread metrics
% for each
for s = 1:nSims
    for m = 1:nMethods
        spreadMat(s, m) = calcSpatialSpread(decVecs{m}{s}, ...
            centroids, pDistMat);
    end
end

% plot the results
myBoxPlot(spreadMat, namesVec, [], darkMode, "horizontal", coloursCell)
yline(5.5, '--k')
yline(10.5, '--k')
yline(12.5, '--k')
title("Spatial Spread Across Decision-Making Methods")
subtitle(regionString + " Region")
xlabel("Spatial Spread (Smaller = More Clustered)")

end