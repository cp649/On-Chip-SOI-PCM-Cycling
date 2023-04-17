% HSVImFilter takes in an RGB image with low and high values for hue on 0
% to 1 scale and returns a binary mask of where the pixels fall within the
% designated hue values along with the RGB mean values for the pixels
% within the mask as well as outside the mask (denoted as meanMask and
% meanBckg respectively.
function [mask, meanMask,meanBckg] = HSVImFilter(image, low_hue,high_hue)
    [row,col,~]=size(image);
    hsvDomainImg = rgb2hsv(image);
    image= double(image);
    mask =zeros(row,col);
    for x = 1:row
        for y = 1:col
            if((hsvDomainImg(x,y,1)<high_hue) && (hsvDomainImg(x,y,1)>low_hue))
                % filter using hsv to see if you are between the hue
                % values. Initially yellow and green.
                mask(x,y)=1;
            end
        end
    end
    meanMask = sum(sum(repmat(mask,[1,1,3]).*image))./(sum(sum(mask)));
    maskBckg = -mask+1;
    meanBckg = sum(sum(repmat(maskBckg,[1,1,3]).*image))./(sum(sum(maskBckg)));
end