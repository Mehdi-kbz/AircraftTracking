function indices_max = Estimation_indices_max(y_l, s_p, T_e,seuil_detection)
    % y_l : signal reçu
    % s_p : signal de préambule

    % Taille du préambule et du signal reçu
    Lp = length(s_p);
    Ly = length(y_l);
    
    % Calcul de l'énergie du préambule
    energy_sp = sum(abs(s_p).^2);

    % Initialisation du vecteur de corrélation
    rho = zeros(1, Ly);
    
    % Boucle pour calculer la corrélation
    for delta_t = 1:(Ly - Lp)
        % Fenêtre de corrélation
        y_window = y_l(delta_t:delta_t + Lp - 1);
        
        % Énergie du signal reçu dans la fenêtre
        energy_yl_window = sum(abs(y_window).^2) ;
        
        % Calcul de la corrélation
        rho(delta_t) = sum(y_window .* conj(s_p))  / (sqrt(energy_sp) * sqrt(energy_yl_window));
    end
    %plot(abs(rho));
    %title("Courbe de rho(delta_t) en fonction de delta_t");
    %ylabel("rho(delta_t)");
    %xlabel("delta_t");
    %%% Trouver tous les indices où la corrélation dépasse le seuil de 0.8
    
    % Trouver les indices où la corrélation absolue est supérieure au seuil
    indices_max = find(abs(rho) > seuil_detection);
    
    % Convertir ces indices en temps en fonction de Te
    temps_indices = (indices_max - 1) * T_e;
    
    % Afficher les indices trouvés
    %disp('Indices de corrélation supérieure à 0.8 :');
    disp(indices_max);
    
    % Afficher le temps correspondant à chaque indice
    %disp('Temps correspondant à chaque indice :');
    disp(temps_indices);


end
