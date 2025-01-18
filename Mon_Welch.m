function [Y, f] = Mon_Welch(x, Nfft, Fe)
    % x : Vecteur contenant les échantillons du signal
    % Nfft : Nombre de points pour calculer la FFT
    % Fe : Fréquence d'échantillonnage
    % Y : Estimation de la DSP
    % f : Vecteur des fréquences associées à la DSP

    % Longueur du signal
    length_sig = length(x);
    
    % Nombre de segments pour la FFT
    nb_segments = floor(length_sig / Nfft);
    
    % Préallouer la matrice des FFT
    M = zeros(nb_segments, Nfft);
    
    % Remplir la matrice avec les FFT des segments
    for i = 1:nb_segments
        % Extraire le segment sans recouvrement
        segment = x((i-1)*Nfft + 1 : i*Nfft);
        
        % Calculer la FFT et la centrer (fftshift)
        M(i, :) = fftshift(fft(segment, Nfft));
    end
    
    % Moyenne des périodogrammes
    m = sum(abs(M).^2, 1) / nb_segments;
    
    % Normaliser par la fréquence d'échantillonnage pour obtenir la DSP
    Y = m / Fe;
    
    % Générer le vecteur des fréquences associées
    f = (-Fe/2 : Fe/Nfft : Fe/2 - Fe/Nfft);
end
