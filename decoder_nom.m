function nom_decode = decoder_nom(vecteur_bits)

    vecteur_bits = num2str(vecteur_bits');

    % Supprimer les espaces entre les bits
    vecteur_bits = strrep(vecteur_bits, ' ', '');
    
    % Dictionnaire de correspondance entre séquences de bits et caractères
    bits_possibles = ["000000" "100000" "010000" "110000" "001000" "101000" "011000" "111000" "000100" "100100" "010100" "110100" "001100" "101100" "011100" "111100" "000010" "100010" "010010" "110010" "001010" "101010" "011010" "111010" "000110" "100110" "010110" "110110" "001110" "101110" "011110" "111110" "000001" "100001" "010001" "110001" "001001" "101001" "011001" "111001" "000101" "100101" "010101" "110101" "001101" "101101" "011101" "111101" "000011" "100011" "010011" "110011" "001011" "101011" "011011" "111011" "000111" "100111" "010111" "110111" "001111" "101111" "011111" "111111"];
    
    caracteres = ["   " "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"  "   " "   " "   " "   "  "   " "SP" "   " "   " "   " "   "  "   " "   " "   " "   " "   " "   " "   " "   " "   " "   " "   " "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"  "   "  "   " "   " "   " "   " "   "];
    
    % Création du dictionnaire pour le décodage
    dictionnaire = dictionary(bits_possibles, caracteres);
    
    % Décoder les bits et afficher le résultat
    nom_decode = dictionnaire(vecteur_bits);
    %disp(vecteur_bits + " correspond à " + nom_decode);
end
