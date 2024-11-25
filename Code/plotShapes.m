function plotShapes(shapeStruct, nameValArgs)
% plotShapes() will simply plot the shape outlines held in shapeStruct

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
% boundary - optional - provides a limit for plotting of the form [xMin,
    % xMax, yMin, yMax], so that only shapes with centroids in this range
    % are plotted - default is [] i.e. no boundary applied
% res - optional - specify as "low" to only plot every second point (will
    % make life easier when plotting large numbers of points) - default is
    % "high", a.k.a. use all points

% process the and extract the nameValArgs
arguments
    shapeStruct
    nameValArgs.colour = "";
    nameValArgs.vals = [];
    nameValArgs.fillIn = "no";
    nameValArgs.indices = "";
    nameValArgs.boundary = [];
    nameValArgs.res = "high";
    nameValArgs.alpha = 1;
    nameValArgs.lineStyle = "-";
end
colour = nameValArgs.colour;
vals = nameValArgs.vals;
fillIn = nameValArgs.fillIn;
indices = nameValArgs.indices;
boundary = nameValArgs.boundary;
res = nameValArgs.res;
alpha = nameValArgs.alpha;
lineStyle = nameValArgs.lineStyle;

% determine the number of shapes
nShapes = length(shapeStruct);

% if we have a boundary, reduce the shapeStruct's contents by the boundary
if ~isempty(boundary)

    % resize the boundary if it is in the form of a partition, aka x =
    % boundary{i}(:, 1)
    if sum(size(boundary) == [1, 4]) ~= 2 && sum(size(boundary) ~= [4, 1]) ...
            == 2
        boundary = [min(boundary(:, 1)), max(boundary(:, 1)), ...
            min(boundary(:, 2)), max(boundary(:, 2))];
    end

    % get rid of shapes outside the boundary
    boundaryMask = false(nShapes, 1);
    for s = 1:nShapes
        if shapeStruct(s).Centroid(1) > boundary(1) ...
                && shapeStruct(s).Centroid(1) <= boundary(2) ...
                && shapeStruct(s).Centroid(2) > boundary(3) ...
                && shapeStruct(s).Centroid(2) <= boundary(4)
        boundaryMask(s) = true;
        end
    end
    nShapes = sum(boundaryMask);
    shapeStruct = shapeStruct(boundaryMask);

    % retain the indices though for later
    indicesVals = find(boundaryMask);
    
else
    indicesVals = 1:nShapes;
end

% if we are plotting with a lower resolution, remove every second point
% from the reef outlines
if res == "low"
    for s = 1:nShapes
        
        % grab every second value from the coordinates and re-save BUT keep
        % any NaN values
        inds = 1:2:length(shapeStruct(s).X);
        nanInds = find(isnan(shapeStruct(s).X));
        inds = [inds, nanInds];
        inds = unique(inds);
        inds = sort(inds, 2, "ascend");
        shapeStruct(s).X = shapeStruct(s).X(inds);
        shapeStruct(s).Y = shapeStruct(s).Y(inds);

    end
end

% setup the colours array, which will hold the colours each 
colours = zeros(nShapes, 3);
if ~isempty(vals)

    for s = 1:nShapes
        colours(s, :) = getColour(vals(s), max(vals));
    end
    cMap = myColourMap();
    colormap(cMap)

    % need to plot some dummy points to get the colorbar to work
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, min(vals))
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, mean(vals))
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.00001, max(vals))
    colBar = colorbar();

else
    if ~isnumeric(colour)
        if colour ~= ""
            colourTrip = getColour(colour);
            colours = repmat(colourTrip, [nShapes, 1]);
        else
            for s = 1:nShapes
                colours(s, :) = [0, 0, 0];
            end
        end
    else
        colours = repmat(colour, [nShapes, 1]);
        colour = "this variable is now a string so my code does'nt " + ...
            "break how fun";
    end
end

% turn hold on
hold on

% need to plot some dummy points to get the colorbar to work
if ~isempty(vals)
    cMap = myColourMap();
    colormap(cMap)
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.0001, min(vals))
    scatter(shapeStruct(1).X(1), shapeStruct(1).Y(1), 0.0001, max(vals))
    colBar = colorbar();
end

if fillIn ~= "fill" && fillIn ~= "fillBorder"

    % if we are not filling each shape, simply loop through and plot
    % outlines
    if isempty(vals) && colour == ""
        for s = 1:nShapes
            plot(shapeStruct(s).X, shapeStruct(s).Y, 'LineStyle', ...
                lineStyle)
        end
    else
        for s = 1:nShapes
            plot(shapeStruct(s).X, shapeStruct(s).Y, "color", ...
                colours(s, :), 'LineStyle', lineStyle)
        end
    end

elseif fillIn == "fillBorder" || fillIn == "fill"

    % set whether we want to fill the borders or not
    warning("off", "all")
    if fillIn == "fillBorder"
        edgeColorArg = colours(s, :);
        edgeAlphaArg = 1;
    else
        edgeColorArg = 'none';
        edgeAlphaArg = 0;
    end
    lineWidthArg = 0.1;
    
    % plot and fill da shapes, using a for loop to deal with holes and NaNs
    % etc - for some reason this goddamn command screws up the axes limits
    % so need to record some bs here
    xMax = -inf;
    xMin = inf;
    yMax = -inf;
    yMin = inf;
    for s = 1:nShapes
        currPoly = polyshape(shapeStruct(s).X, shapeStruct(s).Y);
        plot(currPoly, "FaceColor", colours(s, :), "EdgeColor", ...
            edgeColorArg, "LineWidth", lineWidthArg, "FaceAlpha", alpha, ...
            "EdgeAlpha", edgeAlphaArg);

        % testing some bullshit - the first is fine, second is fine
        % plot(shapeStruct(s).X, shapeStruct(s).Y, 'r.', 'MarkerSize', 20)
        % plot(currPoly.Vertices(:, 1), currPoly.Vertices(:, 2), 'r.', 'MarkerSize', 20)
        xMax = max([xMax; shapeStruct(s).X(:)]);
        xMin = min([xMin; shapeStruct(s).X(:)]);
        yMax = max([yMax; shapeStruct(s).Y(:)]);
        yMin = min([yMin; shapeStruct(s).Y(:)]);

        % testing some more bullshit
        axisVec = axis;
        if axisVec(3) < 7 * 10^6
            test = 0;
        end

    end

end
warning("on", "all")

% plot the indices if needed
if indices == "indices"
    for s = 1:nShapes
        text(shapeStruct(s).Centroid(1), shapeStruct(s).Centroid(2), ...
            num2str(indicesVals(s)), "FontSize", 15)
    end
end

% going to reset the axes limits here because for some stupid ass reason
% it's not behaving itself
if ~isempty(boundary) && fillIn == "fill"
    axis equal
    % boundary = [xMin, xMax, yMin, yMax];
    % xPadding = 0.07 * (boundary(2) - boundary(1));
    % yPadding = 0.07 * (boundary(4) - boundary(3));
    % axis([boundary(1) - xPadding, boundary(2) + xPadding, ...
    %     boundary(3) - yPadding, boundary(4) + yPadding])
    % axis padded
else
    axis equal
end

% set the fontname to times
fTimes()

end