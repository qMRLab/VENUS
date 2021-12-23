# VENUS
Analysis repository for VEndor NeUtral Sequence (VENUS) dataset

![](venus_table.png)
Above data is acquired for `sub-phantom` (ISMRM/NIST system phantom) and for 3 healthy subjects, yielding 24 for acquisitions.

# To execute workflows 

1. Install [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html)
2. Pull Docker images:
    ```
    docker pull qmrlab/minimal:v2.5.0b
    docker pull qmrlab/antsfsl:latest
    ```
3. Download the [dataset](https://osf.io/5n3cu/)
4. Run

Process phantom data
```
nextflow run venus-process-phantom.nf --bids /set/to/bids/directory -with-report phantom-report.html
```
Process in-vivo data
```
nextflow run venus-process-invivo.nf --bids /set/to/bids/directory -with-report invivo-report.html
```