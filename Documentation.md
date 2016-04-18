## Documentation of Two-Layer Reservoir Model
- **Authors: Ryan Niemeyer, Yifan Cheng, John Yearsley, and others**
- **University of Washington - Computational Hydrology Lab**

####Table of Contents:
1. Introduction
2. Theoretical Background
  1. Advection
  2. Diffusion
  3. Surface Energy
3. Subroutines
  1.  Water density
  2.  Mass Balance
  3.  Surface Energy
  4.  Change in temperature
  5.  Blocks
3. Testing
  1.  Numerical
    1. Advection
    2. Diffusion
    3. Surface Energy
  2.  Analytical
    1. Advectoin
    2. Diffusion
    3. Surface Energy
4. Conclusions

####1. Introduction:
Reservoirs in rivers with longer residence times, like lakes, can thermally stratify in the summer. Due to incoming solar and longwave radiation at the surface, the reservoir forms a warmer upper layer, called epilimnion, while a deeper layer called the hypolimnion remains cooler. When stratification occurs, a sharp change in temperature is observed between the epilimnion and hypolimnion. This border is called the thermocline. To accurately model stream temperature in a river system with reservoirs, we developed this two-layer reservoir model. The goal for this model is that it can both be a stand alone simple model and also is being incorporated into the [RBM](http://www.hydro.washington.edu/Lettenmaier/Models/RBM/) distributed stream temperature model. 

####2. Theoretical Background:
This two-layer reservoir model was derived from equations for changes in temperature in the epilimnion and hypolimnoin from equations 31.2 and 31.3 in "Surface Water Quality Modeling" (Chapra, 1997, McGraw Hill).Since both temperature and volume change between time steps, we added a *dV/dt* component to each layer's equation. The change in epilimion temperature equations is as follows:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2CEpil1.png" width="520"> (Eqn. 1)

where, T<sub>e</sub> is epilimnion temperature, T<sub>h</sub> is hypolimnion temperature, V<sub>e</sub> is epilimnion volume, Q<sub>in,e</sub> is inflow discharge into epilimnion, T<sub>in,e</sub> (T<sub>in,h</sub>) is inflow temperature for epilimnion (hypolimnion), Q<sub>vert</sub> is advection flow rate between two layers, Q<sub>out,e</sub> is outflow discharge from epilimnion, K<sub>Z</sub> is diffusion coefficient, A<sub>t</sub> is reservoir surface area, J is net surface energy, ρ is density of water, C<sub>p</sub> is heat capacity of water.
  After transfomation to isolate change in temperature, the equation is as follows:
  
<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2CEpil2.png" width="550"> (Eqn. 2)

The change in hypolimnion temperature equations is as follows:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2CHypo1.png" width="500"> (Eqn. 3)

where Q<sub>in,h</sub> is inflow discharge into hypolimnion and (Q<sub>out,h</sub> is outflow discharge of the hypolimnion.
  After transfomation to isolate change in temperature, the equation is as follows:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2CHypo2.png" width="550"> (Eqn. 4)

Equations 2 and 4 were used in the source code to simulate temperature in our reservoir model. We assume the epilimnion and hypolimnion are well mixed within the layers, but energy fluxes across the border are controlled by advection and diffusion.

#####i. Advection:
Advection includes inflow, outflow, and flow between the epilimnion and hypolimnion. The portion of Q<sub>in</sub> that flows to the epilimnion or hypolimnion is determined by the density of the inflow, hypolimnion and epilimnion.  The equation to determine density is based on 'CRC Handbook of Chemistry and Physics' and determined by the following equation:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2Cdensity.png" width="500"> (Eqn. 5)

where T<sub>x</sub> is temperature of inflow, epilimnion, or hypolimnion, and a - h are constants: a = 1.0000281e-3, b = 999.83952, c = 16.945176, d = 7.9870401e-3, e = 46.170461e-6, f = 105.56302e-9, g = 280.54235e-12, h = 16.87985e-3. 

We also assume the volume of the epilimnion stays constant, therefore Q<sub>in,e</sub> = Q<sub>vert</sub>. 

#####ii. Diffusion:
The diffusion calculation uses K<sub>Z</sub> to calculate the rate of heat transfer via both eddy and molecular diffusion. Diffusion across the thermocline is calculated by:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Eqn%2CK_Z.png" width="500"> (Eqn. 6)

where K<sub>Z,i</sub> D<sub>e</sub> is the depth of the epilimnion, and represents the depth thermocline which is the distance the energy has to cross between the epilimnion and the hypolimnion. We set K<sub>Z,i</sub> to 0.0001 m2/day, so the estimated diffusion eventually has the units m/day. We estimated K<sub>Z,i</sub> from Snodgrass and O'Melia 1975, Quay et al. 1980, Walter et al. 1980, and Benoit and Hemond, 1996 who used either isotopes or numerical estimation based on measured temperatures above and below the thermocline.

Lakes and reservoirs where thermal straitifcation undergo "turnover" in the fall and spring, when the entire water column (i.e. combined epilimnion and hypolimnion) become well-mixed. To simulate this when the date is after August 31st, we set K<sub>Z</sub> to 0.1 if T<sub>e</sub> gets within 2 deg C of T<sub>h</sub>, and K<sub>Z</sub> is set to 1 when T<sub>e</sub> is within 0 deg C of T<sub>h</sub>.

#####iii. Surface Energy:
The net surface energy is based on basic energy physics that includes five components 1) incoming and reflected solar radiation,2) incoming and released longwave radiation, 3) latent heat loss from evaporation, 4) convective energy, and 5) sensible heat gain or loss. This subroutine is the exact same energy subroutine used in RBM, therefore further documentation can be found [here] (http://www.hydro.washington.edu/Lettenmaier/Models/RBM/). Once the net energy is calculated in kcal/sec*m2, the net change in temperature due to net surface energy is calculated with the following equation:

T_energy = (q_surf * delta_t) / (depth_e * density ) heat_c_kcal)  (Eqn. 7)

where .... (**INSERT these values, after the equation **)

####3. Subroutines:

The main program is *reservoir.f90*. This program then calls the four subroutine that are listed below.

#####i. Water Density:
The water density subroutine uses equation 5 to calculate water density of the inflow, hypolimnion, and epilimnion.

#####ii. Mass Balance:
The flow subroutine is a mass balance (i.e. continuity equation) for the epilimnion and hypolimnion. The inflow is read in from VIC flow data. The flow is partitioned to the epilimnion or hypolimnion based on the density of the inflow and the density of the hypolimnion. If the inflow is less dense than the hypolimnion, the inflow is all Q<sub>in,e</sub>, whereas if the inflow is less dense than the hypolimnion the inflow is Q<sub>in,h</sub>. The outflow data can be set to either be the inflow, or can be based on either downstream flow from VIC or measured releases from the reservoir.  These files should be listed in the *input_file*. If the measured releases includes flow partitioned into spillway flow and penstock or sluiceway flow, that can then partion Q<sub>out,e</sub> and Q<sub>out,h</sub> accordingly. 

Once the inflow and outflow are calculated, the subroutine calcualtes for each layer *dV/dt* and the new volume based on the change in volume due to each Q. (**put in those equations?**)

#####iii. Surface Energy:
This surface energy subroutine is the exact subroutine from RBM.

#####iv. Change in temperature:
This final subroutine calculates the change in temperature based on advection, diffusion, and surface energy. First the subroutine calculates the K<sub>Z</sub> based on the the difference in Te and Th and time of year (see 2ii).  Advection is calculated based on Q terms. Energy is calculated with equation 7. The change in temperature due to advection, diffusion, and surface energy are summed to calculate the net change in energy. The outflow temperature is estimated based on the fraction of total outflow between Q<sub>out,e</sub> and Q<sub>out,h</sub>.

#####v. Blocks

*Block_Energy.f90*, *Block_Flow.f90*, and *Block_Energy.f90* are used by the main proram and subroutines to define specific parameters that can then be called and defined in the same way when the Block is called.

####4. Testing - 
To test the validity of our model, we conducted both numerical and analytical solutions. 

#####i. Numerical


######a. Advection:


######b. Diffusion:


######c. Surface Energy:
 
#####ii. Analytical Solutions

**Yifans analytical solutions**

######a. Advection:


######b. Diffusion:


######c. Surface Energy:
 

####6. Conclusions:
 

####Citations:
Benoit, G. & Hemond, H.F. (1996) Vertical eddy diffusion calculated by the flux gradient method: Significance of sediment-water heat exchange. Limnology and oceanography, 41, 157–168.

Quay, P.D., Broecker, W.S., Hesslein, R.H. & Schindler, D.W. (1980) Vertical diffusion rates determined by tritium tracer experiments in the thermocline and hypolimnion of two lakes. Limnology and Oceanography, 25, 201–218.

Snodgrass, W.J. & O’Melia, C.R. (1975) Predictive model for phosphorus in lakes. Environmental Science & Technology, 9, 937–944.

Walters, R.A. (1980) A time-and depth-dependent model for physical chemical and biological cycles in temperate lakes. Ecological Modelling, 8, 79–96.

Weast, R.C. (editor). (1968) CRC Handbook of Chemistry and Physics, 67th Edition, CRC Press, Inc., Boca Raton, Florida, p. F-5.
