### Introduction

_Agah Karakuzu, Labonny Biswas, Julien Cohen-Adad, Nikola Stikov_

<br><br>

````{margin}
<center><img src="https://www.ismrm.org/17/program_files/images/summa-ribbon.png" width="150px"/></center>
````

```{admonition} 🏅 &nbsp;Interact with, explore and reproduce our findings!&nbsp;🏅
:class: seealso
The following pages of this Jupyter Book encapsulates the code, data and runtime (`R` and `Python`) for you to explore our findings using interactive figures. 

You can modify the code, and re-generate the outputs in your web browser without installing or downloading anything to your computer!

If you have any questions or comments, feel free to open an issue by clicking the GitHub icon at the top of this page.👆
```

#### What is VENUS?

VENUS is the acronym of our vendor-neutral [qMRLab](https://qmrlab.org) workflow that begins with the acquisition of qMRI data using [open-source & vendor-neutral pulse sequences](https://github.com/qmrlab/pulse_sequences) and follows with the post-processing using data-driven and container-mediated [qMRFLow](https://github.com/qmrlab/qmrflow) pipelines.

```{image} ../assets/banner.jpg
:class: bg-primary mb-1
:width: 800px
:align: center
```

Open-source and vendor-neutral pulse sequences are developed as [RTHawk](https://www.heartvista.ai/for-research) applications, that can be run on most GE and Siemens clinical scanners.

#### NATIVE vs VENUS: Does it matter to the measurement stability? 

The purpose of this study was to test whether VENUS can improve **inter-vendor** reproducibility of `T1`, `MTR` and `MTSat` measurements across three scanners by two vendors, in phantoms and in-vivo.

To test this, we developed a vendor-neutral 3D-SPGR sequence, then compared measurement stability between scanners using VENUS and vendor-native (NATIVE) implementations.

**Toggle the tabs for details:**

```{tabbed} Scanners
* **G1** GE Discovery 750w (3T)
* **S1** Siemens Prisma (3T)
* **S2** Siemens Skyra (3T)
```

```{tabbed} NATIVE implementation
* **G1** SPGR (`DV25.0_R02_1549.b`)
* **S1** FLASH (`N4_VE11C_LATEST_20160120`)
* **S2** FLASH (`N4_VE11C_LATEST_20160120`)
```

```{tabbed} VENUS implementation
* **G1** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
* **S1** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
* **S2** [qMRPullseq/mt_sat](https://github.com/qMRLab/mt_sat/releases/tag/v1.0) (`v1.0` on `RTHawk v3`)
```

```{tabbed} Phantom
* [ISMRM/NIST System Phantom](https://qmri.com/contrast-mri/) (SN = 42)
```

```{tabbed} In-vivo
* 3 healthy participants volunteered for data collection.
```

#### The answer is yes!

Our results show that VENUS can **significantly** decrease inter-vendor variability of `T1`, `MTR` and `MTsat`.

`````{admonition} Implications
:class: tip
VENUS approach to qMRI has several implications for qMRI research and for the reliability of multicenter clinical trials. 

**This Jupyter Book supports that by highlighting the core idea of VENUS:**

```{epigraph}
To deliver what it promises, quantitative MRI needs to dispense with undisclosed implementation details, from scanner to publication.
```

`````
`````{admonition} See Also
:class: seealso
This work has been accepted for publication in Magnetic Resonance in Medicine. The last version of the preprint is available [here](https://www.biorxiv.org/content/10.1101/2021.12.27.474259v2).
`````

#### About the data and derivatives

[![](https://img.shields.io/badge/DATA%20DOI-10.17605%2FOSF.IO%2F5N3CU-blue)](https://osf.io/5n3cu/)

<img src="https://upload.wikimedia.org/wikipedia/commons/d/de/BIDS_Logo.png" alt="drawing" width="220px"/>

The dataset downloaded to this Jupyter Book includes the raw data and first-order derivatives, **following the [qMRI-BIDS data standard](https://www.medrxiv.org/content/10.1101/2021.10.22.21265382v3)**.

All the figures and statistical analyses were based on the first-order derivatives. 

<img src="https://github.com/qMRLab/qMRFlow/raw/master/assets/qmrflow_small.png" alt="drawing" width="200px"/>


To reproduce the first-order derivatives from the raw data, you need to run `qMRFlow` pipelines using Nextflow.

```{admonition} Click the button to reveal qMRFlow instructions.
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
```

`````{admonition} qMRFLow execution reports
:class: seealso
* 📑 Click here to see the report for the phantom pipeline
* 📑 Click here to see the report for the in-vivo pipeline
`````

#### Acknowledgements

This research was undertaken thanks, in part, to funding from the Canada First ResearchExcellence Fund through the TransMedTech Institute. The work is also funded in part by theMontreal Heart Institute Foundation, Canadian Open Neuroscience Platform (Brain CanadaPSG), Quebec Bio-imaging Network (NS, 8436-0501 and JCA, 5886, 35450), Natural Sciencesand Engineering Research Council of Canada (NS, 2016-06774 and JCA, RGPIN-2019-07244),Fonds de Recherche du Québec (JCA, 2015-PR-182754), Fonds de Recherche du Québec- Santé (NS, FRSQ-36759, FRSQ-35250 and JCA, 28826), Canadian Institute of HealthResearch (JCA, FDN-143263 and GBP, FDN-332796), Canada Research Chair in QuantitativeMagnetic Resonance Imaging (950-230815), CAIP Chair in Health Brain Aging, CourtoisNeuroMod project and International Society for Magnetic Resonance in Medicine (ISMRMResearch Exchange Grant).