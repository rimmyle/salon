#!/bin/bash
echo -e "\n~~~~~ Salon ~~~~~"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES=$($PSQL "select * from services;") 

SERVICE_MENU() {
  echo -e "\nHere are the services we offer:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE | sed 's/ //g')
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-3]) NEXT ;;
        *) SERVICE_MENU ;;
  esac
}
NEXT() {
  echo -e "\nWhat is your phone number?\n"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';" | sed 's/ //g')
  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nLooks like you are new here\nWhat is your name?\n"
    read CUSTOMER_NAME
    CUSTOMER_INSERT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi

  echo -e "\nWelcome, $CUSTOMER_NAME, what time would you like to have your appointment?\n"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME';")
  APPOINTMENT_INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  SERVICE=$($PSQL "select name from services where service_id='$SERVICE_ID_SELECTED';" | sed 's/ //g')
  if [[ $APPOINTMENT_INSERT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
SERVICE_MENU
