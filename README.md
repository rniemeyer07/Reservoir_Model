## Two-Layer Reservoir Model
- **A simple two-layer heat and mass balance reservoir model, written in fortran (90)**
- **Authors: Ryan Niemeyer, Yifan Cheng, John Yearsley, and others**
- **University of Washington - Computational Hydrology Lab**

####Conceptual model of stratified reservoir:
![alt text](https://github.com/rniemeyer07/Reservoir_Model/blob/master/Two_layer_diagram2.png "two-layer reservoir")

![alt text] (<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Two_layer_diagram2.png" width="500"> "two-layer reservoir")
####Conceptual model of two-layer energy fluxes:
![alt text](https://github.com/rniemeyer07/Reservoir_Model/blob/master/Two_layer_conceptual_diagram.png "conceptual model of energy fluxes")

####File descriptions:
  - **Block_Energy.f90**: parameters for energy subroutine (originated from RBM Block)
  - **Block_Reservoir.f90**: parameters for the model
  - **Block_Flow.f90**: parameters for the "flow_subroutine.f90" (continuity/mass balance equation)
  - **reservoir.f90**: main program that calls each subroutine
  - **density_subroutine.f90**: calculates density of incoming river flow, epilimnion, and hypolimnion
  - **flow_subroutine.f90**: continuity/mass balance equation - calculates the flow into hypolimnion 
      and hypolimnion (based on the density) and calculates change in volume of each layer
  - **Energy.f90**: RBM's energy subroutine to calculate surface energy exchange
  - **reservoir_subroutine.f90**: calculate transfer of energy between layers through advection, 
      diffusion, and surface energy
  - **input_file**: file path of line 1- comments, line 2- flow in to reservoir, line 3-flow out reservoir, 
      line 4-energy flux (from VIC), line 5-measured stream temperatures, line 6-measured releases
  - **reservoir_file**: file with information about each reservoir to be modeled. line 1-column names,
      line 2 to n-rows of data. Start node is upstream point (where water enters the reservoir), 
      end node is downstream point (where water exits the reservoir)

####Model code flow diagram:
![alt text](https://github.com/rniemeyer07/Reservoir_Model/blob/master/two-layer_model_flow.png "two-layer diagram")

####To run the model:
Note: assuming input_file and reservoir_file are ready and all files for the input_file are present
  1. enter "*make clean*" - remove any old compiled fortran code
  2. enter "*make*" - compile the fortran code
  3. enter "*./reservoir input_file reservoir_file*"
