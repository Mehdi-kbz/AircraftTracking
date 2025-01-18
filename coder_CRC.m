function [donnees, paquet_Encode] = coder_CRC()

    % Paramètres
    Nb = 88; % Taille des données utiles en bits (nombre de bits du message)

    % Génération d'un message aléatoire de 88 bits
    donnees = randi([0 1], Nb, 1); % 88 bits de données aléatoires

    % Création d'un objet générateur CRC avec le polynôme spécifié
    % Le polynôme binaire utilisé est : 111111111111101000000101
    % Ce polynôme est représenté par ses puissances de x dans l'objet crc.generator
    poly_crc = [24 23 22 21 20 19 18 17 16 15 14 13 12 10 3 0];
    generateur_CRC = comm.CRCGenerator(poly_crc); % Polynôme CRC spécifié

    % Génération du paquet encodé avec CRC
    % La fonction generate prend en entrée les données et retourne un paquet encodé avec CRC
    % Le CRC ajouté est de 24 bits, donc la taille totale du paquet est 88 bits (données) + 24 bits (CRC) = 112 bits
    paquet_Encode = generateur_CRC(donnees); % Paquet total encodé : 112 bits

    % Retourner les données générées et le paquet encodé
    % 'donnees' contient les 88 bits d'origine
    % 'paquetEncode' contient les 88 bits de données suivis des 24 bits de CRC

end
