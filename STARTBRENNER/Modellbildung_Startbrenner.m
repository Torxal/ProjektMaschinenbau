%#eml

clear all; 
close all; 
clc;

%% Zustandsgrößen 

syms        x1                  ...  Temperatur des Brennraumes bzw. Brenngases nach Verbrennung
            x2                  ...  Temperatur des Wärmetauschergases nach dem Brenner
            x3                  ...  Tempeartur der Brennerwand
         
vec_x = [x1;x2;x3];             ...  Zustandsvektor
     
%% Eingangsgrößen/Ausgangsgrößen
     

syms            ms_bg_sym           ... ms_bg_in   = ms_bg_out
                ms_air_sym          ... ms_air_in = ms_air_out

vec_u = [ms_bg_sym ; ms_air_sym];    ... Eingangssignal     
    
%% Störgrößen

syms        T_bg_in_sym         ...
            T_wt_in_sym         ...
            T_u_sym             ...
            
vec_e = [T_bg_in_sym ; T_wt_in_sym ; T_u_sym];        

%% Festlegung der Eingangswerte

T_bg_in             = 293.15;
T_wt_in             = 293.15;
T_u                 = 293.15;

m_sCH4              = 4*(10.^(-4));
m_sair              = 5*(10.^(-3));

%% Parameterfestlegung des Integrators

T_Ini             = [ 293.15  ; 293.15 ; 293.15  ]; ... Anfangsbedingungen des Integrators


%% Berechnung der Massenanteile von Methan, Sauerstoff und Stickstoff im Brenngasgemisch
% (Annahme : eingehender Massenstrom an Methan = 4*e-5 kg/s und wird vollständig verbrannt)
  
% Reaktionsgleihttps: bei vollst. Verbrennung : CH4 + 2 O2 -> CO2 + 2 H2O
    
M_CH4            = 0.01604; 
M_O2             = 0.032;   
M_N2             = 0.028;



n_sCH4           	=  m_sCH4 / M_CH4;
n_sO2               =  2*n_sCH4;                
n_sN2               =  (79/21)*n_sO2;
        
m_sO2               =  n_sO2*M_O2;
m_sN2               =  n_sN2*M_N2;

m_sbg               =  m_sCH4 + m_sO2 + m_sN2;
n_sbg               =  n_sCH4 + n_sO2 + n_sN2;

M_bg                =  m_sbg/n_sbg;

alpha_CH4           = (m_sCH4/m_sbg);
alpha_O2            = (m_sO2/m_sbg);
alpha_N2            = (m_sN2/m_sbg);

%% Berechnung der mittleren Dichte des Brenngasgemisches

rho_CH4             = 0.656;           % Dichte in kg/(m^3)
rho_O2              = 1.43;
rho_N2              = 1.25;
rho_eisen           = 7874;          
rho_air             = 1.293;

%mittlere Dichte des Brenngases (Methan + Luft)

rho_bg              =  (alpha_CH4)*rho_CH4 + (alpha_O2)*rho_O2 + (alpha_N2)*rho_N2; 
 
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
m_b                 =   V_b_i*rho_bg;               ... Brenner
m_wt                =   V_wt*rho_air;               ... Wärmetauscher

%% Parametrieren der spezifischen Wärmekapazitäten
         
c_CH4               =   2200;
c_O2                =   920;
c_N2                =   1042;         
c_bw                =   452;
c_air               =   1050;

% Mittlung der spezifischen Wärmekapazitäten von Brenner bzw. Wärmetauscher

c_bg                =   (alpha_CH4)*c_CH4 + (alpha_O2)*c_O2 + (alpha_N2)*c_N2;
c_b                 =   c_bg;
c_wt                =   c_air;

% Methan-Anteil im Brenngas

y_CH4               =   (n_sCH4/n_sbg);     % in Prozent

%% Verbrennungsenthalpie
% Bildungsenthalpie = Betrag{[Summe der Enthalpien in Produkte - Summe der Enthalpien in Edukte]
% Unter Beachtung der st�chometrischen Verh�tnisse 
     
H_CH4       = -75000;          % in J/mol
H_O2        =  0;
H_CO2       = -392000;
H_H2O       = -242800;
 
H_bg  = abs((H_CO2 + 2*H_H2O) - (H_CH4 + 2*H_O2));                    

%% Festlegung der Wärmeübergangskoeffizienten

k_wt                 = 80;
k_u                  = 0.01;
k_bw                 = 200;

%% Festlegung des Parametervektors

vec_par     = zeros(17,1);

vec_par(1)  = m_b;
vec_par(2)  = c_b;
vec_par(3)  = c_bg;
vec_par(4)  = M_bg;
vec_par(5)  = H_bg;
vec_par(6)  = y_CH4;
vec_par(7)  = c_air;
vec_par(8)  = c_wt;
vec_par(9)  = m_wt;
vec_par(10) = k_wt;
vec_par(11) = A_wt;
vec_par(12) = m_bw;
vec_par(13) = c_bw;
vec_par(14) = A_bw_a;
vec_par(15) = A_bw_i;
vec_par(16) = k_bw;
vec_par(17) = k_u;

%Arbeitspunkte 

e_AP = [T_bg_in ; T_wt_in ; T_u]; 
u_AP = [ m_sbg ; m_sair ];


% stat. Arbeitspunkt ausrechnen: 

dx_dt = Modellgleichung_Startbrenner (vec_x ,u_AP, vec_par, e_AP);

x_AP_berechnet = solve(dx_dt);
x_AP = [double(x_AP_berechnet.x1) ; double(x_AP_berechnet.x2) ; double(x_AP_berechnet.x3)];

%Linearisierung des Zustandvektors

dx_dt = Modellgleichung_Startbrenner (vec_x ,vec_u ,vec_par, vec_e);

A = double(subs(subs(subs( jacobian(dx_dt,vec_x), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));

B = double(subs(subs(subs( jacobian(dx_dt,vec_u), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));

E = double(subs(subs(subs( jacobian(dx_dt,vec_e), vec_x, x_AP), vec_e, e_AP), vec_u, u_AP));


% Eigenwertvorgabe

lambda = (eig(A));
lambda_w = 1.3*lambda;
K = place(A,B,lambda_w);
 

% Zeitkonstanten

1./abs(eig(A))
1./abs(eig(A-B*K))

% Störgrößen

% Regelung

C = [1,0,0;0,1,0];
 
S_v = inv(C*(inv(-A+B*K))*B);

% Initialisierungsparameter für die lineare ZRD
T_Ini_Lin = T_Ini - x_AP;

% Arbeitspunkte der Regelgröße
y_AP = [double(x_AP_berechnet.x1) ; double(x_AP_berechnet.x2) ];

w = [1200; 1000];

% Festlegen Störtemperaturen

T_off_bg  = 0;
T_off_wt  = 0;
T_off_u   = 0;

vec_T = [T_off_bg ; T_off_wt ; T_off_u];

vec_z = vec_T + e_AP;

%Größen des PT1-Signals

t = 60;
