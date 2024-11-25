function plotGBRShape(GBRShape, fig, holdOn, indices, colour)
% plotGBRShape will simply plot the reef outlines held in GBRShape

% inputs:
% GBRShape - holds the reef outlines in a structure with fields X and Y
    % storing the X and Y coordinates
% fig - optional - if specified will create a figure inside this function
    % if specified as "fig"
% holdOn - optional - if specified as "holdOn" will keep the hold on before
    % exiting the method
% indices - optional - if specified as "indices" will also plot the indices
    % of each reef at their centroids
% colour - optional - specifies the colour code

% set a default value for fig and indices if not specified
if nargin < 2 || isempty(fig)
    fig = "";
end
if nargin < 4 || isempty(indices)
    indices = "";
end
if nargin < 5 || isempty(colour)
    colour = "";
end
if nargin < 3 || isempty(holdOn)
    holdOn = "holdOn";
end

% determine the number of reefs
nReefs = length(GBRShape);

% create a figure if necessary
if fig == "fig"
    figure
end

% turn hold on
hold on

if nargin >= 5 && ~isempty(colour)
    
    % loop over each reef and plot it
    if indices ~= "indices"
        for r = 1:nReefs
            plot(GBRShape(r).X, GBRShape(r).Y, colour)
        end
    else
        for r = 1:nReefs
            plot(GBRShape(r).X, GBRShape(r).Y)
            text(GBRShape(r).Centroid(1), GBRShape(r).Centroid(2), num2str(r), colour, "FontSize", 6)
        end
    end

else
    
    % loop over each reef and plot it
    if indices ~= "indices"
        for r = 1:nReefs
            plot(GBRShape(r).X, GBRShape(r).Y)
        end
    else
        for r = 1:nReefs
            plot(GBRShape(r).X, GBRShape(r).Y)
            text(GBRShape(r).Centroid(1), GBRShape(r).Centroid(2), num2str(r), "FontSize", 6)
        end
    end

end

% remove the holdOn if not specified
if holdOn ~= "holdOn"
    hold off
end

% make axis equal 
axis equal

end
