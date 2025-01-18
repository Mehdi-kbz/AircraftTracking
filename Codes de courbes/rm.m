clc;
clear;

%%%% Paramètres de base %%%%
Ts = 1e-6;  % Durée symbole 1µs
Fs = 20e6;  % Fréquence d'échantillonnage 20 MHz
Te = 1/Fs;  % Période d'échantillonnage
Fse = Ts / Te;  % Facteur de surÃ©chantillonnage (20)

%%%% Séquence binaire à transmettre %%%%
b = [1, 0, 0, 1, 0];  % Exemples de bits Ã  transmettre
N = length(b);  % Nombre de bits

%%%% Impulsions PPM pour 0 et 1 %%%%
p1 = [ones(1, Fse/2), zeros(1, Fse/2)];  % Impulsion pour bit 1 (1 puis 0)
p0 = [zeros(1, Fse/2), ones(1, Fse/2)];  % Impulsion pour bit 0 (0 puis 1)

%%%% Génération du signal sl(t) %%%%
sl = [];  % Initialisation du signal émis
for k = 1:N
    if b(k) == 0
        sl = [sl p0];
    else
        sl = [sl p1];
    end
end

%%%% Vecteur temps pour le tracé %%%%
t = (0:length(sl)-1) * Te;  % Vecteur temps


%%%% Modélisation du récepteur (Filtre de réception) %%%%
r_l = conv(sl, fliplr(p1), 'same');  % Convolution avec p1(t)

%%%% Décision pour obtenir rm %%%%
r_m = zeros(1, N);
for k = 1:N
    % Prendre la valeur à  mi-période de chaque symbole (point de décision)
    idx = round(k * Fse - Fse/2);  % Point de décision
    if r_l(idx) > 0.5  % Seuil de décision
        r_m(k) = 1;
    else
        r_m(k) = 0;
    end
end



%%%% Tracé du vecteur rm (le résultat de la décision) %%%%
figure;
stem(1:N, r_m, 'r', 'LineWidth', 2);
xlabel('Numéro du symbole');
ylabel('Valeur du bit r_m');
title('r_m');
