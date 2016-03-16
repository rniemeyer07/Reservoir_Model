module Block_Reservoir

        implicit none

        ! ----------------------- constants --------------------------
        real, parameter ::  prcnt_flow_epil = 1, prcnt_flow_hypo = 0
        real, parameter :: density = 1000, heat_c = 4180, ftsec_to_msec = 0.0283168 
        real, parameter :: J_to_kcal = 0.00023885, kPa_to_mb = 10
        real, parameter :: heat_c_kcal = 1  ! heat capacity in kcal/kg*C
        real            :: K_z    !diffusion coefficient (m^2/sec)
        integer  :: nd_total, nd, ncell  ! total simulation days, index for simulations, etc.

        ! -------------------- temperature and meterological variables ------
        real :: temp_change_ep, temp_change_hyp, energy, stream_T_in, temp_out_tot
      !  real :: T_epil,T_hypo,volume_e_x,volume_h_x
        real :: year, month, day, Q_in, headw_T_in, stream_T_out
        real :: air_T, headw_T_out, Q_out, atm_density

        ! -------------------- reservoinr information --------------
        integer :: nres, nres_skip, dam_number, start_node, end_node, i
        character(len=300 ) ::  dam_name
        real ::  grid_lat, grid_lon, surface_area, length2, depth, width2
        real  :: depth_total, depth_e, depth_h, width, length,outflow_x
        real :: delta_vol_e_x, delta_vol_h_x, flow_epi_hyp_x
        real :: delta_vol_e_T_x, delta_vol_h_T_x, dV_dt_epi,dV_dt_hyp
        real, parameter :: depth_e_frac=0.4, depth_h_frac=0.6

        ! -------------------- energy terms -----------
        real :: energy_x, area, delta_t, q_surf
        real  :: flow_in_hyp_x, flow_in_epi_x, flow_out_epi_x, flow_out_hyp_x
        real  :: epix, hypox, dif_epi_x, dif_hyp_x,  flow_epi_x, flow_hyp_x,vol_x
        real :: advec_in_epix, advec_out_epix, advec_in_hypx, advec_out_hypx
        real :: advec_epi_hyp

        ! --------------- path and directories of input and output files -------
        character(len=300 ) :: inflow_file
        character(len=300 ) :: outflow_file
        character(len=300 ) :: energy_file
        character(len=300 ) :: observed_stream_temp_file
        character(len=300 ) :: input_file
        character(len=300 ) :: reservoir_file

end module Block_Reservoir

