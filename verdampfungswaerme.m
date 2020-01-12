function Q_vd = verdampfungswaerme(T)

 Q_vd =  1/2*(1+tanh(1/0.01*(T-373.15)))*2.26*10^6 ;
 
end
 


