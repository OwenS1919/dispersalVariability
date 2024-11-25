function writeParfevalCode(seqCodeString, futureVecString, nReps, ...
    splitDims, splitVarsStrings)
% writeParfevalCode() is kind of genius if I do say so myself - it will
% take in code which runs a function sequentially, and then convert this
% code into a parallelised version using parfeval

% inputs:

% seqCodeString - a string containing the code to be converted, must be a
    % single line of code which runs a function
% futureVecString - optional - the name of the futureVec to create, i.e. a
    % vector containing the futures for each parfeval task
% nReps - optional - the number of times the parfeval function is called -
    % default is 1, i.e. no repeats
% splitDims - optional - an array used for splitting inputs into parallel
    % chunks, of the form [totalDim, nSplits], where totalDim is the length
    % of the dimension to split down and splitDims is the number of splits
    % to take - default is [], i.e. no splitting
% splitVarsStrings - optional - a string array of the variables to split
    % the above on, with the form varName_nDims_splitDim, e.g. for an array
    % called "cellArray1" with 3 dimensions, the middle of which is to be
    % split on, use "cellArray1_3_2" - default is [];

% I will write the code which can also split up input arrays at a later
% date because that's a screw - around

% set a defaults
if nargin < 2 || isempty(futureVecString)
    futureVecString = "futureVec1";
end
if nargin < 3 || isempty(nReps)
    nReps = 1;
end
if nargin < 4
    splitDims = [];
end
if nargin < 5
    splitVarsStrings = [];
end

% send a warning if trying to split and repeat
if nReps > 1 && ~isempty(splitDims)
    error("Code does not currently support the splitting and repeating of " + ...
        "code");
end

% split the string across the eqauls sign, and extract the function call
% section and the output variables section
splitString = split(seqCodeString, "=");
outVarsString = splitString(1);
funcCallString = splitString(2);

% determine the number of output vars
numOutVars = length(split(outVarsString, ","));

% extract the name of the function itself, along with the input variables
splitString = split(funcCallString, "(");
funcNameString = strtrim(splitString(1));
splitString = split(funcCallString, funcNameString + "(");
inVarsString = splitString(2);

% write the section which will cancel any active futures
checkCancelString = "if exist('" + futureVecString + "', 'var')\n" + ...
    "    cancelFutureVec(" + futureVecString + ");\n    clear " ...
    + futureVecString + "\nend\n";

% write the section which will run the parfeval
runParfevalString = futureVecString + "(1) = parfeval(@" ...
    + funcNameString + ", " + num2str(numOutVars) + ", " + inVarsString ...
    + "\n";

% split the inputs of the above if necessary
if ~isempty(splitDims)

    % send an error if the splitDims don't match
    if splitDims(2) > splitDims(1)
        error("input splitDims is incorrect, as splitDims(2) > " + ...
            "splitDims(1)")
    end

    % calculate the number of indices each split will process
    splitLengths = zeros(splitDims(2), 1);
    splitLengths(1:(end-1)) = ceil(splitDims(1) / splitDims(2));
    if ceil(splitDims(1) / splitDims(2)) == splitDims(1) / splitDims(2)
        splitLengths(end) = splitDims(1) / splitDims(2);
    else
        splitLengths(end) = mod(splitDims(1), ceil(splitDims(1) / ...
            splitDims(2)));
    end

    % calculate the start and end indices of each of the splits
    splitIndices = zeros(splitDims(2), 2);
    splitIndices(1, 1) = 1;
    splitIndices(1, 2) = splitLengths(1);
    for i = 2:splitDims(2)
        splitIndices(i, 1) = splitIndices(i-1, 2) + 1;
        splitIndices(i, 2) = splitIndices(i, 1) + splitLengths(i) - 1;
    end

    % store the original line of code, and then begin to split from it
    runParfevalStringOG = runParfevalString;

    % write a loop which will hold the indices for the splitting
    indSetString = "ind = {";
    for i = 1:(length(splitIndices) - 1)
       indSetString = indSetString + num2str(splitIndices(i, 1)) + ":" ...
           + num2str(splitIndices(i, 2)) + ", ";
    end
    indSetString = indSetString + num2str(splitIndices(i, 1)) + ":" ...
           + num2str(splitIndices(i, 2)) + "};\n";
    indSetString = justifyString(indSetString, 0);

    % write the inner part of the loop, first replace the index of the
    % futureVec and space out the tabs
    runParfevalString = strrep(runParfevalStringOG, "(1)", "(i)");
    runParfevalString = "\t" + runParfevalString;

    % go through and update the indexing of any of the input variables
    for j = 1:length(splitVarsStrings)

        % extract the relevant information for the current variable
        varInfo = split(splitVarsStrings(j), "_");

        % find and replace this variable's indices
        indicesReplace = strings(1, str2num(varInfo(2)));
        if str2num(varInfo(2)) > 1
            indicesReplace(1:end-1) = ":, ";
            indicesReplace(end) = ":";
            indicesReplace(str2num(varInfo(3))) = strrep( ...
                indicesReplace(str2num(varInfo(3))), ":", ...
                "ind{i}");
        else
            indicesReplace(1) = "ind{i}";
        end
        indicesReplace = strjoin(indicesReplace, "");
        runParfevalString = strrep(runParfevalString, varInfo(1), ...
            varInfo(1) + "(" + indicesReplace + ")");

    end

    % split across lines if necessary
    runParfevalString = justifyString(runParfevalString, 1);

    % join the parfeval strings together, with a for loop encapsulating the
    % code
    runParfevalString = indSetString + "for i = 1:" ...
        + num2str(splitDims(2)) + "\n" + runParfevalString + "end\n";

elseif nReps > 1

    % repeat the above if nReps > 1 using a for loop
    if nReps > 1
        runParfevalString = strrep(runParfevalString, "(1)", "(i)");
        runParfevalString = justifyString(runParfevalString, 1);
        runParfevalString = "for i = 1:" + num2str(nReps) + "\n    " ...
            + runParfevalString + "end\n";
    end

else

    % split across lines if not splitting inputs
    runParfevalString = justifyString(runParfevalString, 0);

end

% write line which will extract the outputs
extractVarsString = "\t" + outVarsString +  "= fetchOutputs(" + ...
    futureVecString + "(1));\n";

% split the above if inputs are being split
if ~isempty(splitDims)

    % replace the index of the futureVec
    extractVarsString = strrep(extractVarsString, futureVecString ...
        + "(1)", futureVecString + "(i)");

    % swap cases if we have multiple output variables
    suffixString = "{i}";
    if numOutVars > 1

        % find and replace the names of the output variables to reflect
        % the indices they cover
        splitString = split(outVarsString, ",");
        for j = 1:(numOutVars - 1)
            extractVarsString = strrep(extractVarsString, ...
                splitString(j), splitString(j) + suffixString);
        end
        extractVarsString = strrep(extractVarsString, ...
            "]", suffixString + "]");

    else

        % replace the output of the single output variable
        splitString = split(outVarsString, " ");
        extractVarsString = strrep(extractVarsString, ...
            splitString(1), splitString(1) + suffixString);

    end

    % split across lines if necessary
    extractVarsString = justifyString(extractVarsString, 2);

    % join the extract variables strings together using a for loop
    extractVarsString = "    for i = 1:" + num2str(splitDims(2)) + "\n    " ...
        + extractVarsString + "    end\n";

elseif nReps > 1

    % repeat the extraction process
    extractVarsString = strrep(extractVarsString, futureVecString + "(1)", ...
        futureVecString + "(i)");
    suffixString = "{i}";
    if numOutVars > 1

        % replace output variables with cell arrays
        splitString = split(outVarsString, ",");
        for j = 1:(numOutVars - 1)
            extractVarsString = strrep(extractVarsString, splitString(j), ...
                splitString(j) + suffixString);
        end
        extractVarsString = strrep(extractVarsString, "]", suffixString ...
            + "]");

    else

        % replace the output of the single output variable
        splitString = split(outVarsString, " ");
        extractVarsString = strrep(extractVarsString, ...
            splitString(1), splitString(1) + suffixString);

    end

    % justify the results and add a for loop wrapper
    extractVarsString = justifyString(extractVarsString, 2);
    extractVarsString = "    for i = 1:" + num2str(nReps) + "\n    " ...
        + extractVarsString + "    end\n";

else

    % otherwise, just split code across lines if not splitting inputs
    extractVarsString = justifyString(extractVarsString, 1);

end

% write the section which will extract the outputs
outExtractString = "if checkFutureVec(" + futureVecString + ")\n" + ...
    extractVarsString + "    %% clear " + futureVecString + "\nend\n";

% finally, join all of these strings together and print
finalString = "\n" + "%% ensure parallel processes are cancelled\n" ...
    + checkCancelString + "\n" + "%% run in parallel\n" + runParfevalString ...
    + "\n" + "%% extract results\n" + outExtractString + "\n";
fprintf(finalString)

end

% write a function which can split things across multiple lines
function stringOut = justifyString(string, currLevels)

% replace tabs with a space of similar length
tabString = "    ";
if currLevels == 0
    tabString2 = tabString;
elseif currLevels == 1
    tabString2 = tabString + tabString;
elseif currLevels == 2
    tabString2 = tabString + tabString + tabString;
end
string = strrep(string, "\t", tabString);
    
% check the length of the current string, exit if it isn't too long
lineMax = 75;
if length(char(string)) <= lineMax
    stringOut = string;
    return
end

% otherwise, we need to start splitting lines - figure out the first space
% closest to 75
ctr = 1;
stringLines(1) = string;
while length(char(stringLines(ctr))) > lineMax

    % for the current line, find the space closest to column 75 and insert
    % a line break
    spaceInd = strfind(stringLines(ctr), " ");
    targetInd = find(spaceInd <= 75, 1, "last");
    targetInd = spaceInd(targetInd);
    stringLines(ctr + 1) = tabString2 + extractAfter(stringLines(ctr), ...
        targetInd);
    stringLines(ctr) = extractBefore(stringLines(ctr), targetInd + 1) ...
        + "... \n";
    ctr = ctr + 1;
end

% now, simply concatenate all the strings
stringOut = strjoin(stringLines, "");

end
