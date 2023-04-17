function [Data] = GetImageThorCam(cam,Width, Height, Bits,MemId)
cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
% Copy image from memory
[~, tmp] = cam.Memory.CopyToArray(MemId);

% Reshape image
Data = reshape(uint8(tmp),[Bits/8, Width, Height]);
Data = Data(1:3 , 1:Width , 1:Height);
Data = permute(Data,[3,2,1]);

end