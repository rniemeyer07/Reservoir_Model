SUBROUTINE surf_energy(stream_T_in,q_surf,ncell)
   use Block_Energy
   implicit none
   integer::i,ncell,nd
   real::A,B,q_equil,e0,q_surf,q_conv,q_evap,q_ws,td,stream_T_in
   real, dimension(2):: q_fit, T_fit
!
   td=nd
   T_fit(1)=stream_T_in-1.0
   T_fit(2)=stream_T_in+1.0

   do i=1,2
      e0 = 2.1718E8*EXP(-4157.0/(T_fit(i)+239.09))
      rb = pf*(dbt(1)-T_fit(i))
      lvp = 597.0-0.57*T_fit(i)
      q_evap = 1000.*lvp*evap_coeff*wind(1)
      if(q_evap.lt.0.0) q_evap=0.0
      q_conv = rb*q_evap
      q_evap = q_evap*(e0-ea(1))
      q_ws = 6.693E-2+1.471E-3*T_fit(i)
      q_fit(i) = q_ns(1)+q_na(1)-q_ws-q_evap+q_conv
   end do


    write(31,*) e0, rb, pf, lvp,evap_coeff,wind(ncell), stream_T_in, q_surf, q_fit(1), q_fit(2)  &
               , q_ns(1), q_na(1), q_ws, q_evap, q_conv

!
!     q=AT+B
!
!     Linear fit over the range of 2.0 deg C.
!     These results can be used to estimate the "equilibrium" 
!     temperature and linear rate constant.
!
   A=(q_fit(1)-q_fit(2))/(T_fit(1)-T_fit(2))
    q_surf=0.5*(q_fit(1)+q_fit(2))
   B=(q_surf/A)-((T_fit(1)+T_fit(2))/2) 
   q_equil = A * ((T_fit(1)+T_fit(2))/2) + B
!     ******************************************************
!               Return to Subroutine RIVMOD
!     ******************************************************
!
END Subroutine Surf_Energy
