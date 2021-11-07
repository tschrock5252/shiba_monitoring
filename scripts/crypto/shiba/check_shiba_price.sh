#!/bin/bash

# Set up local script variables
    function DEFINE_VARIABLES {
        TODAYS_DATE=$(date +"%m-%d-%Y");
        TODAYS_DATE_WITH_SECONDS=$(date +"%m-%d-%Y - %H:%M:%S");
        SHIB_TRACKING_DIR="/tmp/shib_tracking";
        SHIBA_LOGS="/var/log/crypto/shiba";
        mkdir -p "${SHIB_TRACKING_DIR}";
        mkdir -p "${SHIBA_LOGS}";
        SHIB_PRICE_LOG="${SHIBA_LOGS}/shib_price.${TODAYS_DATE}.log";
        touch "${SHIB_PRICE_LOG}";
        SHIB_WGET_FILE="${SHIB_TRACKING_DIR}/shib.html";
        SHIB_EMAIL_FILE="${SHIB_TRACKING_DIR}/shib_email.txt";
        SHIB_EMAIL_COUNTER_FILE_1="${SHIB_TRACKING_DIR}/shib_email_counter1.${TODAYS_DATE}.txt";
        SHIB_EMAIL_COUNTER_FILE_2="${SHIB_TRACKING_DIR}/shib_email_counter2.${TODAYS_DATE}.txt";
        SHIB_EMAIL_COUNTER_FILE_3="${SHIB_TRACKING_DIR}/shib_email_counter3.${TODAYS_DATE}.txt";
        SHIB_EMAIL_COUNTER_FILE_4="${SHIB_TRACKING_DIR}/shib_email_counter4.${TODAYS_DATE}.txt";
        touch "${SHIB_EMAIL_COUNTER_FILE_1}" && touch "${SHIB_EMAIL_COUNTER_FILE_2}" && touch "${SHIB_EMAIL_COUNTER_FILE_3}" && touch "${SHIB_EMAIL_COUNTER_FILE_4}";
        COIN_URL="https://crypto.com/price/shiba-inu";
        EMAIL_TO="some_email_address@somewhere.com";    # Configure this appropriately. This is where alerts will be sent to when prices surge.
    }

# Set up a lock to prevent this script from running on top of itself if executed via cron
    function SETUP_LOCK {
        SCRIPT_FILE_NAME=$(echo $(basename $0) | sed 's/\..*$//');
        LOCK_FILE="/var/lock/${SCRIPT_FILE_NAME}.lock";
        touch "${LOCK_FILE}";
        read -r lastPID < "${LOCK_FILE}";
        [ ! -z "$lastPID" -a -d /proc/$lastPID ] && echo "" && echo "# There is another copy of this script currently running. Exiting now for safety purposes." && exit 1
        echo "${BASHPID}" > "${LOCK_FILE}";
    }

# Define the script exit function to clean up
    function FINISH {
        [ -e "${SHIB_WGET_FILE}" ] && rm "${SHIB_WGET_FILE}";
        [ -e "${SHIB_EMAIL_FILE}" ] && rm "${SHIB_EMAIL_FILE}";
    }
    trap FINISH EXIT

# Define the intro function for the script.
    function INTRO {

        # Define the intro text for this script.
            echo "${TODAYS_DATE_WITH_SECONDS}";
            echo "";
            echo "##################################################################################";
            echo '#                  _________  ___ ___  .___ __________    _____                  #';
            echo '#                 /   _____/ /   |   \ |   |\______   \  /  _  \                 #';
            echo '#                 \_____  \ /    ~    \|   | |    |  _/ /  /_\  \                #';
            echo '#                 /        \\    Y    /|   | |    |   \/    |    \               #';
            echo '#                /_______  / \___|_  / |___| |______  /\____|__  /               #';
            echo '#                        \/        \/               \/         \/                #';
            echo "#                                                                                #";
            echo "#               .****.                                      ,******              #";
            echo "#               *********     *#####################,    .*****/***              #";
            echo "#               ****/*/****############################*****/*/****              #";
            echo "#               ***//*///****########################*****///*//***              #";
            echo "#               ***********/***************************************              #";
            echo "#               ,***/*///*********************************///*//**,              #";
            echo "#               #*****/************************************//*/***#              #";
            echo "#             ###********************************************/****##/            #";
            echo "#            #####**********   ********************.   **********#####           #";
            echo "#           /######*******       *****************      ,*******######.          #";
            echo "#           ######***********************************************######          #";
            echo "#          ,#####********@@@@@***********************@@@@@********#####          #";
            echo "#          #####**********@@@@@@@@**************@@@@@@@@@**********####(         #";
            echo "#          ####/****************(@&*************//*****************####/         #";
            echo "#           ###********************             ,******************####          #";
            echo "#           ###         *********     @@@@@@@@     *******.        ####          #";
            echo "#            ##/            ***       @@@@@@@@      **             ###           #";
            echo "#             ###                        @@,                      ###            #";
            echo "#              ###                       #@                     ####             #";
            echo "#               #####               @@ ,.     @@              #####              #";
            echo "#                 ######                      &           .######                #";
            echo "#                   ########                           ########                  #";
            echo "#                      #########.                 ##########                     #";
            echo "#                          #############################                         #";
            echo "#                               .#################                               #";
            echo '#                  _____                   .__   __                              #';
            echo '#                 /     \    ____    ____  |__|_/  |_  ____ _______              #';
            echo '#                /  \ /  \  /  _ \  /    \ |  |\   __\/  _ \\_  __ \             #';
            echo '#               /    Y    \(  <_> )|   |  \|  | |  | (  <_> )|  | \/             #';
            echo '#               \____|__  / \____/ |___|  /|__| |__|  \____/ |__|                #';
            echo '#                       \/              \/                                       #';
            echo "#                                                                                #";
            echo "##################################################################################";
    }

# Define the check shib function.
    function CHECK_SHIB {

        # Download a copy of crypto.com's SHIB page to parse and check what the price currently is.
            wget -q -O "${SHIB_WGET_FILE}" "${COIN_URL}";

        # Determine the number of times to run the loop
            LOOP_COUNT=$(grep -o -i "aria-valuetext=" "${SHIB_WGET_FILE}" | wc -l);
            LOOP_START=1;

        # Loop through the html, parsing for the SHIB value.
            while [ $LOOP_START -ne $LOOP_COUNT ]; do
            # Define variables specific to this while loop.
                LOOP_START=$(($LOOP_START+1));
                SHIB_VALUE=$(cat "${SHIB_WGET_FILE}" | awk -F 'chakra-text' "{ print \$${LOOP_START} }" | awk -F '>' '{ print $2 }' | awk -F '<' '{ print $1 }' | xargs);
                CHECK="USD";
                EMAIL_COUNT_1=$(wc -l "${SHIB_EMAIL_COUNTER_FILE_1}" | awk 'print $1');
                EMAIL_COUNT_2=$(wc -l "${SHIB_EMAIL_COUNTER_FILE_2}" | awk 'print $1');
                EMAIL_COUNT_3=$(wc -l "${SHIB_EMAIL_COUNTER_FILE_3}" | awk 'print $1');
                EMAIL_COUNT_4=$(wc -l "${SHIB_EMAIL_COUNTER_FILE_4}" | awk 'print $1');
            # Here we are defining the values that are our thresholds for alerting on.
            # I only have 4 set in total and they are statically assigned to these values at this time.
            # This is something anyone else can change and expand upon / do better.
                SHIB_LOWER1=0.00008000;
                SHIB_LOWER2=0.00010000;
                SHIB_LOWER3=0.00100000;
                SHIB_LOWER4=0.01000000;

                if [[ "${SHIB_VALUE}" == *"${CHECK}"* ]]; then
                    SHIB_VALUE=$(echo "${SHIB_VALUE}" | awk -F '$' '{ print $2 }' | awk -F " USD" '{print $1}');
                    if (( $(echo "${SHIB_VALUE} < ${SHIB_LOWER1}" |bc -l) )); then
                        echo "Subject: SHIB Alert Email!" > "${SHIB_EMAIL_FILE}";
                        echo "We have not yet begun to take off..." >> "${SHIB_EMAIL_FILE}";
                        echo "Shib value is: ${SHIB_VALUE}" >> "${SHIB_EMAIL_FILE}";
                    # Test if an email needs to be sent.
                        grep "We have not yet begun to take off..." "${SHIB_EMAIL_FILE}";
                        if [ $? -eq 0 ] && [ $EMAIL_COUNT_1 -gt 5 ]; then
                            :;
                        else
                            sendmail "${EMAIL_TO}" < "${SHIB_EMAIL_FILE}";    # All conditions succeeded. Sending an email.
                            echo "Email sent" >> "${SHIB_EMAIL_COUNTER_FILE_1}";    # Incrementing the counter.
                        fi
                    elif (( $(echo "${SHIB_VALUE} > ${SHIB_LOWER1}" |bc -l) )) || (( $(echo "${SHIB_VALUE} < ${SHIB_LOWER2}" |bc -l) )); then
                        echo "Subject: SHIB Alert Email!" > "${SHIB_EMAIL_FILE}";
                        echo "We have started to gain some speed!" >> "${SHIB_EMAIL_FILE}";
                        echo "Shib value is: ${SHIB_VALUE}" >> "${SHIB_EMAIL_FILE}";
                    # Test if an email needs to be sent.
                        grep "We have started to gain some speed" "${SHIB_EMAIL_FILE}";
                        if [ $? -eq 0 ] && [ $EMAIL_COUNT_2 -gt 5 ]; then
                            :;
                        else
                            sendmail "${EMAIL_TO}" < "${SHIB_EMAIL_FILE}";    # All conditions succeeded. Sending an email.
                            echo "Email sent" >> "${SHIB_EMAIL_COUNTER_FILE_2}";    # Incrementing the counter.
                        fi
                    elif (( $(echo "${SHIB_VALUE} > ${SHIB_LOWER2}" |bc -l) )) || (( $(echo "${SHIB_VALUE} < ${SHIB_LOWER3}" |bc -l) )); then
                        echo "Subject: SHIB Alert Email!" > "${SHIB_EMAIL_FILE}";
                        echo "We are starting to take off!" >> "${SHIB_EMAIL_FILE}";
                        echo "Shib value is: ${SHIB_VALUE}" >> "${SHIB_EMAIL_FILE}";
                    # Test if an email needs to be sent.
                        grep "We are starting to take off" "${SHIB_EMAIL_FILE}";
                        if [ $? -eq 0 ] && [ $EMAIL_COUNT_3 -gt 5 ]; then
                            :;
                        else
                            sendmail "${EMAIL_TO}" < "${SHIB_EMAIL_FILE}";    # All conditions succeeded. Sending an email.
                            echo "Email sent" >> "${SHIB_EMAIL_COUNTER_FILE_3}";    # Incrementing the counter.
                        fi
                    elif (( $(echo "${SHIB_VALUE} > ${SHIB_LOWER3}" |bc -l) )) || (( $(echo "${SHIB_VALUE} < ${SHIB_LOWER4}" |bc -l) )); then
                        echo "Subject: SHIB Alert Email!" > "${SHIB_EMAIL_FILE}";
                        echo "We are seeing amazing flight!!" >> "${SHIB_EMAIL_FILE}";
                        echo "Shib value is: ${SHIB_VALUE}" >> "${SHIB_EMAIL_FILE}";
                    # Test if an email needs to be sent.
                        grep "We are seeing amazing flight" "${SHIB_EMAIL_FILE}";
                        if [ $? -eq 0 ] && [ $EMAIL_COUNT_4 -gt 5 ]; then
                            :;
                        else
                            sendmail "${EMAIL_TO}" < "${SHIB_EMAIL_FILE}";    # All conditions succeeded. Sending an email.
                            echo "Email sent" >> "${SHIB_EMAIL_COUNTER_FILE_4}";    # Incrementing the counter.
                        fi
                    elif (( $(echo "${SHIB_VALUE} > ${SHIB_LOWER4}" |bc -l) )); then
                        echo "Subject: SHIB Alert Email!" > "${SHIB_EMAIL_FILE}";
                        echo "To the moon!" >> "${SHIB_EMAIL_FILE}";
                        echo "Shib value is: ${SHIB_VALUE}" >> "${SHIB_EMAIL_FILE}";
                    # Test if an email needs to be sent.
                        grep "To the moon" "${SHIB_EMAIL_FILE}";
                        if [ $? -eq 0 ]; then
                            :;
                        else
                            sendmail "${EMAIL_TO}" < "${SHIB_EMAIL_FILE}";    # All conditions succeeded. Sending an email.
                        fi
                    else
                        :;
                    fi
                else
                    :; # This isn't a real value we are searching for.
                fi
            done

        # Output the date/time and SHIB price to the log file for tracking.
            echo "${TODAYS_DATE_WITH_SECONDS} - ${SHIB_VALUE}" >> "${SHIB_PRICE_LOG}";

    }

# Call all of the script functions
    DEFINE_VARIABLES;
    SETUP_LOCK;
    INTRO;
    CHECK_SHIB;
