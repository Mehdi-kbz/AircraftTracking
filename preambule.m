function [sp] = preambule(Fse)
    %PREAMBULE Génère un préambule de durée Tp = 8 µs
    % Entrée :
    %   Fse : facteur d'échantillonnage
    % Sortie :
    %   sp : vecteur représentant le préambule

    % Taille du préambule en fonction du facteur d'échantillonnage
    Tp_samples = 8 * Fse; % 8 µs en échantillons

    % Initialiser le vecteur préambule avec des zéros
    sp = zeros(1, Tp_samples);

    % Définir les périodes où le préambule est à 1
    % En supposant une séquence d'impulsions
    sp(1:0.5 * Fse) = 1;                     % Première impulsion
    sp(Fse + 1:1.5 * Fse) = 1;               % Deuxième impulsion
    sp(3.5 * Fse + 1:4 * Fse) = 1;           % Troisième impulsion
    sp(4.5 * Fse + 1:5 * Fse) = 1;           % Quatrième impulsion

    % La taille du préambule est désormais égale à 8*Fse
end
