#!/bin/bash
if [[ ! -z "$1" ]]; then
  if [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]]; then
    printf "Messaging syntax:\n  Tell [Contact name|Phone number] that [message]\n"
    printf "App/website syntax:\n  Open [App|Website]\n"
    printf "Adding contacts:\n  [Contact name]'s number is [number]\n"
    echo More coming soon!
    exit 0
  else
    echo Invalid flag. Use -h for help.
  fi
fi

if [ ! -f ./open-a.applescript ] || [ ! -f ./openpg.applescript ] || [ ! -f ./send-m.applescript ] || [ ! -f ./used ] || [ ! -d ./contacts ]; then
  printf "\e[1;31mError: \e[0ma critical file or directory is missing.\n"
  exit 1
fi

if [ -z $(cat used) ]; then
  prompt="Hello, I'm your text-based assistant! How can I help you? "
else
  prompt=": "
fi 

printf "$prompt"
read whattodo
echo 1 > used
if [[ "$whattodo" =~ "that" ]]; then
  recip=$(echo $whattodo | awk '{print $2}')
  messa=$(echo $whattodo | sed 's/.*that //')
  printf "Ok, should I tell $recip that "
  printf "$messa" | sed -e "s|I'm|you're|g" -e "s|i'm|you're|g" -e 's/I/you/g'
  printf "? (y/n) "
  read YORN

  if [[ "$YORN" =~ "y" ]] && [ -f "send-m.applescript" ]; then

    if [[ $recip =~ ^[0-9]+$ ]]; then
      cat send-m.applescript | sed -e "s|MESSA|$messa|" -e "s|RECIP|$recip|" | osascript
      echo Done!
    else

      if [ -f contacts/$recip.txt ]; then
        cat send-m.applescript | sed -e "s|MESSA|$messa|" -e "s|RECIP|$(cat contacts/$recip.txt)|" | osascript
        echo Done!
      fi

    fi

  else

    echo ERROR

  fi
elif [[ "$whattodo" =~ .*\'s\ .*number\ is.* ]]; then
  echo $whattodo | sed 's/[^0-9]//g'
  echo $whattodo | sed "s|'.*$||"
elif [[ "$whattodo" =~ ^open.*$ ]]; then
  if [[ "$whattodo" =~ [a-zA-Z]+\.[a-zA-Z]{2,3} ]]; then
    page=$(echo $whattodo | sed 's/open //' | sed -e "s|https://||g" -e "s|http://||g")
    cat openpg.applescript | sed "s|WEBPAGE|$page|" | osascript
  else
    app=$(echo $whattodo | sed 's/open //')
    cat open-a.applescript | sed "s|APPLICATION|$app|" | osascript
  fi
else :
fi
