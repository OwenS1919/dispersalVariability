function simOutStruct = rerunMPASimulation(simStruct, areaStruct, ...
    areaStructGBR, specStruct, randStruct, actionStruct, simOutStruct)
% rerunMPASimulation() will re-run a number of simulations of the MPA
% decision problem, for a single decision making approach and join
% additional measures to the output structure

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
    % meanVarWeight - if any form of MPT is used, this corresponds to the k
        % value where k = 1 indicates the method only cares about the mean
        % values, and k = 0 indicates the method only cares about variance,
        % with values inbetween indicating tradeoffs
    % additional fields will be related to the specific methods themselves,
    % and I will update the documentation when needed
% simOutStruct - a structure, which contains the following fields:
    % mpaSel - a cell array, where mpaSel{i} is a binary vector, indicating
        % the reefs chosen for the MPA network in the ith simulation
    % I can't be bothered updating the rest of the fields here I don't care
        % if god strikes me down for my insolence I'm sure the names are
        % decent enough for me to remember
       
% output:

% simOutStruct - same as the input argument, however now with some
    % additional fields - basically just relating to the mean and standard
    % deviation of biomass at each reef

% determine the number of simulations to be run, and the number of reefs in
% the study area
nSims = length(simStruct.warmupSeqs);
nReefs = size(areaStruct.conMats{1}, 1);

% initialise the additional output fields
simOutStruct.meanBiomassObs = zeros(nSims, nReefs);
simOutStruct.stdBiomassObs = zeros(nSims, nReefs);
simOutStruct.meanBiomassMPA = zeros(nSims, nReefs);
simOutStruct.stdBiomassMPA = zeros(nSims, nReefs);

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

    % store the mean and standard deviation of the biomass at each reef
    biomassMat = calcBiomass(popMatObsLocal, specStruct.massVec);
    simOutStruct.meanBiomassObs(s, :) = mean(biomassMat, 2)';
    simOutStruct.stdBiomassObs(s, :) = std(biomassMat, [], 2)';
    clear popMatObsLocal

    % run the model for the MPA period
    randStruct.sequence = simStruct.mpaSeqs{s};
    actionStruct.actionVec = zeros(1, length(areaStructGBR.areas));
    reefIndsGBR = find(areaStruct.reefInds);
    actionStruct.actionVec(reefIndsGBR(simOutStruct.mpaSel{s} > 0)) = 1;
    popMatMPA = baseMetapopModel(areaStructGBR.conMats, ...
        areaStructGBR.areas, popMatObsFin, simStruct.tMPA, specStruct, ...
        randStruct, actionStruct);
    popMatMPALocal = popMatMPA(areaStruct.reefInds, :, :);
    clear popMatMPA

    % now that we've run the model for the MPA period, start storing the
    % mean and standard deviation of the biomass at each reef
    biomassMat = calcBiomass(popMatMPALocal, specStruct.massVec);
    simOutStruct.meanBiomassMPA(s, :) = mean(biomassMat, 2)';
    simOutStruct.stdBiomassMPA(s, :) = std(biomassMat, [], 2)';
    clear popMatMPALocal biomassMat
    
end

end