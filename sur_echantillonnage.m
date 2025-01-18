function [x] = sur_echantillonnage(i, j)
% sur_echentillonnage : Fonction pour suréchantillonner un vecteur.
% Entrées :
%   i : vecteur d'entrée (symbole) à suréchantillonner
%   j : facteur de suréchantillonnage (nombre d'échantillons par symbole)
%
% Sortie :
%   x : vecteur suréchantillonné

% Initialisation du vecteur de sortie avec des zéros
x = zeros(1, length(i) * j);

% Boucle pour parcourir chaque élément du vecteur d'entrée
for k = 1:length(i)
    % Remplissage du vecteur suréchantillonné avec des valeurs de 'i'
    % Chaque symbole dans 'i' est répété 'j' fois
    x((k - 1) * j + 1) = i(k); % Affecte le symbole 'i(k)' à la position appropriée
end

end
