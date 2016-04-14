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
3. Testing
  1.  Advectoin
  2.  Diffusion
  3.  Surface Energy
4. Conclusions

####1. Introduction:
Reservoirs in rivers with longer residence times, like lakes, can thermally stratify in the summer. Due to incoming solar and longwave radiation at the surface, the reservoir forms a warmer upper layer, called epilimnion, while a deeper layer called the hypolimnion remains cooler. To accurately model stream temperature in a river system with reservoirs, we developed this two-layer reservoir model. The goal for this model is that it can both be a stand alone simple model and also is being incorporated into the [RBM](http://www.hydro.washington.edu/Lettenmaier/Models/RBM/) distributed stream temperature model. 

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

Equations 2 and 4 were used in the source code to simulate temperature in our reservoir model.

#####i. Advection:
Advection includes inflow, outflow, and flow between the epilimnion and hypolimnion. The portion of Q<sub>in</sub> that flows to the epilimnion or hypolimnion is determined by the density of the inflow, hypolimnion and epilimnion.  The equation to determine density is based on **BLANK (Yifan enter)** and determined by the following equation:

<img src="https://github.com/rniemeyer07/Reservoir_Model/blob/master/Eqn%2CHypo1.png" width="500"> (Eqn. 5)
    density_epil = 1.000028*1e-3*((999.83952+16.945176*T_epil)-(7.9870401e-3*(T_epil**2)-46.170461e-6*(T_epil**3))+ &
                       & (105.56302e-9*(T_epil**4)-280.54235e-12*(T_epil**5)))/(1+16.87985e-3*T_epil)
                       
We also assume the volume of the epilimnion stays constant, therefore Q<sub>in,e</sub> = Q<sub>vert</sub>. 

#####ii. Diffusion:
This two-layer reservoir 

#####iii. Surface Energy:
This two-layer reservoir

####3. Subroutines:
This

#####i. Water Density:
This two-layer reservoir

#####ii. Mass Balance:
This two-layer reservoir

#####iii. Surface Energy:
This two-layer reservoir

#####iv. Change in temperature:
This two-layer reservoir

####4. Testing:
This

#####i. Advection:
This two-layer reservoir

#####ii. Diffusion:
This two-layer reservoir

#####iii. Surface Energy:
This two-layer reservoir

####5. Conclusions:
This
