clc;
clear;

%%%% Paramètres %%%%
T_s = 1e-6; % Période d'échantillonnage en secondes
dt = T_s / 10; % Pas de temps pour la simulation
t = -5*T_s:dt:5*T_s; % Plage de temps pour la simulation en secondes

%%%% Définition des fonctions p_0(t) et p_1(t) %%%%
p_0 = zeros(size(t)); % Fonction pour p_0(t)
p_1 = zeros(size(t)); % Fonction pour p_1(t)

%%%% Fonction rectangulaire pour p_0(t) et p_1(t) %%%%
p_0(t >= 0.5e-6 & t < 1e-6) = 1; 
p_1(t >= 0 & t < 0.5e-6) = 1; 

%%%% Séquence binaire des bits %%%%
b = [1 0 0 1 0]; % Séquence binaire

%%%% Initialisation du signal s_l(t) %%%%
s_l = zeros(size(t));

%%%% Construction du signal s_l(t) %%%%
for k = 1:length(b)
    if b(k) == 0
        % Décalage pour p_0
        impulse = circshift(p_0, [0, round((k-1) * (T_s / dt))]);
    else
        % Décalage pour p_1
        impulse = circshift(p_1, [0, round((k-1) * (T_s / dt))]);
    end
    
    % Superposition non cumulative : assure qu'il n'y a pas de somme supérieure à 1
    s_l = max(s_l, impulse); % Utilisation du maximum pour éviter une amplitude de 2
end

%%%% Tracé du signal %%%%
figure;
plot(t*1e6, s_l, 'r', 'LineWidth', 2); % Conversion du temps en microsecondes pour l'affichage
xlabel('Temps (µs)');
ylabel('s_l(t)');
title('Signal s_l(t)');
grid on;
axis([-1 5 0 1.2]); % Ajustement des axes basé sur la plage de temps et l'amplitude du signal
