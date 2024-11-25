function plotDiagVals(conMatCell, dates, modelNames, saveVar)
% plotDiagVals() can be used to visualise the distributions of the
% diagonals on a connectivity matrix for a single matrix, a 

% inputs:

% conMatCell - a cell array containing a group of cell arrays, one for each
%     model being compared (max 4), with each model cell array containing a
%     number of connectivity matrices, which must be ordered in the same
%     way between models
% dates - a string array with the dates for each run, in the form YYYYMMDD
% modelNames - a string array containing the names of each model used
%     saveVar - optional - if specified as "save" figures will be cleared
%     each time and saved into the folder "figures", with file names
%     corresponding to the models being compared and the dates - default -
%     "off"
% saveVar - optional - specify as "save" if figures are to be produced,
%     wiped and saved

% set a default for saveVar
if nargin < 4 || isempty(saveVar)
    saveVar = "no";
end

% convert saveVar into a boolean
if saveVar == "save"
    saveVar = true;
else
    saveVar = false;
end

% determine the number of models being compared, and number of dates
nModels = length(modelNames);
nDates = length(dates);

% using the above, determine the number of comparisons necessary
nComparisons = nchoosek(nModels, 2);
comparisonMat = nchoosek(1:nModels, 2);

% setup the edges for the histograms
edges = linspace(0, 0.004, 21);

% setup a global figure if we are saving figures
if saveVar
    figure
end

% loop over each scenario being plotted
for d = 1:nDates

    % setup the current figure if not saving figures
    if ~saveVar
        figure
    end

    % setup the tiled layout
    if nComparisons > 1
        tL = tiledlayout(floor((nComparisons - 1) / 2) + 1, 2);
        tL.TileSpacing = "tight";
    else
        tL = tiledlayout(1, 1);
    end
    axVec = [];

    % loop over each comparison
    for c = 1:nComparisons

        % plot current model and title appropriately
        ax = nexttile;
        axVec = [axVec, ax];
        mod1 = comparisonMat(c, 1);
        mod2 = comparisonMat(c, 2);
        h1 = histcounts(diag(conMatCell{mod1}{d}), edges);
        h2 = histcounts(diag(conMatCell{mod2}{d}), edges);
        b = bar(edges(1:(end-1)), [h1; h2]', 1, 'BarWidth', 1, 'LineWidth', ...
            2);
        col1 = getColour('k');
        col2 = getColour('b');
        b(1).FaceColor = col1;
        b(1).EdgeColor = col1;
        b(2).FaceColor = col2;
        b(2).EdgeColor = col2;
        legend(modelNames(mod1), modelNames(mod2))
        set(gca, 'YScale', 'log')

    end

    % setup title and axes labels
    fTimes()
    linkaxes(axVec, 'xy')
    currDate = char(dates(d));
    if length(currDate) == 8
        dateString = currDate(7:8) + "/" + currDate(5:6) + "/" + ...
            currDate(1:4);
    else
        dateString = currDate;
    end
    title(tL, "Comparison of Local Retention Values (" + dateString + ")", ...
        'Interpreter', 'Latex')
    xlabel(tL, "Connection Strength", 'Interpreter', 'Latex')
    ylabel(tL, "Frequency (log scaled)", 'Interpreter', 'Latex')
    width = 600;
    if nComparisons > 1
        set(gcf,'position',[0, 0, width, ...
            0.8 * (floor((nComparisons - 1) / 2) + 1) * width / 2])
    else
        set(gcf,'position',[0, 0, width, 0.8 * width])
    end

    % if saving figures, save and clear current figure
    if saveVar
        figName = "diagVals_" + dates(d);
        for m = 1:nModels
            figName = figName + "_" + modelNames(m);
        end
        exportgraphics(gcf, "Figures\" + figName + ".png", 'Resolution', ...
            600)
        if d ~= nDates
            clf
        end
    end

end

end
