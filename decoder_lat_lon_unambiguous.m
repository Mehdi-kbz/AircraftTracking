function [R_lon_recent, R_lat_recent] = decoder_lat_lon_unambiguous(recent_cpr, lat0, lon0, lat1, lon1)
    % Fonction pour décoder la latitude et la longitude à partir des valeurs encodées de trames successives en binaire

    % Conversion des coordonnées binaires en décimales
    LAT0 = bin2dec(num2str(lat0));
    LON0 = bin2dec(num2str(lon0));
    LAT1 = bin2dec(num2str(lat1));
    LON1 = bin2dec(num2str(lon1));

    % Détermination de la latitude récente
    if recent_cpr == 1
        LON_recent = LON1;
    else
        LON_recent = LON0;
    end

    % Calcul des incréments de latitude
    Nz = 15; 
    Nb = 17; 
    D_lat0 = 360 / (4 * Nz);
    D_lat1 = 360 / (4 * Nz - 1);

    % Calcul de j pour la latitude
    j = floor(1/2 + (59 * LAT0 - 60 * LAT1) / 2^Nb);
    Rlat0 = D_lat0 * (mod(j, 60) + LAT0 / 2^Nb);
    Rlat1 = D_lat1 * (mod(j, 59) + LAT1 / 2^Nb);

    % Attribution de la latitude en fonction de recent_cpr
    if recent_cpr == 1
        R_lat_recent = Rlat1;
    else
        R_lat_recent = Rlat0;
    end

    % Vérification de la possibilité de calcul de la longitude globale
    if cprNL_(Rlat0) ~= cprNL_(Rlat1)
        disp("Solution for global longitude is not possible.");
        R_lon_recent = NaN;
        return;
    else
        n = max(cprNL_(R_lat_recent) - recent_cpr, 1);
        D_lon_recent = 360 / n;
        m = floor(1/2 + (LON0 * (cprNL_(Rlat0) - 1) - LON1 * cprNL_(Rlat1)) / 2^Nb);
        R_lon_recent = D_lon_recent * (mod(m, n) + LON_recent / 2^Nb);
    end
end
