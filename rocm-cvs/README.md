# Understanding ROCM cvs (Cluster Validation Suite)

Repo: <a href="https://github.com/ROCm/cvs">https://github.com/ROCm/cvs</a>

### What is CVS

At the core its a collection of python scripts to validate the health of an AMD AI/GPU cluster.

CVS allows:

- End to End Validation
    - Hardware to application level checks
- Reliable Baseline
    - Establish a known good state for the cluster.
- Easy to deploy testing

### General Info

Leverages PyTest to run tests and generate HTML reports.

Uses a center cluster.json file to manage IP addresses, creds.

Primarily supports only Ubuntu based distros.

- Test categories
    - Host OS, BIOS, Firmware
    - Burn in, AGFHC, Stress testing
    - RAW IB performance and RCCL performance
    - Training performance


