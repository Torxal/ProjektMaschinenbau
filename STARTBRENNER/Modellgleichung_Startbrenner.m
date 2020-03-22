%#eml
function dx_dt = Modellgleichung_Startbrenner (vec_x ,vec_u , vec_par, vec_e)

dx_dt = 0*vec_x;

T_b             = vec_x(1);
T_wt_out        = vec_x(2);
T_bw            = vec_x(3);

T_bg_in         = vec_e(1);
T_wt_in         = vec_e(2);
T_u             = vec_e(3);

m_sbg           = vec_u(1);
ms_sair         = vec_u(2);

m_b             = vec_par(1);
c_b             = vec_par(2);
c_bg            = vec_par(3);
M_bg            = vec_par(4);
H_CH4           = vec_par(5);
y_CH4           = vec_par(6);
c_air           = vec_par(7);
c_wt            = vec_par(8);
m_wt            = vec_par(9);
k_wt            = vec_par(10);
A_wt            = vec_par(11);
m_bw            = vec_par(12);
c_bw            = vec_par(13);
A_bw_a          = vec_par(14);
A_bw_i          = vec_par(15);
k_bw            = vec_par(16);
k_u             = vec_par(17);

dx_dt(1) = (1/(m_b*c_b))     * (m_sbg*c_bg*( T_bg_in - T_b )            -  A_wt*k_wt*(T_b - T_wt_out)   - A_bw_i*k_bw*(T_b - T_bw) + H_CH4*y_CH4*(m_sbg/M_bg));
dx_dt(2) = (1/(c_wt * m_wt)) * (ms_sair * c_air * ( T_wt_in - T_wt_out) +  A_wt*k_wt*(T_b - T_wt_out));
dx_dt(3) = (1/(m_bw*c_bw))   * (A_bw_i*k_bw*(T_b - T_bw)             -  A_bw_a*k_u*(T_bw - T_u) );
end




