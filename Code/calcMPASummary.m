function summaryTable = calcMPASummary(simOutCell, areaString, sysInd)
% calcMPASummary() will calculate some summary statistics for a set of
% decision-making approaches applied to a study area on the GBR

% inputs:

% simOutCell - a cell array, containing simOutStruct structures produced by
    % the runMPASimulation() function, that contain data on the peformance
    % of different MPA decision-making approaches
% areaString - the name of the area being processed
% sysInd - optional - specify as "sys" if the results are to be taken from
    % the MPT implementation in which the entire system is considered

% outputs:

% summaryTable - a table containing the summary statistics for the current
    % study area

% set default for sysInd
if nargin < 3 || isempty(sysInd)
    sysInd = "no";
end

% initialise the table
summaryTable = table(areaString, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...
    'VariableNames', ["studyArea", "varRedLCVsB", "varRedLCVsR", ...
    "varRedBVsR", "expValDecLCVsR", "expValDecBVsR", "expValIncBVsLC", ...
    "expValIncLCVsR", "expValIncBVsR", "expValIncFBVsB", "expValIncNVsR", ...
    "varIncLCVsR", "varIncBVsR", "SlopeLC", "SlopeB"]);

% extract the names of the decision-making approaches
% determine the number of different methods used and simulation repetitions
nMethods = length(simOutCell);

% extract the names of each of the simulations, switching cases based on
% whether we are looking at results using system-wide MPT
namesVec = strings(1, nMethods);
if sysInd == "sys"
    for i = 1:nMethods
        if simOutCell{i}.methodStruct.methodInd == "MPTBiomSys"
            namesVec(i) = "MPT B. (k = " ...
                + num2str(simOutCell{i}.methodStruct.meanVarWeight) + ")";
        elseif simOutCell{i}.methodStruct.methodInd == "MPTLarvContSys"
            namesVec(i) = "MPT LC. (k = " ...
                + num2str(simOutCell{i}.methodStruct.meanVarWeight) + ")";
        elseif simOutCell{i}.methodStruct.methodInd == "none"
            namesVec(i) = "None";
            noneInd = i;
        elseif simOutCell{i}.methodStruct.methodInd == "random"
            namesVec(i) = "Random";
        elseif simOutCell{i}.methodStruct.methodInd == "finalBiom"
            namesVec(i) = "Final B.";
        elseif simOutCell{i}.methodStruct.methodInd == "finalLarvCont"  
            namesVec(i) = "Final LC.";
        else
            namesVec(i) = simOutCell{i}.methodStruct.methodInd;
        end
    end
else
    for i = 1:nMethods
        if simOutCell{i}.methodStruct.methodInd == "MPTBiom"
            namesVec(i) = "MPT B. (k = " ...
                + num2str(simOutCell{i}.methodStruct.meanVarWeight) + ")";
        elseif simOutCell{i}.methodStruct.methodInd == "MPTLarvCont"
            namesVec(i) = "MPT LC. (k = " ...
                + num2str(simOutCell{i}.methodStruct.meanVarWeight) + ")";
        elseif simOutCell{i}.methodStruct.methodInd == "none"
            namesVec(i) = "None";
            noneInd = i;
        elseif simOutCell{i}.methodStruct.methodInd == "random"
            namesVec(i) = "Random";
        elseif simOutCell{i}.methodStruct.methodInd == "finalBiom"
            namesVec(i) = "Final B.";
        elseif simOutCell{i}.methodStruct.methodInd == "finalLarvCont"
            namesVec(i) = "Final LC.";
        else
            namesVec(i) = simOutCell{i}.methodStruct.methodInd;
        end
    end
end
namesVec = namesVec(namesVec ~= "");

% calculate the difference in variance reduction between the two
ind1 = find(namesVec == "MPT LC. (k = 0)");
ind2 = find(namesVec == "MPT B. (k = 0)");
summaryTable{1, "varRedLCVsB"} = (mean(simOutCell{ind2}.objFuncVar) - ...
    mean(simOutCell{ind1}.objFuncVar)) / mean(simOutCell{ind2}.objFuncVar);

% calculate the difference in variance reduction comparative to the
% randomised approaches maybe?
ind3 = find(namesVec == "Random");
summaryTable{1, "varRedLCVsR"} = (mean(simOutCell{ind3}.objFuncVar) - ...
    mean(simOutCell{ind1}.objFuncVar)) / mean(simOutCell{ind3}.objFuncVar);
summaryTable{1, "varRedBVsR"} = (mean(simOutCell{ind3}.objFuncVar) - ...
    mean(simOutCell{ind2}.objFuncVar)) / mean(simOutCell{ind3}.objFuncVar);

% now calculate the associated decrease in expected value required for
% these variance reductions
summaryTable{1, "expValDecLCVsR"} = (mean(simOutCell{ind3}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind3}.objFuncExpVal);
summaryTable{1, "expValDecBVsR"} = (mean(simOutCell{ind3}.objFuncExpVal) - ...
    mean(simOutCell{ind2}.objFuncExpVal)) ...
    / mean(simOutCell{ind3}.objFuncExpVal);

% calculate the difference in the expected biomass between the two
% approaches and random alternatives

% first, do B compared to LC
ind1 = find(namesVec == "MPT LC. (k = 1)");
ind2 = find(namesVec == "MPT B. (k = 1)");
summaryTable{1, "expValIncBVsLC"} = (mean(simOutCell{ind2}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind1}.objFuncExpVal);

% now do LC compared to random
ind1 = find(namesVec == "Random");
ind2 = find(namesVec == "MPT LC. (k = 1)");
summaryTable{1, "expValIncLCVsR"} = (mean(simOutCell{ind2}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind1}.objFuncExpVal);

% now do B compared to random
ind1 = find(namesVec == "Random");
ind2 = find(namesVec == "MPT B. (k = 1)");
summaryTable{1, "expValIncBVsR"} = (mean(simOutCell{ind2}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind1}.objFuncExpVal);

% finally do final B compared to B
ind1 = find(namesVec == "MPT B. (k = 1)");
ind2 = find(namesVec == "Final B.");
summaryTable{1, "expValIncFBVsB"} = (mean(simOutCell{ind2}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind1}.objFuncExpVal);

% do an extra one comparing no MPAs to random approaches - this time look
% at the proportional increase relative to no MPA
ind1 = find(namesVec == "None");
ind2 = find(namesVec == "Random");
summaryTable{1, "expValIncNVsR"} = (mean(simOutCell{ind2}.objFuncExpVal) - ...
    mean(simOutCell{ind1}.objFuncExpVal)) ...
    / mean(simOutCell{ind1}.objFuncExpVal);

% finally, calculate the increases in variance required to reach these
% expected values
ind1 = find(namesVec == "Random");
ind2 = find(namesVec == "MPT LC. (k = 1)");
summaryTable{1, "varIncLCVsR"} = (mean(simOutCell{ind2}.objFuncVar) - ...
    mean(simOutCell{ind1}.objFuncVar)) ...
    / mean(simOutCell{ind1}.objFuncVar);
ind2 = find(namesVec == "MPT B. (k = 1)");
summaryTable{1, "varIncBVsR"} = (mean(simOutCell{ind2}.objFuncVar) - ...
    mean(simOutCell{ind1}.objFuncVar)) ...
    / mean(simOutCell{ind1}.objFuncVar);

% calculate the slopes between the expected values and variance for the
% larval contribution and biomass, first gathering the data
dataXLC = [];
dataYLC = [];
dataXB = [];
dataYB = [];
for i = 1:length(namesVec)
    if contains(namesVec(i), "MPT LC.")
        dataXLC = [dataXLC, median(simOutCell{i}.objFuncExpVal)];
        dataYLC = [dataYLC, median(simOutCell{i}.objFuncVar)];
    elseif contains(namesVec(i), "MPT B.")
        dataXB = [dataXB, median(simOutCell{i}.objFuncExpVal)];
        dataYB = [dataYB, median(simOutCell{i}.objFuncVar)];
    end
end

% yep, the linear model stuff is dumb, should maybe just do it from the
% median values or maybe just means methinks

% run a linear regression
linModel = fitlm(dataXLC, dataYLC);
summaryTable{1, "SlopeLC"} = linModel.Coefficients.Estimate(2);
linModel = fitlm(dataXB, dataYB);
summaryTable{1, "SlopeB"} = linModel.Coefficients.Estimate(2);

end