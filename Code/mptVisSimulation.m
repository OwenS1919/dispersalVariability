function [portPerfMPT, portPerfRand] = mptVisSimulation(conMats, areas, ...
    popInit, resources, randSeq, mpaSel, specStruct, actionEffect, r)
% MPTVisSimulation is useful because this is a metric shitton of code that
% I don't really need to be having in my live scripts - it just runs a
% simulation which allows you to visualise the performance of randomly
% selected portfolios vs MPT solutions

% inputs:

% conMats - a cell array containing the relevant connectivity matrices
% areas - a vector containing the areas of each reef
% popInit - an initial population to run the simulation using
% randSeq - a cell array, where randSeq{r, 1} contains the sequence of
    % connectivity matrices used in the warmup period, randSeq{r, 2}
    % contains the sequence of connectivity matrices used in the
    % observational period, and randSeq{r, 3} contains the the sequence of
    % matrices for the final period idfk, all of which for the rth
    % repetition of the original experiment
% mpaSel - a cell array where mpaSel{r}{1} contains the first MPA network
    % selected during the rth repetition
% specStruct - see baseMetapopModel
% actionEffect - for MPA selection, this is a vector of the altered
    % succession probabilities for reefs deemed MPAs
% r - the repetition to apply this experiment to

% outputs:

% portPerfMPT - fuck idk man I'm in a rush just look at the bottom of the
    % script hehe
% portPerfRand - see above

% set the number of random portfolios, and a number of other important
% things
nRand = 75;
tWarmup = length(randSeq{r, 1}) + 1;
tObs = length(randSeq{r, 2}) + 1;
tFinal = length(randSeq{r, 3}) + 1;
weightVec = specStruct.weightings;
nReefs = size(conMats{1}, 1);

% start by just initialising a bunch of stuff
portPerfRandSel = zeros(1, nRand);
portVarRandSel = zeros(1, nRand);
portPerfMPTSel = zeros(1, 5);
portVarMPTSel = zeros(1, 5);
portPerfRandHist = zeros(1, nRand);
portVarRandHist = zeros(1, nRand);
portPerfMPTHist = zeros(1, 5);
portVarMPTHist = zeros(1, 5);
portPerfRandProsp = zeros(1, nRand);
portVarRandProsp = zeros(1, nRand);
portPerfMPTProsp = zeros(1, 5);
portVarMPTProsp = zeros(1, 5);

% setup the randStruct and actionStruct variables
randStruct.randType = "sequence";
actionStruct.type = "MPA";
actionStruct.actionEffect = actionEffect;

% run the metapopulation model for the warmup period
randStruct.sequence = randSeq{r, 1};
popMatWarmup = baseMetapopModel(conMats, areas, popInit, tWarmup, ...
    specStruct, randStruct);

% run the metapopulation model for the observational period
randStruct.sequence = randSeq{r, 2};
popMatObs = baseMetapopModel(conMats, areas, ...
squeeze(popMatWarmup(:, :, end)), tObs, specStruct, randStruct);

% calculate some shit and setup some functions
data = convertAgeClasses(popMatObs, weightVec);
expReturns = mean(data, 2);
covariances = cov(data');
expFunc = @(x) x * expReturns;
varFunc = @(x) sum((x' * x) .* covariances, "all");

% form a bunch of random portfolios, and test their performance
mpaSelRand = cell(1, nRand);
for m = 1:nRand
    reefSeq = randperm(nReefs);
    mpaSelRand{m} = zeros(1, nReefs);
    for i = 1:nReefs
        randPortTemp = mpaSelRand{m};
        randPortTemp(reefSeq(i)) = 1;
        if randPortTemp * areas < resources
            mpaSelRand{m} = randPortTemp;
        end
    end
end

% evaluate the performance of the reefs selected using MPT without MPAs
% being introduced
for m = 1:5
    portPerfMPTSel(m) = expFunc(mpaSel{r}{m});
    portVarMPTSel(m) = varFunc(mpaSel{r}{m});
end

% evaluate the performance of the reefs selected randomly without MPAs
% being introduced
for m = 1:nRand
    portPerfRandSel(m) = expFunc(mpaSelRand{m});
    portVarRandSel(m) = varFunc(mpaSelRand{m});
end

% test the retroactive performance of the MPAs formed using MPT
popMatCell = cell(1, 5);
for m = 1:5
    actionStruct.actionVec = mpaSel{r}{m};
    popMatCell{m} = baseMetapopModel(conMats, areas, ...
        squeeze(popMatWarmup(:, :, end)), tObs, specStruct, randStruct, ...
        actionStruct);
end
for m = 1:5
    [~, perfTimed] = objFuncMPA(popMatCell{m}, weightVec);
    portPerfMPTHist(m) = mean(perfTimed);
    portVarMPTHist(m) = var(perfTimed);
end

% test the retroactive performance of the MPAS formed randomly
popMatCell = cell(1, nRand);
for m = 1:nRand
    actionStruct.actionVec = mpaSelRand{m};
    popMatCell{m} = baseMetapopModel(conMats, areas, ...
        squeeze(popMatWarmup(:, :, end)), tObs, specStruct, randStruct, ...
        actionStruct);
end
for m = 1:nRand
    [~, perfTimed] = objFuncMPA(popMatCell{m}, ...
        weightVec);
    portPerfRandHist(m) = mean(perfTimed);
    portVarRandHist(m) = var(perfTimed);
end

% test the future performance of the MPAs formed using MPT
randStruct.sequence = randSeq{r, 3};
popMatCell = cell(1, 5);
for m = 1:5
    actionStruct.actionVec = mpaSel{r}{m};
    popMatCell{m} = baseMetapopModel(conMats, areas, ...
        squeeze(popMatObs(:, :, end)), tFinal, specStruct, ...
        randStruct, actionStruct);
end
for m = 1:5
    [~, perfTimed] = objFuncMPA(popMatCell{m}, weightVec);
    portPerfMPTProsp(m) = mean(perfTimed);
    portVarMPTProsp(m) = var(perfTimed);
end

% test the future performance of the MPAs formed randomly
randStruct.sequence = randSeq{r, 3};
popMatCell = cell(1, nRand);
for m = 1:nRand
    actionStruct.actionVec = mpaSelRand{m};
    popMatCell{m} = baseMetapopModel(conMats, areas, ...
        squeeze(popMatObs(:, :, end)), tFinal, specStruct, randStruct, ...
        actionStruct);
end
for m = 1:nRand
    [~, perfTimed] = objFuncMPA(popMatCell{m}, weightVec);
    portPerfRandProsp(m) = mean(perfTimed);
    portVarRandProsp(m) = var(perfTimed);
end

% convert stuff back into our output variables
portPerfMPT = cell(3, 2);
portPerfRand = cell(3, 2);
portPerfRand{1, 1} = portPerfRandSel;
portPerfRand{1, 2} = portVarRandSel;
portPerfRand{2, 1} = portPerfRandHist;
portPerfRand{2, 2} = portVarRandHist;
portPerfRand{3, 1} = portPerfRandProsp;
portPerfRand{3, 2} = portVarRandProsp;
portPerfMPT{1, 1} = portPerfMPTSel;
portPerfMPT{1, 2} = portVarMPTSel;
portPerfMPT{2, 1} = portPerfMPTHist;
portPerfMPT{2, 2} = portVarMPTHist;
portPerfMPT{3, 1} = portPerfMPTProsp;
portPerfMPT{3, 2} = portVarMPTProsp;

end
