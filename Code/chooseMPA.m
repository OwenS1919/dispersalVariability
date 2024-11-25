function [mpaVec, exitFlag] = chooseMPA(popMatObs, areas, resources, ...
    methodStruct)
% chooseMPA will choose an MPA network setup based on an optimisation
% methodology proposed by the user

% inputs:

% popMatObs - a 3d array where popMatObs(i, j, k) indicates the population
    % of the jth age class on the ith reef, at the kth timestep
% areas - a vector containing the amount of reef habitat on each reef
% resources - the proportion of the total area which can be designated an
    % MPA
% methodStruct - a structure, with fields relating to the MPA selection
    % methods:
    % methodInd - a string, which specifies the optimisation method being
        % used, with: "MPTBiom" - applies MPT to the weighted sum of the
        % populations, "MPTCon" - applies MPT to the row sums of the
        % connectivity matrix, "MPTBiomCon" - applies MPT to a weighted sum
        % of the weighted sum of population and row sums of the
        % connectivity matrix, "random" - forms a random MPA network,
        % "none" - returns a vector of 0s, i.e. an empty MPA network,
        % "finalBiom" - chooses an MPA network that maximises the biomass
        % in the final observational year, "finalLarvCont" - maximises the
        % larval contribution in the final observational year, "meanBiom" -
        % maximises the historical mean biomass, "meanLarvCont" - maximises
        % the historical mean larval contribution
    % meanVarWeight - if any form of MPT is used, this corresponds to the k
        % value where k = 1 indicates the method only cares about the mean
        % values, and k = 0 indicates the method only cares about variance,
        % with values inbetween indicating tradeoffs
    % additional fields will be related to the specific methods themselves,
    % and I will update the documentation when needed

% output:

% mpaVec - a binary vector indicating which of the reefs are chosen as part
    % of the MPA network
% exitFlag - for testing purposes, the final exitFlag of from the ga()
    % call, or from any equivalent optimisation call used in choosing an
    % MPA

% transpose the areas if necessary, they should be a row vector
if size(areas, 1) > size(areas, 2)
    areas = areas';
end

% determine the number of reefs in the model
nReefs = size(popMatObs, 1);

% switch cases based on the methodInd
if methodStruct.methodInd == "MPTBiom"

    % run the MPT approach for the population sizes only, first converting
    % the population matrix into a single value for each reef and timestep
    biomassMat = calcBiomass(popMatObs, methodStruct.classWeights);
    [mpaVec, ~, ~, ~, exitFlag] = applyMPT(biomassMat, ...
        methodStruct.meanVarWeight, "discrete", resources * sum(areas), ...
        areas, [], "calcBoundVals");

elseif methodStruct.methodInd == "MPTLarvCont"

    % calculate the larval contribution of each of the reefs through time,
    % and then run the MPT algorithm on the results
    larvalContMat = calcLarvalContrib(popMatObs, methodStruct.fecundVec, ...
        methodStruct.conMats);
    [mpaVec, ~, ~, ~, exitFlag] = applyMPT(larvalContMat, ...
        methodStruct.meanVarWeight, "discrete", resources * sum(areas), ...
        areas, [], "calcBoundVals");

elseif methodStruct.methodInd == "MPTBiomCon"

    % fix this shit or maybe don't even bother using it at all idfk

elseif methodStruct.methodInd == "MPTBiomSys"

    % run the MPT approach for the population sizes across the entire
    % system, first converting the population matrix into a single value
    % for each reef and timestep
    biomassMat = calcBiomass(popMatObs, methodStruct.classWeights);
    [mpaVec, ~, ~, ~, exitFlag] = applyMptSystem(biomassMat, ...
        methodStruct.actionEffect, methodStruct.meanVarWeight, "discrete", ...
        resources * sum(areas), areas, [], "calcBoundVals");

elseif methodStruct.methodInd == "MPTLarvContSys"

    % calculate the larval contribution of each of the reefs through time,
    % and then run the system-wide MPT algorithm on the results
    larvalContMat = calcLarvalContrib(popMatObs, methodStruct.fecundVec, ...
        methodStruct.conMats);
    [mpaVec, ~, ~, ~, exitFlag] = applyMptSystem(larvalContMat, ...
        methodStruct.actionEffect, methodStruct.meanVarWeight, "discrete", ...
        resources * sum(areas), areas, [], "calcBoundVals");

elseif methodStruct.methodInd == "random"

    % switch the order of the areas back for some dumbass reason
    if size(areas, 2) > size(areas, 1)
        areas = areas';
    end

    % form the random portfolio
    reefSeq = randperm(nReefs);
    mpaVec = zeros(1, nReefs);
    for i = 1:nReefs
        randPortTemp = mpaVec;
        randPortTemp(reefSeq(i)) = 1;
        if randPortTemp * areas < resources * sum(areas)
            mpaVec = randPortTemp;
        end
    end
    exitFlag = 0;

elseif methodStruct.methodInd == "none"

    % just return a vector of zeros
    mpaVec = zeros(1, nReefs);
    exitFlag = 0;

elseif methodStruct.methodInd == "finalBiom" || methodStruct.methodInd ...
        == "finalLarvCont" || methodStruct.methodInd == "meanBiom" ...
        || methodStruct.methodInd == "meanLarvCont"

    % gonna do all the methods that are linear in here, just because it is
    % easier then - split between them here

    if methodStruct.methodInd == "finalBiom"

        % convert the population trajectories to biomass, then isolate a
        % vector of the final year's biomass
        biomassMat = calcBiomass(popMatObs, methodStruct.classWeights);
        biomassFinal = biomassMat(:, end);
    
        % set up the objective function
        objFunc = @(x) -(x * biomassFinal);

    elseif methodStruct.methodInd == "finalLarvCont"

        % calculate the yearly larval contributions for each reef, then
        % take the final values
        larvalContMat = calcLarvalContrib(popMatObs, ...
            methodStruct.fecundVec, methodStruct.conMats);
        larvalContFinal = larvalContMat(:, end);

        % set up the objective function
        objFunc = @(x) -(x * larvalContFinal);

    end

    % set the constraints
    A = areas;
    b = resources * sum(areas);
    intcon = 1:nReefs;
    lb = zeros(nReefs, 1);
    ub = ones(nReefs, 1);

    % ensure that the maximum area is not exceeded, and that at least 95%
    % of the area is used - this enhances optimisation too
    A = [A; -A];
    b = [b; -0.95 * b];

    % turn off the display for the ga()
    opts = optimoptions('ga', 'Display', 'off');

    % apply a genetic algorithm to solve for the optimal MPA design until
    % it converges succesfully, or hits the maximum number of iterations
    maxIters = 5;
    iter = 1;
    exitFlag = -100;
    while iter <= maxIters && exitFlag < 0
        [mpaVec, ~, exitFlag] = ga(objFunc, nReefs, A, b, [], [], lb, ub, ...
            [], intcon, opts);
        iter = iter + 1;
    end

    % check the exitFlag, and print if it remains negative
    if exitFlag < 0
        fprintf("Exit flag: %g, k = %g\n", exitFlag, weight)
    end

end

end