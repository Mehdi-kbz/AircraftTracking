function [registre] = bit2registre2(vector,lon_ref, lat_ref)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                         %
    flight_ftc = [9:18, 20:22];         % FTC correspondant à des trames de position en vol              %
    ground_position_ftc = 5:8;          % FTC pour des trames de position au sol                         %
    airborne_velocity_ftc = 19;         % FTC pour la vitesse en vol                                     %
    taille_preambule = 8;               % Longueur du préambule en bits                                  %
                                                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% Décodage CRC et vérification de l'intégrité du message %%%
    [donnees_decodees, erreur_detectee] = decoder_CRC(vector); 
    
%if erreur_detectee
        %disp('Erreur détectée dans le message reçu.');
%else
        disp('%%%%% Début du Message %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        disp('Aucune erreur détectée. Le message est intègre.');
        %%% Initialiser la structure registre %%%
            registre = struct('adresse',[],'format',[],'type',[],'nom',[], ...
                              'altitude',[],'timeFlag',[],'cprFlag',[], ...
                              'latitude',[],'longitude',[]);
        vector = donnees_decodees';
        %disp(vector);

        %%% Extraction des valeurs %%%

        %%% Format de la trame %%%
        registre.format = bin2dec(num2str(vector(1:5)));
        disp("Format: "+registre.format);

        %%% Adresse de l'avion %%%
        OACI_interval = 16 - taille_preambule + [1 24];
        registre.adresse = dec2hex(bin2dec(num2str(vector(OACI_interval(1):OACI_interval(2)))));
        disp("Adresse de l'avion: "+registre.adresse);

        %%% Extraction des bits de la trame ADSB %%%
        adsb_msg = vector(33:88);  
        
        %%% Extraction du CPR Flag %%%
        registre.cprFlag = bin2dec(num2str(adsb_msg(22)));
        disp("CPR Flag: "+registre.cprFlag);

        %%% Extraction du Time Flag %%%
        registre.timeFlag = bin2dec(num2str(adsb_msg(21)));
        disp("Time Flag: "+registre.timeFlag);

        %%% Extraction du FTC %%%
        registre.type = bi2de(adsb_msg(1:5) , 'left-msb');
        disp("Type du message ADSB: "+registre.type+" qui correspond à un:");          


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Identification de l'avion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if 1 <= registre.type && registre.type <= 4

                %%% Message d'identification %%%
                disp("################ Message d'identification ################");

                %%% Catégorie de l'appareil %%%
                cat = bi2de(adsb_msg(6:8),'left-msb');  
                disp("Catégorie de l'appareil: "+cat);
                
                %%% Nom de l'appareil %%%
                nom_decode = [];
                bits_nom = adsb_msg(8:56);
                
                for k=0:1:7
                    % Extraire les 6 bits pour chaque caractère
                    segment_encode = bits_nom(k*6+1 : (k+1)*6);
                    nom_decode = [nom_decode, decoder_nom(num2str(segment_encode'))];
                end
                registre.nom = strjoin(cellstr(nom_decode), '');
                disp("Nom de l'appareil: "+registre.nom);
         end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Position au sol %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

           
         if  ismember(registre.type, ground_position_ftc) 
                
                disp("################ Message de position au sol ################")
                
                %%% Altitude %%%
                %registre.altitude = altitude(lat_ref,lon_ref); % Altitude de l'aéroport selon lat_ref et lon_ref, on peux coder une fonction altitude(lat_ref,lon_ref)
                disp("Altitude de l'aéroport: "+166+" ft"); % altitude de BOD est 166 pieds

                %%% indicateur du mouvement %%%
                mouvement_identif = bi2de(vector(38:44)', 'left-msb');
                disp("Indicateur de Mouvement: "+mouvement_identif);

                %%% indicateur du statut %%%
                status = bi2de(adsb_msg(6:7) , 'left-msb');
                disp("Statut: "+status); 
                
                %%% Extraction et conversion de la latitude et la longitude %%%
                latitude_sol_encodee = [adsb_msg(14:20) adsb_msg(23:39)];
                longitude_sol_encodee = adsb_msg(40:56);
                [registre.latitude, registre.longitude] = decoder_lat_lon_sol(registre.cprFlag, lat_ref, latitude_sol_encodee, lon_ref, longitude_sol_encodee);  % Utilisation de la fonction decoder_lat_lon_sol           
                
                %%% Latitude %%%
                disp("Latitude: "+ registre.latitude+"°");
                
                %%% Longitude %%%
                disp("Longitude: "+ registre.longitude+"°");
          end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Position en vol %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          if  ismember(registre.type, flight_ftc)
                
                disp("################ Message de position en vol #################");
                
                %%% Indicateur du statut %%%
                status = bi2de(adsb_msg(6:7), 'left-msb');
                disp("Statut: "+status); 
                
                %%% Indicateur du type d'antenne %%%
                type_antenne = bi2de(adsb_msg(8), 'left-msb');
                disp("Type de l'antenne: "+type_antenne); 
               
                %%% Altitude %%%
                registre.altitude = decoder_altitude(adsb_msg(9:20));
                disp("Altitude: "+registre.altitude +" ft");
                
                %%% Extraction et conversion de la latitude et la longitude %%%
                latitude_encodee = adsb_msg(23:39);
                longitude_encodee = adsb_msg(40:56);
                [registre.latitude, registre.longitude] = decoder_lat_lon(registre.cprFlag, lat_ref, latitude_encodee, lon_ref, longitude_encodee);  % Utilisation de la fonction decoder_lat_lon
                %[registre.longitude, registre.latitude] = cpr2LatLon_(latitude_encodee,longitude_encodee,registre.cprFlag,lat_ref,lon_ref);  % Utilisation de la fonction cpr2latlon

                %%% Latitude %%%
                disp("Latitude: "+ registre.latitude+"°");
                
                %%% Longitude %%%
                disp("Longitude: "+ registre.longitude+"°");
          end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Vitesse en vol %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Selon la documentation fournie (        ICAO Doc 9871, Technical Provisions for Mode S Services and Extended Squitter    ) 
% et en particulier les pages 152/153 (sections B-25 et B-26) la vitesse en vol doit suivre la logique ci-dessous. 
                       
        if ismember(registre.type, airborne_velocity_ftc) 
       
                disp("################ Message de la vitesse en vol #################");
                
                %%% Sous-Type %%%
                sous_type = bi2de(adsb_msg(6:8),'left-msb');
                if sous_type == bi2de([0 1 0],'left-msb')
                    sous_type = "";
                    disp("Type de la vitesse: Vitesse supersonique" +sous_type);
                elseif sous_type == bi2de([0 0 1],'left-msb')
                    disp("Type de la vitesse: Vitesse Normale" +sous_type); 
                end
                
               

%%%%%%%%%%%%%%%%%% ----> Informations pour les sous-types 1 et 2:  Velocity over ground <---- %%%%%%%%%%%%%%%%%%%%
                 
                if sous_type == bi2de([0 0 1],'left-msb') ||  bi2de([0 1 0],'left-msb')
                    

                    %%% Indice intent Change %%%
                    intent_change = adsb_msg(9);
                    disp("Indice intent Change: "+intent_change);
                    
                    %%% Indice de capacité IFR %%%
                    ifr_cap = adsb_msg(10);
                    disp("ifr_cap_flag: "+ifr_cap);
    
                    %%% Catégorie de la précision de navigation pour la vitesse %%%         (NAVIGATION ACCURACY CATEGORY FOR VELOCITY)
                    nav_acc_cat = bi2de(adsb_msg(11:13),'left-msb');
                    disp("Catégorie de la précision de navigation pour la vitesse: "+nav_acc_cat);

                   
                    
                    %%% Direction de la vitesse Est/West %%%
                    direction_est_west = adsb_msg(14);
                    if direction_est_west == 0
                        disp("Direction de la vitesse Est/West: Est");
                    else
                        disp("Direction de la vitesse Est/West: West");
                    end
                
                    %%% Vitesse Est/West %%%
                    vitesse_est_west = bi2de(adsb_msg(15:24),'left-msb');
                    if vitesse_est_west == 0
                        disp("Pas d'informations sur la vitesse en vol.")
                    end
                    if sous_type == bi2de([0 1 0],'left-msb')
                        vitesse_est_west = vitesse_est_west*4;
                    end
                    disp("Vitesse Est/West: "+vitesse_est_west+"kt");


                    %%% Direction de la vitesse Nord/Sud %%%
                    direction_nord_sud = adsb_msg(25);
                    if direction_nord_sud == 0
                        disp("Direction de la vitesse Nord/Sud: Nord");
                    else
                        disp("Direction de la vitesse Nord/Sud: Sud");
                    end

                    %%% Vitesse Nord/sud %%%
                    vitesse_nord_sud = bi2de(adsb_msg(26:35),'left-msb');
                    if vitesse_nord_sud == 0
                        disp("Pas d'informations sur la vitesse en vol.")
                    end
                    if sous_type == bi2de([0 1 0],'left-msb')
                        vitesse_nord_sud = vitesse_nord_sud*4;
                    end
                    disp("Vitesse Nord/sud: "+vitesse_nord_sud+"kt");

                    %%% Source du taux vertical %%%
                    source_taux_vertical = adsb_msg(36);
                    if source_taux_vertical == 0
                        disp("Source du taux vertical (GNSS/Baro): "+ "GNSS");
                    else
                        disp("Source du taux vertical (GNSS/Baro): "+ "Baro");
                    end
    
                    %%% Signe du taux vertical (haut/bas) %%%
                    signe_vertical_rate = adsb_msg(37);
                    if signe_vertical_rate == 0
                        disp("Signe du taux vertical (up/down): "+ "up");
                    else
                        disp("Signe du taux vertical (up/down): "+ "down");
                    end
                    
                    %%% Taux vertical en pieds/minute %%%
                    taux_vertical = bi2de(adsb_msg(38:46)','left-msb');
                    taux_vertical = taux_vertical * 63.8745;
                    if taux_vertical == 0
                        disp("Taux vertical: 64 ft/min");
                    end
                    disp("Taux vertical: "+taux_vertical + " ft/min");
                    
                    %%% Bits réservés %%%
                    reserved = adsb_msg(47:48);
                    disp("Bits réservés: "+reserved);

                    %%% Bit de différence de signe %%% (0 = Above baro alt, 1 = Below baro alt.)
                    bds = adsb_msg(49);
                    disp("Bits réservés: "+reserved);
                    if bds == 0
                        disp("Bit de différence de signe: "+ "Above baro alt.");
                    else
                        disp("Bit de différence de signe: "+ "Below baro alt.");
                    end

                    %%% Différence de hauteur géométrique par rapport à l'altitude barométrique en pieds %%%
                    diff_alt = bi2de(adsb_msg(50:56)','left-msb');
                    diff_alt = diff_alt * 24.8015 ;
                    if diff_alt == 0
                        disp("Différence de hauteur géométrique par rapport à l'altitude barométrique: 25 ft");
                    end
                    disp("Différence de hauteur géométrique par rapport à l'altitude barométrique: "+diff_alt + " ft");         
                end




%%%%%%%%%%%%%%%%%%%%% ----> Informations pour les sous-types 3 et 4:  Airspeed and heading <---- %%%%%%%%%%%%%%%%%%%%%%%
                 
                if sous_type == bi2de([0 1 1],'left-msb') ||  bi2de([1 0 0],'left-msb')
                    
                    %%% Cap magnétique %%%                (0:    magnetic heading not available and 1 : magnetic heading available)
                    status = adsb_msg(14);
                    if status == 0
                        disp("Statut: Cap magnétique indisponible.");
                    else
                        disp("Statut: Cap magnétique disponible");
                        cap_magnetique = bi2de(adsb_msg(15:24),'left-msb');
                        disp(" -----> Cap magnétique: " +cap_magnetique+"degrées");
                    end
                    
                    %%% Type IAS/TAS de la vitesse  %%%
                    type_ias_tas = adsb_msg(10);
                    if type_ias_tas == 0
                        disp("Type IAS/TAS de la vitesse: IAS");
                    else
                        disp("Type IAS/TAS de la vitesse: TAS");
                    end
                
                    %%% Airspeed %%%
                    airspeed = bi2de(adsb_msg(26:35),'left-msb');
                    if airspeed == 0
                        disp("Pas d'informations sur la vitesse en vol.")
                    end
                    if sous_type == bi2de([0 1 0],'left-msb')
                        airspeed = airspeed*4;
                    end
                    disp("Vitesse en vol: "+airspeed+"kt");

                    %%% Source du taux vertical %%%
                    source_taux_vertical = adsb_msg(36);
                    if source_taux_vertical == 0
                        disp("Source du taux vertical (GNSS/Baro): "+ "GNSS");
                    else
                        disp("Source du taux vertical (GNSS/Baro): "+ "Baro");
                    end
    
                    %%% Signe du taux vertical (haut/bas) %%%
                    signe_vertical_rate = adsb_msg(37);
                    if signe_vertical_rate == 0
                        disp("Signe du taux vertical (up/down): "+ "up");
                    else
                        disp("Signe du taux vertical (up/down): "+ "down");
                    end
                    
                    %%% Taux vertical en pieds/minute %%%
                    taux_vertical = bi2de(adsb_msg(38:46)','left-msb');
                    taux_vertical = taux_vertical * 63.8745;
                    if taux_vertical == 0
                        disp("Taux vertical: 64 ft/min");
                    end
                    disp("Taux vertical: "+taux_vertical + " ft/min");

                    %%% Bits réservés %%%
                    reserved = adsb_msg(47:48);
                    disp("Bits réservés: "+reserved);

                    %%% Bit de différence de signe %%% (0 = Above baro alt, 1 = Below baro alt.)
                    bds = adsb_msg(49);
                    disp("Bits réservés: "+reserved);
                    if bds == 0
                        disp("Bit de différence de signe: "+ "Above baro alt.");
                    else
                        disp("Bit de différence de signe: "+ "Below baro alt.");
                    end

                    %%% Différence de hauteur géométrique par rapport à l'altitude barométrique en pieds %%%
                    diff_alt = bi2de(adsb_msg(50:56)','left-msb');
                    diff_alt = diff_alt * 24.8015 ;
                    if diff_alt == 0
                        disp("Différence de hauteur géométrique par rapport à l'altitude barométrique: 25 ft");
                    end
                    disp("Différence de hauteur géométrique par rapport à l'altitude barométrique: "+diff_alt + " ft");                
                 end
        end % end du if de la vitesse en vol
   disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fin du Message. %%%%%%%');
%end % end du if de CRC
