%#eml
function dx_dt = Modellgleichung (vec_x ,vec_u , vec_par, vec_e)

dx_dt = 0*vec_x;

T_b             = vec_x(1);
T_wt_out        = vec_x(2);
T_bw            = vec_x(3);

ms_wt_f         = vec_u(1);


m_b             = vec_par(1);
c_b             = vec_par(2);
c_bg            = vec_par(3);
ns_bg           = vec_par(4);
H0              = vec_par(5);
y_0             = vec_par(6);
c_wt_f          = vec_par(7);
c_wt            = vec_par(8);
m_wt            = vec_par(9);
k_gas_wt        = vec_par(10);
A_wt            = vec_par(11);
Q_a             = vec_par(12);
Q_b             = vec_par(13);
m_bw            = vec_par(14);
c_bw            = vec_par(15);
A_bw_a          = vec_par(16);
A_bw_i          = vec_par(17);
k_gas_w         = vec_par(18);
k_w_luft        = vec_par(19);
ms_H2O          = vec_par(20);
T_bg_in         = vec_e(1);
T_wt_in         = vec_e(2);
T_u             = vec_e(3);
ms_bg           = vec_e(4);

dx_dt(1) = (1/(m_b*c_b))     * (ms_bg*c_bg*( T_bg_in - T_b )       -  A_wt*k_gas_wt*(T_b - T_wt_out)   - A_bw_i * k_gas_w*(T_b - T_bw) + H0*ns_bg*y_0-Q_a);
dx_dt(2) = (1/(c_wt_function(T_wt_out) * m_wt)) * (ms_wt_f * c_wt_function(T_wt_out) * (T_wt_in - T_wt_out) +  A_wt*k_gas_wt*( T_b - T_wt_out )- verdampfungswaerme(T_wt_out)*ms_wt_f-Q_b);
dx_dt(3) = (1/(m_bw*c_bw))   * (A_bw_i*k_gas_w*(T_b - T_bw)        -  A_bw_a*k_w_luft*(T_bw - T_u));

end




