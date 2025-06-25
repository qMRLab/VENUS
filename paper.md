
# Abstract

This living preprint encapsulates the code, data and runtime (`R` and `Python`) for an interative exploration of our findings from [@karakuzu2022vendor]. 

{button}`📄 VENUS article (MRM) <https://onlinelibrary.wiley.com/doi/full/10.1002/mrm.29292>`

# Introduction

:::{tip} Tip

You can modify the code, and re-generate the outputs in your web browser without installing or downloading anything to your computer!

If you have any questions or comments, feel free to open an issue!

{button}`❔ Ask away <https://github.com/qMRLab/VENUS/issues/new/choose>`
:::

## What is VENUS?

VENUS is the acronym of our vendor-neutral [qMRLab](https://qmrlab.org) workflow that begins with the acquisition of qMRI data using [open-source & vendor-neutral pulse sequences](https://github.com/qmrlab/pulse_sequences) and follows with the post-processing using data-driven and container-mediated [qMRFLow](https://github.com/qmrlab/qmrflow) pipelines ([Figure 1](#qmrlabbanner)).

:::{figure} assets/banner.jpg
:label: qmrlabbanner

Schematic illustration of the VENUS components.
:::

Open-source and vendor-neutral pulse sequences are developed as [RTHawk](https://www.heartvista.ai/for-research) applications, that can be run on most GE and Siemens clinical scanners.



## NATIVE vs VENUS: Does it matter to the measurement stability? 

The purpose of this study was to test whether VENUS can improve **inter-vendor** reproducibility of `T1`, `MTR` and `MTSat` measurements across three scanners by two vendors, in phantoms and in-vivo.

To test this, we developed a vendor-neutral 3D-SPGR sequence, then compared measurement stability between scanners using VENUS and vendor-native (NATIVE) implementations.

**Toggle the tabs for details:**

::::{tab-set}
:::{tab-item} Scanners
:sync: tab1
* **G1** GE Discovery 750w (3T)
* **S1** Siemens Prisma (3T)
* **S2** Siemens Skyra (3T)
:::
:::{tab-item} NATIVE implementation
:sync: tab2
* **G1** SPGR (`DV25.0_R02_1549.b`)
* **S1** FLASH (`N4_VE11C_LATEST_20160120`)
* **S2** FLASH (`N4_VE11C_LATEST_20160120`)
:::
:::{tab-item} VENUS implementation
:sync: tab3
* **G1** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
* **S1** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
* **S2** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
:::
:::{tab-item} Phantom
:sync: tab4
* [ISMRM/NIST System Phantom](https://qmri.com/contrast-mri/) (SN = 42)
:::
:::{tab-item} In-vivo
:sync: tab4
* 3 healthy participants volunteered for data collection.
:::
::::

## The answer is yes!

Our results show that VENUS can **significantly** decrease inter-vendor variability of `T1`, `MTR` and `MTsat`.

::::{admonition} Implications

VENUS approach to qMRI has several implications for qMRI research and for the reliability of multicenter clinical trials. 

**This Jupyter Book supports that by highlighting the core idea of VENUS:**

:::{epigraph}
To deliver what it promises, quantitative MRI needs to dispense with undisclosed implementation details, from scanner to publication.
:::
::::

## About the data and derivatives

The dataset cached for this Jupyter Book includes the raw data and first-order derivatives, following the qMRI-BIDS data standard [@karakuzu2022qmri].

{button}`💽 Download data <https://osf.io/5n3cu/>`

All the figures and statistical analyses were based on the first-order derivatives. 

:::::{admonition} qMRFLow execution reports
:class: seealso

:::{image} https://raw.githubusercontent.com/qMRLab/qMRFlow/master/assets/qmrflow_small.png
:width: 200px
:align: center
:::

You can follow the Nextflow instructions below to execute the workflow yourself. Workflow execution reports are available to provide you with detailed information about pipeline execution, including resource usage, execution time, and process completion status.

::::{grid} 1 1 2 2

:::{card}
:header: 👻 Phantom
{button}`Report <https://qmrlab.org/VENUS/phantom-report.html>`

Interactive nextflow execution report for the phantom pipeline.
:::

:::{card}
:header: 🧠 In-vivo
{button}`Report <https://qmrlab.org/VENUS/qmrflow-exec-report.html>`

Interactive nextflow execution report for the in-vivio pipeline.
:::
::::

:::::

To reproduce the first-order derivatives from the raw data, you need to run `qMRFlow` pipelines using Nextflow.

:::{important} Click the button to reveal qMRFlow instructions.
:class: dropdown

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
2. Pull Docker images:
    ```shell
    docker pull qmrlab/minimal:v2.5.0b
    docker pull qmrlab/antsfsl:latest
    ```
3. Download the [dataset](https://osf.io/5n3cu/)
4. Run

* To process the phantom data:
    ```shell
    cd /to/VENUS
    nextflow run venus-process-phantom.nf --bids /set/to/bids/directory -with-report phantom-report.html
    ```

* To process the in-vivo data:
    ```shell
    cd /to/VENUS
    nextflow run venus-process-invivo.nf --bids /set/to/bids/directory -with-report invivo-report.html
    ```

**If Docker is not available**

You need to make sure that following dependencies are installed on your local machine/environment and accessible via shell (i.e. added to the system PATH):

* qMRLab v2.4.1
* ANTs 
* FSL
* MATLAB or Octave 

In the config file, set the following parameter to `false` at [this line](https://github.com/qMRLab/VENUS/blob/90df3f94aa0c07ee2a116b9ad5785b2b0057fa60/nextflow.config#L131-L133), this will enforce workflow to look for local executables.

Next, set MATLAB or Octave executable path and qMRLab directory at [this line](https://github.com/qMRLab/VENUS/blob/90df3f94aa0c07ee2a116b9ad5785b2b0057fa60/nextflow.config#L144-L148)

Finally, execute the workflows using the `nextflow run` commands above.
:::

# 👻 Phantom Results


## T1 accuracy & inter-vendor agreement

T1 plate of the ISMRM/NIST system phantom was scanned with the following T1 mapping protocol:

:::{important} Click here to reveal the variable flip angle (VFA) protocol.
:class: dropdown

|Parameter (PDw/T1w)|G1<sub>NATIVE</sub>|S1<sub>NATIVE</sub>|S2<sub>NATIVE</sub>| VENUS|
|---------|-----------|-----------|-----------|-----|
| Sequence Name | SPGR  | FLASH| FLASH| mt_sat v1.0 |
| Flip Angle (°) | 6/20  | 6/20| 6/20| 6/20 |
| TR (ms) | 32/18  | 32/18| 32/18| 32/18 |
| TE (ms) | 4  | 4| 4| 4|
| FOV (cm) | 25.6  | 25.6| 25.6| 25.6|
| Acquisition Matrix | 256x256  | 256x256| 256x256| 256x256|
| Receiver BW (kHz) | 62.5  | 62.5| 62.5| 62.5|
| RF Phase Increment (°) | 115.4  | 50| 50| 117|
:::

:::{note} Reference values

The nominal T1 values (s) of the system phantom (SN = 42) were `1.98`, `1.45`, `0.98`, `0.71`, `0.5`, `0.35`, `0.24`, `0.17`, `0.13`, `0.09` in 10 reference spheres (**R1- R10**) of the phantom. The reference measurements are specified by the phantom manufacturer and are traceable to NIST. Wherever applicable in this interactive article, these values are denoted by white cross markers.
:::

## Peak SNR values

:::{tip} ♼ Note

Reproduces Figure 3a from the [article](https://doi.org/10.1002/mrm.29292).
:::

Calculations of `signal` (average value of the highest signal sphere) and `noise` (background standard deviation) were performed manually using 3D Slicer.

VENUS PSNR values are on a par with those of vendor-native T1w and PDw images [](#snrfig).

:::{figure} #snrcell
:label: snrfig

Peak SNR measurements from the system phantom comparing NATIVE vs VENUS acquisitions.
:::

## VENUS vs NATIVE `T1` estimations

:::{tip} ♼ Note

Reproduces Figure 4b from the [article](https://doi.org/10.1002/mrm.29292).
:::

Vendor-native measurements, especially G1{sub}`NATIVE` and S2{sub}`NATIVE`, overestimate T1. G1{sub}`VENUS` and S1-2{sub}`VENUS` remain closer to the reference.

:::{figure} #phant1cell
:label: phant1

T1 values from the vendor-native acquisitions are represented by solid lines and square markers in cold colors, and those from VENUS attain dashed lines and circle markers in hot colors. 
:::

## Percent measurement errors (`∆T1`)

:::{tip} ♼ Note

Reproduces Figure 4c from the [article](https://doi.org/10.1002/mrm.29292).
:::


:::{figure} #delt1cell

For VENUS, ∆T1 remains low for the physiologically relevant range (0.7 to 2s), whereas deviations reach up to 30.4% for vendor-native measurements.
:::

## Averaged  `∆T1` comparison

:::{tip} ♼ Note

Reproduces Figure 4d from the [article](https://doi.org/10.1002/mrm.29292).
:::

T1 values are averaged over S1-2 (SNATIVE and SVENUS, green square and orange circle) and according to the acquisition type (NATIVE and VENUS, black square and black circle). Inter-vendor percent differences are displayed on hover.

:::{figure} #delt1avg

Averaged percent measurement errors.
:::

In addition to the prominent improvement in G1 accuracy, S{sub}`VENUS` is closer to the reference than S<{sub}`NATIVE` for most of the relevant range (∆T1 of 7.6, 3.5, 5.4, 0.7% and 3.2, 0.9, 2, 1.3% for S{sub}`NATIVE` and S{sub}`VENUS`, respectively).

You can change the range (`lastN`) (up to 9) in the [source notebook](phantom-python#main)

:::{important} Conclusion of the phantom experiment

VENUS reduces between-vendor differences with an overall accuracy improvement.
:::

# 🧠 In-vivo Results

## VENUS vs NATIVE `T1` distributions

:::{tip} ♼ Note

Reproduces Figure 5d-g from the [article](https://doi.org/10.1002/mrm.29292) for the Participant-3.
:::

:::{figure} assets/invivo_t1_p3.jpg
:align: center
:label: fig1

Vendor-native and VENUS quantitative T1 maps from P3 are shown in one axial slice.
:::

The following KDEs ([](#kdet1)) agree well with the qualitative observations from the [](#fig1) above: Inter-vendor agreement (G1-vs-S1 and G1-vs-S2) of VENUS is superior to that of vendor-native T1 maps, both in the GM and WM.

:::{figure} #kdet1cell
:label: kdet1

VENUS vs NATIVE in-vivo T1 distributions (s) from each participant.
:::

## VENUS vs NATIVE `MTR` distributions

:::{tip} ♼ Note
:class: tip
Reproduces Figure 5e-h from the [article](https://doi.org/10.1002/mrm.29292) for the Participant-3.
:::

:::{figure} assets/invivo_mtr_p3.jpg
:label: p3mtr

Vendor-native and VENUS quantitative MTR maps from P3 are shown in one axial slice.
:::

The following KDEs ([](#kdemtr)) agree well with the qualitative observations from the [](#p3mtr) above: Inter-vendor agreement (G1-vs-S1 and G1-vs-S2) of VENUS is superior to that of vendor-native MTR maps, both in the GM and WM.

:::{figure} #kdemtrcell
:label: kdemtr

VENUS vs NATIVE in-vivo MTR distributions from each participant.
:::

## VENUS vs NATIVE `MTsat` distributions

:::{tip} ♼ Note
:class: tip
Reproduces Figure 5f-i from [article](https://doi.org/10.1002/mrm.29292) for the Participant-3.
:::

:::{figure} assets/invivo_mtr_p3.jpg
:label: p3mtsat

Vendor-native and VENUS quantitative MTsat maps from P3 are shown in one axial slice.
:::

The following KDEs ([](#kdemtsat)) agree well with the qualitative observations from the [](#p3mtsat) above: Inter-vendor agreement (G1-vs-S1 and G1-vs-S2) of VENUS is superior to that of vendor-native MTsat maps, both in the GM and WM.

:::{figure} #kdemtsatcell
:label: kdemtsat

VENUS vs NATIVE in-vivo MTsat distributions from each participant.
:::

::::{important} Explanation of the statistical method used
:class: simple
:open:

## 🧮 Deciles and shift function

:::{admonition} Note
:class: tip
Reproduces Figure 6a from the [article](https://www.biorxiv.org/content/10.1101/2021.12.27.474259v2).
:::

Before moving on to the next page that performs shift function (for P3) and hierarchical shift function analyses (across participants) in `R`, this subsection provides some background information about these statistical tests.

:::{figure} assets/sf_exp.jpg
:label: sfexp

Explanation of the shift function analysis.
:::

### What is a decile? 

Deciles (a.k.a quantiles) are 1/10th of a distribution, created by splitting the distribution at 9 boundary points (excluding the min and max). For example, median is the 5th decile of a distribution.

### How do deciles create a shift function? 

To characterize differences between two distributions not only at one decile (e.g., the median), but throughout the whole range of the distributions, shift functions calculate differences at each decile. 

:::{figure} #shiftcell

Shift function example.
:::

For example, distributions `X` (green) and `Y` (red) below do not differ much at the central tendency, marked by the dashed lines. The distribution `Y` is slightly higher than `X` at the central decile. 

On the other hand, distributions `X` and `Y` differ in spread. The distribution `X` is much wider than the distribution `Y`. As a result:

* The first decile of `X` (green vertical line on the left) is smaller than that of `Y` (red vertical line on the left)
* The last decile of `X` (green vertical line on the right) is greater than that of `Y` (red vertical line on the right)

The profile of shift function calculated for **X - Y** explains how the deciles of distribution `X` should be shifted to match those of the distribution `Y`: 

* The first decile of `Y` (**D1**) must be shifted towards left (towards lower values) to match that of `X`
* The first decile of `Y` must be shifted towards right (towards higher values) to match that of `X`

Therefore, the first decile on Fig. 4 is below and the last decile is above the zero-crossing.

:::{seealso} See Also

For a more detailed explanation on shift functions, please see this [blog post](https://garstats.wordpress.com/2016/07/12/shift-function/) by Guillaume A. Rousselet.
:::

## What about hierarchical shift functions? 

Hierarchical shift function (HSF) is an extension of the shift function analysis for the comparison of dependent distributions across multiple participants.

In our case, each between-scanner comparison comes from a repeated measurement, given that the same participants were scanned using different scanners and pulse sequence implementations. 

:::{seealso} See Also

For a more detailed explanation on shift functions, please see this [blog post](https://garstats.wordpress.com/2019/02/21/hsf/) by Guillaume A. Rousselet.
:::
::::

### Explore shift functions in pairs

:::{tip} Interactive session

You can start an interactive BinderHub session to explore VENUS (red) vs NATIVE (blue) shift functions side by side for a selected participant, metric and scanner pairs. 

* Participants
    * `sub-invivo1`
    * `sub-invivo2`
    * `sub-invivo3`    
* Metrics
    * `T1`
    * `MTR`
    * `MTsat`
* Scanners
    * `G1`
    * `S1`
    * `S2`
:::

:::{figure} #shiftcell

VENUS vs NATIVE comparision of MTsat values from Participant 3 for Siemens (S1) and GE (G1) scanners.
:::

### Explore HSF plots

:::{figure} assets/hsf_exp.jpg

Explanation of the hierarchical shift function analysis.
:::

:::{tip} Interactive session

You can start an interactive BinderHub session to explore VENUS (red) vs NATIVE (blue) HSF side by side for a selected metric and scanner pairs. 

* Metrics
    * `T1`
    * `MTR`
    * `MTsat`
* Scanners
    * `G1`
    * `S1`
    * `S2`

In addition to the HSF plots, respective bootstrapped differences will also be displayed (second row).
:::

:::{figure} #hsfexample

VENUS vs NATIVE comparision of MTsat values across participants for Siemens (S1) and GE (G1) scanners.
:::

### Significance test

:::{admonition} Note

The values are drawn from the `csv` files available at `.../qMRFlow/sub-invivo#/_SF_` to construct the data frame. 
:::

:::{figure} #pairedcomp

Paired comparison of difference scores between VENUS and NATIVE implementations.
:::

:::{figure} #sigtest

:::

# Conclusion

We conclude that vendor-neutral workflows are feasible and compatible with clinical MRI scanners. The significant reduction of inter-vendor variability using vendor-neutral sequences has important implications for qMRI research and for the reliability of multicenter clinical trials.

:::{important} Peer reviewed article

For further reading, please refer to the published version of this work.

{button}`📄 VENUS article (MRM) <https://onlinelibrary.wiley.com/doi/full/10.1002/mrm.29292>`

:::

# Acknowledgements

This research was undertaken thanks, in part, to funding from the Canada First ResearchExcellence Fund through the TransMedTech Institute. The work is also funded in part by theMontreal Heart Institute Foundation, Canadian Open Neuroscience Platform (Brain CanadaPSG), Quebec Bio-imaging Network (NS, 8436-0501 and JCA, 5886, 35450), Natural Sciencesand Engineering Research Council of Canada (NS, 2016-06774 and JCA, RGPIN-2019-07244),Fonds de Recherche du Québec (JCA, 2015-PR-182754), Fonds de Recherche du Québec- Santé (NS, FRSQ-36759, FRSQ-35250 and JCA, 28826), Canadian Institute of HealthResearch (JCA, FDN-143263 and GBP, FDN-332796), Canada Research Chair in QuantitativeMagnetic Resonance Imaging (950-230815), CAIP Chair in Health Brain Aging, CourtoisNeuroMod project and International Society for Magnetic Resonance in Medicine (ISMRMResearch Exchange Grant).