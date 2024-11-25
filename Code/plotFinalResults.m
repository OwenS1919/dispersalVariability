function plotFinalResults(solCell, regionString, presInd, sysInd)
% plotFinalResults() will plot the final experimental results in the
% expected value - variance space

% inputs:

% solCell - a cell array, where each element is a simOutStruct, as
    % described in runMPASimulation()
% regionString - a string holding the region the values correspond to
% presInd - optional - specify as "pres" if producing a figure for the
    % presentation - default is "no"
% sysInd - optional - specify as "sys" if we want to plot the results from
    % the system as a whole - default is "no"

% set defaults for presInd and sysInd
if nargin < 3 || isempty(presInd) || presInd ~= "pres"
    presInd = false;
else
    presInd = true;
end
if nargin < 4 || isempty(sysInd) || sysInd ~= "sys"
    sysInd = false;
else
    sysInd = true;
end

% this is gonna be fucked, but if we want to plot the system-wide
% approaches only I'm gonna need to do some fucky shit here methinks,,,,,
% hmmmmmm - I'll get rid of any of the solutions that aren't system-based I
% guess
solCellMask = ones(1, length(solCell));
for i = 1:length(solCell)
    if sysInd && contains(solCell{i}.methodStruct.methodInd, "MPT") ...
            && ~contains(solCell{i}.methodStruct.methodInd, "Sys")
        solCellMask(i) = 0;
    elseif ~sysInd && contains(solCell{i}.methodStruct.methodInd, "MPT") ...
            && contains(solCell{i}.methodStruct.methodInd, "Sys")
        solCellMask(i) = 0;
    end
end

% now, let's get rid of any of the solCell entries which don't correspond
% to whatever version we're trying to plot now
solCell = solCell(solCellMask == 1);

% make the Pareto-optimal front a line for each of the thingies

% determine the number of different methods used and simulation repetitions
nMethods = length(solCell);
nSims = length(solCell{1}.mpaSel);

% extract the names of each of the simulations
namesVec = strings(1, nMethods);
for i = 1:nMethods
    if ismember(solCell{i}.methodStruct.methodInd, ["MPTBiom", ...
            "MPTBiomSys"])
        namesVec(i) = "MPT B. (k = " ...
            + num2str(solCell{i}.methodStruct.meanVarWeight) + ")";
    elseif ismember(solCell{i}.methodStruct.methodInd, ["MPTLarvCont", ...
            "MPTLarvContSys"])
        namesVec(i) = "MPT LC. (k = " ...
            + num2str(solCell{i}.methodStruct.meanVarWeight) + ")";
    elseif solCell{i}.methodStruct.methodInd == "none"
        namesVec(i) = "None";
        noneInd = i;
    elseif solCell{i}.methodStruct.methodInd == "random"
        namesVec(i) = "Random";
    elseif solCell{i}.methodStruct.methodInd == "finalBiom"
        if ~presInd
            namesVec(i) = "Final B.";
        else
            namesVec(i) = "Final Biomass";
        end
    elseif solCell{i}.methodStruct.methodInd == "finalLarvCont"
        if ~presInd
            namesVec(i) = "Final LC.";
        else
            namesVec(i) = "Final Larval Contrib.";
        end
    else
        namesVec(i) = solCell{i}.methodStruct.methodInd;
    end
end

% remove the none case
solCell = solCell([1:(noneInd - 1), (noneInd + 1):end]);
namesVec = namesVec([1:(noneInd - 1), (noneInd + 1):end]);
nMethods = nMethods - 1;

% reverse the positions of all my shit because I'm stupid
solCell = solCell(length(solCell):-1:1);
namesVec = namesVec(length(namesVec):-1:1);

% create colours to use for each of the boxplots
coloursCell = cell(1, nMethods);
coloursCell{1} = getColour('lb');
coloursCell{2} = getColour('o');
coloursCell{3} = getColour('y');
for i = 1:5
    coloursCell{3 + i} = getColour(i + 4, 9, 'p');
end
for i = 1:5
    coloursCell{8 + i} = getColour(i + 4, 9, 'g');
end

% instantly reverse this because I'm too lazy to reverse the numbers
coloursCell = coloursCell(length(coloursCell):-1:1);

% can now actually plot this shit but like what the fuck have I done
% ahhahahaha
hold on
medVecMPTBiom = [];
medVecMPTLC = [];
legendString = [];

% scatter all the values into the background first
for i = 1:nMethods

    % first, gather the data for the current method thingy
    xData = solCell{i}.objFuncVar;
    yData = solCell{i}.objFuncExpVal;

    % store the median values if needed
    if contains(namesVec(i), "MPT B.")
        medVecMPTBiom = [medVecMPTBiom; median(xData), median(yData)];
    elseif contains(namesVec(i), "MPT LC.")
        medVecMPTLC = [medVecMPTLC; median(xData), median(yData)];
    end

    % prepare the legend
    legendString = [legendString, ""];

    % plot all the data into the background
    if ~presInd
        scatter(xData, yData, 4, coloursCell{i}, "Filled", ...
            'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.3)
    else
        scatter(xData, yData, 2, coloursCell{i}, "Filled", ...
            'MarkerFaceAlpha', 0.6, 'MarkerEdgeAlpha', 0.3)
    end

end

% do the line between them down here
legendString = [legendString, "", ""];
if ~presInd
    plot(medVecMPTBiom(:, 1), medVecMPTBiom(:, 2), 'Color', ...
        coloursCell{10}, 'LineWidth', 1)
    plot(medVecMPTLC(:, 1), medVecMPTLC(:, 2), 'Color', coloursCell{5}, ...
        'LineWidth', 1)
else
    plot(medVecMPTBiom(:, 1), medVecMPTBiom(:, 2), 'Color', ...
        coloursCell{10}, 'LineWidth', 1.5)
    plot(medVecMPTLC(:, 1), medVecMPTLC(:, 2), 'Color', coloursCell{5}, ...
        'LineWidth', 1.5)
end


for i = 1:nMethods

    % first, gather the data for the current method thingy
    xData = solCell{i}.objFuncVar;
    yData = solCell{i}.objFuncExpVal;

    % plot the median values (and also store them if necessary)
    plot(median(xData), median(yData), '.', 'MarkerSize', 24, 'Color', ...
        coloursCell{i});

    % prepare the legend
    if contains(namesVec(i), "MPT B.")
        if namesVec(i) == "MPT B. (k = 0)"
            if ~presInd
                legendString = [legendString, "MPT B."];
            else
                legendString = [legendString, "MPT Biomass"];
            end
        else
            legendString = [legendString, ""];
        end
    elseif contains(namesVec(i), "MPT LC.")
        if namesVec(i) == "MPT LC. (k = 0)"
            if ~presInd
                legendString = [legendString, "MPT LC."];
            else
                legendString = [legendString, "MPT Larval Contrib."];
            end
        else
            legendString = [legendString, ""];
        end
    else
        legendString = [legendString, namesVec(i)];
    end

end

% set the legend
legend(legendString, 'Location', 'SouthEast')

% set the axes labels
xlabel("Variance in Yearly Biomass")
ylabel("Expected Yearly Biomass")
if ~presInd
    title("Mean-Variance Plot for the " + regionString + " Region")
else
    title("Mean-Variance Plot")
    subtitle(regionString + " Region")
end

end