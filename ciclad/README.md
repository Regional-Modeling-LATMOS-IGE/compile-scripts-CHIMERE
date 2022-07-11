**Edited by Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)**
**11/07/2022**

Details for compiling CHIMERE on CICLAD using intel compiler

##This folder contains : 
1. **mychimere-ciclad.ifort**, script for precising where all necessary compilers and libraries are installed on CICLAD
2. **build-chimere.sh**, script to launch the compilation
3. **Makefile**, must replace the current Makefile in the */src* dir

##Step for compiling CHIMERE CICLAD
1. Check your access on CICLAD
2. Download CHIMERE source code (https://www.lmd.polytechnique.fr/chimere/)
3. Replace **eccodes** by **grib_api** where it appears in */src/Makefile* or replace this file by the *Makefile* given in this folder
4. Execute : **./build-chimere.sh --arch ciclad.ifort**
5. To compile WRF v3.7.1 and its preprocessor WPS for coupled simulations, execute : **./build-wrf.sh --arch ciclad.ifort** 
