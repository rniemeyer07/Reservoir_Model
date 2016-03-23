SUBROUTINE reservoir_subroutine(T_epil,T_hypo, volume_e_x,volume_h_x)
   use Block_Reservoir
   use Block_Flow

implicit none

  real :: volume_e_x, volume_h_x, T_epil, T_hypo
!  real :: flow_in_epi_x , flow_in_hyp_x, flow_epi_hyp_x, flow_out_epi_x, flow_out_hyp_x

 ! ---------------- turnover loop driven only by T_epil and T_hyp ----------
        if ( ( T_epil - T_hypo) .lt. (2)  ) then
                if( (T_epil - T_hypo) .lt. (0) ) then
                         K_z = 10 ! set high K_z when moderately unstable
                else
                         K_z = 1 ! set moderate K_z when system is unstable
                end if
        else ! if T_epil greater than T_hypo
                  K_z = 0.0001  ! set the diffusion coeff. in m^2/day
                  K_z = K_z / (depth_e/2) ! divide by approx thickness of thermocl.
        end if

  ! -------------------- calculate temperature terms  -------------------------
      dif_epi_x  = K_z * surface_area *  (T_hypo - T_epil) / volume_e_x
      dif_hyp_x  = K_z * surface_area *  (T_epil - T_hypo) / volume_h_x

  ! --------------------- calculate advection terms --------------------------- 
         advec_in_epix  = flow_in_epi_x * (stream_T_in - T_epil) / volume_e_x
         advec_epi_hyp = flow_epi_hyp_x *  (T_epil - T_hypo) / volume_e_x
         advec_in_hypx = flow_in_hyp_x * (stream_T_in - T_hypo) / volume_h_x
        ! advec_out_hypx = flow_out_hyp_x * T_hypo_temp

  ! ------------------- calculate change in temperature  ---------------------
      ! ---------------- epilimnion -----------
         ! ------------ calculate total energy ----------
          energy_x  = (q_surf * delta_t ) / (depth_e * density * heat_c_kcal ) ! kcal/sec*m2 to C/day
          temp_change_ep = advec_in_epix + energy_x +  dif_epi_x !  - advec_out_epix - dV_dt_epi ! units = C/day
         ! temp_change_ep = temp_change_ep * delta_t / volume_e_x
         !----- update epilimnion volume for next time step -------
          T_epil = T_epil + temp_change_ep

! print *, nd, T_epil, T_hypo ,energy_x, dif_epi_x, advec_in_epix

      ! ------------------ hypolimnion ----------------
         ! ------------ calculate total energy ----------
          temp_change_hyp = advec_in_hypx + advec_epi_hyp + dif_hyp_x !  - advec_out_hypx - dV_dt_hyp
         !  temp_change_hyp = temp_change_hyp * delta_t / volume_h_x
         !----- update epilimnion volume for next time step -------
          T_hypo = T_hypo +  temp_change_hyp

  !---------- calculate combined (hypo. and epil.) temperature of outflow -----
    epix = T_epil*(flow_out_epi_x/outflow_x)  ! portion of temperature from epilim. 
    hypox= T_hypo*(flow_out_hyp_x/outflow_x)  ! portion of temperature from hypol.
    temp_out_tot = epix + hypox   ! average outflow temperature

end subroutine reservoir_subroutine
