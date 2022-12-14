# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).



## [36.0.0] - 2022-12-14

Release for 3.6.0 GA

### Major changes

- Support for CP4WAIOPS 3.6.0

### Minor changes

- Added Business Criticalities
- Option to freeze the Catalog version





## [35.1.6] - 2022-12-06

### Fixes

- Fixed patching for valid ingress certificates




## [35.1.5] - 2022-11-17

### Major changes

- Added AI Manager Cards
- Added Turbonomic Demo Content




## [35.1.4] - 2022-11-15

### Major changes

- Added Instana to the mix (mostly stolen from Luca Floris - thanks!!!)




## [35.1.3] - 2022-11-11

### Major changes

- A lot of consolidation for integration into https://github.com/IBM/cloud-pak-deployer



## [35.1.2] - 2022-10-27

### Major changes

- Corrected a bug with links in the Demo UI 
- Secured routes for RobotShop, LDAP, Spark



## [35.1.1] - 2022-10-26

### Major changes

- Compatible with 3.5.1
- Added possibility to use custom sizing configurations



## [35.0.5] - 2022-10-23

### Major changes

- Update to DemoUI - new Interface design to match Techzone



## [35.0.5] - 2022-10-21

### Major changes

- Update to DemoUI - separate Namespace
- Corrected blocking installation for DemoUI



## [35.0.4] - 2022-10-12

### Major changes

- OpenLDAP with persistence - thanks Włodzimierz Dymaczewski



## [35.0.3] - 2022-09-30

### Major changes

- Added scripts to check installation



## [35.0.2] - 2022-09-28

Release for 3.5.0 GA

### Major changes

- Support for CP4WAIOPS 3.5.0




## [35.0.1] - 2022-09-08

Realease for 3.5.0 FVT on OCP VPC 2

### Major changes

- Support for OCS/ODF
- New AWX Version 
- Corrected AWX execution bug




## [35.0.0] - 2022-08-29

Realease for 3.5.0 FVT 

### Major changes

- Support for disruptionCostPerMin
- Adapted LAD model






## [34.1.0] - 2022-06-29

Realease for 3.4.1 GA. 

### Major changes

- Support for version WAIOPS 3.4.1
- Re-added fixed ChangeRisk training






## [34.0.2] - 2022-06-29

Realease for 3.4.0 GA. 
Some specifics apply: please see the README file.

### Major changes

- Support for version WAIOPS 3.4
- Completely revamped the Ansible project structure

### Changed features

- All steps for demo content are now automated



## [34.0.1] - 2022-06-14

Complete rewrite for future integration into CloudPak Deployer.
The installation is now based on configuration files containing the features to be installed.
For a complete example see ./ansible/configs/cp4waiops-roks-all-33.yaml 

### Major changes

- New file structure



## [34.0.0] - 2022-06-09

Realease for Field Validation Testing. 
Some specifics apply: please see the README file.

### Major changes

- Support for version WAIOPS 3.4
- All steps can be executed sequentially as connections are getting created by the script

### Changed features

- Updated AWX based install

### Fixes

- Fix for training not running through
- Fix for Turbonomic install