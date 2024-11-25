function clearVarsText = clearVars()
% clearVars() will create a string of the variables I want to clear before
% exiting matlab, to clear then just do eval(clearVars())

% output:

% clearVarsText - a string that holds the text "clear var1 var2 ... " that
    % can then just be eval'd to clear a bunch of temporary variables I
    % often use

% list all the variables, then join them with a clear statement
clearVarsArray = ["i", "j", "k", "r", "m", "n", ...
    "a", "b", "c", "d", "f", "g", "h", ...
    "l", "q", "s", "x", "y", "z", "t", ...
    "tL", ...
    "test", "test1", "test2", "test3", "test4", "test5", "test6", "test7", ...
    "test8", "test9", "test10", ...
    "var", "var1", "var2", "var3", "var4", "var5", "var6", "var7", ...
    "var8", "var9", "var10", ...
    "ind", "ctr", "temp", "idx", "ans", "clearVarsCell", "nReps", ...
    "initVals", "vals", "inds"];
clearVarsText = "clear " + strjoin(clearVarsArray, " ");

end
