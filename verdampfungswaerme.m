function Q_vd = verdampfungswaerme(T)

 e = 0.01;
 Q_vd =  1/2*(1+tanh(1/e*(T-373.15)))*2.26*10^6 ;
 
end
 


