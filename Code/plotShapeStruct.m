function plotShapeStruct(shapeStruct, colour, vals, fillIn, indices, ...
    shapeLims)
% plotshapeStruct will simply plot the shape outlines held in shapeStruct

% inputs:

% shapeStruct - holds the reef outlines in a structure with fields X and Y
    % storing the X and Y coordinates
% colour - optional - specifies the colour code - default is just whatever
    % matlab assigns
% vals - optional - if specified, vals will be used to create a colourmap
    % and control the colours for each reef but only for the fill option -
    % default is "k", i.e. black
% fillIn - optional - specify as "fill" if the shapes are to be filled,
    % "fillBorder" if the borders are also to be coloured, rather than just
    % plotting the outlines - default is "no"
% indices - optional - if specified as "indices" will also plot the indices
    % of each reef at their centroids - default is "" i.e. no indices
% shapeLims - optional - if specified, will take the form of a boundary
    % area, where shapes with centroids within 10% of the boundary will be
    % plot, takes the form [xMin, xMax, yMin, yMax] - default is that this
    % is inactive

% set a default value for indices and colour if not specified
if nargin < 2 || isempty(colour)
    colour = "";
end
if nargin < 3
    vals = [];
end
if nargin < 4 || isempty(fillIn)
    fillIn = "no";
end
if nargin < 5 || isempty(indices)
    indices = "";
end
if nargin < 6 || isempty(shapeLims)
    shapeLims = [-inf, inf, -inf, inf];
end

% determine the number of shapes
nShapes = length(shapeStruct);

% write an anonymous function which will check if a point is within the
% plotting region
xA = 0.05 * (shapeLims(2) - shapeLims(1));
yA = 0.05 * (shapeLims(4) - shapeLims(3));
pointCheck = @(centroid) centroid(1) >= shapeLims(1) - xA ...
    && centroid(1) <= shapeLims(2) + xA && centroid(2) >= shapeLims(3) - yA ...
    && centroid(2) <= shapeLims(4) + yA;

% setup the colours array, which will hold the colours each 
colours = zeros(nShapes, 3);
if ~isempty(vals)

    for s = 1:nShapes
        colours(s, :) = getColour(vals(s), max(vals));
    end
    cMap = myColourMap();
    colormap(cMap)

    % need to plot some dummy points to get the colorbar to work
    s = 1;
    while s < length(shapeStruct)
        if ~pointCheck(shapeStruct(s).Centroid)
            s = s + 1;
            continue
        end
        scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, ...
            min(vals))
        scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, ...
            mean(vals))
        scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, ...
            max(vals))
        break
    end
    colBar = colorbar();
else
    if colour ~= ""
        colourTrip = getColour(colour);
        colours = repmat(colourTrip, [nShapes, 1]);
    else
        for s = 1:nShapes
            colours(s, :) = [0, 0, 0];
        end
    end
end

% turn hold on
hold on

if fillIn ~= "fill" && fillIn ~= "fillIn" && fillIn ~= "fillBorder"

    % if we are not filling each shape, simply loop through and plot
    % outlines
    if isempty(vals)
        for s = 1:nShapes
            if ~pointCheck(shapeStruct(s).Centroid)
                continue
            end
            plot(shapeStruct(s).X, shapeStruct(s).Y, 'Color', ...
                colours(s, :))
        end
    else
        for s = 1:nShapes
            if ~pointCheck(shapeStruct(s).Centroid)
                continue
            end
            plot(shapeStruct(s).X, shapeStruct(s).Y, "color", ...
                colours(s, :))
        end
    end
    if indices == "indices"
        for s = 1:nShapes
            if ~pointCheck(shapeStruct(s).Centroid)
                continue
            end
            text(shapeStruct(s).Centroid(1), ...
                shapeStruct(s).Centroid(2), num2str(s), "FontSize", 15)
        end
    end

elseif fillIn == "fillBorder"

    % otherwise, do the same but filling the shapes and borders
    for s = 1:nShapes

        if ~pointCheck(shapeStruct(s).Centroid)
            continue
        end
        nansRemX = cutNaNs(shapeStruct(s).X);
        nansRemY = cutNaNs(shapeStruct(s).Y);
        for i = 1:length(nansRemX)
            fill(nansRemX{i}, nansRemY{i}, colours(s, :), 'EdgeColor', ...
                colours(s, :), "LineWidth", 0.1)
        end
        if indices == "indices"
            text(shapeStruct(s).Centroid(1), ...
                shapeStruct(s).Centroid(2), num2str(s), "FontSize", 15)
        end
    end


else

    % otherwise, do the same but filling the shapes
    for s = 1:nShapes

        if ~pointCheck(shapeStruct(s).Centroid)
            continue
        end
        nansRemX = cutNaNs(shapeStruct(s).X);
        nansRemY = cutNaNs(shapeStruct(s).Y);
        for i = 1:length(nansRemX)
            fill(nansRemX{i}, nansRemY{i}, colours(s, :), 'EdgeColor', ...
                'none')
        end
        if indices == "indices"
            text(shapeStruct(s).Centroid(1), ...
                shapeStruct(s).Centroid(2), num2str(s), "FontSize", 15)
        end
        
    end

end

% make axis equal 
axis equal

if ~isempty(vals)

    cMap = myColourMap();
    colormap(cMap)

    % need to plot some dummy points to get the colorbar to work
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, min(vals))
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, mean(vals))
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, max(vals))
    colBar = colorbar();

end

% set the axes limits if they were specified
if sum(shapeLims == [-inf, inf, -inf, inf]) ~= 4
    axis(shapeLims)
end

end

function var3 = cutNaNs(x)
% cutNaNs will simply shorten arrays which contain a NaN value at the end,
% used for plotting shape files mainly

% input:

% x - input 1D array

% output:

% x - same as input, however with final value removed if NaN

if isnan(x(end))
    x = x(1:end-1);
end
if isnan(x(1))
    x = x(2:end);
end

var2 = [0, find(isnan(x)), length(x) + 1];
var3 = cell(length(var2) - 1, 1);
for i = 1:length(var3)
    var3{i} = x((var2(i) + 1):(var2(i + 1) - 1));
end

end
