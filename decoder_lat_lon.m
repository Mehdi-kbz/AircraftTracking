function [lat, lon] = decoder_lat_lon(i, lat_ref, r_lat, lon_ref, r_lon)
    % Fonction pour décoder la latitude et la longitude à partir des valeurs encodées en binaire

    LAT = bi2de(r_lat, 'left-msb');  % Conversion de la latitude binaire en décimal
    LON = bi2de(r_lon, 'left-msb');  % Conversion de la longitude binaire en décimal

    Nz = 15;  % Nombre de zones dans le système CPR
    Nb = 17;  % Nombre de bits utilisés pour la latitude et la longitude

    % Calcul de l'intervalle de latitude (D_lat)
    D_lat = 360 / (4 * Nz - i);  % D_lat dépend de l'index i et de Nz
    % Calcul de j basé sur la référence de latitude (lat_ref) et la latitude décodée
    j = floor(lat_ref / D_lat) + floor(1/2 + cprMod_(lat_ref, D_lat) / D_lat - LAT / 2^Nb);

    % Calcul de la latitude réelle
    lat = D_lat * (j + LAT / 2^Nb);  % Latitude en degrés

    % Calcul du nombre de zones pour la latitude (Nl_lat)
    Nl_lat = cprNL_(lat);  % Appel de la fonction définie ci-dessus

    % Condition pour le calcul de D_lon
    if Nl_lat - i > 0
        D_lon = 360 / (Nl_lat - i);  % Si Nl_lat est supérieur à i
    elseif Nl_lat - i == 0
        D_lon = 360;  % Si Nl_lat est égal à i
    else
        D_lon = 0; % Cas d'erreur si Nl_lat est inférieur à i
        warning('Valeur inattendue de Nl_lat - i. D_lon réglé sur 0.');
    end

    % Calcul de m basé sur la référence de longitude (lon_ref) et la longitude décodée
    m = floor(lon_ref / D_lon) + floor(1/2 + cprMod_(lon_ref, D_lon) / D_lon - LON / 2^Nb);

    % Calcul de la longitude réelle
    lon = D_lon * (m + LON / 2^Nb);  % Longitude en degrés
end
 