function masse = m_wt_function(T)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
masse =  -1/2*(1+tanh(1/0.01*(T-373.15)))*(0.18-1.1*10^(-4))+0.18
end

