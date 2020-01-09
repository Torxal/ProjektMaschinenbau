%#eml

clear all; 
close all; 
clc;
% Festlegen aller Variabeln
        
%% Störgrößen 

            Q_a                 = 0;
            Q_b                 = 0;
            Q_c                 = 0;
        
%% Zustandsgrößen 

syms        x1                  ...  Temperatur des Brennraumes bzw. Brenngases nach Verbrennung
            x2                  ...  Temperatur des W�rmetauscherfluides nach dem Brenner
            x3                  ...  Tempeartur der Brennerwand
         
vec_x = [x1;x2;x3];             ...  Zustandsvektor
     
%% Eingangsgrößen/Ausgangsgrößen
     
syms        T_bg_in_sym         ...
            T_wt_in_sym         ...
            T_u_sym             ...
            ms_bg_sym           ... ms_bg_in = ms_bg_out
            ms_wt_f_sym         ... ms_wt_f_in = ms_wt_f_out

vec_u = [ms_bg_sym; ms_wt_f_sym];    ... Eingangssignal     
        
%% Festlegung der Eingangswerte

T_wt_in             = 293.15;
T_bg_in             = 293.15;
T_u                 = 293.15;
ms_CH4              = 4*(10.^(-5)); ... Auslegung an vorgebenen Parametern 

%% Parameterfestlegung des Integrators

Par_Ini             = [293.15;293.15;293.15]; ... Anfangsbedingungen des Integrators

%% Mittelere Dichten 

rho_CH4             = 0.656;           % Dichte in kg/(m^3)
rho_O2              = 1.43;
rho_N2              = 1.25;
rho_eisen           = 7874;          
rho_wt_f            = 997;

%% Berechnung der Massenanteile von Methan, Sauerstoff und Stickstoff im Brenngasgemisch
% (Annahme : eingehender Massenstrom an Methan = 4*e-5 kg/s und wird vollst�ndig verbrannt)
  
% Reaktionsgleichung bei vollst. Verbrennung : CH4 + 2 O2 -> CO2 + 2 H2O
    
molM_CH4            =  0.01604; 
molM_O2             =  0.032;   
molM_N2             =  0.028;
ns_CH4           	=  ms_CH4 / molM_CH4;
ns_O2               =  2*ns_CH4;                
ns_N2               =  (79/21)*ns_O2;
        
ms_O2               = ns_O2*molM_O2;
ms_N2               = ns_N2*molM_N2;

ms_bg               = ms_CH4 + ms_O2 + ms_N2;
ns_bg               = ns_CH4 + ns_O2 + ns_N2;

mAnteil_CH4         = (ms_CH4/ms_bg);
mAnteil_O2          = (ms_O2/ms_bg);
mAnteil_N2          = (ms_N2/ms_bg);


%% Mittlere Dichte des Brenngases (Methan + Luft

rho_bg              =  (mAnteil_CH4)*rho_CH4 + (mAnteil_O2)*rho_O2 + (mAnteil_N2)*rho_N2; 
%% Dynamsiche Viskositäten bei 15°C

eta_CH4 = 10.8 *(10.^-6);        
eta_O2  = 19.2 *(10.^-6);
eta_N2  = 16.2 *(10.^-6);
eta_bg  = (mAnteil_CH4)*eta_CH4 + (mAnteil_O2)*eta_O2 + (mAnteil_N2)*eta_N2;    % dyn. Viskosität des Brenngases

%eta_wt_f = 890*(10.^(-6));   % bei 25°C (l) 
eta_wt_f = 38.48*(10.^(-6));  % bei 750°C (g)

%% Bestimmung der Radien abhängig von der Reynoldszahl der Strömung 

% Herleitung :
% Re = (rho*v*2r)/eta
% Vs = A * v mit A = pi*r² & Vs = ms/rho -> v = ms/(rho*pi*r²)
% Re = (rho*2r*ms)/(rho*pi*r²*eta) = (2*ms)/(pi*r*eta)
% r  = (2*ms)/(Pi*eta*Re)

Re_b  = 200;          % Reynoldszahl für Brenngas (laminare Strömung)
Re_wt = 3000;         % Reynoldszahl für Wasser   (turbulente Strömung)
%R = (2*ms_bg)/(eta_bg*pi*Re_b);        % Radius Brenner  
R = 0.05; 
%r = (2*ms_wt_f)/(eta_wt_f*pi*Re_wt);   % Radius Wärmetauscher
%Dimensionierung Massenstrom des Fluides �ber vorher festgelegten Radius und Reynolds Zahl 
r = 0.005; 
ms_wt_f = r*eta_wt_f*pi*Re_wt/2;

D     =      0.005;                       % Wanddicke vom Brenner 
%% Berechnung der Volumina des Brenners bzw des Wärmetauschers (werden als Zylinder angenommen)              
% bei einem vollständigem Massenaustausch im Brennraum innerhalb 1 Sekunde
%  m_b : ms_b
delta_wt     =   1;            % Massenaustauschverhältnis in %/sek
delta_b      =   1;
Vs_bg        =   ms_bg/rho_bg;    % Volumenstrom Brenngas bzw. Wasser
V_b_i        =   Vs_bg/delta_b;   % Volumen des Brennerinnenraumes bzw Wärmetauschers
%Vs_wt        =   ms_wt_f/rho_wt_f;
%V_wt         =   Vs_wt/delta_wt;
H = V_b_i/(pi*R*R); %H�he des Brenners und der Brennerwand  
%h = V_wt/(pi*r*r);
h = H; 
V_b_a        =   H*pi*((R+D).^2); % äußere Volumen des Brenners
V_wt         =   h*pi*((r).^2);
%% Berechnung der Innen- und Außenfläche der Brennerwand (zylindrig)

%Wiederholung Rohrschleife
wd                  =   15; 

A_bw_a              =   2*pi*(R+D)*((R+D)+H);       ... Außenwand Brenner
A_bw_i              =   2*pi*R*(R+H);               ... Innenwand Brenner
A_wt                =   2*pi*r*(r+h*wd);            ... Wärmetauscher
%% Berechnung der Massen

m_bw                =   (V_b_a-V_b_i)*rho_eisen;    ... Brennwand
m_b                 =   V_b_i*rho_bg;               ... Brenner
m_wt                =   V_wt*rho_wt_f;              ... Wärmetauscher

%% Parametrieren der spezifischen W�rmekapazit�ten
         
c_CH4               =   1867;
c_O2                =   920;
c_N2                =   1042;         
c_eisen             =   452;
c_bw                =   c_eisen;
c_wt_f              =   4190;

% Mittlung der spezifischen W�rmekapazit�ten von Brenner bzw. W�rmetauscher

c_wt                =   c_wt_f;
c_bg                =   (mAnteil_CH4)*c_CH4 + (mAnteil_O2)*c_O2 + (mAnteil_N2)*c_N2;
c_b                 =   c_bg;

% Methan-Anteil im Brenngas

y_CH4               =   (ns_CH4/ns_bg);     % in Prozent

%% Verbrennungsenthalpie
% Bildungsenthlpie = Betrag{[Summe der Enthalpien in Produkte - Summe der Enthalpien in Edukte]
% Unter Beachtung der st�chometrischen Verh�tnisse 
     
H_CH4       = -75000;          % in J/mol
H_O2        = 0;
H_CO2       = -392000;
H_H2O       = -241000;
 
H0  = abs((H_CO2 + 2*H_H2O) - (H_CH4 + 2*H_O2));                    

%% Festlegung des realten Massenstroms CH4  
k_gas_wt             = 1000;
k_w_luft             = 10;
k_gas_w              = 1000;

ms_CH4               = 8*(10.^(-5)); % bitte festlegen 
ns_CH4           	=  ms_CH4 / molM_CH4;
ns_O2               =  2*ns_CH4;                
ns_N2               =  (79/21)*ns_O2;
        
ms_O2               = ns_O2*molM_O2;
ms_N2               = ns_N2*molM_N2;

ms_bg               = ms_CH4 + ms_O2 + ms_N2;
ns_bg               = ns_CH4 + ns_O2 + ns_N2;

mAnteil_CH4         = (ms_CH4/ms_bg);
mAnteil_O2          = (ms_O2/ms_bg);
mAnteil_N2          = (ms_N2/ms_bg);

%% Festlegung des Parametervektors

vec_par     = zeros(23,1);


vec_par(1)  = m_b;
vec_par(2)  = c_b;
vec_par(3)  = c_bg;
vec_par(4)  = ns_bg;
vec_par(5)  = H0;
vec_par(6)  = y_CH4;
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

%Arbeitspunkte von u/x

u_AP = [ms_bg ; ms_wt_f ];
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
    

%% Für gewählte Radien  
% gewählte Abmessungen der Zylinder in m

% % für Brenner
% D            =   0.005;       % Wanddicke vom Brenner
% R            =   0.04;
% H            =   V_b_i/(pi*R*R);
% 
% V_b_a        =   H*pi*((R+D).^2); % äußere Volumen des Brenners
% 
% % für Wärmetauscher (Bereich der sich im Brenner befindet)
% r            =   0.01;
% h            =   V_wt/(pi*r*r); 

% % Reynoldzahlen 
% Re_bg        =   (2*ms_bg)/(pi*R*eta_bg);
% Re_wt        =   (2*ms_wt_f)/(pi*r*eta_wt_f);






 