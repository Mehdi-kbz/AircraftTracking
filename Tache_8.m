clear; 
close all; 
clc; 

%%% Chargement du fichier buffers.mat %%%
load('../TS229-master/data/buffers.mat'); % Assurez-vous que le fichier est dans le répertoire de travail

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                    %
Ts = 1e-6;                               % Temps d'échantillonnage                                  %
Fe = Rs;                                 % Fréquence d'échantillonnage                              %
Te = 1/Fe;                               % Période d'échantillonnage                                %
Fse = Ts * Fe;                           % Facteur de suréchantillonnage                            %
N = 18000000;                                                                                       %
longueur_trame = 112*4;                  % Longueur d'une trame ADS-B en bits sans préambule        %
lon_ref = -0.606629;                     % Longitude de l'ENSEIRB-Matmeca                           %                    
lat_ref = 44.806884;                     % Latitude de l'ENSEIRB-Matmeca                            %
p1 = [ones(1, Fse/2), zeros(1, Fse/2)];  % Impulsion PPM p1                                         %
                                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Recherches des pics d'intercorrelation  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Génération du préambule %%%
preambule = preambule(Fse); 
longueur_preambule = length(preambule);

%%% Détection des indices où la corrélation dépasse le seuil %%%
seuil_detection = 0.60;                     % Seuil de détection pour les pics de corrélation 
indices_picsr = Estimation_indices_max(buffers,preambule,Te,seuil_detection);

%%% Suppression des pics successifs  %%%
indices_pics = indices_picsr(1);

for i = 2:length(indices_picsr)
    if (indices_picsr(i) - indices_pics(end)) >= 400
        %Ajouter à indices_pics si la distance entre les pics est d'au moins 400
        indices_pics = [indices_pics; indices_picsr(i)];
    end
end
%disp(indices_pics);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Extraction des signaux des trames ADS-B %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signaux_trames_adsb = {};
nombre_trames = 0;

% Boucle pour parcourir les indices des pics détectés
for i= 1 : length(indices_pics)
    indice_pic = indices_pics(i);
    
    debut_trame = indice_pic + longueur_preambule + 1;
    fin_trame = debut_trame + longueur_trame;

    %%% Si les indices sont valides (dans la portée de buffer) %%%
    if debut_trame > 0 && fin_trame <= length(buffers)
        
        signaux_trames_adsb{end+1} =  buffers(debut_trame:fin_trame);% Stocker la trame dans une cellule
        nombre_trames = nombre_trames + 1;
        i = i+1;
    end

end

%%% Afficher le nombre de trames trouvées %%%
disp(['Nombre de trames ADS-B extraites : ', num2str(nombre_trames)]); disp("pour un seuil de 0.57.")

sl =0;
mon_adsb_msgs = [];  % Initialiser une matrice vide pour stocker les messages ADS-B
%%% Traitement des trames adsb %%%
for i = 1:length(signaux_trames_adsb)
    sl = signaux_trames_adsb{i};
    
    %%% Filtre Adapte %%%
    filtre_adapte = conj(fliplr(p1));
    
    %%% Convolution avec le filtre adapté %%%
    rl = conv(sl, filtre_adapte, 'same');
    
    %%% Échantillonnage du signal rl à un pas de 2 pour réduire de moitié la taille %%%
    rm = rl(1:2:end);

    %%% Décision selon la méthode du maximum de vraisemblance %%%
    bits_estimes = [];
    for k = 1:(length(rm)/2)
        if (rm(2*k) - rm(2*k+1) > 0)
            bits_estimes = [bits_estimes 1];
        else
            bits_estimes = [bits_estimes 0];
        end
    end
    
    %%% Stocker les bits estimés dans la ième colonne de adsb_msgs %%%
    mon_adsb_msgs(1:length(bits_estimes), i) = bits_estimes;
end




%%%%%%%%%%%%%%%%%%%%%% Extraction des informations nécessaires pour le tracé %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% un tableau de structures pour stocker les registres %%%
registres = struct('adresse', [], 'format', [], 'type', [], 'nom', [], ...
                   'altitude', [], 'timeFlag', [], 'cprFlag', [], ...
                   'latitude', [], 'longitude', []);

%%% Initialisation des vecteurs pour stocker la latitude et la longitude %%%
latitudes = [];
longitudes = [];
for i = 1:size(mon_adsb_msgs, 2)
    trame = mon_adsb_msgs(:, i);
    
    %%% Conversion de la trame en registre et ajout de ce dernier aux registres %%%
    registre = bit2registre2(trame,lon_ref,lat_ref);
    registres(i) = registre;     
    
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracé de la trajectoire de l'avion  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% prochainement.         



