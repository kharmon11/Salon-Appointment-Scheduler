#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

main_menu() {
  # get and show services
  $PSQL "SELECT * FROM services" | while IFS='|' read -r SERVICE_ID NAME
  do
    if [[ -n $SERVICE_ID ]] # Don't print empty lines
      then
        echo "$( echo "$SERVICE_ID" | xargs)) $(echo $NAME | xargs)"
    fi
  done

  # ask for service and process selection
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  case $SERVICE_ID_SELECTED in
    1) process $SERVICE_ID_SELECTED $SERVICE_NAME ;;
    2) process $SERVICE_ID_SELECTED $SERVICE_NAME ;;
    3) process $SERVICE_ID_SELECTED $SERVICE_NAME ;;
    4) process $SERVICE_ID_SELECTED $SERVICE_NAME ;;
    5) process $SERVICE_ID_SELECTED $SERVICE_NAME ;;
    *) 
      echo "Please select a valid option (1 - 5)"
      main_menu ;;
  esac
  exit 0
}

process() {
  # get phone number
  SERVICE_ID_SELECTED=$1
  echo -e "\nYou have chosen ($1) $2!"
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  # check for existing customer
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    # ask for info to create customer
    echo -e "\nWhat is your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # make appointment
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME
  CUSTOMER_INFO=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo "$CUSTOMER_INFO" | IFS='|' read -r CUSTOMER_ID CUSTOMER_NAME
  CUSTOMER_ID=$(echo "$CUSTOMER_INFO" | sed -E 's/^ *([0-9]+) \|.*$/\1/')
  CUSTOMER_NAME=$(echo "$CUSTOMER_INFO" | sed -E 's/^.*\|\s*([^|]+)\s*/\1/')
 
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
}

main_menu