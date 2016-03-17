SUBROUTINE reservoir_subroutine(T_epil,T_hypo, volume_e_x,volume_h_x)
   use Block_Reservoir
   use Block_Flow

implicit none

  real :: volume_e_x, volume_h_x, T_epil, T_hypo
!  real :: flow_in_epi_x , flow_in_hyp_x, flow_epi_hyp_x, flow_out_epi_x, flow_out_hyp_x

  ! -------------------- calculate temperature terms  -------------------------
      dif_epi_x  = K_z * area *  (T_hypo - T_epil) * delta_t / volume_e_x
      dif_hyp_x  = K_z * area *  (T_epil - T_hypo) * delta_t / volume_h_x

  ! --------------------- calculate advection terms --------------------------- 
         advec_in_epix  = flow_in_epi_x * (stream_T_in - T_epil) * delta_t / volume_e_x
         advec_epi_hyp = flow_epi_hyp_x *  (T_epil - T_hypo) * delta_t / volume_e_x
         advec_in_hypx = flow_in_hyp_x * (stream_T_in - T_hypo) * delta_t / volume_h_x
        ! advec_out_hypx = flow_out_hyp_x * T_hypo_temp
 
  ! ------------------------- calculate dV/dt terms ---------------------------
         dV_dt_epi = (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x) * T_epil
         dV_dt_hyp = (flow_in_hyp_x + flow_epi_hyp_x - flow_out_hyp_x) * T_hypo
!  print *, nd, K_z, area, stream_T_in, T_epil
  ! ------------------- calculate change in temperature  ---------------------
      ! ---------------- epilimnion -----------
         ! ------------ calculate total energy ----------
          energy_x  = (q_surf * delta_t ) / (depth_e * density * heat_c_kcal ) ! kcal/sec*m2 to m3*C/sec
          temp_change_ep = advec_in_epix + energy_x +  dif_epi_x !  - advec_out_epix - dV_dt_epi
         ! temp_change_ep = temp_change_ep * delta_t / volume_e_x
         !----- update epilimnion volume for next time step -------
          volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x ) * delta_t
          T_epil = T_epil + temp_change_ep

      ! ------------------ hypolimnion ----------------
         ! ------------ calculate total energy ----------
          temp_change_hyp = advec_in_hypx + advec_epi_hyp + dif_hyp_x !  - advec_out_hypx - dV_dt_hyp
         !  temp_change_hyp = temp_change_hyp * delta_t / volume_h_x
         !----- update epilimnion volume for next time step -------
          volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x) * delta_t
          T_hypo = T_hypo +  temp_change_hyp

  !---------- calculate combined (hypo. and epil.) temperature of outflow -----
    outflow_x = flow_out_epi_x + flow_out_hyp_x
    epix = T_epil*(flow_out_epi_x/outflow_x)  ! portion of temperature from epilim. 
    hypox= T_hypo*(flow_out_hyp_x/outflow_x)  ! portion of temperature from hypol.
    temp_out_tot = epix + hypox   ! average outflow temperature

end subroutine reservoir_subroutine
