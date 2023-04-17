function [cam, Width, Height, Bits,MemId]=InitializeThorCam()

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
cam.PixelFormat.Set(uc480.Defines.ColorMode.RGB8Packed);

% Set trigger mode to software (single image acquisition);
cam.Trigger.Set(uc480.Defines.TriggerMode.Software);
% for i =1:20
% Allocate image memory
[~,MemId] = cam.Memory.Allocate(true);
cam.Timing.Exposure.Set(50);
% Obtain image information
[~, Width,Height, Bits, ~] = cam.Memory.Inquire(MemId);
end