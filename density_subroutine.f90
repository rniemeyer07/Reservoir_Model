subroutine stream_density(T_epil, T_hypo, stream_T_in, density_epil,density_hypo, density_in)
!    use Block_Reservoir

implicit none

    real :: T_epil, T_hypo, stream_T_in, density_epil,density_hypo, density_in

!-------------------calculate the density based on temperature----------------

    density_epil = 1.000028*1e-3*((999.83952+16.945176*T_epil)-(7.9870401e-3*(T_epil**2)-46.170461e-6*(T_epil**3))+ &
                       & (105.56302e-9*(T_epil**4)-280.54235e-12*(T_epil**5)))/(1+16.87985e-3*T_epil)
    density_hypo = 1.000028*1e-3*((999.83952+16.945176*T_hypo)-(7.9870401e-3*(T_hypo**2)-46.170461e-6*(T_hypo**3))+ &
                       & (105.56302e-9*(T_hypo**4)-280.54235e-12*(T_hypo**5)))/(1+16.87985e-3*T_hypo)
    density_in = 1.000028*1e-3*((999.83952+16.945176*stream_T_in)-(7.9870401e-3*(stream_T_in**2)-46.170461e-6*(stream_T_in**3))+ & 
                       & (105.56302e-9*(stream_T_in**4)-280.54235e-12*(stream_T_in**5)))/(1+16.87985e-3*stream_T_in)


end subroutine stream_density

