% implementation 2 - downscaling image with constant sigma
tic
img = imread('../data/einstein.jpg');
img = im2double(img);
img = rgb2gray(img);

intitalsigma =	3;
sigma = intitalsigma;
kfactor = 4;
levels = 3;

imageSize = size(img);
scale_space = zeros(imageSize(1),imageSize(2),levels);
finalFilter = (sigma*sigma) * (fspecial('log',19,3));
filterImage = img;
for i = 1:levels      
    filterResponse = imfilter(filterImage,finalFilter,'same','replicate');
    filterResponse = filterResponse.*filterResponse;
    filterResponse = imresize(filterResponse,imageSize,'bicubic');
    scale_space(:,:,i) = filterResponse;
%     disp(size(scale_space(:,:,i)));
    filterImage = imresize(img,1/(kfactor^i),'bicubic');    
end

new_space = zeros(imageSize(1),imageSize(2),levels);
% temp = scale_space(:,:,3);
% disp(temp(1:6,1:6));

for i = 1:levels
    temp_space = scale_space(:,:,i);
    temp_space2 = ordfilt2(temp_space,9,ones(3,3));
    new_space(:,:,i) = temp_space2;
end
% temp2 = new_space(:,:,3);
% disp(temp2(1:6,1:6));

new_space = scale_space .* (new_space == scale_space);
% temp3 = new_space(:,:,3);
% disp(temp3(1:6,1:6));
% figure
% subplot(1,2,2);
% hist(new_space(:,:,2));

% Threshold supression
threshold = 0.007;
finalRows = [];
finalCols = [];
finalRadii = [];
for i = 1:levels
    [row, col] = find(new_space(:,:,i)>=threshold);
    len = size(row);
    for j = 1 : len
        [~, lev] = max(new_space(row(j),col(j),:));
        sigmaTemp = intitalsigma * kfactor^(lev-1);
        radii = sigmaTemp * sqrt(2);
        finalRows = cat(1,finalRows,row(j));
        finalCols = cat(1,finalCols,col(j));
        finalRadii = cat(1,finalRadii,radii);
    end   
end


%  imgFinal = imread('../data/butterfly.jpg');
show_all_circles(img, finalCols, finalRows, finalRadii);
toc