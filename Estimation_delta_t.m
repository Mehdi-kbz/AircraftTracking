function delta_t_hat = Estimation_delta_t(y_l, s_p, T_e)
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
    % Trouver le maximum de la corrélation
    [~, max_index] = max(abs(rho));
    
    % Estimation du délai temporel
    delta_t_hat = (max_index - 1) * T_e; % Convertir l'indice en temps
    %disp(delta_t_hat);
end
