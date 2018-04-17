% implementation 1- increase in sigma and filter size
tic
img = imread('../data/einstein.jpg');
img = rgb2gray(img);
img = im2double(img);


% InitialSigma
intialsigma = 3;
sigma = intialsigma;
kfactor = 4;
levels = 3;
imageSize = size(img);
scale_space = zeros(imageSize(1),imageSize(2),levels);

% For scale space
for i = 1:levels
    % Finding filter size
    h = (2*round(3*sigma))+1;
    
%     disp(sigma);
%     disp(h);
    
    finalFilter = (sigma*sigma) * (fspecial('log',h,sigma));
    filterResponse = imfilter(img,finalFilter,'same','replicate');
    
    % imshow(filterResponse);
    % scale_space = cat(3,scale_space,filterResponse);
    scale_space(:,:,i) = filterResponse.*filterResponse;
    %     subplot(3,3,i);
    %     imshow(scale_space(:,:,i));
    sigma = sigma * kfactor;
end
% imshow(scale_space(:,:,2));
% figure
% subplot(1,2,1);
% hist(scale_space(:,:,2));
% Non maximum supression
new_space = zeros(imageSize(1),imageSize(2),levels);
% temp = scale_space(:,:,1);
% disp(temp(1:6,1:6));

for i = 1:levels
    temp_space = scale_space(:,:,i);
    temp_space2 = ordfilt2(temp_space,9,ones(3,3));
    new_space(:,:,i) = temp_space2;
end
% temp2 = new_space(:,:,1);
% disp(temp2(1:6,1:6));

new_space = scale_space .* (new_space == scale_space);
% temp3 = new_space(:,:,1);
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
       
        sigmaTemp = intialsigma * kfactor^(lev(1)-1);
        
        radii = sigmaTemp * sqrt(2);
        finalRows = cat(1,finalRows,row(j));
        finalCols = cat(1,finalCols,col(j));
        finalRadii = cat(1,finalRadii,radii);
    end
end

%  imgFinal = imread('../data/butterfly.jpg');
show_all_circles(img, finalCols, finalRows, finalRadii);
toc