function plotConnectivityDist(conMatsCell, modelNames, presInd, settlementInd)
% plotConnectivityDist() will plot a histogram of connectivity values for
% multiple sets of connectivity matrices

% conMatsCell - a cell array of cell arrays, where conMatsCell{i}{j} holds
    % the jth connectivity matrix from the ith biophysical model
% modelNames - a string array, containing the names of each biophysical
    % model
% presInd - optional - specify as "pres" if producing a figure for the
    % presentation - default is "no"

% set defaults
if nargin < 3 || isempty(presInd) || presInd ~= "pres"
    presInd = false;
else
    presInd = true;
end
if nargin < 4 || isempty(settlementInd)
    settlementInd = "no";
end

% first, determine the number of models
nModels = length(conMatsCell);

% create the figure
tL = tiledlayout(ceil(nModels / 2), 2, 'TileSpacing', 'compact');

% loop over the models
for m = 1:nModels

    % first, we need to determine the size of the matrix so that I can
    % calculate the prop nonzero
    nReefs = size(conMatsCell{m}{1}, 1);

    % loop over each of the years, and gather up the data - wipe it once
    % gathered too
    nMats = length(conMatsCell{m});
    currData = [];
    numNonzero = 0;
    if settlementInd ~= "settlement"
        for i = 1:nMats
            currData = [currData; double(conMatsCell{m}{i}(:))];
            currData = currData(currData > 0);
            numNonzero = numNonzero + sum(sum(conMatsCell{m}{i} > 0));
            conMatsCell{m}{i} = [];
        end

        % calculate the proportion of nonzero connections - maybe later
        % remove this and display this information in the tables somewhere
        % instead
        nonzeroProp = numNonzero / (nReefs^2 * nMats);

    else
        for i = 1:nMats
            currData = [currData; double(sum(conMatsCell{m}{i}, 2))];
            currData = currData(currData > 0);
            numNonzero = numNonzero + sum(sum(conMatsCell{m}{i}, 2) > 0);
            conMatsCell{m}{i} = [];
        end

        % calculate the proportion of nonzero connections - maybe later
        % remove this and display this information in the tables somewhere
        % instead
        nonzeroProp = numNonzero / (nReefs * nMats);

    end

    

    % now, create the histogram plot
    nexttile
    histogram(currData, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    if ~presInd && settlementInd ~= "settlement"
        annotateSummaryStats(currData)
        % subtitle("Prop. $> 0$ = " + num2str(round(nonzeroProp, 3)) + ", " + ...
        %     "Tot. = " + num2str(nReefs^2 * nMats, "%.2e"))
    end
    subtitle("Prop. $> 0$ = " + num2str(round(nonzeroProp, 3)))
    xline(median(currData), 'k--')
    if settlementInd ~= "settlement"
        set(gca, 'YScale', 'Log')
    end
    title(modelNames(m))

end

% label the rest of the plot
if settlementInd ~= "settlement"
    xlabel(tL, "$C_{i, j}(t)$", "Interpreter", "Latex")
    ylabel(tL, "Frequency (log scaled)", "Interpreter", "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")
    title(tL, "Connectivity Values Distribution", "Interpreter", ...
        "Latex")
else
    xlabel(tL, "$SP_i(t)$", "Interpreter", "Latex")
    ylabel(tL, "Frequency", "Interpreter", "Latex")
    title(tL, "Settlement Probabilities Distribution", ...
        "Interpreter", "Latex")
    subtitle(tL, "Only reefs with $>1$ nonzero values used", ...
        "Interpreter", "Latex")
end
lG = legend("", "Median", "Location", "layout");
lG.Layout.Tile = "north";

end