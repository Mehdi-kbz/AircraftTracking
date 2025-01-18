clc;
clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %
Ts = 1e-6;                               % Durée symbole 1µs                                        %
Fe = 20e6;                               % Fréquence d'échantillonnage 20 MHz                       %
Te = 1/Fe;                               % Période d'échantillonnage                                %
Fse = Ts / Te;                           % Facteur de suréchantillonnage (20)                       %
Eb_N0_dB = 0:1:10;                       % Eb/N0 en dB de 0 à 10 dB                                 %
TEB = zeros(1, length(Eb_N0_dB));        % Matrice contenant le TEB                                 %
compteur_erreurs = 0;                    % Nombre d'erreurs de transmission                         %
compteur_bits_emis = 0;                  % Nombre d'émissions                                       %
                                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chaine de communications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:length(Eb_N0_dB)             
    while compteur_erreurs < 2000                   

        %%% Séquence de 1000 bits à transmettre %%%
        bits_transmis = (randn(1, 1000) > 0);        
        N = length(bits_transmis);  
                
        %%% Vecteur temps pour le tracé %%%
        t = 0:Te:(N * Ts + Ts); 

        %%% Impulsions PPM  p0 et p1 %%%
        p1 = [ones(1, Fse/2), zeros(1, Fse/2)];  % Impulsion pour bit 1 (1 puis 0)
        p0 = [zeros(1, Fse/2), ones(1, Fse/2)];  % Impulsion pour bit 0 (0 puis 1)
        
        %%% signal sl %%%
        sl = zeros(1, length(t));                
        for i = 0:N-1
            if bits_transmis(i+1) ~= 0                       
                sl(i*Fse+1:(i+1)*Fse) = p1;     
            else                                 
                sl(i*Fse+1:(i+1)*Fse) = p0;      
            end
        end

        %%% Bruit %%%
        Eb_N0 = 10^(Eb_N0_dB(j) / 10);                % Conversion Eb/N0 dB en valeur linéaire
        Eg = sum(abs(p1).^2);                         % Énergie de p1
        N0 = Eg / Eb_N0;                              % DSP du bruit
        bruit = sqrt(N0 / 2) * randn(1, length(sl));  % Bruit gaussien centré avec variance N0/2

        %%% Ajout du Bruit au signal sl %%%
        sl_bruit = sl + bruit;

        %%% signal rl %%%
        filtre_adapte = fliplr(p1);
        rl = conv(sl_bruit, filtre_adapte);             
        rl = rl(1:length(t));    

        %%% decision rm selon la méthode du maximum de vraisemblance %%%
        t_echantillonnage = Ts/2 : Ts/2 : (N-1) * Ts;  
        rm = rl(round(t_echantillonnage / Te));

        bits_estimes = zeros(1, N);                    
        for k = 1:(length(rm)/2)-1                        
            if (rm(2*k) - rm(2*k+1) > 0)    
                bits_estimes(k) = 1;                   
            else
                bits_estimes(k) = 0;                   
            end
        end
        %%% MAJ du nombre d'erreurs accumulées et du nombre de bits envoyés %%%
        compteur_erreurs = compteur_erreurs + sum(bits_transmis ~= bits_estimes);      
        compteur_bits_emis = compteur_bits_emis + 1;     
    end
    
    %%% Calcul du TEB %%%

    TEB(j) = compteur_erreurs / (N * compteur_bits_emis); 
    compteur_erreurs = 0;                              
    compteur_bits_emis = 0;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul du TEB théorique %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Eb_N0 = 10.^(Eb_N0_dB / 10);                 % Conversion de Eb/N0
TEB_theorique = 0.5 * erfc(sqrt(Eb_N0 / 2));  % Probabilité d'erreur binaire



 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracé des courbes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Tracé du signal sl(t) %%%
figure;
subplot(3,1,1);
plot(t*1e6, sl, 'r', 'LineWidth', 2);
xlabel('Temps (\mus)');
ylabel('Amplitude');
title('Signal émis s_l(t)');
grid on;

%%% Tracé du signal reçu r_l(t) %%%
subplot(3,1,2);
plot(t*1e6, rl, 'b', 'LineWidth', 2);
xlabel('Temps (\mus)');
ylabel('Amplitude');
title('Signal reçu r_l(t)');
grid on;

%%% Tracé du vecteur r_m (le résultat de la décision) %%%
subplot(3,1,3);
stem(1:length(bits_transmis), bits_estimes, 'g', 'LineWidth', 2);
xlabel('Numéro du symbole');
ylabel('Valeur du bit r_m');
title('Bits décodés');
grid on;

%%% Tracé du TEB %%%
figure;
semilogy(Eb_N0_dB, TEB, '', 'LineWidth', 1);  
title("Taux d'erreur binaire en fonction de Eb/N0");
xlabel("Eb/N0 (dB)");
ylabel("Taux d'erreur binaire");
grid on;


%%% Tracé de la comparaison entre les TEB théorique et simulé %%%

figure;
semilogy(Eb_N0_dB, TEB, '-ro', 'MarkerFaceColor', 'r');  % TEB simulé en rouge
hold on;
semilogy(Eb_N0_dB, TEB_theorique, '-gs', 'LineWidth', 2); % TEB théorique en vert
xlabel('E_b/N_0 (dB)');
ylabel('TEB');
grid on;
title('Comparaison TEB simulé et TEB théorique');
legend('TEB simulé', 'TEB théorique');
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%