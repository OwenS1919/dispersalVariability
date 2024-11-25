function tL = plotMetapop(popMat, tVec, conMat, horizInd)
% plotMetapop will visualise the trajectories of a set of
% metapopulations by the total population at each reef over time

% inputs:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep
% tVec - a vector of the corresponding times for each timestep
% conMat - optional - a connectivity matrix representing the system to be
    % modelled, where conMat(i, j) represents the probability that larvae
    % released from reef i will settle at reef j - if specified, figure
    % will become a tiledlayout with the connectivity matrix visualised
    % below
% horizInd - optional - if specified as "horizontal", the figure
    % proportions will be altered to fit better in my written progress
    % report - default is "no"

% output:

% tL - the handle to a tiledlayout object if the connectivity matrix is to
    % be visualised alongside

% set a default for the connectivity matrix and horizInd if it is not
% supplied
if nargin < 3
    conMat = [];
end
if nargin < 4 || isempty(horizInd)
    horizInd = "no";
end

% convert the population matrix into the total population at each timestep
% -> note that later on, it may be more useful to convert this into a
% biomass, and could add that as an extra input
totPop = squeeze(sum(popMat, 2));

% determine the number of reefs, age classes, and start the plot
nReefs = size(popMat, 1);
nAges = size(popMat, 2);
figure

% make a vector of the start and end of each of the 4 discretised age
% classes
ageGroupVec = zeros(4, 2);
if nAges > 4

    % attempt to divide the age classes by 4, and assign the remainders
    % otherwise
    agesPerClass = floor(nAges / 4);
    remainder = mod(nAges, 4);

    % assign the ages with the remainders added in
    ageGroupVec(1, 1) = 1;
    for i = 1:remainder

        % assign the initial point
        if i == 1
            ageGroupVec(i, 1) = 1;
        else
            ageGroupVec(i, 1) = ageGroupVec(i-1, 2) + 1;
        end

        % assign the boundary
        ageGroupVec(i, 2) = ageGroupVec(i, 1) + agesPerClass;

    end

    % assign the rest of the ages
    for i = (remainder + 1):nAges

        % assign the initial point
        if i == 1
            ageGroupVec(i, 1) = 1;
        else
            ageGroupVec(i, 1) = ageGroupVec(i-1, 2) + 1;
        end

        % assign the boundary
        ageGroupVec(i, 2) = ageGroupVec(i, 1) + agesPerClass - 1;

    end

else

    % otherwise, the age classes are just each age class
    for i = 1:nAges
        ageGroupVec(i, :) = [i, i];
    end

end

% if a connectivity matrix has been supplied, create a tiledlayout
if ~isempty(conMat)
    if horizInd ~= "horizontal"
        tL = tiledlayout(5, 2, "TileSpacing", "compact", 'TileIndexing', ...
            'rowmajor');
        nexttile([2, 2])
    else
        tL = tiledlayout(4, 4, "TileSpacing", "compact", 'TileIndexing', ...
            'rowmajor');
        nexttile([2, 4])
    end
else
    tL = tiledlayout(7, 2, "TileSpacing", "compact", 'TileIndexing', ...
        'rowmajor');
    nexttile([3, 2])
end

% plot each of the populations one by one, and colour using my colourmap
hold on
for r = 1:nReefs
    plot(tVec, totPop(r, :), 'color', getColour(r, nReefs), 'lineWidth', 1)
    xlim([0, max(tVec) + 1])
end

% if we have less than 6 reefs, show a legend
if nReefs <= 6
    legendCell = cell(1, nReefs);
    for r = 1:nReefs
        legendCell{r} = sprintf('Reef %g', r);
    end
    if horizInd ~= "horizontal"
        legend(legendCell, 'Location', 'best', 'orientation', ...
            'vertical')
    else
        legend(legendCell, 'Location', 'northwest', 'orientation', ...
            'vertical')
    end
end

% title the axes
ylabel('Total Abundance')
xlabel('$t$')
title('Metapopulation Trajectories')

% if a connectivity matrix has been supplied, plot that as well, along with
% the age structure dynamics
if ~isempty(conMat)

    % plot the connectivity matrix visualisations
    if horizInd ~= "horizontal"
        nexttile([2, 1])
    else
        nexttile([2, 2])
    end
    visualiseConMat(conMat, "noFig")
    title('Connectivity Visualisation')
    ax = gca;
    ax.Colorbar.Location = 'southoutside';
    ax.Colorbar.Label.String = "Connection Strength";
    ax.Colorbar.Label.Interpreter = "Latex";

end

% plot the age structure dynamics, creating a tiledlayout inside ->
% later should alter this to just do groupings of ages rather than
% every single age

% now plot each of the age classes
for a = 1:min(4, nAges)

    % split the size of the panels based on whether we are dispaying the
    % connectivity matrix
    if ~isempty(conMat)
        nexttile
    else
        nexttile([2, 1])
    end
    
    % plot the stuff, with a dummy point so I can write the title as a
    % legend instead lmao
    hold on
    for r = 1:nReefs
        plot(tVec, squeeze(sum(popMat(r, ...
            ageGroupVec(a, 1):ageGroupVec(a, 2), :), 2)), 'color', ...
            getColour(r, nReefs))
    end
    xlim([0, max(tVec) + 1])

    % plot the titles if we have the same age classes
    if ageGroupVec(a, 1) == ageGroupVec(a, 2)
        if horizInd ~= "horizontal"
            title(sprintf("Age Class %g", a), 'units', 'normalized', ...
                'Position', [0.5, 1, 0], 'HorizontalAlignment', 'center')
        else
            title(sprintf("Age Class %g", a))
        end
    else
        if horizInd ~= "horizontal"
            title(sprintf("Age Classes %g to %g", ageGroupVec(a, 1), ...
                ageGroupVec(a, 2)), 'HorizontalAlignment', 'center')
        else
            title(sprintf("Ages %g to %g", ageGroupVec(a, 1), ...
                ageGroupVec(a, 2)))
        end
    end

end

end
