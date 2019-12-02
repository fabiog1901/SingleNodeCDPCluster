# Single Node CDP Data Center Cluster 

This script automatically sets up a CDP Data Center Trial cluster on the public cloud on a single VM with the services preconfigured in a template file.

As this cluster is meant to be used for demos, experimenting, training, and workshops, it doesn't setup Kerberos and TLS.

### Configuration and installation

- add 2 inbound rules to the Security Group:
  - to allow your IP only, for all ports.
  - to allow the VM's own IP, for all ports.
- ssh into VM and copy this repo.

```bash
sudo su -
yum install -y git
git clone https://github.com/fabiog1901/SingleNodeCDPCluster.git
cd SingleNodeCDPCluster
```

The script `setup.sh` takes 3 arguments:
- the cloud provider name: `aws`,`azure`,`gcp`;
- the template file;
- OPTIONAL the Docker Device disk mount point.

Example: create cluster on AWS using `base.json`

```bash
./setup.sh aws templates/base.json
```

Wait until the script finishes, check for any error.
