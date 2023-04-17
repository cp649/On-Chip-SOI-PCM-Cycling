function [imgData] = GetScreenshot(pos)

% Take screen capture
robot = java.awt.Robot();
if nargin == 0
    dual=get(0,'MonitorPositions');
    if isequal(size(dual),[3,4])
        farthestScreen = find(dual(:,1)==max(dual(:,1)));
        fS = farthestScreen;
        pos = [dual(fS,1), 0, dual(fS,3),dual(fS,4)]; % [left top width height]
    else
        pos = dual(2,:);
    end
end
rect = java.awt.Rectangle(pos(1),pos(2),pos(3),pos(4));
cap = robot.createScreenCapture(rect);
% Convert to an RGB image
rgb = typecast(cap.getRGB(0,0,cap.getWidth,cap.getHeight,[],0,cap.getWidth),'uint8');
imgData = zeros(cap.getHeight,cap.getWidth,3,'uint8');
imgData(:,:,1) = reshape(rgb(3:4:end),cap.getWidth,[])';
imgData(:,:,2) = reshape(rgb(2:4:end),cap.getWidth,[])';
imgData(:,:,3) = reshape(rgb(1:4:end),cap.getWidth,[])';

end