function plotMPADecSpace(simStruct, areaStruct, areaStructGBR, specStruct, ...
    randStruct, simOutCell, simInd)
% plotMPADecSpace() will plot the decision space for a biomass based MPT
% approach to MPA designation, really this is just a tool for me to ensure
% that my methods are working as expected
    
% inputs:

% simStruct - a structure, with the simulation specific fields:
    % tWarmup - the number of years to run the simulation for from the
        % initial conditions before starting the main simulation
    % tObs - the number of years to run the simulation as an observationary
        % period, where data is to be gathered before MPAs are designed and
        % implemented
    % tMPA - the number of years to run the simulation for with the MPAs
        % present
    % warmupSeqs - a cell array, where warmupSeqs{i} indicates the sequence
        % of conMats to use for the warmup period in the ith simulation
    % obsSeqs - as above, but for the observationary period
    % mpaSeqs - as above, but for the MPA period
    % resources - the proportion of the total area which can be placed
        % under an MPA
% areaStruct - a structure, with the area area specific fields:
    % areas - a vector corresponding to the areas of each of the reefs
    % conMats - a cell array where conMats{i} contains the ith connectivity
        % matrix for the area
    % initPop - the initial population, where popInit(i, j) corresponds to
        % the population in age class j at reef i
% areaStructGBR - as above, but for the whole GBR, not just the area in
    % question
% specStruct - a structure, with the species specific fields:
    % successVec, where successVec(i) is the proportion of individuals in
        % the ith age class who will survive and progress to the ith age
        % class, with no entry for the final age class (i.e. is of length
        % one less than number of age classes)
    % alpha - the alpha parameter for the Beverton - Holt equation for
        % settlers
    % beta - the beta parameter for the Beverton - Holt equation for
        % settlers
    % fecundVec - a vector containing the fecundity of each age classpoo
% randStruct - optional - a structure which holds fields regarding how
    % stochasticity is to be incorporated into the model, with the fields:
    % randType - determines the type of randomness applied, with
        % "randSelection" indicating a matrix is randomly selected from the
        % conMat cell array, "randPert" indicating that the single conMat
        % supplied should be randomly perturbed, and "sequence" indicating
        % the matrices are to be used in a sequence - default is "sequence"
    % sequence - the sequence to use for the matrices, and will only be
        % used if the randType = "sequence"
% simOutCell - a cell array containing structures, which contains the
    % following fields:
    % mpaSel - a cell array, where mpaSel{i} is a binary vector, indicating
        % the reefs chosen for the MPA network in the ith simulation


% start just by running the simulations
randStruct.sequence = simStruct.warmupSeqs{simInd};
popMatWarmup = baseMetapopModel(areaStructGBR.conMats, areaStructGBR.areas, ...
    areaStructGBR.initPop, simStruct.tWarmup, specStruct, randStruct);
randStruct.sequence = simStruct.obsSeqs{simInd};
popMatObs = baseMetapopModel(areaStructGBR.conMats, areaStructGBR.areas, ...
    squeeze(popMatWarmup(:, :, end)), simStruct.tObs, specStruct, ...
    randStruct);

% convert the population matrix to just that of the region in question
popMatObs = popMatObs(areaStruct.reefInds, :, :);

% extract the method types from each of the experiments
methodStrings = strings(1, length(simOutCell));
for i = 1:length(simOutCell)
    methodStrings(i) = simOutCell{i}.methodStruct.methodInd;
end

% evaluate the quantities over time for which we are optimising for
if methodStrings(i) == "MPTBiom"

        % calculate the biomass
        perfMat = calcBiomass(popMatObs, specStruct.massVec);

    elseif methodStrings(i) == "MPTLarvCont"

        % calculate the larval contributions, first storing the relevant
        % connectivity matrices
        conMats = cell(1, simStruct.tObs);
        for t = 1:simStruct.tObs
            conMats{t} = areaStruct.conMats{simStruct.obsSeqs{simInd}(t)};
        end
        perfMat = calcLarvalContrib(popMatObs, specStruct.fecundVec, ...
            conMats);

end

% now, let's set up each of the MPT portfolios
mptPorts = zeros(5, 2);
mptWeights = [1, 0.75, 0.5, 0.25, 0];
for i = 1:length(simOutCell)

    % calculate and store portfolio performance
    currInd = find(mptWeights ...
        == simOutCell{i}.methodStruct.meanVarWeight);
    perfTS = sum(perfMat .* simOutCell{i}.mpaSel{simInd}', 1);
    mptPorts(currInd, 1) = mean(perfTS);
    mptPorts(currInd, 2) = var(perfTS);

end

% set up the random portfolio
randPort = [0, 0];
randInd = find(methodStrings == "random");
randPort(1) = mean(sum(perfMat .* simOutCell{randInd}.mpaSel{simInd}', 1));
randPort(2) = var(sum(perfMat .* simOutCell{randInd}.mpaSel{simInd}', 1));

% let's set up a cloud of random portfolios
newRandPorts = zeros(20, 2);
for i = 1:20

    % setup the random portfolio
    var5.methodInd = "random";
    var4 = chooseMPA(popMatObs, areaStruct.areas, simStruct.resources, ...
        var5);

    % evaluate its performance depending on the method used for the MPT
    newRandPorts(i, 1) = mean(sum(perfMat .* var4', 1));
    newRandPorts(i, 2) = var(sum(perfMat .* var4', 1));

end

% let's now plot all of this shi
figure
hold on
for i = 1:size(mptPorts, 1)
    plot(mptPorts(i, 2), mptPorts(i, 1), '.', 'MarkerSize', 16, 'Color', ...
        getColour(i))
end
plot(randPort(:, 2), randPort(:, 1), '.', 'MarkerSize', 12, 'Color', ...
    getColour(6))
plot(newRandPorts(:, 2), newRandPorts(:, 1), 'k.', 'MarkerSize', 10)
plot(mptPorts(:, 2), mptPorts(:, 1), 'k')
xlabel("Variance")
ylabel("Expected Return")
legend("k = 1", "k = 0.75", "k = 0.5", "k = 0.25", "k = 0", "Random Sim", ...
    "Random")

end