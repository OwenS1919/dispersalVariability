load matlabHonours.mat

% run the simulations :)
nRepsCT = 250;
tWarmup = 100;
tObs = 20;
tFinal = 50;
randStruct = struct();
randStruct.randType = "sequence";
actionStruct.type = "MPA";
actionStruct.actionEffect = successVecCTMPA;
portPerfCTSouth = zeros(nRepsCT, 7);
portPerfCTSouthRetro = zeros(nRepsCT, 7);

% because I'm a genius, I'm gonna store the MPAs created at each rep AND
% the random connectivity matrix sequences at each rep - that way I can
% reliably recreate the population trajectories without re - running
% everything
mpaSelCTSouth = cell(nRepsCT, 1);
randSeqCTSouth = cell(nRepsCT, 3);

% also, the costs will be the areas, and the resources will be 30% of the
% entire area
resourcesCTSouth = 0.3 * sum(areasCTSouth);

% time stuff
tic

% loop over each run
for r = 1:nRepsCT

    % run the metapopulation model for the warmup period
    randStruct.sequence = randi(nMatsCT, 1, tWarmup - 1);
    randSeqCTSouth{r, 1} = randStruct.sequence;
    popMatWarmup = baseMetapopModel(conMatsCTSouth, areasCTSouth, ...
        popInitCTSouth, tWarmup, specStructCT, randStruct);

    % run the metapopulation model for the observational period
    randStruct.sequence = randi(nMatsCT, 1, tObs - 1);
    randSeqCTSouth{r, 2} = randStruct.sequence;
    popMatObs = baseMetapopModel(conMatsCTSouth, areasCTSouth, ...
        squeeze(popMatWarmup(:, :, end)), tObs, specStructCT, ...
        randStruct);

    % convert the age structured population trajectories into a single,
    % size class weighted sum
    biomassMat = convertAgeClasses(popMatObs, massVecCT);

    % run the decision making code to choose the MPAs for each of the
    % options, first calculating the weight = 1 and weight = 0 portfolios,
    % as these will contributed to the boundVals inputs for the following
    % runs
    boundVals = zeros(2, 2);
    mpaSelCTSouth{r} = cell(1, 7);
    [mpaSelCTSouth{r}{1}, boundVals(1, 2), boundVals(2, 2)] = applyMPT( ...
        biomassMat, 1, "discrete", resourcesCTSouth, areasCTSouth);
    [mpaSelCTSouth{r}{5}, boundVals(1, 1), boundVals(2, 1)] = applyMPT( ...
        biomassMat, 0, "discrete", resourcesCTSouth, areasCTSouth);
    mpaSelCTSouth{r}{2} = applyMPT(biomassMat, 0.75, "discrete", ...
        resourcesCTSouth, areasCTSouth, boundVals);
    mpaSelCTSouth{r}{3} = applyMPT(biomassMat, 0.5, "discrete", ...
        resourcesCTSouth, areasCTSouth, boundVals);
    mpaSelCTSouth{r}{4} = applyMPT(biomassMat, 0.25, "discrete", ...
        resourcesCTSouth, areasCTSouth, boundVals);

    % form the random portfolio, and the zero portfolio
    reefSeq = randperm(nReefsCTSouth);
    mpaSelCTSouth{r}{6} = zeros(1, nReefsCTSouth);
    for i = 1:nReefsCTSouth
        randPortTemp = mpaSelCTSouth{r}{6};
        randPortTemp(reefSeq(i)) = 1;
        if randPortTemp * areasCTSouth < resourcesCTSouth
            mpaSelCTSouth{r}{6} = randPortTemp;
        end
    end
    mpaSelCTSouth{r}{7} = zeros(1, nReefsCTSouth);

    % test the retroactive performance of the MPAs
    popMatCell = cell(1, length(mpaSelCTSouth{r}));
    for m = 1:length(mpaSelCTSouth{r})
        actionStruct.actionVec = mpaSelCTSouth{r}{m};
        popMatCell{m} = baseMetapopModel(conMatsCTSouth, areasCTSouth, ...
            squeeze(popMatWarmup(:, :, end)), tObs, specStructCT, ...
            randStruct, actionStruct);
    end

    % evaluate the retroactive performance of the MPA selections
    for m = 1:length(mpaSelCTSouth{r})
        portPerfCTSouthRetro(r, m) = objFuncMPA(popMatCell{m}, massVecCT);
    end

    % select a sequence of connectivity matrices for the final time period,
    % which will be the same across all portfolio samples
    randStruct.sequence = randi(nMatsCT, 1, tFinal - 1);
    randSeqCTSouth{r, 3} = randStruct.sequence;

    % run each of the models for the rest of the testing period
    popMatCell = cell(1, length(mpaSelCTSouth{r}));
    for m = 1:length(mpaSelCTSouth{r})
        actionStruct.actionVec = mpaSelCTSouth{r}{m};
        popMatCell{m} = baseMetapopModel(conMatsCTSouth, areasCTSouth, ...
            squeeze(popMatObs(:, :, end)), tFinal, specStructCT, ...
            randStruct, actionStruct);
    end

    % evaluate the performance of each of the MPA selections
    for m = 1:length(mpaSelCTSouth{r})
        portPerfCTSouth(r, m) = objFuncMPA(popMatCell{m}, massVecCT);
    end

    % every 10 iterations print the time
    if mod(r, 10) == 0
        disp(r)
        toc
        currTime = toc;
    end

end

% now, plot the results for the retroactive approach
names = ["MPT (k = 1)", "MPT (k = 0.75)", "MPT (k = 0.5)", ...
    "MPT (k = 0.25)", "MPT (k = 0)", "Random", "No MPA"];
figure
myBoxPlot(portPerfCTSouthRetro, names)
xlabel("Portfolio Selection Method")
ylabel("Objective Function Performance")
title("Coral Trout Retroactive Portfolio Performance")
figRect(1, 1.2)
% saveFig("CT Portfolio Performance")
darkFig()

% note the difference before in performance before I added the correct
% scaling in the objective function - before, it was clear that the
% variance being minimised was a big deal and hence the expected returns
% were much lower the second the weight < 1

% make a boxplot of the number of reefs chosen
numReefsChosen = zeros(size(portPerfCTSouthRetro));
for m = 1:size(portPerfCTSouthRetro, 2)
    for r = 1:size(portPerfCTSouthRetro, 1)
        numReefsChosen(r, m) = sum(mpaSelCTSouth{r}{m});
    end
end
figure
myBoxPlot(numReefsChosen, names)
xlabel("Portfolio Selection Method")
ylabel("Reefs Chosen")
title("Number of Reefs Chosen Across Methods")
figRect(1, 1.2)
% saveFig("CT Number Reefs Chosen")
darkFig()

% now, plot the results for the retroactive approach
names = ["MPT (k = 1)", "MPT (k = 0.75)", "MPT (k = 0.5)", ...
    "MPT (k = 0.25)", "MPT (k = 0)", "Random", "No MPA"];
figure
myBoxPlot(portPerfCTSouth, names)
xlabel("Portfolio Selection Method")
ylabel("Objective Function Performance")
title("Coral Trout Portfolio Performance")
figRect(1, 1.2)
% saveFig("CT Portfolio Performance")
darkFig()

% note the difference before in performance before I added the correct
% scaling in the objective function - before, it was clear that the
% variance being minimised was a big deal and hence the expected returns
% were much lower the second the weight < 1

% make a boxplot of the number of reefs chosen
numReefsChosen = zeros(size(portPerfCTSouth));
for m = 1:size(portPerfCTSouth, 2)
    for r = 1:size(portPerfCTSouth, 1)
        numReefsChosen(r, m) = sum(mpaSelCTSouth{r}{m});
    end
end
figure
myBoxPlot(numReefsChosen, names)
xlabel("Portfolio Selection Method")
ylabel("Reefs Chosen")
title("Number of Reefs Chosen Across Methods")
figRect(1, 1.2)
% saveFig("CT Number Reefs Chosen")
darkFig()
