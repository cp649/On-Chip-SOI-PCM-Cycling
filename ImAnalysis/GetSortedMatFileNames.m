% Obtained from https://www.mathworks.com/matlabcentral/answers/442520-how-to-sort-the-files-in-a-folder-by-date
function fileNames = GetSortedMatFileNames(filePath)
S = dir(fullfile(filePath,'*mat'));
S = S(~[S.isdir]);
[~,idx] = sort([S.datenum]);
fileNames = S(idx);
end