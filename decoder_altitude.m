function [alt] = decoder_altitude(r_a)
    % Cette fonction décode l'altitude à partir d'un vecteur binaire r_a.
    % L'altitude est codée sur 12 bits, où le 8ème bit est inutile.
    % Le registre r_a est composé des bits suivants : 
    % [b1, b2, b3, b4, b5, b6, b7, b9, b10, b11, b12].

    % Conserver les bits utiles (1 à 7 et 9 à 12) en excluant le 8ème bit
    r_a = [r_a(1:7), r_a(9:12)];
    
    % Convertir le vecteur binaire en entier non signé
    ra = bin2dec(num2str(r_a));
    
    % Calculer l'altitude en pieds
    alt = 25 * ra - 1000;
end
