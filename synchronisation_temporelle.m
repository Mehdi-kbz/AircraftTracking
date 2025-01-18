function [argmax, indice] = synchronisation_temporelle(FSE, preambule, yl, Nb)
    % Fonction de synchronisation temporelle pour déterminer l'indice
    % du signal synchronisé à l'aide d'un préambule.

    T_p = 8 * FSE;  % Durée du préambule en échantillons

    conjugated_preambule = conj(preambule);  % Conjugaison du préambule pour la corrélation

    % Définition de la fonction de corrélation rho(t)
    rho = @(t) (sum(yl(t:t+T_p-1) .* conjugated_preambule(1:T_p))) / ...
                (sqrt(sum(abs(sl(t:t+T_p-1).^2))) * sqrt(sum(abs(preambule(1:T_p).^2))));
    
    num = Nb * FSE;  % Nombre total d'échantillons à analyser pour la synchronisation
    argmax = abs(rho(1));  % Initialisation de la valeur maximale de la corrélation
    indice = 1;  % Initialisation de l'indice correspondant à la valeur maximale

    % Boucle pour parcourir chaque échantillon et trouver le maximum
    for i = 2:num
        % Vérification si la valeur de corrélation courante est supérieure à la maximale
        if abs(rho(i)) > argmax
            argmax = abs(rho(i));  % Mise à jour de la valeur maximale
            indice = i;            % Mise à jour de l'indice correspondant
        end
    end
end
