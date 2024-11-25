function saveFig(figName)
% saveFig() will save a figure directly into the "Figures" folder, which
% should be contained in the "Code" folder

% input:

% figName - a string representing the name of the figure to be saved

% save the figure
exportgraphics(gcf, "Figures\" + figName + ".png", 'Resolution', 400, ...
    'BackgroundColor', 'current')

end
