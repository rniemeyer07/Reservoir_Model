
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


! use Block_Reservoir  
use Block_Energy
use Block_Reservoir

implicit none

real :: T_epil_temp,T_hypo_temp,volume_e_x,volume_h_x
real :: year, month, day, Q_in, headw_T_in, stream_T_out
real :: air_T, headw_T_out, Q_out, temp_epil, temp_hypo
integer :: nd

! --------------- allocate arrays ------------------
!allocate (Q_in(nd_total))
!allocate (stream_T_in(nd_total))
!allocate (headw_T_in(nd_total))
!allocate (Q_out(nd_total))
!allocate (stream_T_out(nd_total))
!allocate (headw_T_out(nd_total))
!allocate (air_T(nd_total))
!allocate (year(nd_total))
!allocate (month(nd_total))
!allocate (day(nd_total))
!allocate (temp_epil(nd_total))
!allocate (temp_hypo(nd_total))
!allocate (temp_out_tot(nd_total))


! -------------------- to read in variables from comman line ---------
!
! Read total number of days to simulate JRY 
!
!  write(*,*) 'Total number of days of simulation'
! read(*,*) nd_total

 nd_total = 22645

! Read some parameters
!
!  write(*,*) 'Input Inflow (m3/day),Inflow
!  Temperature,temp_epil(1),temp_hypo(1),diffusion coefficient'
!  read(*,*) Q_in_epil,Temp_in,temp_epil(1),temp_hypo(1),v_t

! ----------------- read in input file -------
! Note: the input_file should be entered with fortran executable:
!   i.e. "two_layer_model input_file"
! input_file contains paths to VIC files

 call getarg (1, input_file)
 input_file = TRIM(input_file)

! ------------   data for the Cherokee Reservoir (36.1875, -83.4375)
depth_total = 15 ! in meters
depth_e = depth_total * 0.2
depth_h = depth_total * 0.8
width = 1377  ! in meters
length = 86904 ! in meters
area = width*length
delta_t_sec = 84600.   ! Delta t in seconds
delta_t = 1 ! time is days,  assumes all units in equations are in days

flow_constant = 365/(2*Pi)
! ------------------- initial variables ---------------
volume_e_x = area*depth_e
volume_h_x = area*depth_h

T_epil_temp = 15
T_hypo_temp = 15
 
temp_epil = T_epil_temp ! starting epilimnion temperature at 5 C
temp_hypo = T_hypo_temp ! starting hypolimnion temperature at 5 C
v_t = 0.4  ! set the diffusion coeff.

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
  read(45, '(A)') observed_stream_temp_file
  open(unit=49, file=TRIM(observed_stream_temp_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')

   read(46, *) year,month,day, Q_in &
              , stream_T_in, headw_T_in, air_T


    read(47, *) year,month,day, Q_out, stream_T_out &
               , headw_T_out, air_T


!*************************************************************************
!
!       run through loop
!
!*************************************************************************

! -------- set initial temperatures -------------
!t1 = 15
!t2 = 15

! ------------ start loop ---------------------
do  nd=2,nd_total
      
      print *, T_epil_temp,nd


!*************************************************************************
! read forcings for energy and flow from VIC and RVIC
!*************************************************************************

      ! ------------------ read in in VIC flow data --------------
        read(46, *) year,month,day, Q_in &
              , stream_T_in, headw_T_in, air_T

print *, "trial1"

       flow_in_hyp_x = Q_in*prcnt_flow_epil
        flow_in_epi_x = Q_in*prcnt_flow_hypo

     ! ---------- set outflow to inflow (same out as in)  ---
         read(47, *) year,month,day, Q_out, stream_T_out &
            ,  headw_T_out, air_T
print *, "trial new"

!       Q_in(i) = Q_in_epil
!       ! For test

        flow_out_hyp_x = Q_out*prcnt_flow_hypo
        flow_out_epi_x = Q_out*prcnt_flow_epil

      ! ------------- flow between epilim. and hypolim. ---------
        flow_epi_hyp_x = flow_out_hyp_x

      ! ------------- read in stream temperature data --------

      !  Using value of inflow from command line JRY
      !
      !     flow_Tin(i) = Temp_in

      ! ----------------- read in from VIC data -------------------

      !flow_Tin(nd) = stream_T_in(nd)

!*************************************************************************
! read forcings for energy from VIC
!*************************************************************************

    ! ------- ulpload ENERGY subroutine and read in VIC energy ----
        ! read(48, *) year(i),month(i),day(i), Q_in(i), stream_T_in(i)  &
        !        ,  headw_T_in(i), air_T(i)

    ! call energy(T_0,q_surf,nncell)
    !        q_dot=(q_surf/(z*rfac))
    !        T_0=T_0+q_dot*dt_calc
    !        if(T_0.lt.0.0) T_0=0.0

print *, "trial new1"
       x = nd
      energy_x  =  cos(((x)/flow_constant)+ pi )
!
!      energy_x = 0      ! Surface flux set to zero for testing JRY
!
      energy_x =( (energy_x)*150)*delta_t !converts to Joules/m2 * day
      energy_x = energy_x*area


!***********************************************************************
! read flow schedule (spill and turbine outflows)
!*************************************************************************

     ! ---------- set outflow to inflow (same out as in)  ---
!         read(47, *) year(i),month(i),day(i), Q_out(i), stream_T_out(i) &
!            ,  headw_T_out(i), air_T(i)
!!!!!! Is this a repeat?


!*************************************************************************
!      read inflow and river temperature from rbm simulations
!*************************************************************************
print *, "trial 2"

!*************************************************************************
!      call reservoir subroutine
!*************************************************************************

   call reservoir_subroutine (T_epil_temp,T_hypo_temp, volume_e_x, volume_h_x,nd)
!        T_epil_temp = T_epil_temp
!        T_hypo_temp = T_hypo_temp
!        volume_e_x = volume_e_x
!        volume_h_x = volume_h_x   
        temp_epil = T_epil_temp 
        temp_hypo = T_hypo_temp

!*************************************************************************
!          write output
!*************************************************************************


    write(30,*) nd,temp_epil,temp_hypo,temp_out_tot, stream_T_in &
               , temp_change_ep, temp_change_hyp,advec_in_hypx &
               , advec_out_hypx,dV_dt_hyp, flow_epi_hyp_x, volume_e_x & 
               , volume_h_x, flow_in_epi_x, flow_out_hyp_x

print *,nd,temp_epil,temp_hypo,temp_out_tot, stream_T_in &
               , temp_change_ep, temp_change_hyp,advec_in_hypx &
               , advec_out_hypx,dV_dt_hyp, flow_epi_hyp_x, volume_e_x &
               , volume_h_x, flow_in_epi_x, flow_out_hyp_x





!*************************************************************************
!               update temperatures 
!*************************************************************************

!
! Update temperatures for next time step, for example:
!         temp_epil(1) = temp_epil(2)
!         temp_hypo(1) = temp_hypo(2)
! Or, better (1=epilimnion,2=hypolimnion)
!         T_res(1,1)   = T_res(1,2)
!         T_res(2,1)   = T_res(2,2)
!
end do


end program reservoir
