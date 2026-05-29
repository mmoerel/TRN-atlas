{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 2,
   "id": "2c0da237-ad53-4be7-b03d-76d22e72d5af",
   "metadata": {},
   "outputs": [],
   "source": [
    "import nibabel as nib\n",
    "import numpy as np\n",
    "from scipy.ndimage import binary_closing, binary_opening\n",
    "\n",
    "img = nib.load(\"/Users/zuziakotwicka/Desktop/pipeline/segmentation_analysis/segmentations/sub-05_segmentation.nii.gz\")\n",
    "data = img.get_fdata()\n",
    "\n",
    "labels = np.unique(data)\n",
    "labels = labels[labels != 0] #exclude background\n",
    "\n",
    "smoothed_data = np.zeros_like(data)\n",
    "\n",
    "structure = np.ones((3, 3, 3)) #higher for more smoothing\n",
    "\n",
    "for label in labels:\n",
    "    binary_mask = data == label\n",
    "    closed = binary_closing(binary_mask, structure=structure)\n",
    "    opened = binary_opening(closed, structure=structure)\n",
    "    smoothed_data[opened] = label \n",
    "\n",
    "nib.save(nib.Nifti1Image(smoothed_data.astype(np.uint8), img.affine), \"/Users/zuziakotwicka/Desktop/pipeline/segmentation_analysis/final_segmentations/segmentation-sub-05_smoothed.nii.gz\")\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "53533aea-a49e-4e21-9e76-a5cf4dfa013d",
   "metadata": {},
   "outputs": [],
   "source": []
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "9248f79c-a191-4587-a930-4737dd6ebd5a",
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python [conda env:miniconda3]",
   "language": "python",
   "name": "conda-env-miniconda3-py"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.12.8"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
