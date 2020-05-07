# skeletonToCDMIP

This repository contains scripts to transform EM-based neuron skeleton provided
by [neuPrint](https://neuprint.janelia.org/) into the image format that can be
used for [color depth MIP mask search](https://www.janelia.org/open-science/color-depth-mip).

## Preparation

* SWC files can be downloaded from the "Skeleton" view in [neuPrint](https://neuprint.janelia.org/),
which should be stored by cell types under /swc/whateverCellName directories.
* To generate color depth MIP compatible images, you need to download the [LUT file](https://github.com/JaneliaSciComp/ColorMIP_Mask_Search/blob/master/PsychedelicRainBow2.lut) from
the ColorMIP_Mask_Search repository, and save it as psychedelicrainbow.mat containing
a 256 x 3 matrix called psychedelicrainbow.
* [Color depth MIP search](https://www.janelia.org/open-science/color-depth-mip) itself runs on Fiji.

## Usage

* generateColorDepthMIPfromSWC is the main function.
* This is an ongoing work and might require significant amount of calibration before it actually works.
