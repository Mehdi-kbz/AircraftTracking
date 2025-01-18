function [lat, lon] = decoder_lat_lon_sol(i, lat_ref, r_lat, lon_ref, r_lon)
    % Fonction pour décoder la latitude et la longitude au sol à partir des valeurs encodées en binaire
    % i est le bit indicateur de format CPR
    % Conversion binaire à entier des vecteurs binaires r_lat et r_lon
    LAT = bin2dec(num2str(r_lat));  % Conversion de la latitude binaire en décimal
    LON = bin2dec(num2str(r_lon));  % Conversion de la longitude binaire en décimal

    Nz = 15;  % Nombre de zones dans le système CPR
    Nb = 17;  % Nombre de bits utilisés pour la latitude et la longitude

    % Calcul de l'intervalle de latitude (D_lat)
    D_lat = 90 / (4 * Nz - i);  % D_lat dépend de l'index i et de Nz
    % Calcul de j basé sur la référence de latitude (lat_ref) et la latitude décodée
    j = floor(lat_ref / D_lat) + floor(1/2 + cprMod_(lat_ref, D_lat) / D_lat - LAT / 2^Nb);
    
    % Calcul de la latitude réelle
    lat = D_lat * (j + LAT / 2^Nb);  % Latitude en degrés

    % Calcul du nombre de zones pour la latitude (Nl_lat)
    Nl_lat = cprNL_(lat);  % Fonction à définir, calculant le nombre de zones pour la latitude

    % Condition pour le calcul de D_lon basé sur Nl_lat
    if Nl_lat - i > 0
        D_lon = 90 / (Nl_lat - i);  % D_lon si Nl_lat est supérieur à i
    end
    if Nl_lat - i == 0
        D_lon = 90;  % D_lon si Nl_lat est égal à i
    end

    % Calcul de m basé sur la référence de longitude (lon_ref) et la longitude décodée
    m = floor(lon_ref / D_lon) + floor(1/2 + (cprMod_(lon_ref, D_lon) / D_lon) - LON / 2^Nb);
    
    % Calcul de la longitude réelle
    lon = D_lon * (m + LON / 2^Nb);  % Longitude en degrés
end
