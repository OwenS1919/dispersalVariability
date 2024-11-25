function axVec = plotConnectivityStats(dataCell, statString, modelNames, ...
    presInd)
% plotConnectivityStats() will create a histogram of some summary
% statistic for connectivity data

% dataCell - a cell array of the relevant statistics to plot
% statString - a string, indicating the specific statistic being plotted,
    % can be: "mean" - the mean connectivity values for each connection,
    % "std" - the standard deviation of the connectivity values for each
    % connection, "CV" - the coefficient of variation for each connection
% modelNames - a string array, containing the names of each biophysical
    % model
% presInd - optional - specify as "pres" if producing a figure for the
    % presentation - default is "no"

% set default for presInd
if nargin < 4 || isempty(presInd) || presInd ~= "pres"
    presInd = false;
else
    presInd = true;
end

% first, determine the number of models
nModels = length(dataCell);

% create the figure
if ismember(statString, ["CVLoc", "meanTot", "stdTot", "meanTotIn", ...
        "stdTotIn", "CVLocIn", "CVBiom", "CVLC", ...
        "meanLC", "stdLC", "meanBiom", "stdBiom"])
    tL = tiledlayout(nModels, 1, 'TileSpacing', 'compact');
else
    tL = tiledlayout(ceil(nModels / 2), 2, 'TileSpacing', 'compact');
end

% loop over the models
for m = 1:nModels

    % create the histogram plot
    axVec(m) = nexttile;

    % create a set of different cases for the bin edges
    if statString == "CVLoc"
        edges = linspace(0, 4, 17);
    elseif statString == "CVLocIn"
        edges = linspace(0, 4, 17);
    elseif statString == "CVLC"
        edges = linspace(0, 3, 101);
    elseif statString == "CVBiom"
        edges = linspace(0, 0.05, 101);
    elseif statString == "meanTot"
        edges = linspace(0, 1, 17);
    elseif statString == "meanTotIn"
        edges = linspace(0, 2.5, 17);
    elseif statString == "stdTot"
        edges = linspace(0, 0.4, 17);
    elseif statString == "stdTotIn"
        edges = linspace(0, 1.5, 17);
    elseif statString == "meanLC"
        edges = linspace(0, 7 * 10^7, 101);
    elseif statString == "stdLC"
        edges = linspace(0, 10^7, 101);
    elseif statString == "meanBiom"
        edges = linspace(0, 22, 51);
    elseif statString == "stdBiom"
        edges = linspace(0, 1.4, 51);
    elseif statString == "correlationLoc"
        edges = linspace(-1, 1, 51);
    elseif statString == "autocorrelation"
        edges = linspace(-1, 1, 101);
    else
        edges = [];
    end

    if ~isempty(edges)
        histogram(dataCell{m}, edges, "EdgeAlpha", 0, "FaceColor", ...
            getColour('b'))
    else
        histogram(dataCell{m}, "EdgeAlpha", 0, "FaceColor", ...
            getColour('b'))
    end
    if ismember(statString, ["CV"]) && ~presInd
        % annotateSummaryStats(dataCell{m}, "northwest")
    elseif ~ismember(statString, ["correlationLoc", "correlation", ...
            "CV", "meanSett", "stdSett"])
        annotateSummaryStats(dataCell{m})
    end
    if ~ismember(statString, ["autocorrelation"]) && ~presInd
        xline(median(dataCell{m}), 'k--')
        if m == 1
            lG = legend("", "Median", "Location", "layout");
            lG.Layout.Tile = "north";
        end
    end

    if ismember(statString, ["correlationLoc", "CVLoc", ...
            "CVLC", "CVBiom", "meanTot", "stdTot", "autocorrelation", ...
            "meanTotIn", "stdTotIn", "CVLocIn", "correlation", "CVSett", ...
            "meanSett", "stdSett"])
        ylabel(tL, "Frequency", "Interpreter", "Latex")
    else
        set(gca, 'YScale', 'Log')
        ylabel(tL, "Frequency (log scaled)", "Interpreter", "Latex")
    end
    title(modelNames(m))

end

% link the axes (at least in terms of the x axis)
if ~ ismember(statString, ["meanBiom", "CV", "CVSett", "meanSett", ...
        "stdSett", "mean", "std"])
    linkaxes(axVec, 'x')
end

% link the axes in y for some of the thingys methinks
if statString == "correlationLoc"
    linkaxes(axVec(3:end), 'y')
end

% label the rest of the plot based on the statistic being plotted
if statString == "mean"

    xlabel(tL, "Mean$\{C_{i, j}(t)\}$", "Interpreter", "Latex")
    title(tL, "Mean of Individual Connections", "Interpreter", "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "meanTot"
    
    xlabel(tL, "E$\left[ \sum_{k} C_{i, k}(t)\right]$", "Interpreter", ...
        "Latex")
    title(tL, "Mean of Total Larval Output Probability", "Interpreter", ...
        "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "meanTotIn"
    
    xlabel(tL, "E$\left[ \sum_{k} C_{k, j}(t)\right]$", "Interpreter", ...
        "Latex")
    title(tL, "Mean of Total Larval Input Probability", "Interpreter", ...
        "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "meanSett"

    xlabel(tL, "Mean$\{SP_{i}(t)\}$", "Interpreter", "Latex")
    title(tL, "Mean of Settlement Probabilities", "Interpreter", "Latex")
    subtitle(tL, "Only reefs with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "stdTot"
    
    xlabel(tL, "Std $ \left[ \sum_{k} C_{i, k} (t) \right] $", "Interpreter", ...
        "Latex")
    title(tL, "Standard Deviation of Total Larval Output Probability", ...
        "Interpreter", "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "stdSett"
    
    xlabel(tL, "Std$\{ SP_i(t) \} $", "Interpreter", ...
        "Latex")
    title(tL, "Standard Deviation of Settlement Probabilities", ...
        "Interpreter", "Latex")
    subtitle(tL, "Only reefs with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "stdTotIn"
    
    xlabel(tL, "Std $ \left[ \sum_{k} C_{i, k} (t) \right] $", "Interpreter", ...
        "Latex")
    title(tL, "Standard Deviation of Total Larval Input Probability", ...
        "Interpreter", "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "std"

    xlabel(tL, "Std$\{C_{i, j}(t)\}$", "Interpreter", "Latex")
    title(tL, "Standard Deviation of Individual Connections", ...
        "Interpreter", "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "CV"

    xlabel(tL, "CV$\{C_{i, j}(t)\}$", "Interpreter", "Latex")
    if ~presInd
        title(tL, "Coefficient of Variation of Individual Connections", ...
            "Interpreter", "Latex")
        subtitle(tL, "Only connections with $>1$ nonzero values used", ...
            "Interpreter", "Latex")
    else
        title(tL, "CV of Individual Connections", ...
            "Interpreter", "Latex")
    end

elseif statString == "CVSett"

    xlabel(tL, "CV$\{SP_i(t)\}$", "Interpreter", "Latex")
    if ~presInd
        title(tL, "Coefficient of Variation of Settlement Probabilities", ...
            "Interpreter", "Latex")
        subtitle(tL, "Only reefs with $>1$ nonzero values used", ...
            "Interpreter", "Latex")
    else
        % title(tL, "CV of Individual Connections", ...
        %     "Interpreter", "Latex")
    end

elseif statString == "autocorrelation"

    xlabel(tL, "Autocorr$\{C_{i, j}(t), \, C_{i, j}(t + 1)\}$", "Interpreter", "Latex")
    title(tL, "Autocorrelation of Individual Connections", "Interpreter", ...
        "Latex")
    subtitle(tL, "Only connections with $>1$ nonzero values used", ...
        "Interpreter", "Latex")

elseif statString == "correlation"

    xlabel(tL, "Corr$\{SP_i(t), \,\, SP_j(t)" + ...
        "\}$", "Interpreter", "Latex")
    title(tL, "System-Wide Correlations in Settlement Probabilities", ...
        "Interpreter", "Latex")

elseif statString == "correlationLoc"

    xlabel(tL, "Corr$\{ SP_i(t), \,\, SP_j(t)" + ...
        "\}$", "Interpreter", "Latex")
    if ~presInd
        title(tL, "Local and GBR-Wide Correlations in " + ...
            "Settlement Probability", "Interpreter", "Latex")
    else
        title(tL, {"Local and GBR-Wide Correlations", "in Total Larval " + ...
            "Output"}, "Interpreter", "Latex")
    end

elseif statString == "CVLoc"

    xlabel(tL, "CV$\left[\sum_{k} C_{i, k}(t), \right]$", "Interpreter", ...
        "Latex")
    if ~presInd
        title(tL, "Local and Global CV values in Total Larval " + ...
            "Output of Reefs", "Interpreter", "Latex")
    else
        title(tL, {"Local and Global CV Values", "in Total Larval " + ...
            "Output"}, "Interpreter", "Latex")
    end

elseif statString == "CVLocIn"

    xlabel(tL, "CV$\left[\sum_{k} C_{k, j}(t)\right]$", "Interpreter", ...
        "Latex")
    title(tL, "Local and Global CV values in Total Larval " + ...
        "Input Probability", "Interpreter", "Latex")

elseif statString == "CVLC"

    title(tL, "Larval Contribution CV Values", "Interpreter", "Latex")
    xlabel(tL, "$\approx$ CV$\left[P_i \sum_{k} C_{i, k}(t) \right]$", ...
        "Interpreter", ...
        "Latex")

elseif statString == "stdLC"

    title(tL, "Standard Deviation of Larval Contribution", "Interpreter", "Latex")
    xlabel(tL, "$\approx$ Std$\left[P_i \sum_{k} C_{i, k}(t) \right]$", ...
        "Interpreter", ...
        "Latex")

elseif statString == "meanLC"

    title(tL, "Larval Contribution Mean Values", "Interpreter", "Latex")
    xlabel(tL, "$\approx$ E$\left[P_i \sum_{k} C_{i, k}(t) \right]$", ...
        "Interpreter", "Latex")

elseif statString == "CVBiom"

    title(tL, "Biomass CV Values", "Interpreter", "Latex")
    xlabel(tL, "CV$\left[B_i(t) \right]$", "Interpreter", "Latex")

elseif statString == "meanBiom"

    title(tL, "Mean Biomass Values", "Interpreter", "Latex")
    xlabel(tL, "E$\left[B_i(t) \right]$", "Interpreter", "Latex")

elseif statString == "stdBiom"

    title(tL, "Standard Deviation of Biomass Values", "Interpreter", "Latex")
    xlabel(tL, "Std$\left[B_i(t) \right]$", "Interpreter", "Latex")

end

end