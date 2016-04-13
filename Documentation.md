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
3. Justification
  1.  Advectoin
  2.  Diffusion
  3.  Surface Energy
4. Conclusions

####Introduction:
Reservoirs in rivers with longer residence times, like lakes, can thermally stratify into a warmer upper layer, called epilimnion, that absorbs incoming radiation and a cooler deeper layer called the hypolimnion. To accurately model stream temperature in a river system with reservoirs, we developed this two-layer reservoir model.  This two-layer reservoir model was derived from equations for changes in temperature in the epilimnion and hypolimnoin from equations 31.2 and 31.3 in "Surface Water Quality Modeling" (Chapra, 1997, McGraw Hill).Since both temperature and volume change between time steps, we added a *dV/dt* component to each layer's equation. The final equations are as follows:

where v
