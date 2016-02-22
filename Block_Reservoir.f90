module Block_Reservoir

        implicit none

        ! 1-dim. real array for 10 years
        !real :: flow_in,flow_out,flow_eout,flow_hout
        !real ::  temp_epil,temp_hypo, temp_out_tot
        real :: temp_change_ep, temp_change_hyp, energy,stream_T_in
        real :: energy_tot, diffusion_tot, T_in_tot, T_out_tot,temp_out_tot

        REAL, PARAMETER ::  prcnt_flow_epil = 0,prcnt_flow_hypo=1
        REAL, PARAMETER :: density = 1000, heat_c = 4180
        real          :: v_t    !diffusion coefficient (m/day) Input on command line JRY
        !    diffusion coefficient - based on Snodgrass, 1974

        real  :: flow_constant
        integer  :: i_inflow, no_flow, no_heat !  year, month, day
        !
        ! Added some variables JRY
        !
        integer  :: nd_total                  ! Total number of days for simulation
        real     :: Q_in_epil,Temp_in            ! Inflow and inflow temperature
        real     :: delta_t_sec                  ! Time step, seconds

        real :: x,  x1, x2, x3

        real  :: depth_total, depth_e, depth_h, width, length,outflow_x
        real :: energy_x, area, delta_t
        real  :: flow_in_hyp_x, flow_in_epi_x, flow_out_epi_x, flow_out_hyp_x
        real  :: epix, hypox, dif_epi_x, dif_hyp_x,  flow_epi_x, flow_hyp_x,vol_x
        real :: advec_in_epix, advec_out_epix, advec_in_hypx, advec_out_hypx
        real :: delta_vol_e_x, delta_vol_h_x, flow_epi_hyp_x, advec_epi_hyp
        real :: delta_vol_e_T_x, delta_vol_h_T_x
        real :: dV_dt_epi,dV_dt_hyp

        ! --------------- path and directories of input and output files -------

        character(*), PARAMETER :: path="/raid3/rniemeyr/practice/practice_fortran/output/"
        character(len=300 ) :: inflow_file
        character(len=300 ) :: outflow_file
        character(len=300 ) :: energy_file
        character(len=300 ) :: observed_stream_temp_file
        character(len=300 ) :: input_file

        ! --------------------- allocatable variables --------------------
        !real, dimension(:),     allocatable :: Q_in
        !real, dimension(:),     allocatable :: stream_T_in
        !real, dimension(:),     allocatable :: headw_T_in
        !real, dimension(:),     allocatable :: Q_out
        !real, dimension(:),     allocatable :: stream_T_out
        !real, dimension(:),     allocatable :: headw_T_out
        !real, dimension(:),     allocatable :: air_T
        !real, dimension(:),     allocatable :: year
        !real, dimension(:),     allocatable :: month
        !real, dimension(:),     allocatable :: day
        !real, dimension(:),     allocatable :: temp_epil
        !real, dimension(:),     allocatable :: temp_hypo
        !real, dimension(:),     allocatable :: temp_out_tot



        ! ----------------------- constants --------------------------
        !density = 1000 !  density of water in kg / m3
        !heat_c = 4180  !  heat capacity of water in joules/ kg * C

end module Block_Reservoir

