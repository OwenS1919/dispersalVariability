function cancelFutureVec(futureVec)
% cancelFutureVec is a helper function I am writing to help me cancel all
% processes inside of futureVec which are still running

% this is useful each time a new set of parfeval commands is to be run, to
% ensure the old 

% input:

% futureVec - a vector of parallel.Future objects, alternatively if
    % futureVec is left as empty or not specified at all, the method will
    % output some relevant code which can be used to set up an if statement
    % around this function
    % if futureVec is set as a string, the relevant code will occur with
    % the string as the name of the object

% NOTE: at some point, need to figure out how to free up the memory used by
% the parallel workers

% print out the relevant code if futureVec is empty or a string
if nargin == 0 || isempty(futureVec)
    fprintf("if exist('futureVec', 'var')\n\tcancelFutureVec(futureVec);\n" ...
        + "\tclear futureVec\nend\n")
    return
elseif isstring(futureVec)
    fprintf("if exist('" + futureVec + "', 'var')\n\tcancelFutureVec(" ...
        + futureVec + ");\n\tclear " + futureVec + "\nend\n")
    return
end

% if nothing is running, return a message saying there is no need for
% cancellation
numFin = 0;
for i = 1:length(futureVec)
    if futureVec(i).State == "finished"
        numFin = numFin + 1;
    end
end
if numFin == length(futureVec)
    fprintf("All futures finished or cancelled.\n")
    return
end

% otherwise, cancel the results and print a message
cancel(futureVec);
fprintf("Futures cancelled.\n")

end