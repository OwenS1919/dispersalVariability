function lightFig()
% darkFig is a function I wrote myself to convert figures into light mode
% automatically

% set all axes and colsours to dark mode where possible
axesVec = findall(gcf, 'type', 'axes');
set(gcf, 'color', 'w')
for i = 1:length(axesVec)

    % first, change each axes background and text / labels colours
    set(axesVec(i), 'color', 'w')
    set(axesVec(i), 'xcolor', 'k')
    set(axesVec(i), 'ycolor', 'k')
    try
        set(axesVec(i), 'zcolor', 'k')
    catch
    end

    % if the axes has a legend, change that too
    if ~isempty(axesVec(i).Legend)
        axesVec(i).Legend.TextColor = 'k';
        axesVec(i).Legend.EdgeColor = 'k';
        axesVec(i).Legend.Color = 'w';
    end

    % change the axes title colour if possible
    if ~isempty(axesVec(i).Title)
        axesVec(i).Title.Color = 'k';
    end

    % change the axes subtitle colour if possible
    if ~isempty(axesVec(i).Subtitle)
        axesVec(i).Subtitle.Color = 'k';
    end

    % change the text on the colorbar if it exists
    if ~isempty(axesVec(i).Colorbar)
        axesVec(i).Colorbar.Color = 'k';
    end

    % if the current axes has any colours, change them too
    axesChildVec = axesVec(i).Children;
    for c = 1:length(axesChildVec)

        % try changing the colours for lines and points
        try
            if isprop(axesChildVec(c), "Color")

                % if we have a white (or close to) line, convert it to
                % black
                if sum(axesChildVec(c).Color == 1) == 3
                    axesChildVec(c).Color = [0, 0, 0];
                    axesChildVec(c).Alpha = 1;
                    continue
                end

            end

        catch
        end

        % try changing the colours for shapes
        try
            if axesChildVec(c).FaceColor == "auto"
                axesChildVec(c).FaceColor = getColour('lb');
            end
            axesChildVec(c).FaceColor = axesChildVec(c).Color + ...
                lightFact * ([1, 1, 1] - axesChildVec(c).Color);
        catch
        end

        % try changing the edge colour for shapes
        % try
            % if axesChildVec(c).EdgeColor ~= 'w'
            %     axesChildVec(c).EdgeColor = 'w';
            %     axesChildVec(c).LineWidth = 0.1;
            % end
        % catch
        % end
    end

    % if there are textual annotations in the figure, atempt to change them
    for j = 1:length(axesVec(i).Children)
        try
            if axesVec(i).Children(j).Type == "text"
                axesVec(i).Children(j).Color = 'k';
            end
        catch
        end
    end

end

% check if the figure has a tiledlayout, if so alter its properties
currFig = gcf;
w = [1, 1, 1];
if class(currFig.Children) == "matlab.graphics.layout.TiledChartLayout"
    currFig.Children.YLabel.Color = 'k';
    currFig.Children.XLabel.Color = 'k';
    currFig.Children.Title.Color = 'k';
    currFig.Children.Subtitle.Color = 'k';
end

end
