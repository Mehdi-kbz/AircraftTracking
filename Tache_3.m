close all;
clear;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%% Génération + codage CRC + Transmission du paquet encodé %%%%%%%%%%%%%%%%%%%%%%%

[donnees, paquet_Encode] = coder_CRC(); 

%%% Simuler une erreur dans le paquet encodé %%%
paquet_Encode_avec_erreur = paquet_Encode;

%%% Inversion d'un bit spécifique pour simuler une erreur %%%%
bit_position = 10;                          % Position du bit à inverser (par exemple, le 10e bit ici)
paquet_Encode_avec_erreur(bit_position) = ~paquet_Encode_avec_erreur(bit_position); % Inversion du bit


% Pour simuler une erreur, commentez la ligne 19 et enlevez le commentaire de la ligne 22


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Décodage CRC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Décodage CRC et vérification de l'intégrité du message %%%
[donnees_decodees, erreur_detectee] = decoder_CRC(paquet_Encode); 

%%% Décodage CRC et vérification de l'intégrité du message avec erreur %%%
%[donnees_decodees, erreur_detectee] = decoder_CRC(paquet_Encode_avec_erreur); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Affichage des résultats %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if erreur_detectee
    disp('Erreur détectée dans le message reçu.');
else
    disp('Aucune erreur détectée. Le message est intègre.');
end