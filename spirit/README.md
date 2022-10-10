**Edited by Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)**

**10/10/2022**

Details for compiling CHIMERE on SPIRIT using intel compiler

## Steps for compiling CHIMERE 
1. Check your access on SPIRIT
2. Download CHIMERE source code (https://www.lmd.polytechnique.fr/chimere/)
3. Copy the architecture file (**mychimere-spirit.ifort**) in *mychimere/*
4. Execute **./build-chimere.sh --arch spirit.ifort**

##Steps for compiling WRF for WRF-CHIMERE coupling simulations
1. Copy the configure file **configure.wrf.ifort\_spirit** in *mychimere/config_wrf*
2. Execute **./build-chimere.sh --arch spirit.ifort --wrf**

##Steps for compiling WPS for WRF-CHIMERE coupling simulations
1. Download the WPS source code (https://github.com/wrf-model/WPS)

tested version = WPS4.4
2. Copy **configurewps.sh** and **compilewps.sh** in the WPS directory and check the **WRF\_DIR** path in these files
3. Execute **./configurewps.sh**
4. Execute **./compilewps.sh**
5. Modify **dir\_wps** in *mychimere/statcodes_path.sh*
