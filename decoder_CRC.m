function [donnees_decodees, erreur_detectee] = decoder_CRC(paquet_Encode)

    % Paramètres
    Nb = 88; % Taille des données utiles en bits

    % Redéfinition du polynôme CRC utilisé lors du codage
    poly_crc = [24 23 22 21 20 19 18 17 16 15 14 13 12 10 3 0];
    
    % Création de l'objet détecteur CRC basé sur le même polynôme que le codeur
    detecteur_CRC = comm.CRCDetector(poly_crc);
    
    % Détection des erreurs dans le message encodé
    [donnees_decodees, erreur_detectee] = detecteur_CRC(paquet_Encode); % Appel direct à l'objet

    % Les 88 premiers bits sont les données utiles, on les extrait du paquet décodé
    donnees_decodees = donnees_decodees(1:Nb); 

   
end
