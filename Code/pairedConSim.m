function [resMat, conStrengthMat] = pairedConSim(conMats, areaVec, popInit, ...
    specStruct, actionStruct)
% pairedConnSim() will run simulations which investigate the effect of
% investing in pairs of reefs which are connected, using simulations across
% all connectivity matrices in order

% inputs:

% conMats - a 1D cell array containing multiple connectivity matrices
    % representing the system to be modelled, where conMats{k}(i, j)
    % represents the probability that larvae released from reef i will
    % settle at reef j, in the kth timestep
% areaVec - a vector containing the amount of reef habitat on each reef
% popInit - the initial population, where popInit(i, j) corresponds to the
    % population in age class j at reef i
% specStruct - a structure, with the species specific fields:
    % successVec, where successVec(i) is the proportion of individuals in
        % the ith age class who will survive and progress to the ith age
        % class, with no entry for the final age class (i.e. is of length
        % one less than number of age classes)
    % alpha - the alpha parameter for the Beverton - Holt equation for
        % settlers
    % beta - the beta parameter for the Beverton - Holt equation for
        % settlers
    % fecundVec - a vector containing the fecundity of each age class

% outputs:

% resMat - an nReefs x nReefs x 4 matrix, with upper triangular elements
    % only, where resMat(i, j, k) indicates the base OF value for k = 1
    % without any action, with the rest indicating the added benefit of
    % investing in reef i for k = 2, reef j for k = 3, and both for k = 4
% conStrengthMat - a matrix where conStrengthMat(i, j) holds a measure of
    % the connectivity strength between reefs i and j, upper triangular
    % only

% determine the number of reefs, and the number of matrices
nReefs = size(conMats{1}, 1);
nMats = length(conMats);

% average the connectivity matrices
aveConMat = zeros(size(conMats{1}));
for i = 1:nMats
    aveConMat = aveConMat + conMats{i};
end
aveConMat = aveConMat / nMats;

% begin by calculating the connectivity strenghts of each of the
% connections, using his weird ass metric that I should almost certainly
% later change maybe idk
conStrengthMat = -1 * ones(nReefs, nReefs);
for i = 1:nReefs
    for j = (i + 1):nReefs
        conStrengthMat(i, j) = sqrt(aveConMat(i, j) ...
            * aveConMat(i, j)) + aveConMat(i, j) ...
            + aveConMat(j, i);
    end
end

% run the simulation first without any MPAs
zeroVec = zeros(1, nReefs);
actionStruct.actionVec = zeroVec;
popMat = baseMetapopModel(conMats, areaVec, popInit, nMats, specStruct, [], ...
    actionStruct);

% calculate the objective function, and assign it to the first layer of
% resMat
resMat = zeros(nReefs, nReefs, 4);
resMat(:, :, 1) = sum(sum(convertAgeClasses(popMat, ...
    specStruct.weightings)));

% now, loop over all remaining connections
for i = 1:nReefs
    for j = (i + 1):nReefs

        % simulate the protection of reef i only and store results
        actionVec = zeroVec;
        actionVec(i) = 1;
        actionStruct.actionVec = actionVec;
        popMat = baseMetapopModel(conMats, areaVec, popInit, nMats, ...
            specStruct, [], actionStruct);
        resMat(i, j, 2) = sum(sum(convertAgeClasses(popMat, ...
            specStruct.weightings))) - resMat(i, j, 1);

        % simulate the protection of reef j only and store results
        actionVec = zeroVec;
        actionVec(j) = 1;
        actionStruct.actionVec = actionVec;
        popMat = baseMetapopModel(conMats, areaVec, popInit, nMats, ...
            specStruct, [], actionStruct);
        resMat(i, j, 3) = sum(sum(convertAgeClasses(popMat, ...
            specStruct.weightings))) - resMat(i, j, 1);

        % simulate the protection of both reefs and store results
        actionVec = zeroVec;
        actionVec(i) = 1;
        actionVec(j) = 1;
        actionStruct.actionVec = actionVec;
        popMat = baseMetapopModel(conMats, areaVec, popInit, nMats, ...
            specStruct, [], actionStruct);
        resMat(i, j, 4) = sum(sum(convertAgeClasses(popMat, ...
            specStruct.weightings))) - resMat(i, j, 1);

    end
end

end