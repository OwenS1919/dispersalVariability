function imagescText(mat)
% imagescText is just imagesc, but it will also plot in text the actual
% values which is cool

% input:

% mat - the matrix to be imagesc'd

% do the imagesc command
imagesc(mat)

% put in the actual proportions as text
for i = 1:size(mat, 1)
    for j = 1:size(mat, 2)
        text(j, i, num2str(round(mat(i, j), 3)), ...
            "HorizontalAlignment", "center", "Color", [1, 1, 1])
    end
end

end