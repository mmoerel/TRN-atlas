# TRN-atlas
Code accompanying the manuscript "A probabilistic atlas of the human thalamic reticular nucleus derived from 7T MRI"

Kotwicka, Z., Gulban, O. F., Dowdle, L., Auksztulewicz, R., & Moerel, M.


**Overview**

This repository contains scripts used to generate and evaluate a probabilistic atlas of the human thalamic reticular nucleus (TRN) from ultra-high-resolution 7 Tesla MRI data.
The repository includes code for:
- smoothing manual TRN segmentations,
- generating group-level probability maps,
- quantifying interhemispheric similarity of individual TRN segmentations,
- quantifying intersubject similarity of individual TRN segmentations.

MRI preprocessing is not included in this repository and was performed using the meso-MRI pipeline:
https://github.com/ofgulban/meso-MRI


**Data Availability**

The MRI data, manual segmentations, probability maps, and transformation files are available on Zenodo:
[ADD ZENODO DOI]

The dataset includes:
- raw MRI data for participants sub-01 to sub-05 and sub-10,
- manual TRN segmentations for all in vivo and postmortem datasets,
- group-level probability maps,
- preprocessed MRI derivatives,
- spatial transformation files.


**Script Descriptions**
- smooth_segmentations.py: Applies spatial smoothing to manual TRN segmentations prior to probability-map generation.
- generate_probability_maps.m: Generates group-level probability maps from individual TRN segmentations transformed to MNI space.
- quantify_interhemispheric_similarity.m: Computes Dice similarity coefficient and average Hausdorff distance (AHD) between left and right TRN segmentations within the same brain.
- quantify_intersubject_similarity.m: Computes Dice similarity coefficient and average Hausdorff distance (AHD) between TRN segmentations across datasets in MNI space.


**Citation**

If you use this code or the accompanying dataset, please cite:
Kotwicka, Z., Gulban, O. F., Dowdle, L., Auksztulewicz, R., & Moerel, M. (submitted). A probabilistic atlas of the human thalamic reticular nucleus derived from 7T MRI.

In addition, please cite the accompanying dataset:
[ADD ZENODO DOI]
