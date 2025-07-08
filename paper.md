---
title: Vendor-neutral sequences and their implications for the reproducibility of quantitative MRI
tags:
  - quantitative MRI
  - vendor-neutral seuqences
  - MRI metrology
  - reproducibility
  - magnetization transfer
  - relaxometry
authors:
  - name: Agah Karakuzu
    affiliation: "1, 2"
  - name: Labonny Biswas
    affiliation: "3"
  - name: Julien Cohen-Adad
    affiliation: "1,4,5"
  - name: Nikola Stikov
    affiliation: "1,2,6"
affiliations:
 - name: NeuroPoly Lab, Polytechnique Montreal, Montreal, QC, Canada
   index: 1
 - name: Montreal Heart Institute, Montreal, QC, Canada
   index: 2
 - name: Sunnybrook Research Institute, University of Toronto, Toronto, ON, Canada
   index: 3
 - name: Functional Neuroimaging Unit, CRIUGM, Montreal, QC, Canada
   index: 4
 - name: Mila - Quebec Artificial Intelligence Institute, Montreal, QC, Canada
   index: 5
 - name: Center for Advanced Interdisciplinary Research, University Ss Cyril and Methodius in Skopje
   index: 6
date: 17 June 2025
bibliography: paper.bib
---

# Abstract

This living preprint [@karakuzu_nl;@harding2023canadian;@karakuzu2025;@dupre2022beyond] encapsulates the code, data and runtime (`R` and `Python`) for an interative exploration of our findings from [@karakuzu2022vendor].

# Background

Quantitative magnetic resonance imaging (qMRI) holds significant potential as a tool for precision medicine, offering objective biomarkers that can enhance diagnostic accuracy and therapeutic monitoring across a broad spectrum of clinical applications [@karakuzu2024reproducible]. Despite this promise, achieving reproducibility in qMRI measurements remains a major challenge, particularly in multi-site studies that rely on scanners from different vendors [@stikov2023relaxometry]. Much of this variability arises from differences in pulse sequence implementations among MRI manufacturers, which can introduce systematic biases that reduce the reliability of quantitative metrics [@boudreau2024repeat].

The development of vendor-neutral pulse sequences [@layton2017pulseq;@hoinkiss2023ai] marks a significant step toward standardized qMRI protocols that can be consistently applied across different scanner platforms [@karakuzu2022vendor]. By standardizing key acquisition parameters and sequence timing to ensure that each scanner plays out the same physics, these approaches aim to reduce inter-vendor variability while preserving the quantitative accuracy required for clinical interpretation. This standardization is especially important for multi-site collaborations, longitudinal studies, and the creation of normative databases, all of which depend on high reproducibility across diverse imaging settings [@10.1162/imag_a_00409].

Achieving vendor neutrality in qMRI has implications that go beyond technical consistency. Reliable quantitative measurements enable data sharing across institutions, support meta-analyses of imaging biomarkers, and contribute to the development of universal reference standards for disease assessment. Moreover, standardized acquisition protocols can help bridge the gap between research and clinical adoption by providing validated, implementation-independent methods that are readily deployable across healthcare systems [@karakuzu2025rethinking]. 

Open science practices and reproducible research workflows [@niso2022open] further reinforce this transition by ensuring that qMRI methods can be systematically validated across research environments. In this context, standardized data organization [@karakuzu2022qmri] plays a central role in supporting transparency, replicability, and long-term usability of qMRI datasets.

# Results

In phantom experiments, the vendor-neutral sequence substantially minimized inter-vendor differences, reducing them from a range of 8–19.4% down to 0.2–5%. This also improved accuracy relative to ground truth T1 values, lowering deviations from 7–11% to just 0.2–4%. In vivo, the use of the vendor-neutral sequence led to a significant reduction in variability across vendors for all quantitative maps assessed (T1, MTR, and MTsat), with statistical support (p = 0.015).

# Conclusion

Our findings demonstrate that vendor-neutral imaging protocols are readily deployable on conventional clinical MRI systems. Through substantial reduction of inter-vendor variability, these transparent and reproducible measurement frameworks provide a viable pathway toward enhanced qMRI reliability and improved clinical outcomes in multicenter research settings.