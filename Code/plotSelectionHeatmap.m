function plotSelectionHeatmap(simOutCell, modInds, plotDesc, ...
    shapeStruct, typeString)
% plotSelectionHeatmap() will create a heatmap based on the proportion of 
% repetitions a reef was selected in a decision making problem, or can
% create a plot containing the frequency and areas of the reefs chosen

% inputs:

% simOutCell - a cell array holding structures, which each contain the
    % field:
    % mpaSel - a cell array, where mpaSel{i} is a binary vector, indicating
        % the reefs chosen for the MPA network in the ith simulation
% modInds - a vector containing the indices of the models (m in
    % selectionCell) to plot
% plotDesc - a string indicating a description for the plot which is added
    % after the title
% shapeStruct - a structure array where each element corresponds to the
    % shape of a reef, holding the fields X and Y
% typeString - optional - a string indicating the type of plot to be made,
    % with "heatmap" for the heatmap plot, and "frequency" for the
    % frequency plot - default is "heatmap"

% set default for typeString
if nargin < 5 || isempty(typeString)
    typeString = "heatmap";
end

% ok so fun fact - I previously wrote this code for different inputs and
% can't be bothered to fix that so I will just convert the new inputs into
% the old and pretend everything is ok in my life
selectionsCell = cell(1, length(simOutCell{1}.mpaSel));
for i = 1:length(simOutCell{1}.mpaSel)
    selectionsCell{i} = cell(1, length(simOutCell));
    for j = 1:length(simOutCell)
        selectionsCell{i}{j} = simOutCell{j}.mpaSel{i};
    end
end

% also need to convert the modInds
modDescs = strings(1, length(simOutCell));
for i = 1:length(simOutCell)
    if simOutCell{i}.methodStruct.methodInd == "MPTBiom"
        modDescs(i) = simOutCell{i}.methodStruct.methodInd + " ($k = " ...
            + simOutCell{i}.methodStruct.meanVarWeight + "$)";
    elseif simOutCell{i}.methodStruct.methodInd == "MPTLarvCont"
        modDescs(i) = simOutCell{i}.methodStruct.methodInd + " ($k = " ...
            + simOutCell{i}.methodStruct.meanVarWeight + "$)";
    else
        modDescs(i) = simOutCell{i}.methodStruct.methodInd;
    end
end
modDescs = modDescs(modInds);

% initialise an array which will hold the number of times each reef is
% selected, for each model
selCounts = zeros(length(modInds), length(selectionsCell{1}{1}));

% loop over each of the repetitions
for r = 1:length(selectionsCell)

    % loop over each of the models
    for m = 1:length(modInds)
        selCounts(m, :) = selCounts(m, :) ...
            + selectionsCell{r}{modInds(m)};
    end

end

% divide by the number of repetitions so that it becomes a proportion
selCounts = selCounts / length(selectionsCell);

% switch cases based on the type of plots being made
tL = tiledlayout(ceil(length(modInds) / 2), 2, "TileSpacing", "compact");

if typeString == "heatmap"

    % plot the heatmaps for each of the desired models
    for i = 1:length(modInds)
        ax(i) = nexttile;
        plotShapeStruct(shapeStruct, [], selCounts(i, :), "fillBorder")
        title(modDescs(i))
        colorbar off
        axis normal
    end

    % create global figure annotations
    set(ax, 'colormap', myColourMap(), 'CLim', [0, 1]);
    clb = colorbar(ax(end));
    clb.Layout.Tile = "north";
    title(tL, "Heatmap of Reef Selections By Model - " + plotDesc, ...
        "Interpreter", "Latex")
    subtitle(tL, "Colours indicate proportion of repetitions in which " + ...
        "reef was chosen", "Interpreter", "Latex")
    xlabel(tL, "Longitude", "Interpreter", "Latex")
    ylabel(tL, "Latitude", "Interpreter", "Latex")

else

    % otherwise, we will create this frequency plot thingy that I don't
    % have a better word for - begin by creating a vector of reef areas
    areaVec = zeros(length(shapeStruct), 1);
    for i = 1:length(areaVec)
        areaVec(i) = shapeStruct(i).Shape_Area;
    end

    % loop over each of the desired models
    for i = 1:length(modInds)

        % sort the values by the frequency of selection
        [barVals, inds] = sort(selCounts(i, :));
        areaVecSorted = areaVec(inds);

        % plot the bar chart using some matlab fuckery
        ax(i) = nexttile;
        hold on
        title(modDescs(i))
        x = 1:length(barVals);
        for j = 1:length(areaVecSorted)
            barObj(j) = bar(x(j), barVals(j), 'FaceColor', 'flat', ...
                'EdgeColor', 'none', 'CData', getColour(areaVecSorted(j), ...
                max(areaVecSorted)), 'BarWidth', 1);
            % barObj(j).CData(j, :) = getColour(areaVecSorted(j), ...
            %     max(areaVecSorted));
        end

    end

    % create global figure annotations
    linkaxes(ax)
    set(ax, 'colormap', myColourMap(), 'CLim', [0, max(areaVecSorted)]);
    clb = colorbar(ax(end));
    clb.Layout.Tile = "north";
    title(tL, "Bar Plot of Reef Selection Frequencies By Model - " ...
        + plotDesc, "Interpreter", "Latex")
    subtitle(tL, "Colours indicate area of reef", "Interpreter", "Latex")
    xlabel(tL, "Indices (ordered by selection frequency)", "Interpreter", ...
        "Latex")
    ylabel(tL, "Proportion of repetitions selected", "Interpreter", "Latex")

end

end