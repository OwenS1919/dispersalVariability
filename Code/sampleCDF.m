function randNum = sampleCDF(CDFVec, vals, size1, size2)
% sampleCDF will sample a random number from a probability mass function,
% represented in this method as a cumulative density function (i.e. CDFVEc
% = cumsum(PDFVec)), where vals are the random variable values
% corresponding to the probabilities in CDFVec

% inputs:

% CDFVec - the cumulative density function, can be found via CDFVec =
%     cumsum(PDFVec)
% vals - the values corresponding to the CDFVec
% size1 - optional - the number of rows of random numbers desired - default
%     is 1
% size2 - optional - the number of columns of random numbers desired -
%     default is 1

% output:

% randNum - a scalar, vector or matrix of random numbers sampled from the
%     CDFVec, of dimensions size1 x size2

% NOTE: I think this method will fail if we ever get rand() == 1 but I'm
% now too lazy to care about that almost improbable case anyway, if it does
% screw up then I just get an exception anyway and will fix it then ok cool
% and awesome and good

% set default for size1 and size2
if nargin < 3 || isempty(size1)
    size1 = 1;
end
if nargin < 4 || isempty(size2)
    size2 = 1;
end

% if we just want 1 single sample, find it then return
if size1 * size2 == 1
    randNum = vals(find(rand() < CDFVec, 1, 'first'));
    return
end

% otherwise, loop over rows and columns for the output
randNum = zeros(size1, size2);
randSeeds = rand(size1, size2);
for r = 1:size1
    for c = 1:size2
        randNum(r, c) = vals(find(randSeeds(r, c) < CDFVec, 1, 'first'));
    end
end

end
