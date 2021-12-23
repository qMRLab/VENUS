# VENUS
Analysis repository for VEndor NeUtral Sequence (VENUS) dataset

|Session|Scanner OS|Scanner Model| Acquisition|MTsat|
|--|--|--|--|--|--|
|rth750rev  | RTHawk v3  | GE 750 Discovery 3T  | revised | VENUS MTS|
|rthPRIrev  | RTHawk v3 | Siemens Prisma 3T   | revised | VENUS MTS|
|rthSKYrev  | RTHawk v3 | Siemens Skyra 3T   |  revised | VENUS MTS|
|vendor750rev  | DV25.0_R02_1549.b  | GE 750 Discovery 3T  | revised | SPGR |
|vendorPRIrev  | N4_VE11C_LATEST_20160120  | Siemens Prisma 3T   | revised | FLASH |
|vendorSKYrev  | N4_VE11C_LATEST_20160120  | Siemens Skyra 3T   | revised | FLASH|

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