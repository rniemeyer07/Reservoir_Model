SUBROUTINE flow_subroutine ( flow_in_epi_x , flow_in_hyp_x, flow_epi_hyp_x, flow_out_epi_x, flow_out_hyp_x, volume_e_x, volume_h_x)

   use Block_Reservoir
   use Block_Energy 

implicit none

  real :: flow_in_epi_x, flow_in_hyp_x, flow_epi_hyp_x, flow_out_hyp_x,flow_out_epi_x,volume_e_x, volume_h_x 
  real :: T_epil, T_hypo
 ! real :: Q_in,Q_out, ftsec_to_msec, prcnt_flow_hypo, prcnt_flow_epil
 ! real :: stream_T_in, stream_T_out, headw_T_in, headw_T_out, air_T
 ! integer :: year, month, day

      !*************************************************************************
      !      read inflow from vic/rvic simulations
      !*************************************************************************


      ! ------------------ read in in VIC flow data --------------
       read(46, *) year,month,day, Q_in &
             , stream_T_in, headw_T_in, air_T

        Q_in = Q_in * ftsec_to_msec ! converts ft^3/sec to m^3/sec

         flow_in_hyp_x = Q_in*prcnt_flow_hypo
         flow_in_epi_x = Q_in*prcnt_flow_epil

      ! ---------- set outflow to inflow (same out as in)  ---
      !   read(47, *) year,month,day, Q_out, stream_T_out &
      !      ,  headw_T_out, air_T

      !   Q_out = Q_out * ftsec_to_msec ! converts ft^3/sec to m^3/day

       !  flow_out_hyp_x = Q_out * prcnt_flow_hypo
       !  flow_out_epi_x = Q_out*prcnt_flow_epil
        flow_out_hyp_x = flow_in_hyp_x + flow_in_epi_x
        flow_out_epi_x = 0
       !  flow_out_hyp_x = 0
       !  flow_out_epi_x = flow_in_epi_x

      ! ------------- flow between epilim. and hypolim. ---------
         flow_epi_hyp_x = flow_in_epi_x
       !  flow_epi_hyp_x = 0



      ! ------------------------- calculate dV/dt terms ---------------------------
         dV_dt_epi = (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x) * T_epil
         dV_dt_hyp = (flow_in_hyp_x + flow_epi_hyp_x - flow_out_hyp_x) * T_hypo

      !----- update epilimnion and hypolimnion volume  -------
          volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x -flow_epi_hyp_x ) * delta_t
          volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x) * delta_t


      !   outflow_x = flow_out_epi_x + flow_out_hyp_x

END SUBROUTINE flow_subroutine
