%% Clear, close
clear; close all;

%% Add folders to path
folder = {'descriptor','external_code'};
for i=1:length(folder)
    p = genpath(folder{i});
    addpath(p);
end


%% Settings
descriptor = 'PCEHD';  %  'LGHD'|'EHD'|'PCEHD'

%% RGB-LWIR sample
im_rgb = rgb2gray(imread('test_images/rgb37.bmp'));
im_lwir = im2uint8(imread('test_images/lwir37.png'));

% Detect features
rgb_points = detectFASTFeatures(im_rgb);
lwir_points = detectFASTFeatures(im_lwir,'MinContrast',0.1);

% Compute descriptors
fd = FeatureDescriptor(descriptor);
res_fd_rgb = fd.compute(im_rgb, rgb_points.Location);
res_fd_lwir = fd.compute(im_lwir, lwir_points.Location);

% Matching
[indexPairs,matchmetric] = matchFeatures(res_fd_rgb.des,res_fd_lwir.des,'MaxRatio',1,'MatchThreshold', 100,'Unique',true); %100 in paper
matchedPoints1 = res_fd_rgb.kps(indexPairs(:, 1), :);
matchedPoints2 = res_fd_lwir.kps(indexPairs(:, 2), :);
% Filter result using RANSAC
[F,inliersIndex] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2);
matchedPoints1 = matchedPoints1(inliersIndex, :);
matchedPoints2 = matchedPoints2(inliersIndex, :);

% Show images
figure; showMatchedFeatures(im_rgb, im_lwir, matchedPoints1, matchedPoints2,'method', 'montage');



