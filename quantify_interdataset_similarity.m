%% Load NIfTI files

clear all;
close all;

label = 1;
file1 = '/Users/zuziakotwicka/';
file2 = '/Users/zuziakotwicka/';
v1 = niftiread(file1);
v2 = niftiread(file2);
dim1 = size(v1);
dim2 = size(v2);
labels_this1 = unique(v1);
labels_this2 = unique(v2);
labels_this1 = labels_this1(2:end);
labels_this2 = labels_this2(2:end);

x_center = round(dim1(1) / 2);
y_center = round(dim1(2) / 2);




%% For statistics, make sure that midline is at the same location!
% Otherwise align them (and align size)

%% Statistics MGB

% Setting values of TRN segmentations to 0
%v1MGB = v1(:,:,:);
%v1MGB(v1MGB==3)=0;
%v1MGB(v1MGB==2)=0;

%v2MGB = v2(:,:,:);
%v2MGB(v2MGB==3)=0;
%v2MGB(v2MGB==2)=0;


% Statistics (midline aligned)
%MGBDiceAutoMidline = generalizedDice(v1MGB,v2MGB);
%MGBDiceManualMidline = manualDice(v1MGB,v2MGB,1);
%MGBHausdorff1Midline = HausdorffDist(v1MGB,v2MGB);
%MGBHausdorff2Midline = hausdorff(v1MGB,v2MGB);


% Print results
%fprintf('MGB Results:\n');
%fprintf('Automatic DICE: %f \n',MGBDiceAutoMidline);
%fprintf('Manual DICE: %f \n',MGBDiceManualMidline);
%fprintf('Hausdorff Version 1: %f \n',MGBHausdorff1Midline);
%fprintf('Hausdorff Version 2: %f \n',MGBHausdorff2Midline);
%fprintf('\n');
%fprintf('\n');


%% Statistics TRN

% plane = x_center; % extract slice number of midline
% right = v1(1:plane,:,:); % new array with right half
% left = v2(plane:(plane*2-1),:,:); % new array with left half
% 
% mleft = flip(left, 1);
% 
% % Setting values of MGB segmentations to 0 
% % and equalling the TRN segmentation labels (setting them to value 3)
% rightTRN = right(1:(end-1),:,:);
% rightTRN(rightTRN==labels_this1(2))=3;
% 
% 
% mleftTRN = mleft(1:(end-1),:,:);
% mleftTRN(mleftTRN==labels_this2(3))=3;


radius = 2;


% Statistics (midline aligned)
%TRNDiceAutoMidline = generalizedDice(v1,v2);
TRNAverageHausdorff = hausdorffDistAverage(v1, v2);
TRNAverageHausdorff_mm = TRNAverageHausdorff * 0.7;

v1l = v1; v1l(v1l>0) = 1;
v2l = v2; v2l(v2l>0) = 1;
TRNDiceManualMidline = manualDice(v1l,v2l,label);
%TRNHausdorff1Midline = HausdorffDist(v1TRN,v2TRN);
%TRNHausdorff2Midline = hausdorff(v1TRN,v2TRN);



% Print results
fprintf('TRN Results:\n');
%fprintf('Automatic DICE: %f \n',TRNDiceAutoMidline);
fprintf('Average Hausdorff Distance (voxels): %f \n', TRNAverageHausdorff);
fprintf('Average Hausdorff Distance (mm): %f \n', TRNAverageHausdorff_mm)
fprintf('Manual DICE: %f \n',TRNDiceManualMidline);

%fprintf('Hausdorff Version 1: %f \n',TRNHausdorff1Midline);
%fprintf('Hausdorff Version 2: %f \n',TRNHausdorff2Midline);








%% Manual DICE calculation (function)

function result = manualDice(block1,block2,label)
    match = 0;
    volume1 = 0;
    volume2 = 0;

    % Iterating over both matrices and counting how many times both have a
    % non-zero value, and how many times only one has a non-zero value
    for a = 1:size(block1,1)
        for b = 1:size(block1,2)
            for c = 1:size(block1,3)
                if isequal(block1(a,b,c),label) && isequal(block2(a,b,c),label)
                    match = match+1;
                end
                if isequal(block1(a,b,c),label)
                    volume1 = volume1+1;
                end
                if isequal(block2(a,b,c),label)
                    volume2 = volume2+1;
                end 
            end
        end
    end

    disp(['volume1 count: ', num2str(volume1)]);
    disp(['volume2 count: ', num2str(volume2)]);
    disp(['match count: ', num2str(match)]);
    
    % Formula for the DICE coefficient
    result = (2*match)/(volume1+volume2);
end

function hd = hausdorffDistAverage(volume1, volume2)
    % Convert segmentations to point clouds
    pts1 = extractSurfacePoints(volume1);
    pts2 = extractSurfacePoints(volume2);
    
    if isempty(pts1) || isempty(pts2)
        error('One of the input volumes has no surface points!');
    end

    % Reduce computational load
    maxPoints = 5000;
    pts1 = sortrows(pts1);
    pts2 = sortrows(pts2);
    if size(pts1, 1) > maxPoints
        pts1 = pts1(1:maxPoints, :);
    end
    if size(pts2, 1) > maxPoints
        pts2 = pts2(1:maxPoints, :);
    end

    % Compute directed distances
    d1 = vecnorm(pts1 - pts2(knnsearch(pts2, pts1), :), 2, 2);
    d2 = vecnorm(pts2 - pts1(knnsearch(pts1, pts2), :), 2, 2);

    % Average of both directions
    hd = mean([d1; d2]);
end

function pts = extractSurfacePoints(volume)
    % Extract boundary voxels from a binary 3D volume
    boundary = bwperim(volume, 26); % 26-connectivity ensures full 3D boundaries
    [x, y, z] = ind2sub(size(volume), find(boundary));
    pts = [x, y, z]; % Store as Nx3 point cloud
end

