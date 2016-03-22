
program reservoir
!
!------------------------------------------------------------------------- 
!         Two-layer Reservoir River Temperature model
!              University of Washington - Computational Hydrology Lab
!         Authors: Ryan Niemeyer, Yifan Cheng, John Yearsley, and others
!         Date: February 2016
!
!-------------------------------------------------------------------------

!*************************************************************************
!
!    declare variables and initialize parameters
!
!*************************************************************************

use Block_Energy
use Block_Reservoir
use Block_Flow

implicit none

 real :: T_epil,T_hypo,volume_e_x,volume_h_x
! real :: flow_in_epi_x , flow_in_hyp_x, flow_epi_hyp_x, flow_out_epi_x, flow_out_hyp_x

ncell = 2

allocate (dbt(ncell))
allocate (ea(ncell))
allocate (q_ns(ncell))
allocate (q_na(ncell))
allocate (press(ncell))
allocate (wind(ncell))

 nd_total =  22645

! ----------------- read in input file -------
! Note: the input_file should be entered with fortran executable:
!   i.e. "two_layer_model input_file"
! input_file contains paths to VIC files

 call getarg (1, input_file)
 input_file = TRIM(input_file)

 call getarg (2, reservoir_file)
 reservoir_file = TRIM(reservoir_file)

delta_t = 86400 ! timestep in seconds,  assumes all units in equations are in seconds

! ------------------ read in reservoir data ---------------------
 ! ----- which reservoir to read ----
 nres = 4  ! which reservoir to read
 nres_skip = nres - 1

 OPEN(UNIT=55, FILE=TRIM(reservoir_file), status='old')
   read(55, *)  !skip the first line

 ! ----- skip reservoirs not modeling ----
 do i=1,nres_skip
   read(55,*)
 end do

 ! ----- read in reservoir ------
 read(55, *) dam_number, dam_name, grid_lat, grid_lon, surface_area, length2 &
       ,  depth,  width2, start_node, end_node
 ! print *, dam_name, dam_number

depth_e = depth * depth_e_frac
depth_h = depth * depth_h_frac
volume_e_x = surface_area * depth_e
volume_h_x = surface_area * depth_h
depth_e_inital = depth_e
volume_e_initial = volume_e_x
depth_h_inital = depth_h
volume_h_initial = volume_h_x

! -------------------- Upload files in input file -----------------
! NOTE: once incorporated into RBM, these data will already be called in 
!       the model 
 OPEN(UNIT=45, FILE=TRIM(input_file), status='old')
   read(45, *)  ! skip first line
!
! ----- read in inflow file -----
  read(45, '(A)') inflow_file
  open(unit=46, file=TRIM(inflow_file), ACCESS='SEQUENTIAL', FORM='FORMATTED',STATUS='old')

! ------- read in outflow file -------
  read(45, '(A)') outflow_file
  open(unit=47, file=TRIM(outflow_file), ACCESS='SEQUENTIAL', FORM='FORMATTED',STATUS='old')

! ------- read in energy file -------
  read(45, '(A)') energy_file
  open(unit=48, file=TRIM(energy_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')
!
! ------- read in observed stream temperature file -------
  read(45, *) ! skip the observed data
! read(45, '(A)') observed_stream_temp_file
!  open(unit=49, file=TRIM(observed_stream_temp_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')

! ------- read in observed stream temperature file -------
  read(45, '(A)') releases_file
  open(unit=56, file=TRIM(releases_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')
   read(56, *)  !skip the first line of releases file


! ------------------- initial temperature ---------------
T_epil = 15
T_hypo = 15

K_z = 5.7E-8 ! set the diffusion coeff. in m^2/sec
K_z = K_z / (depth_e/2)  ! divide by approximate thickness of thermocline

!*************************************************************************
!
!       run through loop
!
!*************************************************************************

! ------------ start loop ---------------------
do  nd=1, nd_total
      
      !*************************************************************************
      !      loop to read in flows, calculate volume change
      !*************************************************************************

       call flow_subroutine( flow_in_epi_x, flow_in_hyp_x, flow_epi_hyp_x &
                , flow_out_epi_x, flow_out_hyp_x, volume_e_x, volume_h_x &
                , ratio_sp, ratio_pen)

      !*************************************************************************
      ! read forcings for energy from VIC
      !*************************************************************************

      ! ------- ulpload ENERGY subroutine and read in VIC energy ----
         read(48, *) year, month, day, dbt(1), ea(1), q_ns(1), q_na(1), atm_density  &
                  ,  press(1), wind(1)
      !---------units transform--------------------------------------
            q_ns(1) = J_to_kcal*q_ns(1)  ! W/m**2 to kcal/m**2/sec  
            q_na(1) = J_to_kcal*q_na(1)  ! W/m**2 to kcal/m**2/sec  
            ea(1) = kPa_to_mb * ea(1)             !kPa to mb 
            press(1) = kPa_to_mb * ea(1)          !kPa to mb 

       call surf_energy(T_epil, q_surf, ncell)

      !*************************************************************************
      !      call reservoir subroutine
      !*************************************************************************

        call reservoir_subroutine (T_epil,T_hypo, volume_e_x, volume_h_x)

      !*************************************************************************
      !          write output
      !*************************************************************************


            write(30,*) nd, T_epil, T_hypo, temp_out_tot, stream_T_in &
                       , temp_change_ep, advec_in_epix &
                       , advec_out_epix,dif_epi_x, dV_dt_epi, flow_epi_hyp_x, volume_e_x & 
               , volume_h_x, flow_in_epi_x, flow_out_hyp_x, q_surf, energy_x &
               , advec_out_hypx, advec_in_hypx, advec_epi_hyp, temp_change_hyp


           write(32,*)  T_epil, T_hypo ! , flow_in_epi_x, flow_out_epi_x, flow_epi_hyp_x, flow_out_hyp_x


  ! print *,nd,T_epil,T_hypo ! , flow_out_hyp_x, flow_out_epi_x, volume_e_x,volume_h_x ! print  temperatures in console

end do


end program reservoir
