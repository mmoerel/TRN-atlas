clearvars; close all;

folder  = '/Users/zuziakotwicka/';
pattern = '*.nii';
threshold_mask = 0;

files = dir(fullfile(folder, pattern));
nsubs = numel(files);
if nsubs == 0
    error('No NIfTI files found.');
end

% Read template
tinfo = niftiinfo(fullfile(folder, files(1).name));
tmpl  = niftiread(tinfo);
if ndims(tmpl) == 4
    tmpl = tmpl(:,:,:,1);
end
dims = size(tmpl);

OverlapCounts = zeros(dims, 'double');

for i = 1:nsubs
    vol = niftiread(fullfile(folder, files(i).name));
    if ndims(vol) == 4
        vol = vol(:,:,:,1);
    end

    if ~isequal(size(vol), dims)
        warning('Skipping %s (dimension mismatch).', files(i).name);
        continue
    end

    OverlapCounts = OverlapCounts + double(vol > threshold_mask);
end

OverlapProb = OverlapCounts / nsubs;

min_overlap = 4;
HeatmapMask = OverlapCounts >= min_overlap;

% Create mask of voxels meeting minimum overlap
consensus_mask = OverlapCounts >= min_overlap;

% Apply mask to probability map
OverlapProb_4plus = zeros(size(OverlapProb), 'single');
OverlapProb_4plus(consensus_mask) = OverlapProb(consensus_mask);


outname = fullfile(folder, 'Overlap_Probability.nii');
info_out = tinfo;
info_out.Datatype = 'single';
info_out.ImageSize = size(OverlapProb);

overlap_levels = 0:nsubs;
voxel_counts = zeros(size(overlap_levels));

for k = overlap_levels
    voxel_counts(k+1) = sum(OverlapCounts(:) == k);
end

fprintf('\nVoxel overlap summary:\n');
fprintf('Overlap\tVoxel count\tFraction of brain\n');

total_voxels = numel(OverlapCounts);

for k = overlap_levels
    fprintf('%d\t%d\t\t%.4f\n', ...
        k, voxel_counts(k+1), voxel_counts(k+1) / total_voxels);
end

niftiwrite(single(OverlapProb), outname, info_out);
fprintf('Saved probabilistic overlap map: %s\n', outname);

outname = fullfile(folder, 'Overlap_Probability_4plus.nii');
info_out = tinfo;
info_out.Datatype = 'single';
info_out.ImageSize = size(OverlapProb_4plus);

fprintf('\nOverlap of individual segmentations with heatmap (≥%d):\n', min_overlap);
fprintf('Subject\tVoxels_in_Seg\tVoxels_in_Heatmap\tOverlap_%%\n');

overlap_percent = zeros(nsubs,1);

for i = 1:nsubs
    vol = niftiread(fullfile(folder, files(i).name));
    if ndims(vol) == 4
        vol = vol(:,:,:,1);
    end

    seg = vol > threshold_mask;

    % Skip empty segmentations (just in case)
    n_seg_vox = sum(seg(:));
    if n_seg_vox == 0
        overlap_percent(i) = NaN;
        continue
    end

    % Intersection
    overlap_vox = sum(seg(:) & HeatmapMask(:));

    overlap_percent(i) = 100 * overlap_vox / n_seg_vox;

    fprintf('%s\t%d\t\t%d\t\t%.2f\n', ...
        files(i).name, n_seg_vox, overlap_vox, overlap_percent(i));
end


niftiwrite(single(OverlapProb_4plus), outname, info_out);
fprintf('Saved probability map (≥4 overlaps): %s\n', outname);

