## Documentation of Two-Layer Reservoir Model
- **Authors: Ryan Niemeyer, Yifan Cheng, John Yearsley, Yixin Mao, and Bart Nijssen**
- **University of Washington - [Computational Hydrology Lab] (http://uw-hydro.github.io/)** 
([GitHub site] (https://github.com/UW-Hydro))

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/UW_Hydro_Logo.png" width="200">

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
    1. Energy components: Advection, Diffusion, Surface Energy
    2. Cherokee Reservoir Example
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

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Eqn%2CK_Z.png" width="120"> (Eqn. 6)

where K<sub>Z,i</sub> D<sub>e</sub> is the depth of the epilimnion, and represents the depth thermocline which is the distance the energy has to cross between the epilimnion and the hypolimnion. We set K<sub>Z,i</sub> to 0.0001 m2/day, so the estimated diffusion eventually has the units m/day. We estimated K<sub>Z,i</sub> from Snodgrass and O'Melia 1975, Quay et al. 1980, Walter et al. 1980, and Benoit and Hemond, 1996 who used either isotopes or numerical estimation based on measured temperatures above and below the thermocline.

Lakes and reservoirs where thermal straitifcation undergo "turnover" in the fall and spring, when the entire water column (i.e. combined epilimnion and hypolimnion) become well-mixed. To simulate this when the date is after August 31st, we set K<sub>Z</sub> to 0.1 if T<sub>e</sub> gets within 2 deg C of T<sub>h</sub>, and K<sub>Z</sub> is set to 1 when T<sub>e</sub> is within 0 deg C of T<sub>h</sub>.

#####iii. Surface Energy:
The net surface energy is based on basic energy physics that includes five components 1) incoming and reflected solar radiation,2) incoming and released longwave radiation, 3) latent heat loss from evaporation, 4) convective energy, and 5) sensible heat gain or loss. This subroutine is the exact same energy subroutine used in RBM, therefore further documentation can be found [here] (http://www.hydro.washington.edu/Lettenmaier/Models/RBM/). Once the net energy is calculated in kcal/sec*m2, the net change in temperature due to net surface energy is calculated with the following equation:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Eqn%2Cenergy.png" width="400"> (Eqn. 7)

where delta_T<sub>energy</sub> is the net change in temperature due to the net surface energy exchange, q<sub>surf</sub> is the nex surface energy exchange, and dt is change in time (i.e. simulation time step, typically 86400 seconds).

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

####4. Testing 
To test the validity of our model, we conducted both numerical and analytical solutions. 

#####i. Numerical
The goal of numerical solutions is to plot different a) situations or b) compare summarized data to ensure the model is performing as we would expect. 

######a. Energy components: Advection, Diffusion, and Surface Energy:

First, we looked at the weekly surface energy components to A) ensure each component appeared reasonable, and b) that the net surface energy (Q_net) was positive in the summer and negative in the winter.

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Wkly_energy_components%2CCherokee_Reservoir.png" width="400"> 

We see clearly that shortwave (S_in) and longwave (L_in) are postive and longwave out (Lw,back) is negative.  Also, we see that the net energy change from latent heat (Q_evap) and convection (Q_conv) are minor.  Finally, the net surface energy goes form positive in the spring and summer (gaining energy) to negative in the fall and winter.

Second, we looked at the energy components for the epilimnion. 

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Monthly%2CEpilimnion%2CTemperature_Change%2CCherokee_Reservoir.png" width="400"> 

For the epilimnion, we see clearly that since in our model, advection in equals advection out, the two terms cancel themselves out.  Furthermore, we see surface energy drives fluctuations in annual temperature, with a net gain in surface energy driving summer warming of epilimnion, and a net surface energy loss driving cooling in the winter.  We also see diffusion being close to 0 during the summers, when stratification occurs and the diffusion coefficient is very low. Conversley we see gain in energy in the winter when the diffusion of energy from hypolimnion enters the epilimnion. 

Finally we looked at the energy components for the hypolimnion. 

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Monthly%2CHypolimnion%2CTemperature_Change%2CCherokee_Reservoir.png" width="400"> 

For the hypolimnion, we see that advection is the dominant energy component. Advection from the epilimnion warms the hypolimnion in the spring and summer. In the winter, diffusion of energy from hypolimnion to epilimnion clearly cools the hypolimnion.

######b. Cherokee Reservoir Example:

To test our model, we used Cherokee Reservoir (36°09'55.6"N 83°29'50.8"W), a large reservoir on the Holston River, a major tributary of the Tenessee River.  We simulated inflow from RVIC and the inflow temperature from an RBM simulation.  The observed data is from a four-year period where USGS measured temperature near Knoxvillie, TN, approximately 40 miles downstream of the Cherokee Reseservoir.  Almost all Cherkoee Reservoir releases are from the penstock, therefore the majority of downstream water will come from the hypolimnion. Below is a plot of observed and simulated stream temperature:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Water_temperature%2CCherokee_Reservoir.png" width="600"> 

We can see that indeed the epilimnion is much warmer than the hypolimnion and observed downstream temperature is relatively similar to the hypolimnion temperature. We initially simulated this reservoir with RBM where the Nash-Sutcliffe Model Efficiency was 0.39. When we incorporated this two-layer reservoir model into RBM (i.e. for a cell that was on a reservoir, this two-layer model was used instead of RBM), the Nash-Sutcliffe efficiency was 0.73. 
 
#####ii. Analytical Solutions

In addition to numerical tests, we calculated analyical solutions to validate our model. Analyitical solutions use Fourier transforms to calcualte a specific solution for a simplified siutaiton, and then then runs the reseroivr model in that situation and compares that analytical solution and simulated output.  In contrast to numerical solutions, this allows for comparison between the model input and calculated solutions that we know are correct.  Although we briefly cover these analytical solutions here, further detail about the analytical solutions, fourier transforms, etc. can be found in the **BLANK (Yifan's analytical solution document)** file.  

######a. Advection:
For the "advection only" analytical solution, we set the hypolimnion and epilimnion temperature to 0 deg C, and the inflow to a constant 20 deg C. This situation can be seen here: 

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Fig%2CAdvec_Only.png" width="400"> 

The simulated T<sub>e</sub> and T<sub>h</sub> and analytical solutions for T<sub>e</sub> and T<sub>h</sub> are plotted below. Simulated temperatures are a solid line and analytical solutions are in a dotted line. We can see that the analytical solutions fit perfectly with the simulated temperature. Therefore we can trust our model indeed is accurate. 

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Analytical_Advection.png" width="400">

######b. Diffusion:
For the "diffusion only" analytical test, we set T<sub>e</sub> to 20 deg C and T<sub>h</sub> to 0 deg C, and isolated diffusion (i.e. set advection and net surface energy to "0"). This idealized situation is represeted in the following conceptual model:


The simulated T<sub>e</sub> and T<sub>h</sub> and analytical solutions for T<sub>e</sub> and T<sub>h</sub> are plotted below. We can see that the simulations (solid line) and analytical solutions (dots) fit quite well.

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Analytical_Diffusion.png" width="400">

However, they were not a perfect fit so we changed dt from 1 day to 1 hour. These update simulations are below. We can see that with an hourly time step, the simulated T<sub>e</sub> and T<sub>h</sub> are nearly identical to the analytical soltuion.

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Analytical_Diffusion2.png" width="400">

######c. Surface Energy:
 For the analytical solution for surface energy exchange, we set diffusion and hypolimnion advection to "0". So we simulated a constant net energy and a constant advection input and output. A conceptual model for this idealized scenario is below:
 
 <img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Fig%2CSolar_Only.png" width="400">

 Since net energy fluctuates from positive in the summer to negative in the winter in typical seasonal climates, we varied the net energy based on a sine function that peaked fluctated between 11.574 and -11.574 J/m<sup>2</sup>/sec. This value was chosen since it was the approximate net energy fluxes at our test site on the Tennessee River Basin in Tennessee, USA. We also simulated a simple sine function variation in energy from 1 to -1 J/m<sup>2</sup>/sec. We simulated a constant T<sub>in,e</sub> of 15 deg C, and identical Q<sub>in,e</sub> and Q<sub>out,e</sub>.
 
 The simulated T<sub>e</sub> for both the 11.574 and 1  J/m<sup>2</sup>/sec net energy were almost identical to the analytical solutions. This reveals that our incorporation of net energy in the model is accurate.
 
<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/figures/Analytical_Solar.png" width="400">

####6. Conclusions:
We used previous conceptions of reservoir models to develop a simple two-layer reservoir model. Based on our numerical and analytical tests, our model indeed performs quite well. The ultimate goal for this model is to incorporated into distributed river and river temperature modeling schemes that use VIC, RVIC, and RBM (see [UW-Hydro code site](http://uw-hydro.github.io/code/) for description of these models). This reservoir model should indeed be useful for this and other applications to simulate temperature in reservoirs.

####Citations:
Benoit, G. & Hemond, H.F. (1996) Vertical eddy diffusion calculated by the flux gradient method: Significance of sediment-water heat exchange. Limnology and oceanography, 41, 157–168.

Quay, P.D., Broecker, W.S., Hesslein, R.H. & Schindler, D.W. (1980) Vertical diffusion rates determined by tritium tracer experiments in the thermocline and hypolimnion of two lakes. Limnology and Oceanography, 25, 201–218.

Snodgrass, W.J. & O’Melia, C.R. (1975) Predictive model for phosphorus in lakes. Environmental Science & Technology, 9, 937–944.

Walters, R.A. (1980) A time-and depth-dependent model for physical chemical and biological cycles in temperate lakes. Ecological Modelling, 8, 79–96.

Weast, R.C. (editor). (1968) CRC Handbook of Chemistry and Physics, 67th Edition, CRC Press, Inc., Boca Raton, Florida, p. F-5.
