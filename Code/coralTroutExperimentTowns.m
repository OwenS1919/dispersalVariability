% load in the relevant data
if ~exist("workspaceVarHonours", 'var')
    load matlabHonours.mat
    setInterpLatex()
end

% run the simulations :), this time just forming the portfolios first, and
% doing the rest in a separate loop
nRepsCTTowns = 100;
tWarmup = 100;
tObs = 20;
tFinal = 50;
randStruct = struct();
randStruct.randType = "sequence";
actionStruct.type = "MPA";
actionStruct.actionEffect = successVecCTMPA;
portPerfCTTowns = zeros(nRepsCT, 7);
portVarCTTowns = zeros(size(portPerfCTTowns));
portPerfCTTownsRetro = zeros(nRepsCT, 7);
portVarCTTownsRetro = zeros(size(portPerfCTTownsRetro));

% because I'm a genius, I'm gonna store the MPAs created at each rep AND
% the random connectivity matrix sequences at each rep - that way I can
% reliably recreate the population trajectories without re - running
% everything
mpaSelCTTowns = cell(nRepsCT, 1);
randSeqCTTowns = cell(nRepsCT, 3);

% also, the costs will be the areas, and the resources will be 30% of the
% entire area
resourcesCTTowns = 0.3 * sum(areasCTTowns);

% time stuff
tic

% loop over each run and construct the portfolios only
for r = 1:nRepsCT

    % run the metapopulation model for the warmup period
    randStruct.sequence = randi(nMatsCT, 1, tWarmup - 1);
    randSeqCTTowns{r, 1} = randStruct.sequence;
    popMatWarmup = baseMetapopModel(conMatsCTTowns, areasCTTowns, ...
        popInitCTTowns, tWarmup, specStructCT, randStruct);

    % run the metapopulation model for the observational period
    randStruct.sequence = randi(nMatsCT, 1, tObs - 1);
    randSeqCTTowns{r, 2} = randStruct.sequence;
    popMatObs = baseMetapopModel(conMatsCTTowns, areasCTTowns, ...
        squeeze(popMatWarmup(:, :, end)), tObs, specStructCT, ...
        randStruct);

    % convert the age structured population trajectories into a single,
    % size class weighted sum
    biomassMat = convertAgeClasses(popMatObs, massVecCT);

    % calculate the MPA networks
    boundVals = zeros(2, 2);
    mpaSelCTTowns{r} = cell(1, 7);
    [mpaSelCTTowns{r}{1}, boundVals(1, 2), boundVals(2, 2)] = applyMPT( ...
        biomassMat, 1, "discrete", resourcesCTTowns, areasCTTowns);
    [mpaSelCTTowns{r}{5}, boundVals(1, 1), boundVals(2, 1)] = applyMPT( ...
        biomassMat, 0, "discrete", resourcesCTTowns, areasCTTowns);
    mpaSelCTTowns{r}{2} = applyMPT(biomassMat, 0.75, "discrete", ...
        resourcesCTTowns, areasCTTowns, boundVals);
    mpaSelCTTowns{r}{3} = applyMPT(biomassMat, 0.5, "discrete", ...
        resourcesCTTowns, areasCTTowns, boundVals);
    mpaSelCTTowns{r}{4} = applyMPT(biomassMat, 0.25, "discrete", ...
        resourcesCTTowns, areasCTTowns, boundVals);

    % form the random portfolio, and the zero portfolio
    reefSeq = randperm(nReefsCTTowns);
    mpaSelCTTowns{r}{6} = zeros(1, nReefsCTTowns);
    for i = 1:nReefsCTTowns
        randPortTemp = mpaSelCTTowns{r}{6};
        randPortTemp(reefSeq(i)) = 1;
        if randPortTemp * areasCTTowns < resourcesCTTowns
            mpaSelCTTowns{r}{6} = randPortTemp;
        end
    end
    mpaSelCTTowns{r}{7} = zeros(1, nReefsCTTowns);

    % select a sequence of connectivity matrices for the final time period,
    % which will be the same across all portfolio samples
    randStruct.sequence = randi(nMatsCT, 1, tFinal - 1);
    randSeqCTTowns{r, 3} = randStruct.sequence;

    % every 10 iterations print the time and save the results
    if mod(r, 10) == 0
        disp(r)
        toc
        currTime = toc;
        save matlabTownsExp.mat mpaSelCTTowns randSeqCTTowns
    end

end

% save the results
save matlabTownsExp.mat mpaSelCTTowns randSeqCTTowns resourcesCTTowns

% clear some of the redundant variables
clear popMatCell popMatWarmup popMatObs
