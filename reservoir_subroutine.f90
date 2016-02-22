SUBROUTINE reservoir_subroutine(T_epil_temp,T_hypo_temp, volume_e_x,volume_h_x)
   use Block_Reservoir

implicit none

real :: volume_e_x, volume_h_x, T_epil_temp, T_hypo_temp

  ! ------------ calculate temperature change due to diffusion ---------------
      ! NOTE: don't need to multiply by heat capacity or density of water
      ! because
      !       energy component is divided by those two

      dif_epi_x  = v_t * area * density * heat_c * (T_hypo_temp - T_epil_temp)
      dif_hyp_x  = v_t * area * density * heat_c * (T_epil_temp - T_hypo_temp)

  ! ------------------------- calculate advection --------------------------- 

    ! ---------------- epilimnion -------------
         advec_in_epix  = flow_in_epi_x * density * heat_c * (stream_T_in)
         advec_out_epix = flow_out_epi_x * density * heat_c * (T_epil_temp)
         advec_epi_hyp = flow_epi_hyp_x * density * heat_c * (T_epil_temp)
         advec_out_epix = advec_out_epix + advec_epi_hyp

     ! ---------------- hypolimnion ------------
         advec_in_hypx = flow_in_hyp_x * density * heat_c * (stream_T_in)
         advec_in_hypx = advec_in_hypx + advec_epi_hyp
         advec_out_hypx = flow_out_hyp_x * density * heat_c * (T_hypo_temp)

  ! ------------------------- calculate dV/dt ---------------------------
    ! ---------------- epilimnion -------------
         dV_dt_epi = (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x) * density * heat_c * (T_epil_temp)


    ! ---------------- hypolimnion ------------
         dV_dt_hyp = (flow_in_hyp_x + flow_epi_hyp_x - flow_out_hyp_x) * density * heat_c * (T_hypo_temp)

   ! ------------------- calculate change in temperature  ---------------------

       ! ---------------- epilimnion -----------

          !----- calculate change in layer volume  -------
             delta_vol_e_x = flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x
             delta_vol_e_T_x = (-1) * density * heat_c * (T_epil_temp) * &
                         delta_vol_e_x / delta_t

            ! ------------ calculate total energy ----------
            temp_change_ep = advec_in_epix - advec_out_epix  + energy_x + dif_epi_x - dV_dt_epi
!  write(*,*) advec_in_epix, advec_out_epix, energy_x, dif_epi_x
! write(*,*) dif_epi_x, temp_hypo(i-1), temp_change_hyp(i) 
            ! loop to calculate volume if Qout > volume
            ! if (flow_out_epi_x > volume_e_x) then
            !  vol_x = flow_in_epi_x
            ! else if (flow_out_epi_x < volume_e_x) then
              vol_x = volume_e_x
            ! end if

           temp_change_ep = temp_change_ep/(vol_x * density * heat_c)
           temp_change_ep = temp_change_ep * delta_t

            ! -------- save each energy component ------
             energy_tot = energy_x
             diffusion_tot = dif_epi_x
             T_in_tot = flow_in_epi_x*stream_T_in/volume_e_x
             T_out_tot = flow_out_epi_x*T_epil_temp/volume_e_x



            !----- update epilimnion volume for next time step -------
              volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x + flow_epi_hyp_x ) *delta_t
              T_epil_temp = T_epil_temp +  temp_change_ep


       ! ------------------ hypolimnion ----------------

          !----- calculate change in layer volume  -------
           delta_vol_h_x = flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x
           delta_vol_h_T_x = (-1) * density * heat_c * (T_hypo_temp) * &
                        delta_vol_h_x / delta_t

          ! ------------ calculate total energy ----------
            temp_change_hyp = advec_in_hypx -  advec_out_hypx  +  dif_hyp_x -dV_dt_hyp

            ! loop to calculate temperature change with Qin, IF Qout >
            ! volume_h_x
            ! if (flow_out_hyp_x > volume_h_x) then
            !   vol_x = flow_epi_hyp_x
            ! else if (flow_out_hyp_x < volume_h_x) then
                vol_x = volume_h_x
            ! end if

            !   write(*,*) volume_h_x, vol_x, flow_out_hyp_x,flow_epi_hyp_x,
            !   temp_change_hyp(i)

           temp_change_hyp = temp_change_hyp/(vol_x * density * heat_c)
           temp_change_hyp = temp_change_hyp * delta_t

          !----- update epilimnion volume for next time step -------
           volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x)*delta_t
           T_hypo_temp = T_hypo_temp +  temp_change_hyp
!
! Print output to unit = 30 JRY
!


  !---------- calculate combined (hypo. and epil.) temperature of outflow -----
    outflow_x = flow_out_epi_x + flow_out_hyp_x
    epix = T_hypo_temp*(flow_out_epi_x/outflow_x)  ! portion of temperature from epilim. 
    hypox= T_hypo_temp*(flow_out_hyp_x/outflow_x)  ! portion of temperature from hypol.
    temp_out_tot = epix + hypox

!------------- write energy budget terms each time step and data to save -----
!          write(*,*) dif_epi_x, temp_hypo, temp_change_hyp(i),advec_in_hypx &
!                 ,  advec_out_hypx,  dif_hyp_x

          write (*,*) i

!          write(30,*) i,temp_epil,temp_hypo,temp_out_tot(i), flow_Tin(i) &
!               ,  temp_change_ep(i), temp_change_hyp(i), advec_in_hypx,advec_out_hypx,dV_dt_hyp &
!                , flow_epi_hyp_x, volume_e_x, volume_h_x, flow_in_epi_x,flow_out_hyp_x
end subroutine reservoir_subroutine
