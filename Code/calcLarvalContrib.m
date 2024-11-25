function larvalContMat = calcLarvalContrib(popMat, fecundVec, conMats)
% calcLarvalContrib() will calculate the larval contribution from each reef
% at each timestep, where larval contribution simply corresponds to the
% total larvae from a reef that will successfully settle on a reef

% inputs:

% popMat - a 3d array where popMat(i, j, k) indicates the population of the
    % jth age class on the ith reef, at the kth timestep (does not include
    % the initial condition)
% fecundVec - a vector containing the fecundity of each age class
% conMats - a connectivity matrix representing the system to be modelled,
    % where conMat(i, j) represents the probability that larvae released
    % from reef i will settle at reef j, can also be a 1D cell array
    % containing multiple connectivity matrices, which are used based on
    % the guidelines in randStruct

% output:

% larvalContMat - a matrix for which larvalContMat(i, k) represents the
    % larval contribution of the ith reef in the kth timestep

% determine the number of reefs, timesteps, and connectivity matrices
nReefs = size(popMat, 1);
nTimes = size(popMat, 3);
nMats = length(conMats);

% if we just have a single matrix, convert it into a cell array so that the
% rest of the code can work in the same way because I'm lazy :)
if nMats < nTimes || class(conMats) == "double"
    conMatsTemp = cell(1, nTimes);
    for t = 1:nTimes
        conMatsTemp{t} = conMats;
    end
    conMats = conMatsTemp;
    clear conMatsTemp
    nMats = nTimes;
end

% create summed versions of the outgoing connectivity for each of the
% reefs, so that the multiplications later are easier
conMatsSummary = zeros(nReefs, nMats);
for t = 1:nMats
    conMatsSummary(:, t) = sum(conMats{t}, 2);
end

% loop over each of the timesteps and calculate the larval contribution of
% each reef
larvalContMat = zeros(nReefs, nTimes);
for t = 1:nTimes
    currPop = squeeze(popMat(:, :, t));
    larvalContMat(:, t) = conMatsSummary(:, t) .* (currPop * fecundVec');
end

end