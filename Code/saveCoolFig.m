function saveCoolFig(figName, textInd)
% saveCoolFig() will save cool figures I generate into my folder of cool
% figures :)

% input:

% figName - a string representing the name of the figure to be saved
% textInd - optional - specify as "none" to remove all text based labels
    % including axis ticks and colourbar, "labels" will remove just the
    % titles and axis labels, "labelsLegend" will also remove the legend
    % text - default is "keep", i.e. text is kept

% set a default for textInd
if nargin < 2 || isempty(textInd)
    textInd = "keep";
end

% remove the labels if required
if textInd == "labels" || textInd == "none" || textInd == "labelsLegend"
    textObjs = findall(gcf, 'Type', 'Text');
    delete(textObjs)
    tiledlayoutObj = findall(gcf, 'Type', 'tiledlayout');
    if ~isempty(tiledlayoutObj)
        tiledlayoutObj.Title.String = '';
    end
end

% remove the legend text if required
if textInd == "labelsLegend" || textInd == "none"

    % delete the legend text
    legendObjs = findall(gcf, 'Type', 'Legend');
    if length(legendObjs) == 1
        if class(legendObjs.String) == "cell"
            for i = 1:length(legendObjs.String)
                legendObjs.String{i} = "";
            end
        else
            legendObjs.String = "";
        end
    elseif length(legendObjs) > 1
        for i = 1:length(legendObjs)
            if class(legendObjs(i).String) == "cell"
                for j = 1:length(legendObjs(i).String)
                    legendObjs(i).String{j} = "";
                end
            else
                legendObjs(i).String = "";
            end
        end
    end

end

% remove all text if required
if textInd == "none"
    
    % remove the x, y and z tick labels
    axesObjs = findall(gcf, 'Type', 'Axes');
    if length(axesObjs) == 1
        axesObjs.XTickLabel = [];
        axesObjs.YTickLabel = [];
        try
            axesObjs.ZTickLabel = [];
        catch
        end
    else
        for i = 1:length(axesObjs)
            axesObjs(i).XTickLabel = [];
            axesObjs(i).YTickLabel = [];
            try
                axesObjs(i).ZTickLabel = [];
            catch
            end
        end
    end

    % remove the coorbar ticks if needed
    colorbarObjs = findall(gcf, 'Type', 'Colorbar');
    if length(colorbarObjs) == 1
        colorbarObjs.TickLabels = [];
    elseif length(colorbarObjs) > 1
        for i = 1:length(colorbarObjs)
            colorbarObjs(i).TickLabels = [];
        end
    end

end

% save the figure in my cool figures folder :)
exportgraphics(gcf, "C:\Users\sowen\Pictures\Cool Matlab Figures\" ...
    + figName + ".png", 'Resolution', 200, 'BackgroundColor', 'current')

end
