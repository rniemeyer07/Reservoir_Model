SUBROUTINE reservoir_subroutine(volume_e_x,volume_h_x)
   use Block_Reservoir

implicit none

real :: volume_e_x, volume_h_x

  ! ------------ calculate temperature change due to diffusion ---------------
      ! NOTE: don't need to multiply by heat capacity or density of water
      ! because
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

  ! ------------------------- calculate dV/dt ---------------------------
    ! ---------------- epilimnion -------------
         dV_dt_epi = (flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x) * density * heat_c * (temp_epil(i-1))


    ! ---------------- hypolimnion ------------
         dV_dt_hyp = (flow_in_hyp_x + flow_epi_hyp_x - flow_out_hyp_x) * density * heat_c * (temp_hypo(i-1))

   ! ------------------- calculate change in temperature  ---------------------

       ! ---------------- epilimnion -----------

          !----- calculate change in layer volume  -------
             delta_vol_e_x = flow_in_epi_x - flow_out_epi_x - flow_epi_hyp_x
             delta_vol_e_T_x = (-1) * density * heat_c * (temp_epil(i-1)) * &
                         delta_vol_e_x / delta_t

            ! ------------ calculate total energy ----------
            temp_change_ep(i) = advec_in_epix - advec_out_epix  + energy_x + dif_epi_x - dV_dt_epi
!  write(*,*) advec_in_epix, advec_out_epix, energy_x, dif_epi_x
! write(*,*) dif_epi_x, temp_hypo(i-1), temp_change_hyp(i) 
            ! loop to calculate volume if Qout > volume
            ! if (flow_out_epi_x > volume_e_x) then
            !  vol_x = flow_in_epi_x
            ! else if (flow_out_epi_x < volume_e_x) then
              vol_x = volume_e_x
            ! end if

           temp_change_ep(i) = temp_change_ep(i)/(vol_x * density * heat_c)
           temp_change_ep(i) = temp_change_ep(i) * delta_t

            !----- update epilimnion volume for next time step -------
              volume_e_x = volume_e_x + (flow_in_epi_x - flow_out_epi_x + flow_epi_hyp_x ) *delta_t
              temp_epil(i) = temp_epil(i-1) +  temp_change_ep(i)


            ! -------- save each energy component ------
             energy_tot(i) = energy_x
             diffusion_tot(i) = dif_epi_x
             T_in_tot(i) = flow_in_epi_x*flow_Tin(i)/volume_e_x
             T_out_tot(i) = flow_out_epi_x*temp_epil(i-1)/volume_e_x

       ! ------------------ hypolimnion ----------------

          !----- calculate change in layer volume  -------
           delta_vol_h_x = flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x
           delta_vol_h_T_x = (-1) * density * heat_c * (temp_hypo(i-1)) * &
                        delta_vol_h_x / delta_t

          ! ------------ calculate total energy ----------
            temp_change_hyp(i) = advec_in_hypx -  advec_out_hypx  +  dif_hyp_x -dV_dt_hyp

            ! loop to calculate temperature change with Qin, IF Qout >
            ! volume_h_x
            ! if (flow_out_hyp_x > volume_h_x) then
            !   vol_x = flow_epi_hyp_x
            ! else if (flow_out_hyp_x < volume_h_x) then
                vol_x = volume_h_x
            ! end if

            !   write(*,*) volume_h_x, vol_x, flow_out_hyp_x,flow_epi_hyp_x,
            !   temp_change_hyp(i)

           temp_change_hyp(i) = temp_change_hyp(i)/(vol_x * density * heat_c)
           temp_change_hyp(i) = temp_change_hyp(i) * delta_t

          !----- update epilimnion volume for next time step -------
           volume_h_x = volume_h_x + (flow_in_hyp_x - flow_out_hyp_x + flow_epi_hyp_x)*delta_t
           temp_hypo(i) = temp_hypo(i-1) +  temp_change_hyp(i)
!
! Print output to unit = 30 JRY
!


  !---------- calculate combined (hypo. and epil.) temperature of outflow -----
    outflow_x = flow_out_epi_x + flow_out_hyp_x
    epix = temp_epil(i)*(flow_out_epi_x/outflow_x)  ! portion of temperature from epilim. 
    hypox= temp_hypo(i)*(flow_out_hyp_x/outflow_x)  ! portion of temperature from hypol.
    temp_out_tot(i) = epix + hypox

!------------- write energy budget terms each time step and data to save -----
!          write(*,*) dif_epi_x, temp_hypo, temp_change_hyp(i),advec_in_hypx &
!                 ,  advec_out_hypx,  dif_hyp_x
          write (*,*) i

!          write(30,*) i,temp_epil,temp_hypo,temp_out_tot(i), flow_Tin(i) &
!               ,  temp_change_ep(i), temp_change_hyp(i), advec_in_hypx,advec_out_hypx,dV_dt_hyp &
!                , flow_epi_hyp_x, volume_e_x, volume_h_x, flow_in_epi_x,flow_out_hyp_x
end subroutine reservoir_subroutine
