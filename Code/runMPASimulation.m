function simOutStruct = runMPASimulation(simStruct, areaStruct, ...
    areaStructGBR, specStruct, randStruct, actionStruct, methodStruct, ...
    saveInd)
% runMPASimulation() will run a number of simulations of the MPA decision
% problem, for a single decision making approach

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
    % reefInds - a vector containing the indices of each of the reefs used
        % relative to the reefs in the total GBR system
% areaStructGBR - as above, however holds the data relative to the entire
    % GBR, not just the current study area
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
% actionStruct - a structure, with fields indicating the conservation
    % action being undertaken:
    % type - the type of action being taken, "MPA" for MPA reserves
    % actionVec - a vector indicating where and with what intensity actions
        % are being undertaken - for MPAs, this is just a binary vector
        % indicating which reefs are being designated MPAs
    % actionEffect - the effect of taking an action, for MPAs this will be
        % be a vector indicating the new successVec to be applied to reefs
        % inside the MPA network
% methodStruct - a structure, with fields relating to the MPA selection
    % methods:
    % methodInd - a string, which specifies the optimisation method being
        % used, with: "MPTBiom" - applies MPT to the biomass, "MPTCon" -
        % applies MPT to the row sums of the connectivity matrix,
        % "MPTPopCon" - applies MPT to a weighted sum of the weighted sum
        % of population and row sums of the connectivity matrix, "random" -
        % forms a random MPA network, "none" - returns a vector of 0s, i.e.
        % an empty MPA network
    % meanVarWeight - if any form of MPT is used, this corresponds to the k
        % value where k = 1 indicates the method only cares about the mean
        % values, and k = 0 indicates the method only cares about variance,
        % with values inbetween indicating tradeoffs
    % additional fields will be related to the specific methods themselves,
    % and I will update the documentation when needed
% saveInd - optional - specify as "saveLocName" if the method is to save
    % its output (the simOutStruct) to a .mat file in ../Data/mpaSimResults
    % - default is "no" aka no saving
       
% output:

% simOutStruct - a structure, which contains the following fields:
    % mpaSel - a cell array, where mpaSel{i} is a binary vector, indicating
        % the reefs chosen for the MPA network in the ith simulation
    % I can't be bothered updating the rest of the fields here I don't care
        % if god strikes me down for my insolence I'm sure the names are
        % decent enough for me to remember

% set a default for the saveInd
if nargin < 8 || isempty(saveInd)
    saveInd = "no";
end

% check if we've already done this run, and if so, skip the entire run
saveInd = char(saveInd);
if contains(saveInd, "save")
    saveFileName = "../Data/mpaSimOutputs/" + methodStruct.methodInd + "_" ...
        + strrep(num2str(methodStruct.meanVarWeight), '.', 'p') + "_" ...
        + saveInd(5:end) + ".mat";
    if isfile(saveFileName)
        simOutStruct = NaN;
        return
    end
end

% determine the number of simulations to be run
nSims = length(simStruct.warmupSeqs);

% initialise the random structure
randStruct.randType = "sequence";

% setup the methodStruct, which holds information on how the MPA networks
% are selected

% initialise the output
simOutStruct.mpaSel = cell(nSims, 1);
simOutStruct.objFuncTot = zeros(nSims, 1);
simOutStruct.objFuncTS = cell(nSims, 1);
simOutStruct.objFuncExpVal = zeros(nSims, 1);
simOutStruct.objFuncVar = zeros(nSims, 1);
simOutStruct.objFuncTotRetro = zeros(nSims, 1);
simOutStruct.objFuncTSRetro = cell(nSims, 1);
simOutStruct.exitFlag = zeros(nSims, 1);

% also, let's assign the methodStruct to the simOutStuct so that each
% set of results is tied to the methods which produced it
simOutStruct.methodStruct = methodStruct;

% note that I clear some variables below etc etc just to avoid using
% excessive amounts of memory

% loop over each simulation
for s = 1:nSims

    % run the model for the preliminary period, to remove the effects of
    % the initial conditions
    randStruct.sequence = simStruct.warmupSeqs{s};
    popMatWarmup = baseMetapopModel(areaStructGBR.conMats, ...
        areaStructGBR.areas, areaStructGBR.initPop, simStruct.tWarmup, ...
        specStruct, randStruct);
    popMatWarmupFin = squeeze(popMatWarmup(:, :, end));
    clear popMatWarmup

    % run the model for the observational period
    randStruct.sequence = simStruct.obsSeqs{s};
    popMatObs = baseMetapopModel(areaStructGBR.conMats, ...
        areaStructGBR.areas, popMatWarmupFin, simStruct.tObs, specStruct, ...
        randStruct);
    popMatObsFin = squeeze(popMatObs(:, :, end));

    % convert the observational population matrix to just that of the local
    % area
    popMatObsLocal = popMatObs(areaStruct.reefInds, :, :);
    clear popMatObs

    % store the connectivity matrices used in the methodStruct, if the
    % method requires it
    if methodStruct.methodInd == "MPTLarvCont" ...
            || methodStruct.methodInd == "finalLarvCont" ...
            || methodStruct.methodInd == "MPTLarvContSys"
        methodStruct.conMats = cell(1, simStruct.tObs);
        for t = 1:simStruct.tObs
            methodStruct.conMats{t} = ...
                areaStruct.conMats{simStruct.obsSeqs{s}(t)};
        end
    end

    % choose an MPA network design, and store in simOutStruct
    [simOutStruct.mpaSel{s}, simOutStruct.exitFlag(s)] = chooseMPA( ...
        popMatObsLocal, areaStruct.areas, simStruct.resources, ...
        methodStruct);
    clear popMatObsLocal

    % run the model for the MPA period
    randStruct.sequence = simStruct.mpaSeqs{s};
    actionStruct.actionVec = zeros(1, length(areaStructGBR.areas));
    actionStruct.actionVec(areaStruct.reefInds(simOutStruct.mpaSel{s} ...
        > 0)) = 1;
    popMatMPA = baseMetapopModel(areaStructGBR.conMats, ...
        areaStructGBR.areas, popMatObsFin, simStruct.tMPA, specStruct, ...
        randStruct, actionStruct);
    popMatMPALocal = popMatMPA(areaStruct.reefInds, :, :);
    clear popMatMPA

    % evaluate the objective function here, and store in simOutStruct
    [simOutStruct.objFuncTot(s), simOutStruct.objFuncTS{s}] = ...
        objFuncMPA(popMatMPALocal, specStruct.massVec);
    simOutStruct.objFuncExpVal(s) = mean(simOutStruct.objFuncTS{s});
    simOutStruct.objFuncVar(s) = var(simOutStruct.objFuncTS{s});

    % run the model for a retroactive approach - commenting this out now,
    % no longer useful
    % randStruct.sequence = simStruct.obsSeqs{s};
    % popMatObsRetro = baseMetapopModel(areaStructGBR.conMats, ...
    %     areaStructGBR.areas, popMatWarmupFin, simStruct.tObs, specStruct, ...
    %     randStruct, actionStruct);
    % popMatObsRetroLocal = popMatObsRetro(areaStruct.reefInds, :, :);
    % clear popMatObsRetro
    % [simOutStruct.objFuncTotRetro(s), simOutStruct.objFuncTSRetro{s}] = ...
    %     objFuncMPA(popMatObsRetroLocal, specStruct.massVec);
    % clear popMatObsRetro
    
end

% save the results if we're done this run
saveInd = char(saveInd);
if saveInd(1:4) == "save"
    save(saveFileName, "simOutStruct")
end

end