clc;
clear 
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                         %
Fe = 4e6;                                % Fréquence d'échantillonnage en Hz                             %
lon_ref = -0.606629;                     % Longitude de l'ENSEIRB-Matmeca                                %
lat_ref = 44.806884;                     % Latitude de l'ENSEIRB-Matmeca                                 %
                                                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement des données %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('adsb_msgs.mat');                                                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%% Extraction des informations nécessaires pour le tracé %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% un tableau de structures pour stocker les registres %%%
registres = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                   'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                   'latitude', [], 'longitude', []);

%%% Initialisation des vecteurs pour stocker la latitude et la longitude %%%
latitudes = [];
longitudes = [];
for i = 1:size(adsb_msgs, 2)
    trame = adsb_msgs(:, i);
    
    %%% Conversion de la trame en registre et ajout de ce dernier aux registres %%%
    registre = bit2registre(trame,lon_ref,lat_ref);
    registres(i) = registre;     
    
    %%% Vérification et ajout des informations de latitude et longitude %%%
    if ~isempty(registre.latitude) && ~isempty(registre.longitude)
        latitudes = [latitudes , registre.latitude ];   
        longitudes = [longitudes , registre.longitude];   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracé de la trajectoire de l'avion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;

%%% Affichage de l'image de fond %%%
affiche_carte(lon_ref, lat_ref);

hold on; 
plot(longitudes, latitudes, 'b --','LineWidth', 2);
title("Trajectoire de l'avion");
xlabel('Longitude (°)');
ylabel('Latitude (°)');
grid on;
axis on;           
