clear all; clc;
fileDiruc480 = 'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\';
addpath(fileDiruc480)

%Add NET assembly
% May need to change specific location of library
NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll')

% Create camera object handle
cam = uc480.Camera;

% Open the first available camera
cam.Init(0);

% Set display mote to bitmap (DiB)
cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);

%Set color mode to 8-bit RGV
cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw16);

% Set trigger mode to software (single image acquisition);
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
% for i =1:20
% Allocate image memory
[~,MemId] = cam.Memory.Allocate(true);
cam.Timing.Exposure.Set(71);
cam.Gain.Hardware.Scaled.SetMaster(0)
cam.Gain.Hardware.Scaled.SetBlue(40)
cam.Gain.Hardware.Scaled.SetRed(0);
cam.Gain.Hardware.Scaled.SetGreen(0);
cam.Gain.Hardware.Scaled.SetBlue(40);
% Obtain image information
[~, Width,Height, Bits, ~] = cam.Memory.Inquire(MemId);
%%
% Acquire image
cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw16);
% cam.PixelFormat.Set(uc480.Defines.ColorMode.UYVYBayerPacked);
while(true)
% cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
cam.Acquisition.Capture(uc480.Defines.DeviceParameter.Wait);
% Copy image from memory
[~, tmp] = cam.Memory.CopyToArray(MemId);

% Reshape image
Data = reshape(uint16(tmp),[Bits/8, Width, Height]);
Data = Data(1:3 , 1:Width , 1:Height);
Data = permute(Data,[3,2,1]);

% Display Image
himg = imshow(cat(3,Data(:,:,3),Data(:,:,2),Data(:,:,1))*255);
title(datestr(datetime))
pause(0.001)
end
% title(num2str(i));
% end
%%
% Close camera
cam.Exit;

