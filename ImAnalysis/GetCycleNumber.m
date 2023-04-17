function [cyc] = GetCycleNumber(fileNameString)
    ncs = strfind(fileNameString,'_cyc')+4;
    nce = strfind(fileNameString,'_t')-1;
    if (~isempty(ncs )) && (~isempty(nce))
        cyc = uint16(str2num(fileNameString(ncs:nce)));
    else
        cyc = -2;
    end
end