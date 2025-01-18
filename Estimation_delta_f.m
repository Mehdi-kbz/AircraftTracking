function delta_f_hat = Estimation_delta_f(y_l, s_p, T_e)
    % y_l : signal reçu
    % s_p : signal de préambule

    % Taille du préambule et du signal reçu
    Lp = length(s_p);
    Ly = length(y_l);
    
    % Initialisation du vecteur de corrélation
    rho = zeros(1, Ly - Lp + 1);
    
    % Boucle pour calculer la corrélation
    for delta_t = 1:(Ly - Lp)
        y_window = y_l(delta_t:delta_t + Lp - 1);
        rho(delta_t) = sum(y_window .* conj(s_p));
    end
    
    % Trouver l'indice du maximum de corrélation
    [~, max_index] = max(abs(rho));
    
    % Définir une fenêtre autour de l'indice pour calculer l'estimation du décalage fréquentiel
    if max_index + 1 <= Ly
        phase_diff = angle(rho(max_index + 1)) - angle(rho(max_index));
        delta_f_hat = phase_diff / (2 * pi * T_e);
    else
        delta_f_hat = NaN;
        disp('Erreur : l\'indice maximum est hors des limites.');
    end
end
