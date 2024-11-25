function plotConnectivityAnalysis(meanConn, stdConn, minMaxConn, ...
    nonzeroProp, descString, xLims)
% plotConnectivityAnalysis() will plot the analysis on connectivity values
% conducted in the connectivityAnalysis() function

% inputs:

% meanConn - an n x 1 vector containing the mean connectivity value for
    % each connection above the nonzeroProp threshold
% stdConn - as above, but holding the standard deviations
% minMaxConn - as above, but of dimension n x 2 holding the minimum and
    % maximum connection values in that order
% nonzeroProp - optional - the proportion of matrices for which a
    % connection must be nonzero for the value to be used in the analysis -
    % default is eps (i.e. must have at least one nonzero value)
% descString - a string describing the model and the time intervals it
    % operates over
% xLims - optional - a cell array containing the x limits for each axis -
    % default is nothing, so matlab will decide limits themselves

% the way I wrote this method originally was dumb so now I'm making a new
% approach, which changes if you input the data as a cell array in the
% first argument - split the cases here
if class(meanConn) == "cell"

    % fuck ok so can basically just copy paste some shit from the next
    % section - first need to extract the stuff though
    conMats = meanConn{1};
    stdConn = meanConn{3};
    autoCorr = meanConn{4};
    corrMat = meanConn{5};
    meanConn = meanConn{2};

    % set up the figure
    tL = tiledlayout(3, 2, 'TileSpacing', 'compact');

    % first, we need to determine the size of the matrix so that I can
    % calculate the prop nonzero
    nReefs = size(conMats{1}, 1);

    % loop over each of the years, and gather up the data - wipe it once
    % gathered too
    nMats = length(conMats);
    currData = [];
    numNonzero = 0;
    for i = 1:nMats
        currData = [currData; double(conMats{i}(:))];
        currData = currData(currData > 0);
        numNonzero = numNonzero + sum(sum(conMats{i} > 0));
        conMats{i} = [];
    end

    % calculate the proportion of nonzero connections - maybe later remove
    % this and display this information in the tables somewhere instead
    nonzeroProp = numNonzero / (nReefs^2 * nMats);

    % now, create the histogram plot
    nexttile
    histogram(currData, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    annotateSummaryStats(currData)
    xline(median(currData), 'k--')
    set(gca, 'YScale', 'Log')
    xlabel("$C_{i, j}(t)$", "Interpreter", "Latex")
    title("Connectivity Values $>0$", "Interpreter", ...
        "Latex")
    
    % plot the mean
    nexttile
    histogram(meanConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    annotateSummaryStats(meanConn)
    xline(median(meanConn), 'k--')
    set(gca, 'YScale', 'Log')
    title("Mean")
    xlabel("$\mu_{i, j}$")

    % plot the variance
    nexttile
    histogram(stdConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    annotateSummaryStats(stdConn)
    xline(median(stdConn), 'k--')
    set(gca, 'YScale', 'Log')
    title("Standard Deviation")
    xlabel("$\sigma_{i, j}$")

    % plot the coefficient of variation
    coeffVarConn = stdConn ./ meanConn;
    nexttile
    histogram(coeffVarConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    set(gca, 'YScale', 'Log')
    annotateSummaryStats(coeffVarConn, "northwest")
    xline(median(coeffVarConn), 'k--')
    title("Coefficient of Variation")
    xlabel("$CV_{i, j}$")

    % plot the autocorrelation
    nexttile
    histogram(autoCorr, "EdgeAlpha", 0, "FaceColor", getColour('b'))
    annotateSummaryStats(autoCorr)
    xline(median(currData), 'k--')
    set(gca, 'YScale', 'Log')
    title("Autocorrelation")
    xlabel("Autocorr$\{C_{i, j}(t)\}$")

    % plot the correlation
    nexttile
    histogram(corrMat(:), "EdgeAlpha", 0, "FaceColor", getColour('b'))
    annotateSummaryStats(corrMat(:), "southeast")
    xline(median(corrMat(:)), 'k--')
    set(gca, 'YScale', 'Log')
    title("Larval Output Correlation")
    xlabel("Corr$\left[\sum_{k} C_{i, k}(t), \, \sum_{k} C_{j, k}(t)" + ...
        "\right]$")

    % annotate the figure
    title(tL, descString + " Connectivity Variation Analysis", ...
        "interpreter", "latex")
    subtitle(tL, {"Only connections with $\geq 1$ nonzero value " + ...
        "considered", "\# Reefs = " + num2str(nReefs) + ", \# Matrices = " ...
        + num2str(nMats) + ", Prop. $C_{i, j}(t) > 0$ = " ...
        + num2str(nonzeroProp, 2)}, "interpreter", "latex")
    ylabel(tL, "Frequency (log scaled)", "Interpreter", "Latex")
    lG = legend("", "Median", "Location", "layout");
    lG.Layout.Tile = "north";

    % set some characteristics for the figure
    figResize(2.25, 1.3)
    setFontSize(12)

    % return xd
    return

end

% check if xLims has been inputted
if nargin < 6 || isempty(xLims)
    xLimsInd = false;
else
    xLimsInd = true;
end

% set up the figure
tL = tiledlayout(2, 2, 'TileSpacing', 'compact');

% plot the mean
nexttile
histogram(meanConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
if xLimsInd && ~isempty(xLims{1})
    xlim(xLims{1})
end
annotateSummaryStats(meanConn)
set(gca, 'YScale', 'Log')
title("Mean")
xlabel("$\mu$")

% plot the variance
nexttile
histogram(stdConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
if xLimsInd && length(xLims) >= 2 && ~isempty(xLims{2})
    xlim(xLims{2})
end
annotateSummaryStats(stdConn)
set(gca, 'YScale', 'Log')
title("Standard Deviation")
xlabel("$\sigma$")

% plot the coefficient of variation
coeffVarConn = stdConn ./ meanConn;
nexttile
histogram(coeffVarConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
if xLimsInd && length(xLims) >= 3 && ~isempty(xLims{3})
    xlim(xLims{3})
end
set(gca, 'YScale', 'Log')
annotateSummaryStats(coeffVarConn, "northwest")
title("Coefficient of Variation")
xlabel("$CV$")

% plot the range of values
rangeConn = minMaxConn(:, 2) - minMaxConn(:, 1);
nexttile
histogram(rangeConn, "EdgeAlpha", 0, "FaceColor", getColour('b'))
if xLimsInd && length(xLims) >= 4 && ~isempty(xLims{4})
    xlim(xLims{4})
end
set(gca, 'YScale', 'Log')
title("Range")
annotateSummaryStats(rangeConn)
xlabel("Range")
title(tL, descString + " Connectivity Variation Analysis", "interpreter", ...
    "latex")
if nonzeroProp < 10^-4
    subtitle(tL, "Only connections with $\geq 1$ nonzero value considered", ...
        "interpreter", "latex")
else
    subtitle(tL, "Note: only connections with " + num2str(100 * ...
        nonzeroProp) + "\% nonzero values across time series included, " + ...
        "lines indicate mean values", "interpreter", "latex")
end
ylabel(tL, "Count", 'Interpreter', 'Latex')

% set some characteristics for the figure
figResize(1.8, 1.5)
setFontSize(13)

end