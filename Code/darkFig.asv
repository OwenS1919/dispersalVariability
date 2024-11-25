function darkFig(colormapInd)
% darkFig is a function I wrote myself to convert figures into dark mode
% automatically

% input:

% colormapInd - optional - if specified as "colormap", the colormap will be
    % converted to a dark mode version - default is "no"

% set defaults
if nargin < 1 || isempty(colormapInd)
    colormapInd = "no";
end

% set a lightening factor for each colour 
lightFact = 0.25;

% set all axes and colsours to dark mode where possible
axesVec = findall(gcf, 'type', 'axes');
set(gcf, 'color', 'k')
for i = 1:length(axesVec)

    % first, change each axes background and text / labels colours
    set(axesVec(i), 'color', 'k')
    set(axesVec(i), 'xcolor', 'w')
    set(axesVec(i), 'ycolor', 'w')
    try
        set(axesVec(i), 'zcolor', 'w')
    catch
    end

    % if the axes has a legend, change that too
    if ~isempty(axesVec(i).Legend)
        axesVec(i).Legend.TextColor = 'w';
        axesVec(i).Legend.EdgeColor = 'w';
        axesVec(i).Legend.Color = 'k';
    end

    % change the axes title colour if possible
    if ~isempty(axesVec(i).Title)
        axesVec(i).Title.Color = 'w';
    end

    % change the axes subtitle colour if possible
    if ~isempty(axesVec(i).Subtitle)
        axesVec(i).Subtitle.Color = 'w';
    end

    % if there's a colourmap, convert it to my dark mode if it's my
    % colourmap
    if colormapInd == "colormap"
        if ~isempty(axesVec(i).Colormap)

            if sum(axesVec(i).Colormap == ...
                    myColourMap(size(axesVec(i).Colormap, 1))) == ...
                    size(axesVec(i).Colormap, 1)
                axesVec(i).Colormap = axesVec(i).Colormap + ...
                    lightFact * ([1, 1, 1] - axesVec(i).Colormap);
            end

        end
    end

    % change the text on the colorbar if it exists
    if ~isempty(axesVec(i).Colorbar)
        axesVec(i).Colorbar.Color = 'w';
    end

    % if the current axes has any colours, change them too
    axesChildVec = axesVec(i).Children;
    for c = 1:length(axesChildVec)

        % try changing the colours for lines and points
        try
            if isprop(axesChildVec(c), "Color")

                % if we have a black (or close to) line, convert it to
                % white
                if sum(axesChildVec(c).Color == 0) == 3 ...
                        || sum(axesChildVec(c).Color == 0.15) == 3
                    axesChildVec(c).Color = [1, 1, 1];
                    axesChildVec(c).Alpha = 1;
                    continue
                end

                % watch out for the alphas here, and the effect this could
                % have on some things
                % if we have a white color, convert it to black
                if (sum(axesChildVec(c).Color == 1) == 3) ...
                        || (sum(axesChildVec(c).Color == [0, 0, 0]) == 3)
                    axesChildVec(c).Color = [0, 0, 0];
                    axesChildVec(c).Alpha = 1;
                    continue
                end

                % otherwise, just lighten the colour
                axesChildVec(c).Color = axesChildVec(c).Color + ...
                    lightFact * ([1, 1, 1] - axesChildVec(c).Color);
                continue
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
        try
            % if axesChildVec(c).EdgeColor ~= 'w'
            %     axesChildVec(c).EdgeColor = 'w';
            %     axesChildVec(c).LineWidth = 0.1;
            % end
        catch
        end
    end

    % if there are textual annotations in the figure, atempt to change them
    for j = 1:length(axesVec(i).Children)
        try
            if axesVec(i).Children(j).Type == "text"
                axesVec(i).Children(j).Color = 'w';
            end
        catch
        end
    end

end

% check if the figure has a tiledlayout, if so alter its properties
currFig = gcf;
w = [1, 1, 1];
if class(currFig.Children) == "matlab.graphics.layout.TiledChartLayout"
    currFig.Children.YLabel.Color = w;
    currFig.Children.XLabel.Color = w;
    currFig.Children.Title.Color = w;
    currFig.Children.Subtitle.Color = w;
end

end
