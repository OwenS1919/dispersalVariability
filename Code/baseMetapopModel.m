function popMat = baseMetapopModel(conMat, areaVec, popInit, tMax, ...
    specStruct, randStruct, actionStruct)
% baseMetapopModel() will run a metpopulation model based on the model
% presented in "Surrogates for reef fish connectivity when designing marine
% protected area networks" (Bode et al., 2012)

% this function will serve as a base model, for which parent functions for
% each species can call - as a result, it will be pretty gross and have a
% lot of inputs, but oh well

% inputs:

% conMat - a connectivity matrix representing the system to be modelled,
    % where conMat(i, j) represents the probability that larvae released
    % from reef i will settle at reef j, can also be a 1D cell array
    % containing multiple connectivity matrices, which are used based on
    % the guidelines in randStruct
% areaVec - a vector containing the amount of reef habitat on each reef
% popInit - the initial population, where popInit(i, j) corresponds to the
    % population in age class j at reef i
% tMax - the number of timesteps to run the model for (not including the
    % initial timestep)
% specStruct - a structure, with the species specific fields:
    % successVec - where successVec(i) is the proportion of individuals in
        % the ith age class who will survive and progress to the ith age
        % class, with no entry for the final age class (i.e. is of length
        % one less than number of age classes)
    % alpha - the alpha parameter for the Beverton - Holt equation for
        % settlers
    % beta - the beta parameter for the Beverton - Holt equation for
        % settlers
    % fecundVec - a vector containing the fecundity of each age class
% randStruct - optional - a structure which holds fields regarding how
    % stochasticity is to be incorporated into the model, with the fields:
    % randType - determines the type of randomness applied, with
        % "randSelection" indicating a matrix is randomly selected from the
        % conMat cell array, "randPert" indicating that the single conMat
        % supplied should be randomly perturbed, and "sequence" indicating
        % the matrices are to be used in a sequence - dedault is "sequence"
    % pertFact - a factor indicating the amount to which elements of the
        % conMat should be randomly perturbed -> will finish setting this
        % up later
    % sequence - the sequence to use for the matrices, and will only be
        % used if the randType = "sequence"
% actionStruct - optional - a structure, with fields indicating the
    % conservation action being undertaken:
    % type - the type of action being taken, "MPA" for MPA reserves, more
        % to be added soon
    % actionVec - a vector indicating where and with what intensity actions
        % are being undertaken - for MPAs, this is just a binary vector
        % indicating which reefs are being designated MPAs
    % actionEffect - the effect of taking an action, for MPAs this will be
        % be a vector indicating the new successVec to be applied to reefs
        % inside the MPA network

% outputs:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep (does not include
    % the initial condition)

% because I'm lazy, I'm going to allow this method to take in a structure
% as the first argument which will hold the first three arguments
if class(conMat) == "struct"
    areaStruct = conMat;
    conMat = areaStruct.conMats;
    areaVec = areaStruct.areas;
    popInit = areaStruct.initPop;
end

% set defaults for randStruct, and determine the number of reefs
if class(conMat) == "cell"
    nReefs = size(conMat{1}, 1);
    if nargin < 6 || isempty(randStruct)
        randStruct = struct();
        randStruct.randType = "sequence";
        randStruct.sequence = 1:tMax;
    end
else
    nReefs = size(conMat, 1);
    if nargin < 6 || isempty(randStruct)
        randStruct = struct();
        randStruct.randType = "none";
    end
end

% set a default of uniform areas
if nargin < 2 || isempty(areaVec)
    areaVec = ones(nReefs, 1);
end

% set a default for actionStruct
if nargin < 7 || isempty(actionStruct)
    actionStruct.type = "none";
end

% extract the necessary species - specific information from the specStruct
successVec = specStruct.successVec;
alpha = specStruct.alpha;
beta = specStruct.beta;
fecundVec = specStruct.fecundVec;

% ensure variables are of the correct orientation
if size(fecundVec, 1) < size(fecundVec, 2)
    fecundVec = fecundVec';
end
if size(successVec, 1) > size(successVec)
    successVec = successVec';
end
if size(areaVec, 2) > size(areaVec, 1)
    areaVec = areaVec';
end

% determine the number of reefs and age classes
nAges = length(successVec) + 1;

% initialise the storage vectors, which will store the densities at each
% reef, for each age class and time, and set the initial populations
denseMat = zeros(nReefs, nAges, tMax + 1);
denseMat(:, :, 1) = popInit ./ areaVec;
settleVec = zeros(nReefs, 1);

% to avoid if statements in the below loop, generate the connectivity
% matrix sequence applied here
conMatCell = cell(1, tMax);
if randStruct.randType == "randSelection"

    % for random selection, just choose a random sequence of numbers with
    % replacement, and set up the conMatCell in the same way
    nMats = length(conMat);
    for t = 1:tMax
        conMatCell{t} = conMat{randi(nMats)};
    end

elseif randStruct.randType == "randPert"

    % code up later -> don't know about this shit

elseif randStruct.randType == "sequence"

    % check if the current sequence is long enough to accomodate all years
    if length(randStruct.sequence) < tMax

        % if it isn't, we will just replicate the pattern
        nMats = length(conMat);
        for t = 1:tMax
            conMatCell{t} = conMat{randStruct.sequence(mod(t - 1, ...
                length(randStruct.sequence)) + 1)};
        end

    else

        % otherwise, just copy over to conMatCell
        conMatCell = cell(1, tMax);
        for t = 1:tMax
            conMatCell{t} = conMat{randStruct.sequence(t)};
        end

    end

else

    % the only other possibility is that none of the above have been
    % specified, and in this case we'e only been supplied a single
    % connectivity matrix, and so should just replicate it
    for t = 1:tMax
        conMatCell{t} = conMat;
    end

end

% setup the succesMat, to hold the succession probabilities for each
% different reef
if actionStruct.type == "MPA"
    successMat = zeros(nReefs, nAges - 1);
    for r = 1:nReefs
        if actionStruct.actionVec(r) > 0
            successMat(r, :) = actionStruct.actionEffect;
        else
            successMat(r, :) = successVec;
        end
    end
else
    successMat = repmat(successVec, [nReefs, 1]);
end

% iterate through the timesteps
for t = 1:tMax

    % calculate the larval output from each reef
    larvOut = denseMat(:, :, t) * fecundVec;

    % calculate the density of settlers at each reef -> check that this
    % setup makes sense
    for r = 1:nReefs
        settleVec(r) = sum(conMatCell{t}(:, r) .* areaVec .* larvOut) ...
            / areaVec(r);
    end

    % apply the Beverton - Holt form for the settlement survival
    denseMat(:, 1, t + 1) = alpha * settleVec ./ (1 + beta * settleVec);

    % apply the age structure progression
    denseMat(:, 2:end, t + 1) = denseMat(:, 1:(end - 1), t) .* ...
        successMat;

end

% need to convert the above entries in denseMat from the densities they
% currently represent, back into true population values
popMat = denseMat .* areaVec;

% remove the first page of values, as they correspond to the IC
popMat = popMat(:, :, 2:end);

end
