# Lab VM setup

## Prerequisites

The following softwares have to be installed on you host machine

- Git client [download here](https://git-scm.com/downloads)
- Virtualbox [download here](https://www.virtualbox.org/wiki/Downloads)
- Vagrant [download here](https://www.vagrantup.com/downloads.html)
- Bash command line (Git bash, Moba or Cygwin if you are on Windows) 

## VM provisioning

Install the Vagrant hostmanager plugin

```
$ vagrant plugin install vagrant-hostmanager
```

Then clone the repo and build the VM using Vagrant

```
$ git clone https://github.com/sunnyvale-academy/SNY.OSS.TRF.01.01.00.git
$ cd SNY.OSS.TRF.01.01.00/vagrant
$ vagrant plugin install vagrant-hostmanager
```

Enter into the newly born VM

```
$ vagrant ssh
```

