#
# Makefile for the grid-based semi-Lagrangian water temperature model, RBM10_VIC
#
# Start of the makefile
#
# Defining variables
#
objects = reservoir.o\
          Block_Energy.o Block_Reservoir.o\
	  Energy.o reservoir_subroutine.o
	 	  
f90comp = gfortran
# Makefile
reservoir: $(objects)
	$(f90comp) -o reservoir $(objects)
Block_Energy.o: Block_Energy.f90
	$(f90comp) -c Block_Energy.f90
block_energy.mod: Block_Energy.f90
	$(f90comp) -c Block_Energy.f90
Block_Reservoir.o: Block_Reservoir.f90
	$(f90comp) -c Block_Reservoir.f90
block_reservoir.mod: Block_Reservoir.o Block_Reservoir.f90
	$(f90comp) -c Block_Reservoir.f90
Energy.o: block_energy.mod Energy.f90
	$(f90comp) -c Energy.f90
reservoir_subroutine.o: block_reservoir.mod reservoir_subroutine.f90
	$(f90comp) -c reservoir_subroutine.f90
reservoir.o: block_energy.mod block_reservoir.mod reservoir.f90
	$(f90comp) -c reservoir.f90

# Cleaning everything
clean:
	rm block_energy.mod block_reservoir.mod\
           reservoir
	rm $(objects)
