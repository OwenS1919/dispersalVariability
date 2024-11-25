function plotSelections(simStruct, simInds, plotDesc, shapeStruct)
% plotSelectionHeatmap() will create a heatmap based on the proportion of 
% repetitions a reef was selected in a decision making problem, or can
% create a plot containing the frequency and areas of the reefs chosen

% inputs:

% simStruct - a structure, that contains the field:
    % mpaSel - a cell array, where mpaSel{i} is a binary vector, indicating
        % the reefs chosen for the MPA network in the ith simulation
% simInds- a vector containing the indices of the simulations to plot
% plotDesc - a string indicating a description for the plot which is added
    % after the title
% shapeStruct - a structure array where each element corresponds to the
    % shape of a reef, holding the fields X and Y

% switch cases based on the type of plots being made
tL = tiledlayout(ceil(length(simInds) / 2), 2, "TileSpacing", "compact");

% plot the heatmaps for each of the simulations
for i = 1:length(simInds)
    ax(i) = nexttile;
    plotShapeStruct(shapeStruct, [], simStruct.mpaSel{simInds(i)}, ...
        "fillBorder")
    title("Simulation " + num2str(simInds(i)))
    colorbar off
    axis normal
end

% create global figure annotations
set(ax, 'colormap', myColourMap(), 'CLim', [0, 1]);
clb = colorbar(ax(end));
clb.Layout.Tile = "north";
title(tL, "MPA Network Solutions - " + plotDesc, ...
    "Interpreter", "Latex")
xlabel(tL, "Longitude", "Interpreter", "Latex")
ylabel(tL, "Latitude", "Interpreter", "Latex")

end