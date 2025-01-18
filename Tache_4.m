close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %
Tp = 8 * 1e-6;                           % Durée du Préambule en secondes                           %
Ts = 1e-6;                               % Durée symbole 1µs                                        %
Fe = 20e6;                               % Fréquence d'échantillonnage 20 MHz                       %
Te = 1/Fe;                               % Période d'échantillonnage                                %
Fse = Ts / Te;                           % Facteur de suréchantillonnage (20)                       %
Eb_N0_dB = 0:1:10;                       % Eb/N0 en dB de 0 à 10 dB                                 %
TEB = zeros(1, length(Eb_N0_dB));        % Matrice contenant le TEB                                 %
compteur_erreurs = 0;                    % Nombre d'erreurs de transmission                         %
compteur_bits_emis = 0;                  % Nombre d'émissions                                       %
M = 1998;                                % Nombre d'échantillons souhaités                          %
                                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chaine de communications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:length(Eb_N0_dB)
    while compteur_erreurs < 100
        
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
            %plot(sl);

            %%% Génération du préambule %%%
            s_p = preambule(Fse); 
            %plot(s_p);
            
            %%% Ajout du préambule %%%
            sl_p = [s_p, sl]; 
            %plot(sl_p);
            
            %%% Bruit %%%
            Eb_N0 = 10^(Eb_N0_dB(j) / 10);                % Conversion Eb/N0 dB en valeur linéaire
            Eg = sum(abs(p1).^2);                         % Énergie de p1
            N0 = Eg / Eb_N0;                              % DSP du bruit
            bruit = sqrt(N0 / 2) * randn(1, length(sl_p));  % Bruit gaussien centré avec variance N0/2
    
            %%% Taille du préambule en échantillons %%%
            preambule_samples = length(s_p);
            
            %%%%%%%%%%%%%%%%%%%%%% Désynchronisation %%%%%%%%%%%%%%%%%%%%%%

            %%% Paramètres de désynchronisation %%%
            delta_t = rand * 100*Ts;                % Délai de propagation aléatoire entre 0 et 100 Te
            delta_f = rand * -2000 + 1e3;           % Décalage en fréquence entre -1 kHz et 1 kHz
            phi_0 = rand * 2 * pi;                  % Déphasage aléatoire entre 0 et 2π
            alpha = 1;                              % Facteur d'atténuation
            
            %%% Appliquer le délai de propagation %%%
            delay_samples = round(delta_t * Fe);                            % Convertir le délai en échantillons
            sl_filtre_delayed = [zeros(1, delay_samples), sl_p];            % Ajouter des zéros au début pour le délai
            sl_filtre_delayed = sl_filtre_delayed(1:length(sl_p));          % Ajuster la taille
            
            %%% Calculer le signal reçu (désynchronisé) %%%
            yl = alpha * sl_filtre_delayed .* exp(-1j * 2 * pi * delta_f * (0:length(sl_p)-1) * Ts) .* exp(1j * phi_0)   ;
            
            %%%%%%%%%%%%%%%%%%%% Estimation de delta_t %%%%%%%%%%%%%%%%%%%%
            delta_t_estime = Estimation_delta_t(yl, s_p, 1/Fe);
            
            %%% Convertir le décalage estimé en échantillons %%%
            delta_samples_estime = round(delta_t_estime * Fe);
            
            %%%%%%%%%%%%%%%%%%% Synchronisation du signal %%%%%%%%%%%%%%%%%
            yl_synchronise = yl(delta_samples_estime  + 1 : end);
            
            %%% signal synchronisé sans le préambule %%%
            yl_synchronise_sans_preambule = yl(delta_samples_estime + preambule_samples + 1 : end);
            
            %%% Filtre Adapte %%%
            filtre_adapte = conj(fliplr(p1)); 
            
            %%% Convolution avec le filtre adapté %%%
            rl = conv(yl_synchronise_sans_preambule, filtre_adapte, 'same'); 
            
            %%% Échantillonnage à Ts/2 %%%
               
            %%%% Calcul des instants d'échantillonnage %%%%
            indices_echantillonnage = round(linspace(1, length(rl), M));  
            
            %%%% Échantillonnage du signal rl %%%%
            rm = rl(indices_echantillonnage);        

            %%% decision selon la méthode du maximum de vraisemblance %%%
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
    %%% pour debugger %%%
    %disp("Nombre d'erreurs : "); disp(compteur_erreurs);
    %disp("Nombre de bits émis :"); disp(compteur_bits_emis);
    
    %%% Calcul du TEB %%%
    TEB(j) = compteur_erreurs / (N * compteur_bits_emis); 
    compteur_erreurs = 0;

end
            

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul du TEB théorique %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Eb_N0 = 10.^(Eb_N0_dB / 10);                  % Conversion de Eb/N0
TEB_theorique = 0.5 * erfc(sqrt(Eb_N0 / 2));  % Probabilité d'erreur binaire


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Estimation de delta_t %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

fprintf('Délai de propagation réel: %.6f µs\n', delta_t * 1e6);
fprintf('Délai de propagation estimé: %.6f µs\n', delta_t_estime * 1e6);
fprintf('Erreur d''estimation: %.6f µs\n', abs(delta_t - delta_t_estime) * 1e6);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracé des courbes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% Tracé de la comparaison entre les TEB théorique et simulé %%%
%{
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
%}

%%% Tracé du TEB %%%
figure;
semilogy(Eb_N0_dB, TEB, '', 'LineWidth', 1);  
title("Taux d'erreur binaire en fonction de Eb/N0");
xlabel("Eb/N0 (dB)");
ylabel("Taux d'erreur binaire");
grid on;

figure;
%%% Tracé du signal désynchronisé %%%
subplot(3, 1, 1); 
plot(abs(yl));
title('Signal désynchronisé');
legend('yl');

%%% Tracé du signal synchronisé %%%
subplot(3, 1, 2); 
plot(abs(yl_synchronise));
title('Signal synchronisé');
legend('yl synchronisé');

%%% Tracé du signal synchronisé sans preambule %%%
subplot(3, 1, 3); 
plot(abs(yl_synchronise_sans_preambule));
title('Signal synchronisé sans preambule');
legend('yl synchronisé sans preambule');



