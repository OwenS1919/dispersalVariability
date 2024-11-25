function myBoxPlot(resultsMat, names, plotType, darkMode, orientation, ...
    coloursCell)
% myBoxPlot() will create a box - plot esque figure because the default
% matlab one is lame

% inputs:

% resultsMat - a matrix used to store results, where resultsMat(r, m) is
    % the results from the rth repetition using the mth method / model etc
% names - optional - the names of the methods / models etc being plot -
    % default is just to use none
% plotType - optional - a string, indicating how to handle the whiskers -
    % "minMax" indicates the whiskers extend to the minimum and maximum
    % data values, "outliers" uses the 1.5 times IQR and outliers rule,
    % "confInt" plots the 95% confidence intervals - default is "outliers"
% darkMode - optional - a boolean, set as true to make the polygon outline
    % white rather than black - default is true
% orientation - optional - specify as "vertical" for the box plot to be
    % oriented vertically, and "horizontal" for the box plot to be oriented
    % horizontally - default is "vertical"
% coloursCell - optional - a cell array holding the colours to plot each
    % box in, where colours are RGB triplets - default will just use random
    % colour orders

% note: I should eventually add in code which plots the outliers, or does
% the classic box plot thing of plotting max as the max of the IQR times
% whatever or the max blah blah

% determine the number of methods / models used
nMods = size(resultsMat, 2);

% set defaults
if nargin < 2 || isempty(names)
    names = strings(1, nMods);
    for m = 1:nMods
        names(m) = num2str(m);
    end
end
if nargin < 3 || isempty(plotType)
    plotType = "outliers";
end
if nargin < 4 || isempty(darkMode)
    darkMode = true;
end
if nargin < 5 || isempty(orientation)
    orientation = "vertical";
end
if nargin < 6 || isempty(coloursCell)
    coloursCell = cell(1, nMods);
    for i = 1:nMods
        coloursCell{i} = getColour(i);
    end
end

% determine the IQR
estimate75 = quantile(resultsMat, 0.75);
estimateMed = quantile(resultsMat, 0.5);
estimate25 = quantile(resultsMat, 0.25);

% determine the extent of the whiskers
if plotType == "minMax"

    % determine the min and max values
    estimateUpper = max(resultsMat, [], 1);
    estimateLower = min(resultsMat, [], 1);

elseif plotType == "confInt"

    % determine 95% CI
    estimateUpper = quantile(resultsMat, 0.975);
    estimateLower = quantile(resultsMat, 0.025);

else

    % calculate the point closest inside the median +- the 1.5 * IQR range
    iqrLength = estimate75 - estimate25;
    estimateUpper = zeros(1, size(resultsMat, 2));
    estimateLower = zeros(1, size(resultsMat, 2));

    % determine the upper points using a for loop because I'm too scared to
    % do it otherwise
    for i = 1:size(resultsMat, 2)

        % find the point closest to the upper bound
        mask = resultsMat(:, i) > estimateMed(i) + 1.5 * iqrLength(i);
        var1 = resultsMat(:, i);
        var1(mask) = -realmax;
        [~, ind] = min(estimateMed(i) + 1.5 * iqrLength(i) ...
            - var1);
        estimateUpper(i) = resultsMat(ind, i);

        % find the point closest to the lower bound
        mask = resultsMat(:, i) < estimateMed(i) - 1.5 * iqrLength(i);
        var1 = resultsMat(:, i);
        var1(mask) = realmax;
        [~, ind] = min(var1 - (estimateMed(i) ...
            - 1.5 * iqrLength(i)));
        estimateLower(i) = resultsMat(ind, i);

    end
    

end

% set some parameters for plotting
iqrWidth = 0.1;
lineWidth = 0.65;

% create figure, plot results and label plot
hold on
for i = 1:size(resultsMat, 2)

    % plot the outliers if necessary
    if plotType == "outliers"

        % determine the outliers, and plot them
        mask = resultsMat(:, i) > estimateUpper(i);
        if orientation == "vertical"
            plot(i * ones(size(resultsMat(mask, i))), resultsMat(mask, i), ...
                '.', 'Color', coloursCell{i}, 'MarkerSize', 8)
        else
            plot(resultsMat(mask, i), i * ones(size(resultsMat(mask, i))), ...
                '.', 'Color', coloursCell{i}, 'MarkerSize', 8)
        end
        mask = resultsMat(:, i) < estimateLower(i);
        if orientation == "vertical"
            plot(i * ones(size(resultsMat(mask, i))), resultsMat(mask, i), ...
                '.', 'Color', coloursCell{i}, 'MarkerSize', 8)
        else
            plot(resultsMat(mask, i), i * ones(size(resultsMat(mask, i))), ...
                '.', 'Color', coloursCell{i}, 'MarkerSize', 8)
        end
        
    end

    % plot the extent of the data
    if orientation == "vertical"
        plot([i, i], [estimateUpper(i), estimateLower(i)], 'k-', ...
            'LineWidth', lineWidth)
    else
        plot([estimateUpper(i), estimateLower(i)], [i, i], 'k-', ...
            'LineWidth', lineWidth)
    end

    % create a polygon of the IQR
    iqrPolyX = [i - iqrWidth, i + iqrWidth, i + iqrWidth, i - iqrWidth, ...
        i - iqrWidth];
    iqrPolyY = [estimate25(i), estimate25(i), estimate75(i), estimate75(i), ...
        estimate25(i)];
    if orientation == "vertical"
        if ~darkMode
            fill(iqrPolyX, iqrPolyY, 'w');
            fill(iqrPolyX, iqrPolyY, coloursCell{i}, 'FaceAlpha', 0.4, ...
                'LineWidth', lineWidth, 'EdgeColor', 'k');
        else
            fill(iqrPolyX, iqrPolyY, coloursCell{i}, 'FaceAlpha', 1, ...
                'LineWidth', lineWidth, 'EdgeColor', 'w');
        end
    else
        if ~darkMode
            fill(iqrPolyY, iqrPolyX, 'w');
            fill(iqrPolyY, iqrPolyX, coloursCell{i}, 'FaceAlpha', 0.4, ...
                'LineWidth', lineWidth, 'EdgeColor', 'k');
        else
            fill(iqrPolyY, iqrPolyX, coloursCell{i}, 'FaceAlpha', 1, ...
                'LineWidth', lineWidth, 'EdgeColor', 'w');
        end
    end
    
    % plot the median and the upper limit
    if orientation == "vertical"
        plot([i - 0.6  * iqrWidth, i + 0.6 * iqrWidth], [estimateUpper(i), ...
            estimateUpper(i)], 'k', 'LineWidth', lineWidth)
        plot([i - 0.6  * iqrWidth, i + 0.6 * iqrWidth], [estimateLower(i), ...
            estimateLower(i)], 'k', 'LineWidth', lineWidth)
        plot([i - iqrWidth, i + iqrWidth], [estimateMed(i), ...
            estimateMed(i)], 'k', 'LineWidth', lineWidth)
    else
        plot([estimateUpper(i), estimateUpper(i)], [i - 0.6  * iqrWidth, ...
            i + 0.6 * iqrWidth], 'k', 'LineWidth', lineWidth)
        plot([estimateLower(i), estimateLower(i)], [i - 0.6  * iqrWidth, ...
            i + 0.6 * iqrWidth], 'k', 'LineWidth', lineWidth)
        plot([estimateMed(i), estimateMed(i)], [i - iqrWidth, i ...
            + iqrWidth], 'k', 'LineWidth', lineWidth)
    end
    
end

% label figure
if plotType == "minMax"
    subtitle("Min. and Max., IQR, Median")
elseif plotType == "confInt"
    subtitle("95\% CI, IQR, Median")
else
    subtitle("Median $\pm 1.5 \times$ IQR, IQR, Median")
end
if orientation == "vertical"
    set(gca, 'XTick', 1:nMods, 'XTickLabel', names)
else
    set(gca, 'YTick', 1:nMods, 'YTickLabel', names)
end

end
