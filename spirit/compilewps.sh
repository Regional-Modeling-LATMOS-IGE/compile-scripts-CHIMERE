#!/bin/bash
#-------- Set everything for WPS compilation on SPIRIT --------
# Léo Clauzel (leo.clauzel@univ-grenoble-alpes.fr)
#07.10.2022

#---Select WPS version---
export WRF_DIR=../WRFV3_cpl371

#---Load module + export variable + set environment---
module purge
module load intel/19.0.8.324
module load openmpi/4.0.7
module load netcdf-c/4.7.4-mpi
module load netcdf-fortran/4.5.3-mpi
module load jasper/2.0.32
module load hdf5/1.10.7-mpi

export CC=icc
export FC=ifort
export F90=ifort
export F77=ifort
export CXX=icpc
export FCFLAGS=-m64
export FFLAGS=-m64

export JASPERLIB=/home/lclauzel/WRF_setup/Build_WRF/my_wrf_link/lib
export JASPERINC=/home/lclauzel/WRF_setup/Build_WRF/my_wrf_link/include
export LDFLAGS=-L/home/lclauzel/WRF_setup/Build_WRF/my_wrf_link/lib
export CPPFLAGS=-I/home/lclauzel/WRF_setup/Build_WRF/my_wrf_link/include

export NETCDF=/home/lclauzel/WRF_setup/Build_WRF/my_wrf_link
export NETCDF_HOME=$NETCDF
export NETCDF_FORTRAN_HOME=$NETCDF
export NETCDF_LIB=$NETCDF/lib
export NETCDF_INCLUDE=$NETCDF/include
export NETCDF_BIN=$NETCDF/bin
export NETCDF_FORTRAN_LIB=$NETCDF/lib
export NETCDF_FORTRAN_INCLUDE=$NETCDF/include
export NETCDF_FORTRAN_BIN=$NETCDF/bin

export OPENMPI=${OPENMPI_ROOT}
export OMPI_CC=$CC
export OMPI_CXX=$CXX
export OMPI_FC=$FC
export ESMF_COMM=openmpi
export MPI_ROOT=${OPENMPI_ROOT}

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_LIB"

export WRF_EM_CORE=1
export WRF_NMM_CORE=0
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
ulimit -s unlimited
ulimit unlimited
unset MPI_LIB

#---Configure WPS---
echo "---- Start WPS compilation -----"
./compile 2>&1 | tee compile.log
du -sh geogrid/src/geogrid.exe
du -sh metgrid/src/metgrid.exe
du -sh ungrib/src/ungrib.exe
echo "==> Compilation completed <=="
