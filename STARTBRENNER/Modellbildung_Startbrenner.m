%#eml

clear all; 
close all; 
clc;
% Festlegen aller Variabeln

Q_a = 0;
Q_b = 0;
Q_c = 0;

%% Zustandsgrößen 

syms        x1                  ...  Temperatur des Brennraumes bzw. Brenngases nach Verbrennung
            x2                  ...  Temperatur des Wärmetauschergases nach dem Brenner
            x3                  ...  Tempeartur der Brennerwand
         
vec_x = [x1;x2;x3];             ...  Zustandsvektor
     
%% Eingangsgrößen/Ausgangsgrößen
     

syms            ms_bg_sym           ... ms_bg_in   = ms_bg_out
            ms_wt_air_sym           ... ms_air_in = ms_air_out

vec_u = [ms_bg_sym ; ms_wt_air_sym];    ... Eingangssignal     
    
%% Störgrößen

syms        T_bg_in_sym         ...
            T_wt_in_sym         ...
            T_u_sym             ...
            
vec_e = [T_bg_in_sym ; T_wt_in_sym ; T_u_sym];        

%% Festlegung der Eingangswerte

T_bg_in             = 293.15;
T_wt_in             = 293.15;
T_u                 = 293.15;
ms_CH4              = 4*(10.^(-4));
ms_wt_air           = 6*(10.^(-3));

%% Parameterfestlegung des Integrators

Par_Ini             = [ 293.15  ; 293.15 ; 293.15  ]; ... Anfangsbedingungen des Integrators


%% Berechnung der Massenanteile von Methan, Sauerstoff und Stickstoff im Brenngasgemisch
% (Annahme : eingehender Massenstrom an Methan = 4*e-5 kg/s und wird vollständig verbrannt)
  
% Reaktionsgleichung bei vollst. Verbrennung : CH4 + 2 O2 -> CO2 + 2 H2O
    
molM_CH4            = 0.01604; 
molM_O2             = 0.032;   
molM_N2             = 0.028;

ns_CH4           	=  ms_CH4 / molM_CH4;
ns_O2               =  2*ns_CH4;                
ns_N2               =  (79/21)*ns_O2;
        
ms_O2               =  ns_O2*molM_O2;
ms_N2               =  ns_N2*molM_N2;

ms_bg               =  ms_CH4 + ms_O2 + ms_N2;
ns_bg               =  ns_CH4 + ns_O2 + ns_N2;

mAnteil_CH4         = (ms_CH4/ms_bg);
mAnteil_O2          = (ms_O2/ms_bg);
mAnteil_N2          = (ms_N2/ms_bg);

%% Berechnung der mittleren Dichte des Brenngasgemisches

rho_CH4             = 0.656;           % Dichte in kg/(m^3)
rho_O2              = 1.43;
rho_N2              = 1.25;
rho_eisen           = 7874;          
rho_air             = 1.293;

%mittlere Dichte des Brenngases (Methan + Luft)

rho_bg              =  (mAnteil_CH4)*rho_CH4 + (mAnteil_O2)*rho_O2 + (mAnteil_N2)*rho_N2; 
 
%% Berechnung der Volumina des Brenners bzw des Wärmetauschers (werden als Zylinder angenommen)        

R = 0.12;
D = 0.005;
H = 0.2;

V_b_i = pi*H*R*R;
V_b_a = pi*H*(R+D)*(R+D);

r = 0.025;
h = 0.10;
n = 30;         % Anzahl der Rohrabknickungen/ -windungen

V_wt  = n*pi*h*r*r;

%% Berechnung der Innen- und Außenfläche der Brennerwand (zylindrig)

A_bw_a              =   2*pi*(R+D)*((R+D)+H);       ... Außenwand Brenner
A_bw_i              =   2*pi*R*(R+H);               ... Innenwand Brenner
A_wt                =   n*2*pi*r*(r+h);             ... Wärmetauscher

%% Berechnung der Massen

m_bw                =   (V_b_a-V_b_i)*rho_eisen;    ... Brennwand
m_b                 =   V_b_i*rho_bg;        ... Brenner
%m_b                 =   (V_b_i-V_wt)*rho_bg;        ... Brenner
m_wt                =   V_wt*rho_air;               ... Wärmetauscher

%% Parametrieren der spezifischen Wärmekapazitäten
         
c_CH4               =   2200;
c_O2                =   920;
c_N2                =   1042;         
c_bw                =   452;
c_air               =   1050;

% Mittlung der spezifischen Wärmekapazitäten von Brenner bzw. Wärmetauscher

c_bg                =   (mAnteil_CH4)*c_CH4 + (mAnteil_O2)*c_O2 + (mAnteil_N2)*c_N2;
c_b                 =   c_bg;
c_wt                =   c_air;

% Methan-Anteil im Brenngas

y_CH4               =   (ns_CH4/ns_bg);     % in Prozent

%% Verbrennungsenthalpie
% Bildungsenthalpie = Betrag{[Summe der Enthalpien in Produkte - Summe der Enthalpien in Edukte]
% Unter Beachtung der st�chometrischen Verh�tnisse 
     
H_CH4       = -75000;          % in J/mol
H_O2        =  0;
H_CO2       = -392000;
H_H2O       = -242800;
 
H0  = abs((H_CO2 + 2*H_H2O) - (H_CH4 + 2*H_O2));                    

%% Festlegung der Wärmeübergangskoeffizienten

k_gas_wt             = 80;
k_w_air              = 0.01;
k_gas_w              = 200;

%% Festlegung des Parametervektors

vec_par     = zeros(19,1);

vec_par(1)  = m_b;
vec_par(2)  = c_b;
vec_par(3)  = c_bg;
vec_par(4)  = ns_bg;
vec_par(5)  = H0;
vec_par(6)  = y_CH4;
vec_par(7)  = c_air;
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
vec_par(19) = k_w_air;

%Arbeitspunkte 

e_AP = [T_bg_in ; T_wt_in ; T_u]; 
u_AP = [ ms_bg ; ms_wt_air ];


% stat. Arbeitspunkt ausrechnen: 

dx_dt = Modellgleichung_Startbrenner (vec_x ,u_AP, vec_par, e_AP);

x_AP_berechnet = solve(dx_dt);
x_AP = [double(x_AP_berechnet.x1) ; double(x_AP_berechnet.x2) ; double(x_AP_berechnet.x3)];

%Linearisierung des Zustandvektors

dx_dt = Modellgleichung_Startbrenner (vec_x ,vec_u ,vec_par, vec_e);

A = double(subs(subs(subs( jacobian(dx_dt,vec_x), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));

B = double(subs(subs(subs( jacobian(dx_dt,vec_u), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));

E = double(subs(subs(subs( jacobian(dx_dt,vec_e), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));

% Zeitkonstanten
1./abs(eig(A))

% Eigenwertvorgabe

p = (eig(A));
p_w = 1.3*p;
K = place(A,B,p_w); 

% Störgrößen

D_e = zeros(3,5);
B_e = [B,E];
%K_e = K*[1,0;0,1;0,0];
K_e = place(A,B_e,p_w);



% Regelung

C_lin = [1,0,0;0,1,0];
D_lin = zeros(2,2);

C =[1,0,0;0,1,0;0,0,1];
D = zeros(3,2);

 
S = (C_lin*((B*K-A)^(-1))*B)^(-1);
% Initialisierungsparameter für die lineare ZRD
Par_Ini_lin = Par_Ini - x_AP;

% Zeitkonstant des geregleten Systems
1./abs(eig(A-B_e*K_e))

% Arbeitspunkte der Regelgröße
x_AP_lin = [double(x_AP_berechnet.x1) ; double(x_AP_berechnet.x2) ];

K_2 = [1,0;0,0]*K;

p_2 = eig(A-B*K_2); % -> Eigenwerte sind negativ -> asymptotisch stabil

%x_soll = x_AP_lin;
x_soll = [ 2400 ; 2000];


% vec_u_stoer = [vec_u;vec_e];
% u_AP_stoer  = [u_AP;e_AP];


