function plotConnectivityMat(connectivityMat)
% plotConnectivityMat will plot a connectivity matrix without using
% imageSC, as this seems difficult to view

% input:
% connectivityMat - a connectivity matrix

% create figure, set hold on and set the background to black
figure
hold on
set(gca,'Color','k')
set(gca, 'YDir','reverse')

% determine the number of rows/cols
nSites = size(connectivityMat, 1);

% determine the max and min values
maxVal = max(max(connectivityMat));
minVal = min(min(connectivityMat));

% create a colour mapping, which we will later index into
cMap = vertcat([0, 0, 0], jet(500));

% determine the number of colours
nColours = length(cMap);

% rather than going through and plotting every different colour, instead
% loop through and store the row - column coordinates of each point, for
% each colour
colourCell = cell(nColours, 1);
for r = 1:nSites
    for c = 1:nSites
        if connectivityMat(r, c) > minVal

            % determine the appropriate colour
            colIndex = ceil(((connectivityMat(r, c) - minVal) ...
                / (maxVal - minVal)) * nColours);

            % save the point's locations
            colourCell{colIndex} = vertcat(colourCell{colIndex}, [r, c]);

        end
    end
end

% now plot each colour one by one
for c = 1:nColours
    if ~isempty(colourCell{c}) && length(colourCell{c}) > 1
        plot(colourCell{c}(:, 2), colourCell{c}(:, 1), '.', 'MarkerSize', ...
            4, 'Color', cMap(c, :))
    end
end

% plot a diagonal line through the main diagonal
plot([1, nSites], [1, nSites], "Color", [1, 1, 1], "LineWidth", 0.1)

% neaten axes and add colourbar
colormap(myColourMap())
colorbar
axis([1, nSites, 1, nSites])
axis equal

end
