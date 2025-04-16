#!/bin/bash

# Path to Nagios log
LOG_FILE="/usr/local/nagios/var/nagios.log"

# Email address to send alerts
#EMAIL="support@jeebr.net"
EMAIL="mahendranath123mp@gmail.com"

# Path to msmtp
MSMTP="/usr/bin/msmtp"

# Optional log file for monitoring events
MONITOR_LOG="/var/log/nagios_monitor.log"

# Hostname prefixes to trigger alerts for
ALERT_PREFIXES=("Pharma" "Infinity_Cars" "Priceline.com" "AR_Gold"  "Vishwa_Niketan" "Fifth_Gear_Ventures" "Sound_and_Vision" "AP_Shah" "EZO" "Tejax_Support" "SME_Cellcure" "Hubcom_Technology" "Multistream_Technology" "SME_Sectona_Technologies" "Light_House_Learning" "Maharashtra_State_Skills" "LRN_Technologies"  "PLEASE_SEE_ADVERTISING"  "Reflection_Pictures"  "UFO_Moviez_India" "SALMAN_SALIM_KHAN" "The_Byke_Hospitality"  "Hindustan_Construction"  "Bits_And_Bytes_Ghansoli" "Skanem"  "Work_Store"  "Tikona_Infinet_Hindustan_Platinum_TTC_INDUSTRIAL_Pawane"  "Serviz_4U_Prama"    "Prama"  "Kadri_Consultants"  "Serviz_4U_GCC_Hotel" "Serviz_4U_Nivea_India" "Laqshya_Live_Experiences" " SP_Jain_School"  "Isha_Agro_Developers"    "Indo_Bakels_Pvt_Ltd_Govandi"  "Maneesh_Pharmaceuticals"  "Ajmal_And_Sons"    "Eschmann_Textures" "Bits_And_Byte_Global_DP_Road_Pune" "Passcom_Navnit_Motors_Waterford"  "Indoco_Remedies"  "Tikona_BOMBAY_SCOTTISH_SCHOOL_POWAI"
    "Shree_L._R._Tiwari_degree_College"  "Aries_Agro_Ltd_Go"  "Chartered_Finance_Management"  "Nimap_Infotech_LLP_Lower_Parel"  "Rotex_Manufacturing_CKT_4002_Backup_From_Saan"  "Saan"
   "Awfis_Space_Solutions"  "ENEM_NOSTRUM_REMEDIES_Pvt_Ltd"  "Tikona_Infinet_FORT_CKT_3433"  "DEVISHA_FASHIONS"  "Kama_Schachter"  "Cadmatic_Software"  "Rotex_Manufacturers"
   "Multilink_IT_Solutions_Panalal_Comopund"  " TUV_INDIA_PVT_LTD_GhatkoprW"  "Indian_Corporation_Modi" "Ring_Networks_solitaire" "BEC_CHEMICALS"  "Tescom_Business_Solutions_T"
"Chat_Signal_Pvt_Ltd__Leadership"   "Goprime_Networks"  "Big_Vision_Technology"  "Tulip_Enterprises_Lotus_Goregaon"   "Powergrid_Thane_Court_Naka_To_MIDC"   "Ring_Networks_HDIL_Tower_Bandra"
  "Vidya_Vikas_Education" "Index_Logistics_Pvt"  "Multilink_IT_Solutions_Sahar_Airport"  "sme_I-FOUR_TRANSFORMATION"  "MIPL_Gajju_Technologies" "SME_Paygate_india_private_limited_"
  "Raschig_PMC_India_Pvt._Ltd_Nehru"  "Serviz_4U_Dimension_NXG_Private_Limited"   "GS_Sethi_Sons_Central_Plaza_Kalina_Santacruz"  "Ayushakti_Ayurved_Pvt_Ltd" "Aurionpro_Solutions_Limited"
  "Choice_Consultancy_Pvt_Ltd"   "Choice_International_Pvt_Ltd"  "Horizon_Projects_Private"   "Bprimo_Telecommunication_PVT_LTDFort"   "Casamia_Building_Material_Trading_Pvt_Ltd_Lower"
  "Tejax_Support_Services_PVT_LTD_Seepz"    "Ahluwalia_Contracts_India_Pvt_Ltd_Parel_"    "Community_Spaces_Akruti_Tred_Andheri_East"   "Ivalue_Infosolutions_Pvt_Ltd_Donar_house_MIDC"
      "MIRAJ_Entertainment_Ltd_Eureka_Tower_Malad_West"   "Punjab_National_Bank_BKC_CE_CKT_"  "B_Primo_telecommunication_Fort"  "Jay_Precision_Products_India"   "Limerick_Technologies_Pvt_"   "CEAT_Limited_RPG_House_Worli"   "Sun_Petrochemicals_Pvt_Ltd_ATL_Corporate_Park_Saki_Vihar_Road_Powai"  "Everest_Fleet_Pvt_Ltd_4th_Floor_Korum_Mall"
 "Kavis_fashions_Pvt_Ltd_Miraroad"  "Sureflo_Techcon_Pvt_Ltd_MIDC_Andheri_E"  "Everest_Fleet_Pvt_Ltd_Chennai_Tamilnadu"  "Hubcom_Techno_Systems_LLP_Wadala_Monorail"  "Grace_Teleinfra_Pvt._Ltd."  "E_Revbay_Pvt_Ltd"   "Hotel_Jewel_of_Chembur"  "Limerick_Technologies_Pvt_Ltd"   "Tescom_Business_Solutions_LLP_Kamlacharan_Commercial_Premises_Goregaon_West"   "Spearhead_Live_India_Pvt_Ltd_Jaguar_Land_Rover_Workshop_Vikhroli"  "CFM_Asset_Reconstruction_1st_Floor"  "Jay_Precision_Pharmeceuticals_Pvt"  "SATEC_ENVIR_ENGINEERING_INDIA_PVT_LTD"   "Calcio_Restaurants_Pvt_Ltd_Gopi_Chamber_Andheri" "Hubcom_Techno_Systems_LLP_MMRDA_Old_Building_E_Block_BKC"   "Finbros_Capital_Advisory_Pvt_Ltd"  "Innovators_Facade_Systems_Ltd_Shanti_Nagar_Miraroad"  "Prijai_Heat_Exchanger_Pune_Chakan_To_Airoli_P2P_Mkt"  "Everest_Fleet_pvt_Ltd_Gachibowli_Hyderabad_Telangana_CKT"  "CEAT_Limited_RPG_House_Worli"  "Imaginarium_Rapid_Pvt_Ltd_Andheri_To_Vasai_P2P "  "Hubcom_Techno_Systems_LLP_Mumbai_Bank"  "Hotel_Suba_Palace_Pvt_Ltd_Apollo_Bandar_Colaba"  "Ten_X_Realty_Ltd_CKT_11680"  "Terminal_Technologies_Valiv" "Internet_Mumbai_Andheri_East"  "HCIN_Telecom_Pvt_Ltd_Rupa_Renaissance"  "Pamac_Finserve_Pvt.Ltd_Wadala_west"   "Achole_Developers_Pvt_Ltd_Nallasopara_East"  "LEAP_INDIA_PRIVATE_LIMITED_Kandivali"  "Gemson_Precision_Engineering_Pvt_Ltd_Vasai"
  "Masina_Hospital_Trust_Sant_Savta_Marg_Byculla"  "Roofsol_Energy_Pvt_Ltd"  "Gemological_Science_International_Private_Limited_Marol_Andheri"  "Multilink_IT_Solutions_Boston_House_Andheri_East"  "ASHOK_SHARMA_MAINFRAME_PREMISES_GOREGAON_EAST"   "Alstom_Transport_India_Limited_Aarey_Metro_Yard_Goregaon"   "Kanakia_International_School_Bhayandar"  "Babubhai_Kanakia_Foundation_Chembur"  "Goldmine_Advertising_Pvt_Ltd_Vile_Parle_East"  "MYTEK_INNOVATIONS_PVT_LTD_ARIHANT_AURA_TURBHE"  "Giganet_Powai_Bandwidth_OPT"  "Sanghvi_Beauty_and_Technologies_Pvt_Ltd"  "Juniper_Hotels_Ltd_Hyatt_Regency_Andheri"  "Kontor_Space_Limited_Akruti_Star_Andheri_East"   "NAVBHARAT_CONSOLIDATION_PVT_LTD_SAKINAKA"  "Phonographic_Performance_Ltd_Crescent_Tower_Andheri_West_CKT"
 "Cent_Bank_Home_Finance_Limited_Fort"  "Seven_Eleven_Education_Society_Mira_Road_East"  "Serviz_4u_Networks_Lighthouse_Advisors_Bandra_East"  "Larsen_and_Toubro_Ltd_Sewri" "Shree_Sukh_Sagar_Hospitality_Services_NAIGAON_EAST" "Serviz_4u_Networks_India_Pvt_Ltd_National_Highway_CBD_Belapur" "Aurionpro_Solutions_Ltd_Synergia_IT_Park_Rabale"  "Airnet_Telecom_Services_Roopmangal_Buildg_Santacruz_West"  "Cosmos_Maya_India_Pvt_Ltd_Chintamani_Classique_Goregaon_East"      "ISSGF_INDIA_PRIVATE_LIMITED_Reliable_Tech_Park_Airoli_CKT_15816"    "Hotel_Sahil_PVT_LTD_Mumbai_Central"   "Chitchat_ILL_Mahindra_And_Mahindra" "Mudita_Bangur_Nagar_Goregoan_West"  "Venture_Catalysts_Pvt_Ltd_Times_Square_Marol"  "RELIANCE_COMMERCIAL_DEALERS_LTD_Santacruz_East"  "Tescom_Business_LLP_Lodha_Supremus_Thane_West"  "TSSAP_Tech_Juhu_Andheri_West"   "Zaco_Computers_Pvt_Ltd_Goregaon_West_CKT_16471"  "Suyog_Telematics_Ltd_MIDC_Andheri_East"  "EXHEAT_PROCESS_HEAT_INDIA_PVT_LTD_Modi_House_Thane_West" "Dravstream_Technologies_Pvt_Ltd_Goregaon"   "Spearhead_Live_India_Pvt_Ltd_Taj_Wellington_Mews_Apollo_Bandar_Colaba_"  "FAST_FIVE_NETWORK_SOLUTIONS_Kurla_Bail_Bazar"
 "KINETIC_BPO_SERVICES_PVT_LTD_Andheri_East" "Larsen_Toubro_LTD_Madh"  "NPL_BLUESKY_AUTOMOTIVE_PVT_LTD_Goregaon"   "Zenriv_Exim_LLP_Morya_Classic_Adarsh_Nagar_Andheri_West"
 "Larsen_and_Toubro_LTD_Sai_Samarth_Business_Park_Govandi"    "MAHARASHTRA_NURSING_COUNCIL_Bombay_Mutual_Annexe"  "Alliant_Technologies_Chintamani_Avenue_Goregaon"  "NCC_Limited_CKT"
  "CRESCENT_ACCOUNTING_SERVICES_PRIVATE_LIMITED"   "Tata_projects_limited_Cignus_tower_Kailash_nagar"  "Bennett_Coleman_Co_Ltd_Chennai"   "Puretech_Internet_Pvt_Ltd_Phoenix_Marketcity"
 "Smt_K_L_Tiwari_College_of_Architecture_Miraroad_CKT"   "Institute_for_technology_and_management_trust_Kharghar_ILL_P2P"   "EBRANDZ_LLP_Yashodham_CKT" "SDI_Tech_Services_India_Pvt_Ltd_Byke_Event_Thane_CKT" "Spearhead_Live_India_Pvt_Ltd_Suraj_Plaza_Thane"  "ILG_India_Fashion_LLP"  "Awliv_living_solutions_Bandra_BKC"  "Focus_Lighting_and_Fixtures_Ltd_Tulsi_Pipe_Prabhadevi"
"EDERNITY_INITIATIVES_PRIVATE_LIMITED_Pinnacle_Business_Park"  "Multilink_IT_Solutions_Fortune_2000_BKC"   "TRIMBLE_SOLUTIONS_INDIA_PRIVATE_LIMITED_Shree_Savan_Knowledge_" "testing1" )

# Associative array to track hosts already alerted
declare -A alerted_hosts

echo "[ $(date) ] Starting real-time monitoring of Nagios log..." | tee -a "$MONITOR_LOG"

# Use stdbuf to force line buffering; -n 0 avoids replaying old log lines
sudo stdbuf -oL tail -n 0 -F "$LOG_FILE" </dev/null | while read -r line; do
    event_type=""
    host=""

    # Check for HOST NOTIFICATION events from Nagios
    if echo "$line" | grep -q "HOST NOTIFICATION:"; then
         if echo "$line" | grep -q ";DOWN;"; then
             event_type="HOST DOWN"
             host=$(echo "$line" | awk -F';' '{print $2}')
         elif echo "$line" | grep -q ";UP;"; then
             event_type="HOST UP"
             host=$(echo "$line" | awk -F';' '{print $2}')
         fi
    # Check for host timeout events
    elif echo "$line" | grep -q "Warning: Check of host" && echo "$line" | grep -q "timed out"; then
         event_type="HOST TIMEOUT"
         host=$(echo "$line" | sed -nE "s/.*Check of host '([^']+)'.*/\1/p")
    else
         continue
    fi

    # Skip if host is empty
    [[ -z "$host" ]] && continue

    # Process events only if the host matches one of our prefixes
    should_alert=false
    for prefix in "${ALERT_PREFIXES[@]}"; do
        if [[ "$host" == "$prefix"* ]]; then
            should_alert=true
            break
        fi
    done

    if [[ "$should_alert" == true ]]; then
        # For DOWN or TIMEOUT events, only alert if we haven't already alerted the host
        if [[ "$event_type" == "HOST DOWN" || "$event_type" == "HOST TIMEOUT" ]]; then
            if [[ -z "${alerted_hosts[$host]}" ]]; then
                # Try extracting an epoch timestamp from the log entry; if not available, use the current time
                epoch=$(echo "$line" | sed -nE 's/^\[([0-9]+)\].*/\1/p')
                if [[ -n "$epoch" ]]; then
                    timestamp_readable=$(date -d @"$epoch" "+%A %d %B %Y %I:%M:%S %p %Z")
                else
                    timestamp_readable=$(date "+%A %d %B %Y %I:%M:%S %p %Z")
                fi

                echo "[${timestamp_readable}] ALERT: Host '$host' is $event_type. Sending notification..." | tee -a "$MONITOR_LOG"
                alerted_hosts["$host"]=1

                body=$(cat <<EOF
To: $EMAIL
Subject: ** NAGIOS ALERT: Host $host is $event_type **

***** Nagios Realtime Monitor *****

Event Type: $event_type
Host: $host

Log Entry:
$line

Date/Time: $timestamp_readable
EOF
)
                echo "$body" | $MSMTP -t >> /var/log/msmtp.log 2>&1 &
            else
                echo "[INFO] Duplicate event for '$host' ignored." | tee -a "$MONITOR_LOG"
            fi

        # For recovery events, reset the alerted flag so future DOWN events can trigger notifications again
        elif [[ "$event_type" == "HOST UP" ]]; then
             if [[ -n "${alerted_hosts[$host]}" ]]; then
                 epoch=$(echo "$line" | sed -nE 's/^\[([0-9]+)\].*/\1/p')
                 if [[ -n "$epoch" ]]; then
                     timestamp_readable=$(date -d @"$epoch" "+%A %d %B %Y %I:%M:%S %p %Z")
                 else
                     timestamp_readable=$(date "+%A %d %B %Y %I:%M:%S %p %Z")
                 fi

                 echo "[${timestamp_readable}] RECOVERY: Host '$host' is now UP. Clearing alert flag." | tee -a "$MONITOR_LOG"
                 unset alerted_hosts["$host"]

                 # Optional: send a recovery notification email
                 body=$(cat <<EOF
To: $EMAIL
Subject: ** NAGIOS RECOVERY: Host $host is now UP **

***** Nagios Realtime Monitor *****

Host $host has recovered (UP).

Log Entry:
$line

Date/Time: $timestamp_readable
EOF
)
                 echo "$body" | $MSMTP -t >> /var/log/msmtp.log 2>&1 &
             fi
        fi
    fi
done
