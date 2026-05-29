
%% DICE and HAUSDORFF calculations

file = '/Users/zuziakotwicka/';
%% Split at midline and mirror left half
% Load image
v = niftiread(file);
dim = size(v);
labels_this = unique(v);
labels_this = labels_this(2:end);

% Compute image center in X and Y
x_center = round(dim(1) / 2);
y_center = round(dim(2) / 2);

% Loop over Z to insert a vertical line in the center
% Set entire sagittal midline plane (X = x_center) to label 4, only on background
for y = 1:dim(2)
    for z = 1:dim(3)
        if v(x_center, y, z) == 0
            v(x_center, y, z) = 4;
        end
    end
end

index = find(v==4); % find midline (label 4 in segmentation)
[x,y,z] = ind2sub(dim, index); % translate to coordinates
plane = x_center; % extract slice number of midline
right = v(1:plane,:,:); % new array with right half
left = v(plane:(plane*2-1),:,:); % new array with left half

disp(length(x))

mleft = flip(left, 1); % mirror the left half

%% Statistics TRN

%equalling the TRN segmentation labels (setting them to value 3)

rightTRN = right(1:(end-1),:,:);
%rightTRN(rightTRN==1)=0;
rightTRN(rightTRN==labels_this(1))=3;

 
mleftTRN = mleft(1:(end-1),:,:);
%mleftTRN(mleftTRN==1)=0;
mleftTRN(mleftTRN==labels_this(2))=3;

disp('Unique labels in RIGHT (raw right):');
disp(unique(right));

disp('Unique labels in LEFT (raw left):');
disp(unique(left));

disp('Unique labels in MIRRORED LEFT (mleft):');
disp(unique(mleft));

disp('Unique labels in rightTRN:');
disp(unique(rightTRN));

disp('Unique labels in mleftTRN:');
disp(unique(mleftTRN));

disp(['# rightTRN == 3: ', num2str(sum(rightTRN(:)==3))]);
disp(['# mleftTRN == 3: ', num2str(sum(mleftTRN(:)==3))]);


% Statistics (midline aligned)
TRNDiceAutoMidline = generalizedDice(rightTRN,mleftTRN);
TRNDiceManualMidline = manualDice(rightTRN,mleftTRN,3);
TRNAverageHD_voxels = hausdorffDistAverage(rightTRN, mleftTRN);
TRNAverageHD_mm = TRNAverageHD_voxels * 0.7;
TRNDiceDilated = dilatedDice(rightTRN, mleftTRN);


% Print results
fprintf('TRN Results :\n');
fprintf('Automatic DICE: %f \n',TRNDiceAutoMidline);
fprintf('Manual DICE: %f \n',TRNDiceManualMidline);
fprintf('Hausdorff Distance Average (voxel): %f \n', TRNAverageHD_voxels);
fprintf('Hausdorff Distance Average (mm): %f \n', TRNAverageHD_mm);
fprintf('Dilated DICE %f \n', TRNDiceDilated);

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

%% Average Hausdorff distance function

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


