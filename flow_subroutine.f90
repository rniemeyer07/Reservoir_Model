SUBROUTINE flow_subroutine ( flow_in_epi_x , flow_in_hyp_x, flow_epi_hyp_x, flow_out_epi_x, flow_out_hyp_x &
        ,  volume_e_x, volume_h_x, ratio_sp, ratio_pen, density_epil, density_hypo, density_in)

   use Block_Reservoir
   !use Block_Energy 

implicit none

  real :: flow_in_epi_x, flow_in_hyp_x, flow_epi_hyp_x, flow_out_hyp_x,flow_out_epi_x,volume_e_x, volume_h_x 
  real :: T_epil, T_hypo, ratio_sp, ratio_pen, density_epil, density_hypo, density_in

      !*************************************************************************
      !      read inflow from vic/rvic simulations
      !*************************************************************************

      ! ------------------ read in in VIC flow data --------------
       read(57, *) year,month,day, Q_in2 &
             , stream_T_in, headw_T_in, air_T

        Q_in = Q_in  * ftsec_to_msec * delta_t ! converts ft^3/sec to m^3/sec, multiplys by seconds per time step

        if ( density_in .le. density_hypo ) then
                flow_in_hyp_x = 0 
                flow_in_epi_x = Q_in
        else
                flow_in_hyp_x = Q_in
                flow_in_epi_x = 0
        end if

      !-------------- measured releases (penstock and spillway) ---------------
      !  read(56, *) datetime,Q_tot, Q_pen, Q_spill

      !  flow_out_hyp_x = Q_pen * ftsec_to_msec * delta_t ! converts ft^3/sec to m^3/sec, multiplys by seconds per time step
      !  flow_out_epi_x = Q_spill * ftsec_to_msec * delta_t ! converts ft^3/sec to m^3/sec, multiplys by seconds per time step
      !  flow_epi_hyp_x = flow_in_epi_x - flow_out_epi_x

      ! ---------- set outflow to inflow (same out as in)  ---
         read(47, *) year,month,day, Q_out, stream_T_out &
            ,  headw_T_out, air_T

        Q_out = Q_in
        ! flow_out_hyp_x = Q_out * ftsec_to_msec * delta_t

        ratio_sp = Q_spill/Q_tot
        ratio_pen = Q_pen/Q_tot

       if(Q_tot .gt. 0) then
               flow_out_hyp_x = Q_out * ftsec_to_msec * delta_t * (Q_pen/Q_tot)
               flow_out_epi_x = Q_out * ftsec_to_msec * delta_t * (Q_spill/Q_tot)
               flow_epi_hyp_x = flow_in_epi_x - flow_out_epi_x
       else
           flow_out_hyp_x = Q_out ! * ftsec_to_msec * delta_t
           flow_out_epi_x = 0
           flow_epi_hyp_x = flow_in_epi_x
       end if

      ! ------------------------- calculate dV/dt terms ---------------------------
         dV_dt_epi = (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x) * T_epil
         dV_dt_hyp = (flow_in_hyp_x + flow_epi_hyp_x - flow_out_hyp_x) * T_hypo

      !----- update epilimnion and hypolimnion volume  -------
        volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x )
        volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x)
        outflow_x = flow_out_epi_x + flow_out_hyp_x

 print *, nd, flow_in_epi_x, flow_out_hyp_x, volume_e_x, volume_h_x

END SUBROUTINE flow_subroutine
