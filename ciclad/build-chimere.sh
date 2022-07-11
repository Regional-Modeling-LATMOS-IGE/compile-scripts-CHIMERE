#!/bin/bash
export LANG=en_US
export LC_NUMERIC=C
export LC_ALL=C
ulimit -s unlimited

# Main script for compilation of CHIMERE + OASIS

export chimere_root=`pwd`
arch_defined=false
export my_bigarray=Yes
compil_mode=PROD
compile_oasis=true

# Where are the source codes
source ./mychimere/statcodes_paths.sh

# Deal with prompt 
while (($# > 0))
do
    case $1 in
        "-h"|"--h"|"--help"|"-help") 
            echo "build-chimere.sh - installs CHIMERE and OASIS3-MCT on your architecture"
            echo "build-chimere.sh [options]"
            echo "      [ -h | --h | -help | --help ] : this help message"
            echo "      [--dev | --devel] : compilation in development/debug mode (default : production mode)"
            echo "      [--mychimere | --arch arch] : to choose target architecture (file mychimere/mychimere-arch must exist - default : last architecture used)"
            echo "      [--avail] : to know available target architectures"
            echo "      [--no-oasis] : to not compile oasis (if already done with same compiler)"
            exit ;;
        "--mychimere"|"--arch") arch=$2 ; arch_defined=true ; shift ; shift ;;
        "--devel"|"--dev") compil_mode=DEVEL ; shift ;;
        "--prod") compil_mode=PROD ; shift ;;
        "--prof") compil_mode=PROF ; shift ;;
        "--avail") ls mychimere/mychimere-* | cut -d"-" -f2 | sed 's/^/    /'  ; exit ;;
        "--no-oasis") compile_oasis=false  ; shift ;;
        *) code=$1 ; shift ;;

    esac
done

export my_mode=${compil_mode}

./scripts/chimere-banner.sh c


# Initialize variables
if ${arch_defined}
then 
    if test -f mychimere/mychimere-${arch}
    then 
        \rm -f src/mychimere.sh
        ln -s ${chimere_root}/mychimere/mychimere-${arch} src/mychimere.sh
    else
        echo "Architecture file mychimere/mychimere-${arch} does not exist"
        echo 'Provide an existing one  with : ./build-chimere.sh --arch myarch'
        echo 'List of available architecture file :'
        ls mychimere/mychimere-* | cut -d"-" -f2 | sed 's/^/    /' 
        exit 1
    fi
elif test -e src/mychimere.sh
then
    echo " WARNING : no target architecture file "
    echo " WARNING : using older architecture file "
    ls -l src/mychimere.sh | cut -d">" -f2
    arch=`ls -l src/mychimere.sh | cut -d">" -f2 | awk -F/ '{print $NF}' | cut -d"-" -f2`
else
    echo 'No architecture file found. You need one'
    echo 'Provide if with : ./build-chimere.sh --arch myarch'
    echo 'List of available architecture file :'
    ls mychimere/mychimere-* | cut -d"-" -f2 | sed 's/^/    /' 
    exit 1
fi

echo ' '

source src/mychimere.sh 

./scripts/check_config.sh

rm -f src/Makefile.hdr || exit 1
ln -s ../mychimere/makefiles.hdr/${my_hdr} src/Makefile.hdr || exit 1

# MAKE,AWK and NCDUMP are set by the calling script. We check it again
${my_make} --version 2>/dev/null >/dev/null || \
    { echo "You need gmake to run CHIMERE. Bye ..."; exit 1; }

chimverb=5
chimbuild=${chimere_root}/build
exedir=${chimere_root}/exe_${my_mode}
tmplab=`date +"%s"`
ithermo=1
soatyp=1
soa="h2o"
export ARCHDIR=${chimbuild}/bin   # for oasis compilation
export COUPLE=${oasis_dir}

if [ ${soatyp} = "5" ] ; then
   soa="h2or"
fi

# Compilation of programs in the ${chimbuild} directory

mkdir -p ${chimbuild}


mkdir -p ${exedir}


#---------------------------------------------------------------------------------------

compildef=`grep ^REALFC ${chimere_root}/src/Makefile.hdr|sed s/[[:blank:]]//g`
compilo=`eval echo ${compildef}|sed s,REALFC,,|sed s,=,,`
unset compildef

which $compilo >/dev/null 2>&1 || { echo "${0}: No real compiler defined. Bye."; exit 1; }

if [ $chimverb -ge 2 ] ; then
   echo "   Compiler: "$compilo
   echo "   Status in: "${garbagedir}/make.${tmplab}.log
   echo "   Using ${my_mode} mode for compiling under architecture ${arch}"
   echo " "
fi

cd ${chimbuild}

if [ -d ${exedir} ] ; then
   [ ${chimverb} -gt 3 ] && echo "   Removing ${exedir}"
   rm -rf ${exedir}
fi

# if a directory already exists, copy in the TMP

imakecompil=1

mkdir -p ${exedir}

wait

if [[ $chimverb -ge 2 ]] ; then
echo "   Copy of source files"
fi

\cp -fp ${chimere_root}/src/*                       ${chimbuild}

echo "   Use netcdf4/HDF5 parallel library"

# if the user wants to force the compilation, make clean

cd ${chimbuild}

${my_make} clean >/dev/null 2>&1

echo "   Start compilation"

# OASIS compilation
if ${compile_oasis} ; then
    echo "   Compiling OASIS..."
    \rm -rf bin
    ${my_make} oasis > ${garbagedir}/make.oasis.${tmplab}.log 2>&1
    if [ $? -ne 0 ] ; then
    echo
    echo "================================================="
    tail -20 ${garbagedir}/make.oasis.${tmplab}.log
    echo "================================================="
    echo "OASIS compilation aborted"
    echo "Check file ${garbagedir}/make.oasis.${tmplab}.log"
    echo
    exit 1
    fi
    cp -r ${chimbuild}/bin ${oasis_dir}/
fi

echo "   Compiling CHIMERE..."
${my_make} all > ${garbagedir}/make.${tmplab}.log 2>&1

if [ $? -ne 0 ] ; then
    echo
    echo "================================================="
    tail -20 ${garbagedir}/make.${tmplab}.log
    echo "================================================="
    echo "CHIMERE compilation aborted"
    echo "Check file ${garbagedir}/make.${tmplab}.log"
    echo
    exit 1
fi

N_warnings_gfortran=`grep -c "Warning" ${garbagedir}/make.${tmplab}.log`
N_warnings_ifort=`grep -c "remark" ${garbagedir}/make.${tmplab}.log`
N_warnings=$(($N_warnings_ifort+$N_warnings_gfortran))
if [ ${N_warnings} -ne "0" ] ; then
    echo -e "\033[01;31;1m   "${N_warnings}" Warnings in CHIMERE compilation. Check file ${garbagedir}/make.${tmplab}.log \033[m"
fi

# if the compilation is OK, save in exedir

[ $? -eq 0 ] || { echo "Abnormal termination of chimere-compil.sh"; exit 1; }

echo -n "   Compilation OK. Saving compiled code to ${exedir}..."
echo


# Copy of results in the EXE directory
# only fortran , C and executable files

rm -rf ${exedir} && mkdir ${exedir}

cp -r *.F90 *.e *.cxx* *.hxx *.f *.cpp *.h mychimere.sh ${exedir} || { echo " failed. Bye"'!' ; exit 1; }

# update date files
touch ${exedir}/*.F90

ldd ${exedir}/*.e >> ${garbagedir}/checkConfig.log
cd ${chimere_root}

exit 0

