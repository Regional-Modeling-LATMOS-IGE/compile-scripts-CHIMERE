#-*-makefile-*-

include		Makefile.hdr

LDFLAGS =       $(NETCDFLIBS)

# compilation option for OASIS
FLAGS_dirPSMILE=-I${oasis_dir}/bin/build/lib/psmile.${CHAN}/
OASISFLAGS_LIB=${oasis_dir}/bin/lib/libpsmile.${CHAN}.a ${oasis_dir}/bin/lib/libmct.a ${oasis_dir}/bin/lib/libmpeu.a ${oasis_dir}/bin/lib/libscrip.a

RM_LIST =	*.a *.o *.e *.mod core


all:		chimere prep chemprep domains meteo-ecm

chimere:	pncvar libsoap libiso libtools libmodel main
		$(MPIFC) -o chimere.e  $(FFLAGS) $(OBJSmain)	\
		$(OBJSOAP) $(OBJSiso) $(OBJStools) $(OBJSmodel) $(OBJSpncvar)	\
		$(LDFLAGS)  $(FLAGS_dirPSMILE)		\
		$(OASISFLAGS_LIB) $(FLAGS_STDCXX)

oasis:		oasis-makedirs makemct makelibs makepsmile

.PHONY:		chimere all main libiso libtools libmodel prep


#------------------------------------------------------------------------------
# specific format of isoropia files		
OBJSiso =	isocom.o isofwd.o isorev.o 

libiso: 	$(OBJSiso)

#------------------------------------------------------------------------------
# c++ SOAP files
OBJSOAP =	soap.o

libsoap: 	$(OBJSOAP)

#------------------------------------------------------------------------------

OBJStools =	calendar.o io.o subs.o

SRCtools =      calendar io subs

libtools:
		for fic in ${SRCtools} ; do \
		echo $$fic ; \
			$(REALFC) -I. -o $$fic.o $(FFLAGS) -I. -c $$fic.F90 ; \
		done

#------------------------------------------------------------------------------

OBJSmodel =  chimere_consts.o chimere_params.o chisis_exchanges.o	\
		chimere_common.o gridvars.o interp_tools.o ncvar.o			\
	    	fjx_cmn_mod.o fjx_sub_mod.o atmphys.o chimere_allocs.o 		\
	    	fjx_init_mod.o worker_message_subs.o absor.o integer_chemistry.o		\
	    	chemistry.o chem.o coagu.o depaero.o humidaero.o		\
	    	deposition.o depvel.o depwet.o emissions.o		\
	    	equilibrium.o henry.o call_soap.o searchinterv.o evaporation.o	\
	    	write_depo.o outprint.o worker_bc.o	prep_aemis.o prep_femis.o \
	    	renewhour.o readmetro.o	\
	    	checkcfl.o calc_deepconv.o calc_tiedke.o calc_winw.o	\
	    	calc_turb.o met2chim.o worker_dust.o write_bemis.o write_semis.o write_demis.o	\
	    	diagbio_megan.o worker_bio.o	worker_salt.o	\
	    	diagpol_science.o worker_pol.o worker_dms.o\
	    	prep_temis.o meteo-prepwrf.o aerosol_effects.o iniworker.o \
	    	interlin_N.o intermin.o interval.o	\
	    	locvalues.o inter_aeroorg.o nuclea.o		\
	    	nucleation.o photorates_fastj.o resuspension.o	\
	    	physics.o phys_aerodiam.o iniconc.o calcqt.o phys_ph.o ppm.o		\
	    	rates.o sedim.o surfcalc.o twostep_mod.o splitting.o vanleer.o dl99.o thermo.o		\
	    	thermow.o transmix.o prodloss.o prodloss_trans.o prodloss_aero.o 		\
	    	lidar.o vertav.o vtransport.o 	\
	    	wdeposition.o zenith.o readhour.o worker.o  inichimere.o	\
	    	inicdf.o iniaero.o initimesteps.o \
	    	inicoef.o  coagulation_kernel.o \
	    	profile.o inigeom.o inichem.o	\
	    	findspec.o inifastj.o inidepo.o iniemis.o ini_demis.o	\
	    	ini_bemis.o ini_semis.o iniout.o iniend.o 	\
	    	ini_norm.o inidepout.o          		\
	    	meteo-prep_bilin.o

libmodel:	pncvar ${OBJSmodel}

# specific rules of libmodel

# pgf90 preprocessor does not understand the "##" operator
ifeq	($(COMPILO),BROKEN_CPP)
worker_message_subs.o:		worker_message_subs.F90 chimere_params.o chimere_common.o gridvars.o
				$(CPP) worker_message_subs.F90 worker_message_subs.f 
				$(MPIFC) -o worker_message_subs.o $(FFLAGS) -I.  -c worker_message_subs.f
				$(RM) worker_message_subs.f
endif

#------------------------------------------------------------------------------
OBJSmain =      chimere.o

main:		libmodel ${OBJSmain}
#------------------------------------------------------------------------------

OBJSprep =      chimere_consts.o chimere_params.o interp_tools.o \
		chimere_common.o gridvars.o params_bc.o ncvar.o

prep:		${OBJStools} chisis_exchanges.o pncvar_common.o chimere_consts.o chimere_common.o gridvars.o  chimere_params.o chimere_consts.o interp_tools.o prep_bc.e prep_chimere.e prep_mie.e

pncvar_common.o:		chimere_params.o
pncvar.o:		chimere_consts.o chimere_params.o
interp_tools.o:		chimere_params.o
chimere_common.o:	gridvars.o


params_bc.o:		ncvar.o
prep_bc.o:		params_bc.o

prep_mie.o:		prep_mie.F90
			$(REALFC) -o prep_mie.o $(FFLAGS) -I. -c prep_mie.F90

prep_mie.e:		prep_mie.o spher.o
			$(REALFC) -o prep_mie.e prep_mie.o spher.o $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

prep_bc.o:		prep_bc.F90
			$(REALFC) -o prep_bc.o $(FFLAGS) $(NORANGECHK) -c prep_bc.F90 $(FLAGS_dirPSMILE) $(OASISFLAGS_LIB)

spher.o:		spher.f
			$(REALFC) -o spher.o $(F77FLAGS) -c spher.f

# this .e rule only for the prep executable files to create
%.e:			%.o
			$(REALFC) -o $@ $<  $(FFLAGS) $(OBJSprep) $(LDFLAGS) $(OBJStools)
#------------------------------------------------------------------------------
OBJSmeteo-MM5 = 	meteo-prepmm5.o meteo-prep_bilin.o meteo-mm5_consts.o interp_tools.o pncvar_common.o ncvar.o

meteo-MM5:	libtools prepmm5.e

prepmm5.e:	$(OBJSmeteo-MM5)
		$(REALFC) -o $@ $(OBJSmeteo-MM5) $(FFLAGS_BIG) $(LDFLAGS) ${OBJStools} $(NETCDFLIBS)

subs.o:		calendar.o

meteo-prepmm5.o:	meteo-prepmm5.F90 meteo-mm5_consts.o interp_tools.o  ncvar.o

meteo-prep_bilin.o:	interp_tools.o 
#------------------------------------------------------------------------------
OBJSmeteo-ECM = 	meteo-prepecm.o meteo-ecm_par.o meteo-ecm_consts.o meteo-prep_bilin.o interp_tools.o  pncvar_common.o ncvar.o

meteo-ecm:	libtools prepecm.e

prepecm.e:	${OBJSmeteo-ECM}
		$(REALFC) -o $@ ${OBJSmeteo-ECM} $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS) -L${GRIBLIB} -lgrib_api -lgrib_api_f90

meteo-prepecm.o:	meteo-ecm_par.o meteo-ecm_consts.o interp_tools.o ncvar.o

subs.o:		calendar.o

meteo-prep_bilin.o:	interp_tools.o
#------------------------------------------------------------------------------
chemprep:	libtools chemprep-families.e chemprep-distrib.e

chemprep-families.e:	chemprep-families.F90
			$(REALFC) -o $@ $(FFLAGS) $< ${OBJStools} $(NETCDFLIBS)
chemprep-distrib.e:	chemprep-distrib.F90
			$(REALFC) -o $@ $(FFLAGS) $< ${OBJStools} $(NETCDFLIBS)
#------------------------------------------------------------------------------
OBJSdomains = 	interp_tools.o pncvar_common.o ncvar.o chimere_consts.o chimere_params.o
 
domains:	libtools domains-extract_landuse.e domains-remap_ef.e domains-extract_geog.e \
                domains-extract_z0.e domains-extract_mineral.e domains-extract_erod.e domains-extract_pollen.e \
                domains-extract_dms.e calcnxx.e domains-calc-hcoord.e

domains-extract_landuse.e:      domains-extract_landuse.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_landuse.o:      $(OBJSdomains)

subs.o:         calendar.mod

domains-extract_z0.e:     domains-extract_z0.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(FFLAGS) $(LDFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_z0.o:     $(OBJSdomains)

domains-remap_ef.e:	domains-remap_ef.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(FFLAGS) $(LDFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-remap_ef.o:	$(OBJSdomains)

domains-extract_geog.e:		domains-extract_geog.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_geog.o:		$(OBJSdomains)

domains-extract_mineral.e:	       domains-extract_mineral.o $(OBJSdomains)
	       $(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_mineral.o:	       $(OBJSdomains)

domains-extract_erod.e:	       domains-extract_erod.o $(OBJSdomains)
	       $(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_erod.o:	       $(OBJSdomains)

domains-extract_pollen.e:      domains-extract_pollen.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_pollen.o:      $(OBJSdomains)

domains-extract_dms.e:        domains-extract_dms.o $(OBJSdomains)
		$(REALFC) -o $@ $<  $(OBJSdomains) $(LDFLAGS) $(FFLAGS) ${OBJStools} $(NETCDFLIBS)

domains-extract_dms.o:        $(OBJSdomains)

%.o:		%.F90
		$(REALFC) -o $@  -c $< $(FFLAGS)

%.mod:          %.F90
		$(REALFC) -o $*.o $(FFLAGS) -c $<
#------------------------------------------------------------------------------
#
# Rules for creating OASIS build and library directories
#
oasis-makedirs:
		@mkdir -p $(ARCHDIR)/build/lib/scrip
		@mkdir -p $(ARCHDIR)/build/lib/mctdir
		@mkdir -p $(ARCHDIR)/build/lib/mct
		@mkdir -p $(ARCHDIR)/build/lib/psmile.${CHAN}
		@mkdir -p $(ARCHDIR)/lib
#------------------------------------------------------------------------------
#
# Rules for compiling mpeu/mct library
#
makemct:
	@echo "=> Compiling library mpeu and mct"
	(cd $(ARCHDIR)/build/lib/mctdir; \
	 cp -f -r -p $(oasis_dir)/lib/mct/* .;\
         ./configure MPIFC="$(my_mpif90)" FC="$(my_mpif90)" CC="$(my_mpicc)" ;\
         $(MAKE) ; \
         cp -f ./*/lib*.a   $(ARCHDIR)/lib/; \
         cp -f ./*/*.o    $(ARCHDIR)/build/lib/mct/; \
         cp -f ./*/*.mod  $(ARCHDIR)/build/lib/mct/;)
#------------------------------------------------------------------------------
#
# Rules for compiling the libraries scrip and psmile
#
makelibs:
	@echo "=> Compiling library scrip"
	(export FFLAGS="-g -ffree-line-length-0 -fbounds-check ${CPPDEF} -I${NETCDF_INCLUDE1} -I${NETCDF_INCLUDE2}"; \
	 cd $(ARCHDIR)/build/lib/scrip; \
	 cp -f $(oasis_dir)/lib/scrip/src/Makefile .;\
         $(MAKE) all )

makepsmile:
	@echo "=> Compiling library psmile"
	(cd $(ARCHDIR)/build/lib/psmile.${CHAN} ; \
         cp -f $(oasis_dir)/lib/psmile/src/Makefile . ; \
         $(MAKE) all )
#------------------------------------------------------------------------------
OBJSpncvar = 	pncvar_common.o pncvar.o

pncvar:		pncvar_common.o pncvar.o

pncvar.o:	pncvar.F90
		$(MPIFC) -o pncvar.o $(FFLAGS) -c pncvar.F90
#------------------------------------------------------------------------------
# General rules

%.o:		%.F90
		$(MPIFC) -I. $(FLAGS_dirPSMILE) -o $@ $(FFLAGS) -c $<

%.o:		%.f
		$(REALFC)  -o $@ $(F77FLAGS) -c $<

soap.o:		soap.cpp
		$(REALCC) -o soap.o -c soap.cpp -I $(BLITZLIB)

clean:
		$(RM) $(RM_LIST)
