function [s_chapeau] = sous_echantillonnage(re, Fse, Ns, g_a)
% sous_ech : Fonction pour effectuer le sous-échantillonnage d'un signal.
% Entrées :
%   re : signal d'entrée à sous-échantillonner
%   Fse : facteur d'échantillonnage
%   Ns : nombre de symboles souhaités dans le signal de sortie
%   g_a : filtre utilisé pour le sous-échantillonnage
%
% Sortie :
%   s_chapeau : signal sous-échantillonné

% Calcul de la longueur du filtre g_a
D = length(g_a);

% Longueur du signal d'entrée
ends = length(re);

% Initialisation du vecteur de sortie avec des zéros
s_chapeau = zeros(1, Ns);

% Boucle pour sous-échantillonner le signal
for i = 1:Ns
    % Calcul de l'indice de début pour le sous-échantillonnage
    start_index = D + (i - 1) * Fse;
    % Calcul de l'indice de fin pour le sous-échantillonnage
    end_index = start_index + D - 1;

    % Vérification si l'indice de fin dépasse la longueur du signal d'entrée
    if end_index > ends
        % Si oui, assigne 0 à la sortie pour cette position
        s_chapeau(i) = 0;
    else
        % Sinon, effectue le produit de convolution avec le filtre g_a
        s_chapeau(i) = sum(re(start_index:end_index) .* g_a);
    end
end
