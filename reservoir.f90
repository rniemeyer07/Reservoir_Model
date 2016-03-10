
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
real :: air_T, headw_T_out, Q_out, temp_epil, temp_hypo, atm_density, energy_x2
integer :: nd,ncell

ncell = 2

allocate (dbt(ncell))
allocate (ea(ncell))
allocate (q_ns(ncell))
allocate (q_na(ncell))
allocate (press(ncell))
allocate (wind(ncell))
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
depth_e = depth_total * 0.4
depth_h = depth_total * 0.6
width = 1377  ! in meters 
length = 86904 ! in meters
area = width*length
delta_t_sec = 86400.   ! Delta t in seconds
delta_t = 86400 ! time is days,  assumes all units in equations are in days

! ------------------- initial variables ---------------
volume_e_x = area*depth_e
volume_h_x = area*depth_h

T_epil_temp = 15
T_hypo_temp = 15
 
temp_epil = T_epil_temp ! starting epilimnion temperature at 5 C
temp_hypo = T_hypo_temp ! starting hypolimnion temperature at 5 C
v_t = 5.7E-8 ! set the diffusion coeff. in m^2/sec
v_t = v_t / (depth_e/2)  ! divide by approximate thickness of thermocline 

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
  
   read(48, *) year, month, day,  dbt(1), ea(1), q_ns(1), q_na(1), atm_density  &
                ,  press(1), wind(1)


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

        Q_in = Q_in * 0.0283168 ! converts ft^3/sec to m^3/sec

        flow_in_hyp_x = Q_in*prcnt_flow_hypo
        flow_in_epi_x = Q_in*prcnt_flow_epil

     ! ---------- set outflow to inflow (same out as in)  ---
         read(47, *) year,month,day, Q_out, stream_T_out &
            ,  headw_T_out, air_T
print *, "trial new"

!       Q_in(i) = Q_in_epil
!       ! For test

        Q_out = Q_out * 0.0283168 ! converts ft^3/sec to m^3/day


      !  flow_out_hyp_x = Q_out * prcnt_flow_hypo
      !  flow_out_epi_x = Q_out*prcnt_flow_epil
        flow_out_hyp_x = flow_in_hyp_x + flow_in_epi_x
        flow_out_epi_x = 0

      ! ------------- flow between epilim. and hypolim. ---------
                flow_epi_hyp_x = flow_in_epi_x


        !*************************************************************************
        ! read forcings for energy from VIC
        !*************************************************************************

            ! ------- ulpload ENERGY subroutine and read in VIC energy ----
                 read(48, *) year, month, day, dbt(1), ea(1), q_ns(1), q_na(1), atm_density  &
                        ,  press(1), wind(1)
            !---------units transform--------------------------------------
                  
                q_ns(1) = 0.00023885*q_ns(1)  ! W/m**2 to kcal/m**2/sec  
                q_na(1) = 0.00023885*q_na(1)  ! W/m**2 to kcal/m**2/sec  
                ea(1) = 10 * ea(1)             !kPa to mb 
                press(1) = 10 * ea(1)          !kPa to mb 


             call surf_energy(stream_T_in,q_surf,ncell)
             !----------------unit transform---------------------------------
         !       q_surf = q_surf*4186.8        !kcal/m**2/sec to W/m**2     

        !        if(T_0.lt.0.0) T_0=0.0 ! might need to add this below

        print *, "trial new1"
        !       x = nd
        !      energy_x  =  cos(((x)/flow_constant) + pi ) * 100
        !
        !      energy_x = 0      ! Surface flux set to zero for testing JRY

        !      energy_x =(q_surf/(depth_e*rfac))     ! 
        !      energy_x = energy_x !  delta_t_sec  ! converts W/m2 to Joules/m2 * day
        !      energy_x = energy_x * area


        !***********************************************************************
        ! read flow schedule (spill and turbine outflows)
        !*************************************************************************

        !read in any flow from spillway or turbines

        !*************************************************************************
        !      read inflow and river temperature from rbm simulations
        !*************************************************************************
        print *, "trial 2"

        !*************************************************************************
        !      call reservoir subroutine
        !*************************************************************************

           call reservoir_subroutine (T_epil_temp,T_hypo_temp, volume_e_x, volume_h_x,energy_x2)
        !        T_epil_temp = T_epil_temp
        !        T_hypo_temp = T_hypo_temp
        !        volume_e_x = volume_e_x
        !        volume_h_x = volume_h_x   
                temp_epil = T_epil_temp 
                temp_hypo = T_hypo_temp

        ! loop to increase diffusion in fall when epil and hypo temperatures
        ! match

     !   if (  abs(T_epil_temp -  T_hypo_temp) .lt. 1 .and.  month > 8 .or. month < 4 ) then
     !           v_t = 1.04E-5  ! set high v_t when turnover occurs
     !   else if(month == 4)  then ! on april 1st, reset diffusion to low value 
     !           v_t = 5.78E-8  ! set the diffusion coeff. in m^2/day
     !           v_t = v_t / (depth_e/2) ! divide by approximate thickness of thermocline 
     !    end if

        !*************************************************************************
        !          write output
        !*************************************************************************


            write(30,*) nd, temp_epil, temp_hypo, temp_out_tot, stream_T_in &
                       , temp_change_ep, advec_in_epix &
                       , advec_out_epix,dif_epi_x,energy_x2, dV_dt_epi, flow_epi_hyp_x, volume_e_x & 
               , volume_h_x, flow_in_epi_x, flow_out_hyp_x, q_surf, energy_x &
               , advec_out_hypx, advec_in_hypx, temp_change_hyp 

            write(32,*) nd, temp_epil, temp_hypo


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
