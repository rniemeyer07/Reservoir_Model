program two_layer_diffusion
!
!------------------------------------------------------------------------- 
!         Two-layer Sream Temperature model
!              University of Washington - Computational Hydrology Lab
!         Authors: Ryan Niemeyer, Yifan Cheng, John Yearsley, and others
!         Date: January 2016
!         based on Strzepek et al. (2015) equations 6 & 7, which is based
!               off of Chapra 1997
!
!-------------------------------------------------------------------------
!!!!This is the trial for pull request!!!!!!!!!!!!
implicit none

!-------------------------------------------------------------------------
!    define variables
!-------------------------------------------------------------------------

! 1-dim. real array for 10 years
real, dimension(22645) :: flow_in,flow_out,flow_eout,flow_hout, flow_Tin
real, dimension(22645) ::  temp_epil,temp_hypo, temp_out_tot
real, dimension(22645) :: temp_change_ep, temp_change_hyp, energy
real, dimension(22645) :: energy_tot, diffusion_tot, T_in_tot, T_out_tot

REAL, PARAMETER :: Pi = 3.1415927, prcnt_flow_epil = 0.2, prcnt_flow_hypo=0.8
real            :: v_t      !diffusion coefficient (m/day) Input on command line JRY
!    diffusion coefficient - based on Snodgrass, 1974

real  :: flow_constant
integer  :: i,i_inflow, no_flow, no_heat !  year, month, day
!
! Added some variables JRY
!
integer  :: nd_total                     ! Total number of days for simulation
real     :: Q_in_epil,Temp_in            ! Inflow and inflow temperature
real     :: delta_t_sec                  ! Time step, seconds

real :: x,  x1, x2, x3

real  :: depth_total, depth_e, depth_h, width, length, volume_e_x, outflow_x
real :: energy_x, volume_h_x, area, density, heat_c, delta_t
real  :: flow_in_hyp_x, flow_in_epi_x, flow_out_epi_x, flow_out_hyp_x
real  :: epix, hypox, dif_epi_x, dif_hyp_x,  flow_epi_x, flow_hyp_x, vol_x
real :: advec_in_epix, advec_out_epix, advec_in_hypx, advec_out_hypx
real :: delta_vol_e_x, delta_vol_h_x, flow_epi_hyp_x, advec_epi_hyp

! --------------- path and directories of input and output files -------
CHARACTER(*), PARAMETER :: path = "/raid3/rniemeyr/practice/practice_fortran/output/" 
character(len=300 ) :: inflow_file
character(len=300 ) :: outflow_file
character(len=300 ) :: energy_file
character(len=300 ) :: observed_stream_temp_file
character(len=300 ) :: input_file

! --------------------- allocatable variables --------------------
real, dimension(:),     allocatable :: Q_in
real, dimension(:),     allocatable :: stream_T_in
real, dimension(:),     allocatable :: headw_T_in
real, dimension(:),     allocatable :: Q_out
real, dimension(:),     allocatable :: stream_T_out
real, dimension(:),     allocatable :: headw_T_out
real, dimension(:),     allocatable :: air_T
real, dimension(:),     allocatable :: year
real, dimension(:),     allocatable :: month
real, dimension(:),     allocatable :: day
!
! Read total number of days to simulate JRY 
!
write(*,*) 'Total number of days of simulation'
read(*,*) nd_total
!
! Read some parameters
!
write(*,*) 'Input Inflow,Inflow Temperature,temp_epil(1),temp_hypo(1),diffusion coefficient'
read(*,*) Q_in_epil,Temp_in,temp_epil(1),temp_hypo(1),v_t
!
! Allocate arrays
!
allocate (Q_in(nd_total))
allocate (stream_T_in(nd_total))
allocate (headw_T_in(nd_total))
allocate (Q_out(nd_total))
allocate (stream_T_out(nd_total))
allocate (headw_T_out(nd_total))
allocate (air_T(nd_total))
allocate (year(nd_total))
allocate (month(nd_total))
allocate (day(nd_total))

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

!-------------------------------------------------------------------------
!
!    read in  flow and energey temporal variables
!
!-------------------------------------------------------------------------

! --------- constant flow paramaeter -------
! constant  to change day of
!  flow to go "up and down" with sin wave,  with 0 and 365 being "0" point
flow_constant = 365/(2*Pi)

! generates flow eacy day as a sin wave with the peak flow on April 1
! at 90000 cfs, and lowest point is 30000 cfs on October 1
! days are calendar year (day = 1 = January 1)

!
! Commented all the following out for testing JRY
!
! ----------------------- flow and energy (from VIC simulations) --------
!
!OPEN(UNIT=45, FILE=TRIM(input_file), status='old')
!read(45, *)  ! skip first line
!
! ----- read in inflow file -----
!read(45, '(A)') inflow_file
!open(unit=46, file=TRIM(inflow_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')

! ------- read in outflow file -------
! read(45, '(A)') outflow_file
! open(unit=47, file=TRIM(outflow_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')

! ------- read in energy file -------
! read(45, '(A)') energy_file
! open(unit=48, file=TRIM(energy_file), ACCESS='SEQUENTIAL', FORM='FORMATTED', STATUS='old')
!
! ------- read in observed stream temperature file -------
! read(45, '(A)') observed_stream_temp_file 
! open(unit=49, file=TRIM(observed_stream_temp_file), ACCESS='SEQUENTIAL', FORM='FORMATTED' &
!        ,  STATUS='old')


!-------------------------------------------------------------------------
!
!              Calculate two-layer stream temperature   
!
!-------------------------------------------------------------------------

! ----------------------- constants --------------------------
density = 1000 !  density of water in kg / m3
heat_c = 4180  !  heat capacity of water in joules/ kg * C

! ------------------- initial variables ---------------
volume_e_x = area*depth_e
volume_h_x = area*depth_h
!
! Just to make sure JRY
!
write(*,*) 'Starting temperature - ',temp_epil(1),temp_hypo(1)
!
!temp_epil(1) = 15 ! starting epilimnion temperature at 5 C
!temp_hypo(1) = 15 ! starting hypolimnion temperature at 5 C

! --------- constant flow paramaeter -------
! constant  to change day of flow to go "up and down" with sin wave, 
!   with 0 and 365 being "0" point
flow_constant = 365/(2*Pi)

!-------------------------------------------------------------------------
!                       start loop!
!-------------------------------------------------------------------------

! start at 2, because need to have an epil and hypo temperature to start out
do  i=2,nd_total
  
  ! ---------------------- calculate streamflow entering resevoir  ------------------

     ! ------ get flow in to the reservoir for the year ------
       ! flow_in_hyp_x =  sin( i/flow_constant)   !sets flow as a sine function
       !flow_in_hyp_x = (flow_in_hyp_x + 2)*30000   ! flow vary from 30000 to 90000cfs
       !flow_in_hyp_x = (flow_in_hyp_x/35.315)*delta_t_sec  ! converts ft3/sec to m3/day
     
       ! flow_in_epi_x =  sin( i/flow_constant)   !sets flow as a sine function
       !flow_in_epi_x = (flow_in_epi_x + 2)*30000   ! flow varies from 30000 to 90000cfs
       !flow_in_epi_x = (flow_in_epi_x/35.315)*delta_t_sec  ! converts ft3/sec to m3/day
 
     ! -----  divide incoming flow to epilimnion and hypolimnion ------
         ! flow_in_hyp_x = flow_in(i)*prcnt_flow_epil
         ! flow_in_epi_x = flow_in(i)*prcnt_flow_hypo

     ! --------------- just set flow as a constant ------------
!      flow_in_epi_x = 50000
!
! Use values from command line JRY
!
      flow_in_epi_x = Q_in_epil
!
      flow_in_hyp_x = 0

      ! ------------------ read in in VIC flow data --------------
       ! read(46, *) year(i),month(i),day(i), Q_in(i) &
       !       , stream_T_in(i), headw_T_in(i), air_T(i)

       ! flow_in_hyp_x = Q_in(i)*prcnt_flow_epil
       ! flow_in_epi_x = Q_in(i)*prcnt_flow_hypo


  ! ------------- calculate flow between epilimnion and hypolimnion  ------------------
      flow_epi_hyp_x = flow_in_epi_x

  ! ---------------------- calculate streamflow exiting resevoir  ------------------

     ! ----------------- read in outflow file ---------------
      flow_out_hyp_x = flow_epi_hyp_x
      flow_out_epi_x = 0 

     ! ---------- set outflow to inflow (same out as in)  ---
       !  read(47, *) year(i),month(i),day(i), Q_out(i), stream_T_out(i),
           !  headw_T_out(i), air_T(i)

       !  flow_out_hyp_x = Q_in(i)*prcnt_flow_epil
       !  flow_out_epi_x = Q_in(i)*prcnt_flow_hypo

  ! ------------------------- read in streamflow temperature ---------------------

    ! ----- set stream temp vary with sine fxn -------
    !  flow_Tin(i)  =  cos((i/flow_constant)+ Pi)
    !  flow_Tin(i) = (flow_Tin(i) + 1.5)*10   ! temperature varies form  5 to  25C

    ! ------- set stream temp as constant --------
!
!  Using value of inflow from command line JRY
!
     flow_Tin(i) = Temp_in

  ! ------------------  calculate incoming net energ to epilimnion ------------

    ! --------- vary energy annually with cos fxn ------
       ! gets net energy (positive downward) to vary from:
       ! " +0.7)*120":  -36 to 204 W/m2
       ! " +0.5)*120":  -60 to 180 W/m2
       ! " +0.2)*100": -80 to 120 W/m2
       ! units are  W/m2 or Joules/m2 * sec
!      energy_x  =  cos((i/flow_constant)+ Pi)
!
      energy_x = 0.0      ! Surface flux set to zero for testing JRY
!
      energy_x =( (energy_x)*30)*delta_t_sec !converts to Joules/m2 * day
      energy_x = energy_x*area

    ! ------- ulpload ENERGY subroutine and read in VIC energy ----
        ! read(48, *) year(i),month(i),day(i), Q_in(i), stream_T_in(i)  &
        !        ,  headw_T_in(i), air_T(i)

      ! divide incoming flow into reservoir to epilimnion and hypolimnion
      ! flow_in_hyp_x = flow_in(i)*prcnt_flow_epil
      ! flow_in_epi_x = flow_in(i)*prcnt_flow_hypo


  ! ------------ calculate temperature change due to diffusion ---------------
      ! NOTE: don't need to multiply by heat capacity or density of water because
      !       energy component is divided by those two

      dif_epi_x  = v_t * area * density * heat_c * (temp_hypo(i-1) - temp_epil(i-1))
      dif_hyp_x  = v_t * area * density * heat_c * (temp_epil(i-1) - temp_hypo(i-1))

  ! ------------------------- calculate advection --------------------------- 

    ! ---------------- epilimnion -------------
         advec_in_epix  = flow_in_epi_x * density * heat_c * (flow_Tin(i))
         advec_out_epix = flow_out_epi_x * density * heat_c * (temp_epil(i-1))
         advec_epi_hyp = flow_epi_hyp_x * density * heat_c * (temp_epil(i-1))
         advec_out_epix = advec_out_epix + advec_epi_hyp

     ! ---------------- hypolimnion ------------
         advec_in_hypx = flow_in_hyp_x * density * heat_c * (flow_Tin(i))
         advec_in_hypx = advec_in_hypx + advec_epi_hyp
         advec_out_hypx = flow_out_hyp_x * density * heat_c * (temp_hypo(i-1))

   ! ------------------- calculate change in temperature  ---------------------

       ! ---------------- epilimnion -----------

          !----- calculate change in layer volume  -------
             delta_vol_e_x = volume_e_x - (flow_in_epi_x - flow_out_epi_x)

            ! ------------ calculate total energy ----------
            temp_change_ep(i) = advec_in_epix - advec_out_epix  + energy_x + dif_epi_x
write(*,*) advec_in_epix,advec_out_epix,energy_x,dif_epi_x
            ! loop to calculate volume if Qout > volume
             if (flow_out_epi_x > volume_e_x) then
              vol_x = flow_in_epi_x
             else if (flow_out_epi_x < volume_e_x) then
              vol_x = volume_e_x
             end if

           temp_change_ep(i) = temp_change_ep(i)/(vol_x * density * heat_c)
           temp_change_ep(i) = temp_change_ep(i) * delta_t

            !----- update epilimnion volume for next time step -------
              volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x)
              temp_epil(i) = temp_epil(i-1) +  temp_change_ep(i)


            ! -------- save each energy component ------
             energy_tot(i) = energy_x
             diffusion_tot(i) = dif_epi_x
             T_in_tot(i) = flow_in_epi_x*flow_Tin(i)/volume_e_x
             T_out_tot(i) = flow_out_epi_x*temp_epil(i-1)/volume_e_x

       ! ------------------ hypolimnion ----------------

          !----- calculate change in layer volume  -------
           delta_vol_h_x = volume_h_x - (flow_in_hyp_x - flow_out_hyp_x) 

          ! ------------ calculate total energy ----------
            temp_change_hyp(i) = advec_in_hypx -  advec_out_hypx  +  dif_hyp_x  

            ! loop to calculate temperature change with Qin, IF Qout > volume_h_x
             if (flow_out_hyp_x > volume_h_x) then
               vol_x = flow_in_hyp_x
             else if (flow_out_hyp_x < volume_h_x) then
                vol_x = volume_h_x
             end if

           temp_change_hyp(i) = temp_change_hyp(i)/(vol_x * density * heat_c)
           temp_change_hyp(i) = temp_change_hyp(i) * delta_t

          !----- update epilimnion volume for next time step -------
           volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x)
           temp_hypo(i) = temp_hypo(i-1) +  temp_change_hyp(i)
!
! Print output to unit = 30 JRY
!
           write(30,*) i,temp_epil(i),temp_hypo(i)
!
  !---------- calculate combined (hypo. and epil.) temperature of outflow -----
    outflow_x = flow_out_epi_x + flow_out_hyp_x
    epix = temp_epil(i)*(flow_out_epi_x/outflow_x)  ! portion of temperature from epilim. 
    hypox= temp_hypo(i)*(flow_out_hyp_x/outflow_x)  ! portion of temperature from hypol.
    temp_out_tot(i) = epix + hypox

  ! -------------- loop to print out data throughout the loop -----------------
 if (i==2 .or. i==3  .or. i==180 .or. i==365) then
  print *, "run: ", i
  print *, "temperature change of hypol.:  ", temp_change_hyp(i)
  print *, "temp change of previous hypol: ", temp_hypo(i-1) 
!  print *,"energy of incoming radiation " , energy(i)/(delta_t_sec)
!  print *, "energy - joules/day*m2", energy(i)
!  print *, "area:                 ", area
!  print *, "numeriator  of energy equation: ", x1
!  print *, "heat capacity  ", heat_c
!  print *, "density   ", density
!  print *, "volume of epilimnion: ", volume_e_x
!  print *, "denominator of energy equation: ", x2
!  print *, "volume of epilimnion: ", volume_e_x
!   print *, "change in volume - epilim.: ", flow_in_epi_x -  flow_out_epi_x
!   print *, "change in volume - hypolim.: ", flow_in_hyp_x - flow_out_hyp_x
!   print *, "depth of epilimnion: ", volume_e_x/area
!   print *, "depth of hypolimnion: ", volume_h_x/area
  print *, "diffusion energy in epil.: ", dif_epi_x
  print *, "diffusion energy in hypol.: ", dif_hyp_x
  print *, "energy temp change is : ",energy_x/(volume_e_x * density * heat_c)
  print *, "diffus temp change  is: ", dif_epi_x/(volume_e_x * density *heat_c)
!  print *, "Qin temp change: ", (flow_in_epi_x * flow_Tin(i))/volume_e_x
!  print *, "Qout temp change: ", (flow_out_epi_x * temp_epil(i-1))/volume_e_x
!  print *, "flow epilim. temp change: ", flow_epi_x/(volume_e_x*density* heat_c)
!   print *, "flow hypolim.  temp change is: ", flow_hyp_x
!  print *, "depth of epilimnion: ", volume_e_x/area 
   print *, "temperature of incoming streamflow: ", flow_Tin(i)
!  print *, "temperature change in epilimnion:  ", temp_change_ep(i)
   print *, "outflow temperature from epilimnion is: ", temp_epil(i)
!   print *, "depth of hypolimnion: ", volume_h_x/area
!  print *, "temperature change in hypolimnion:  ", temp_change_hyp(i)
  print *, "outflow temperature from hypolimnion is: ", temp_hypo(i)
!   print *, "outflow (combined)  temperature is: ", temp_out_tot(i)
!  print *, "  "
 end if

end  do
 
!-------------------------------------------------------------------------
!
!         Calculations to print at the end 
!
!-------------------------------------------------------------------------

print *, x

! open(unit=30, file=path//"hypo_temp_change.txt",action="write",status ="replace")
! open(unit=31, file=path//"epil_temp_change.txt",action="write",status="replace")
! open(unit=40, file=path//"temperature_epil.txt",action="write",status="replace")
! open(unit=41, file=path//"temperature_hypo.txt",action="write",status="replace")
! open(unit=42, file=path//"flow_in.txt", action="write", status="replace") 
! open(unit=43, file=path//"stream_T_in.txt", action="write", status="replace") 
! open(unit=44, file=path//"headw_T_in.txt", action="write", status="replace") 
! open(unit=55, file=path//"stream_T_out.txt", action="write", status="replace") 

! write(30,*),temp_change_hyp
! write(31,*),temp_change_ep
! write(40,*),temp_epil
! write(41,*),temp_hypo
! write(42,*), Q_in
! write(43,*), stream_T_in
! write(44,*), headw_T_in
! write(55,*), temp_out_tot

! close(30)
! close(31)
! close(40)
! close(41)
! close(42)
! close(43)
! close(44)
! close(55)
! close(45)
! close(46)
! close(47)
! close(48)
! close(49)

 print *,"total simulation temperature change in epilim.: ", sum(temp_change_ep(1:3650))
 print *,"total simulation  temperature change in hypolim.: ",  sum(temp_change_hyp(1:3650))
 print *, "temp change in winter in epilm.: ",sum(temp_change_ep(365:368))
 print *, "temp change in spring in epilm.: ",sum(temp_change_ep(450:480))
 print *, "temp change in summer  in epilm.: ",sum(temp_change_ep(540:570))
 print *, "temp change in fall  in epilm.: ",sum(temp_change_ep(630:660))

! print *, "sum of 1:720 temp change due to flow in: ", sum(T_in_tot(1:720))
! print *, "sum of 1:720 temp change due to flow out: ", sum(T_out_tot(1:720))
! print *, "sum of 1:720 temp change due to energy: ", sum(energy_tot(1:720))
! print *, "sum of 1:720 temp change due to diffusion: ", sum(diffusion_tot(1:720))


end program two_layer_diffusion
