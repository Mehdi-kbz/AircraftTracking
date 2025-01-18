close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %
Fe = 20 * 1e6;                          % Fréquence d'échantillonnage                               %
Ts = 1e-6;                              % Période d'échantillonnage                                 %
Fse = Ts * Fe;                          % Facteur de suréchantillonnage                             %
N_b = 1000;                             % Nombre de bits                                            %
NFFT = 256;                             % Taille de la FFT                                          %
sigma = 0.1;                            % Variance du bruit                                         %                                      
                                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chaine de communications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Génération de bits aléatoires %%%
b = randi([0 1], 1, N_b); 

%%% Conversion des bits en symboles %%%
a = b;
a(a == 1) = -1; % 1 devient -1
a(a == 0) = 1;  % 0 devient 1

%%% Suréchantillonnage par Fse %%%
b_se = sur_echantillonnage(a, Fse);

%%% Filtre de mise en forme %%%
t = linspace(0, Ts, Fse);
p1 = zeros(size(t));
p1(t >= 0.5 * Ts & t <= Ts) = 0.5;
p2 = zeros(size(t));
p2(t >= 0 & t <= 0.5 * Ts) = -0.5;
p = p1 + p2;

%%% Convolution du filtre de mise en forme avec le vecteur symbole b_se %%%
sl = 0.5 + conv(b_se, p, 'same'); 

%%% Générer du bruit blanc gaussien %%%
bruit = sigma * randn(size(sl));

sl_bruit = sl + bruit; 

%%% DSP expérimentale (sans fenêtres ni recouvrement) %%%
dsp_exp = (abs(fftshift(fft(sl, NFFT))).^2) / (NFFT * Fe);        % Calcul de la DSP
f_exp = linspace(-Fe/2, Fe/2, NFFT);                              % Axe de fréquence pour DSP expérimentale


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul de la DSP théorique %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirac = zeros(1, N_b);
dirac(N_b / 2 + 1) = 1; 
axe_f = linspace(-Fe/2, Fe/2, N_b);
dsp_th = 0.25 * dirac + (pi^2) * (Ts^3) * (axe_f.^2) .* (sinc((Ts/2) * axe_f).^4) / 16;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracé des courbes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Tracé de la DSP expérimentale %%%
figure;
semilogy(f_exp, dsp_exp, "b");
hold on;

%%% Tracé de la DSP théorique %%%
semilogy(axe_f, dsp_th, "r");
hold on;

%%% Titre et légende %%%
title("DSP Théorique et DSP Expérimentale");
xlabel("Fréquence (Hz)");
ylabel("DSP");
legend("DSP_{Exp} obtenue avec la fonction Mon-Welch", "DSP_{Th} obtenue avec le calcul.");
grid on;

%%% Ajustement de l'axe des x pour superposition %%%
xlim([-Fe/2 Fe/2]);