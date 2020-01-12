%#eml

clear all; 
close all; 
clc;
% Festlegen aller Variabeln
        
%% St�rgr��en 

            Q_a                 = 0;
            Q_b                 = 0;
            Q_c                 = 0;
        
%% Zustandsgr��en

syms        x1                  ...  Temperatur des Brennraumes bzw. Brenngases nach Verbrennung
            x2                  ...  Temperatur des W�rmetauscherfluides nach dem Brenner
            x3                  ...  Tempeartur der Brennerwand
         
vec_x = [x1;x2;x3];             ...  Zustandsvektor
     
%% Eingangsgr��en/Ausgangsgr��en
     
syms        T_bg_in_sym         ...
            T_wt_in_sym         ...
            T_u_sym             ...
            ms_bg_sym           ... ms_bg_in = ms_bg_out
            ms_wt_f_sym         ... ms_wt_f_in = ms_wt_f_out

vec_u = [ms_wt_f_sym];    ... Eingangssignal     
        
%% Festlegung der Eingangswerte

T_wt_in             = 293.15;       ... Eingangstemperatur des W�rmetauschers 
T_bg_in             = 1000;         ... Eingangstemperautur des Brenners 
T_u                 = 293.15;       ... Umgebungstemperatur
ms_H2               = 5*(10.^(-6)); ... Massenstrom Wasserstoff  
ms_wt_f             = 5.5*10^(-4);
% Parameterfestlegung des Integrators

Par_Ini             = [1000;293.15;293.15];      ... Anfangsbedingungen des Integrators
%% Festlegen der Brennergeometrie  

R     = 0.01;                        ... Radius des Brenners
D     = 0.005;                       ... Wanddicke vom Brenner                          ... Anzahl der Rohrwiederholungen (Fl�che wurde so gew�hlt, dass 80% des Brennraumvolumens eingenommen wird)
H     = 0.025;                        ... L�nge/H�he des Brennraumzylinders
%% W�rmedurchgangskoeffizienten  

k_gas_wt             = 40;
k_w_luft             = 0.4;
k_gas_w              = 40;

%% Mittelere Dichten 

rho_H2              = 0.0899;       ... Dichte Wasserstoff
rho_O2              = 1.43;         ... Dichte Sauerstoff 
rho_N2              = 1.25;         ... Dichte Stickstoff 
rho_eisen           = 7874;         ... Dichte Eisen
rho_H2O             = 0.59;         ... Dampf 

%% Parametrieren der spezifischen W�rmekapazit�ten
         
c_H2                =   1870;
c_O2                =   920;
c_N2                =   1042;         
c_eisen             =   452;
c_bw                =   c_eisen;
c_wt_f              =   4190;
c_H2O               =   4190; 
%% Berechnung der Massenanteile von Methan, Sauerstoff und Stickstoff im Brenngasgemisch

ms_H2O              = 4.5*10^(-5);   ... Aus Richtwerten

molM_H2             =  0.001; 
molM_O2             =  0.032;   
molM_N2             =  0.028;
molM_H2O            =  0.016;

ns_H2           	=  ms_H2 / molM_H2;
ns_O2               =  1/2*ns_H2;                
ns_N2               =  (79/21)*ns_O2;
ns_H2O              =  ms_H2O / molM_H2O; 

ms_O2               = ns_O2*molM_O2; ... 
ms_N2               = ns_N2*molM_N2;

ms_bg               = ms_H2 + ms_O2 + ms_N2 + ms_H2O;
ns_bg               = ns_H2 + ns_O2 + ns_N2 + ns_H2O;

mAnteil_H2          = (ms_H2/ms_bg);
mAnteil_O2          = (ms_O2/ms_bg);
mAnteil_N2          = (ms_N2/ms_bg);
mAnteil_H2O         = (ms_H2O/ms_bg); 

%% Mittlere Dichte des Brenngases (Methan + Luft
rho_bg              =  (mAnteil_H2)*rho_H2 + (mAnteil_O2)*rho_O2 + (mAnteil_N2)*rho_N2 + (mAnteil_H2O)*rho_H2O; 

%% Volumen Brenner und W�rmetauscher 
V_b_i        =   H*pi*((R)^2);
V_b_a        =   H*pi*((R+D).^2); % �u�ere Volumen des Brenners
%% Berechnung der Innen- und Au�enfl�che der Brennerwand (zylindrig)
A_bw_a              =   2*pi*(R+D)*((R+D)+H);       ... Au�enwand Brenner
A_bw_i              =   2*pi*R*(R+H);               ... Innenwand Brenner
A_wt                =   0.12;            ... W�rmetauscher
%% Berechnung der Massen

m_bw                =   (V_b_a-V_b_i)*rho_eisen;    ... Brennwand
m_b                 =   V_b_i*rho_bg;               ... Brenner
m_wt                =   1.17*10^(-4)       ;               ... W�rmetauscher

%% Mittlung der spezifischen W�rmekapazit�t

c_bg                =   (mAnteil_H2)*c_H2 + (mAnteil_O2)*c_O2 + (mAnteil_N2)*c_N2 + (mAnteil_H2O)*c_H2O;
c_b                 =   c_bg;

% Methan-Anteil im Brenngas

y_H2               =   (ns_H2/ns_bg);     % in Prozent


%% Verbrennungsenthalpie

    
H0          = abs(-282000);                    

%% Festlegung des Parametervektors
c_wt = 0; %.. Bitte ignorieren. Hat kein Relevanz mehr

vec_par     = zeros(24,1);


vec_par(1)  = m_b;
vec_par(2)  = c_b;
vec_par(3)  = c_bg;
vec_par(4)  = ns_bg;
vec_par(5)  = H0;
vec_par(6)  = y_H2;
vec_par(7)  = c_wt_f;
vec_par(8)  = c_wt;
vec_par(9)  = m_wt;
vec_par(10) = k_gas_wt;
vec_par(11) = A_wt;
vec_par(12) = Q_a;
vec_par(13) = Q_b;
vec_par(14) = m_bw;
vec_par(15) = c_bw;
vec_par(16) = A_bw_a;
vec_par(17) = A_bw_i;
vec_par(18) = k_gas_w;
vec_par(19) = k_w_luft;
vec_par(20) = T_bg_in;
vec_par(21) = T_wt_in ;
vec_par(22) = T_u;
vec_par(23) = ms_bg;
vec_par(24) = ms_H2O; 
%%
%Arbeitspunkte von u/x

u_AP = [ms_wt_f];
x_AP = 900*ones(size(vec_x));

%Linearisierung des Zustandvektors

syms lin_A b;

lin_A   = lin_A*0;

b       = b*0;

dx_dt = Modellgleichung (vec_x ,vec_u , vec_par);

lin_A = double(subs(subs( jacobian(dx_dt,vec_x), vec_x, x_AP), vec_u, u_AP));

%b     = double(subs(subs( jacobian(dx_dt,vec_u), vec_x, x_AP), vec_u, u_AP));

%
% stat. Arbeitspunkt ausrechnen: 

dx_dt = Modellgleichung (vec_x ,u_AP, vec_par)
x_AP_berechnet = solve(dx_dt)
double(x_AP_berechnet.x1)
double(x_AP_berechnet.x2)

% Zeitkonstanten
1./abs(eig(lin_A))
    
%% Regelung
%p_w gew�nschte Polstelle
%K = place(lin_A, b, p_w); 
%pw =... 
%p_or = eig(lin_A); 

%% Bitte ignorieren. Ist nur zur Pr�fung der Gr��enverh�ltnisse Berechnung der Volumina des Brenners bzw des Wärmetauschers (werden als Zylinder angenommen)              
% bei einem vollständigem Massenaustausch im Brennraum innerhalb 1 Sekunde
%  m_b : ms_b
%delta_b      =   1;
%Vs_bg        =   ms_bg/rho_bg;    % Volumenstrom Brenngas bzw. Wasser
%V_b_i        =   Vs_bg/delta_b;   % Volumen des Brennerinnenraumes bzw Wärmetauschers


 