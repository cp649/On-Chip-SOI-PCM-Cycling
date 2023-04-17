function LastCycle = GetLastCycle(fileNames)
    totalFiles = numel(fileNames);
    for nn = totalFiles:-1:1
        if (GetCycleNumber(fileNames(nn).name)>0)
            LastCycle = GetCycleNumber(fileNames(nn).name);
            break;
        end
    end

end