% load in the relevant data
if ~exist("workspaceVarHonours", 'var')
    load matlabHonours.mat
    setInterpLatex()
end

% run the simulations :), this time just forming the portfolios first, and
% doing the rest in a separate loop
nRepsCTSwains = 100;
tWarmup = 100;
tObs = 20;
tFinal = 50;
randStruct = struct();
randStruct.randType = "sequence";
actionStruct.type = "MPA";
actionStruct.actionEffect = successVecCTMPA;
portPerfCTSwains = zeros(nRepsCT, 7);
portVarCTSwains = zeros(size(portPerfCTSwains));
portPerfCTSwainsRetro = zeros(nRepsCT, 7);
portVarCTSwainsRetro = zeros(size(portPerfCTSwainsRetro));

% because I'm a genius, I'm gonna store the MPAs created at each rep AND
% the random connectivity matrix sequences at each rep - that way I can
% reliably recreate the population trajectories without re - running
% everything
mpaSelCTSwains = cell(nRepsCT, 1);
randSeqCTSwains = cell(nRepsCT, 3);

% also, the costs will be the areas, and the resources will be 30% of the
% entire area
resourcesCTSwains = 0.3 * sum(areasCTSwains);

% time stuff
tic

% loop over each run and construct the portfolios only
for r = 1:nRepsCT

    % run the metapopulation model for the warmup period
    randStruct.sequence = randi(nMatsCT, 1, tWarmup - 1);
    randSeqCTSwains{r, 1} = randStruct.sequence;
    popMatWarmup = baseMetapopModel(conMatsCTSwains, areasCTSwains, ...
        popInitCTSwains, tWarmup, specStructCT, randStruct);

    % run the metapopulation model for the observational period
    randStruct.sequence = randi(nMatsCT, 1, tObs - 1);
    randSeqCTSwains{r, 2} = randStruct.sequence;
    popMatObs = baseMetapopModel(conMatsCTSwains, areasCTSwains, ...
        squeeze(popMatWarmup(:, :, end)), tObs, specStructCT, ...
        randStruct);

    % convert the age structured population trajectories into a single,
    % size class weighted sum
    biomassMat = convertAgeClasses(popMatObs, massVecCT);

    % calculate the MPA networks
    boundVals = zeros(2, 2);
    mpaSelCTSwains{r} = cell(1, 7);
    [mpaSelCTSwains{r}{1}, boundVals(1, 2), boundVals(2, 2)] = applyMPT( ...
        biomassMat, 1, "discrete", resourcesCTSwains, areasCTSwains);
    [mpaSelCTSwains{r}{5}, boundVals(1, 1), boundVals(2, 1)] = applyMPT( ...
        biomassMat, 0, "discrete", resourcesCTSwains, areasCTSwains);
    mpaSelCTSwains{r}{2} = applyMPT(biomassMat, 0.75, "discrete", ...
        resourcesCTSwains, areasCTSwains, boundVals);
    mpaSelCTSwains{r}{3} = applyMPT(biomassMat, 0.5, "discrete", ...
        resourcesCTSwains, areasCTSwains, boundVals);
    mpaSelCTSwains{r}{4} = applyMPT(biomassMat, 0.25, "discrete", ...
        resourcesCTSwains, areasCTSwains, boundVals);

    % form the random portfolio, and the zero portfolio
    reefSeq = randperm(nReefsCTSwains);
    mpaSelCTSwains{r}{6} = zeros(1, nReefsCTSwains);
    for i = 1:nReefsCTSwains
        randPortTemp = mpaSelCTSwains{r}{6};
        randPortTemp(reefSeq(i)) = 1;
        if randPortTemp * areasCTSwains < resourcesCTSwains
            mpaSelCTSwains{r}{6} = randPortTemp;
        end
    end
    mpaSelCTSwains{r}{7} = zeros(1, nReefsCTSwains);

    % select a sequence of connectivity matrices for the final time period,
    % which will be the same across all portfolio samples
    randStruct.sequence = randi(nMatsCT, 1, tFinal - 1);
    randSeqCTSwains{r, 3} = randStruct.sequence;

    % every 10 iterations print the time and save the results
    if mod(r, 10) == 0
        disp(r)
        toc
        currTime = toc;
        save matlabSwainsExp.mat mpaSelCTSwains randSeqCTSwains
    end

end

% save the results
save matlabSwainsExp.mat mpaSelCTSwains randSeqCTSwains

% clear some of the redundant variables
clear popMatCell popMatWarmup popMatObs
