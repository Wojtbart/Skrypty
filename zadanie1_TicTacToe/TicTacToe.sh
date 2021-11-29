#!/bin/bash

PLANSZA=("-" "-" "-" "-" "-" "-" "-" "-" "-")
KONIEC=0
arrForInputValue=()
saveFile=""

function wyswietl {
    clear
    echo "--------------------"
    echo "Tic Tac Toe"
    echo "JESTEŚ X, zaś komputer jest O"
	echo -e "save - wpisanie powoduje zapisanie gry do pliku"
    echo  "load - wczytanie zapisane gry, wczytanie tylko bieżącej zapisane gry"
    echo "quit - wpisanie powoduje zakonczenie gry"
    echo "Numery liczb na planszy:"
    echo  "0 1 2 "
    echo  "3 4 5 "
    echo -e  "6 7 8\n"
    echo  "${PLANSZA[0]} ${PLANSZA[1]} ${PLANSZA[2]}"
    echo  "${PLANSZA[3]} ${PLANSZA[4]} ${PLANSZA[5]}"
    echo  "${PLANSZA[6]} ${PLANSZA[7]} ${PLANSZA[8]}"
    # echo "Wartości w tablicY: ${arrForInputValue[*]}"
    echo "--------------------"
}


function koniecGry {
    if [ $KONIEC -eq 1 ]
	then 
		echo "Wygrałeś, jesteś najlepszy, konczę grę!!"
        sleep 3
        exit 0
	elif [ $KONIEC -eq 2 ]
	then
		echo "Wygral komputer, musisz się bardziej postarać, kończę grę!!"
        sleep 3
        exit 0
	elif [ $KONIEC -eq 3 ]
	then
		echo "Nastapil remis"
        sleep 3
        exit 0
	elif [ $KONIEC -eq 4 ]
	then
		echo "KONIEC GRY!!!"
        exit 0
	fi
}

function sprawdzWygrana {

    if [[ "${PLANSZA[0]}" == 'X' ]] && [[ "${PLANSZA[1]}" == 'X' ]] && [[ "${PLANSZA[2]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi
    if [[ "${PLANSZA[3]}" == 'X' ]] && [[ "${PLANSZA[4]}" == 'X' ]] && [[ "${PLANSZA[5]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi
    if [[ "${PLANSZA[6]}" == 'X' ]] && [[ "${PLANSZA[7]}" == 'X' ]] && [[ "${PLANSZA[8]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi

    if [[ "${PLANSZA[0]}" == 'X' ]] && [[ "${PLANSZA[3]}" == 'X' ]] && [[ "${PLANSZA[6]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi
    if [[ "${PLANSZA[1]}" == 'X' ]] && [[ "${PLANSZA[4]}" == 'X' ]] && [[ "${PLANSZA[7]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi
    if [[ "${PLANSZA[2]}" == 'X' ]] && [[ "${PLANSZA[5]}" == 'X' ]] && [[ "${PLANSZA[8]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi

    if [[ "${PLANSZA[0]}" == 'X' ]] && [[ "${PLANSZA[4]}" == 'X' ]] && [[ "${PLANSZA[8]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi
    if [[ "${PLANSZA[2]}" == 'X' ]] && [[ "${PLANSZA[4]}" == 'X' ]] && [[ "${PLANSZA[6]}" == 'X' ]] ; then KONIEC=1; koniecGry; fi

    if [[ "${PLANSZA[0]}" == '0' ]] && [[ "${PLANSZA[1]}" == '0' ]] && [[ "${PLANSZA[2]}" == '0' ]] ; then KONIEC=2; koniecGry; fi
    if [[ "${PLANSZA[3]}" == '0' ]] && [[ "${PLANSZA[4]}" == '0' ]] && [[ "${PLANSZA[5]}" == '0' ]] ; then KONIEC=2; koniecGry; fi
    if [[ "${PLANSZA[6]}" == '0' ]] && [[ "${PLANSZA[7]}" == '0' ]] && [[ "${PLANSZA[8]}" == '0' ]] ; then KONIEC=2; koniecGry; fi

    if [[ "${PLANSZA[0]}" == '0' ]] && [[ "${PLANSZA[3]}" == '0' ]] && [[ "${PLANSZA[6]}" == '0' ]] ; then KONIEC=2; koniecGry; fi
    if [[ "${PLANSZA[1]}" == '0' ]] && [[ "${PLANSZA[4]}" == '0' ]] && [[ "${PLANSZA[7]}" == '0' ]] ; then KONIEC=2; koniecGry; fi
    if [[ "${PLANSZA[2]}" == '0' ]] && [[ "${PLANSZA[5]}" == '0' ]] && [[ "${PLANSZA[8]}" == '0' ]] ; then KONIEC=2; koniecGry; fi

    if [[ "${PLANSZA[0]}" == '0' ]] && [[ "${PLANSZA[4]}" == '0' ]] && [[ "${PLANSZA[8]}" == '0' ]] ; then KONIEC=2; koniecGry; fi
    if [[ "${PLANSZA[2]}" == '0' ]] && [[ "${PLANSZA[4]}" == '0' ]] && [[ "${PLANSZA[6]}" == '0' ]] ; then KONIEC=2; koniecGry; fi

    if [ ${PLANSZA[0]} != "-" ] && [ ${PLANSZA[1]} != "-" ] && [ ${PLANSZA[2]} != "-" ] && 
	[ ${PLANSZA[3]} != "-" ] && [ ${PLANSZA[4]} != "-" ] && [ ${PLANSZA[5]} != "-" ] && 
	[ ${PLANSZA[6]} != "-" ] && [ ${PLANSZA[7]} != "-" ] && [ ${PLANSZA[8]} != "-" ]; then KONIEC=3; koniecGry; fi
}

while [ "$KONIEC" -eq 0 ] 
do
    wyswietl
    echo "Wpisz odpowiednią komendę lub liczbe od 0 do 8, gdzie wstawię X: "
    # wybór opcji
    read POLE
    if [ "$POLE" == "save" ]; then
        saveFile="Game_$(date +'%Y%m%d_%H%M%S').txt"
        for i in {0..8} 
        do
            echo ${PLANSZA[$i]} >> $saveFile
        done
        echo "Gra zapisana pod nazwą $saveFile, gra bedzie kontynuowana za 5s"
        sleep 5
    elif [ "$POLE" == "quit" ]; then
        KONIEC=4
        koniecGry
    elif [ "$POLE" == "load" ]; then
        n=0
        while read line
        do
            if [ $n -le 8 ]
            then
                PLANSZA[$n]=$line
                n=$(( $n + 1 ))
            fi
        done < $saveFile
        echo "Wczytuje grę z pliku: $saveFile ..."
        sleep 3
    else
        arrForInputValue+=($POLE)
        PLANSZA[$POLE]='X'
        # sprawdzWygrana

        for POLKO in {0..8} 
        do 
        RAND=$(( $RANDOM % 8 ))
                for item in $arrForInputValue
                do
                if [[ ! " ${arrForInputValue[*]} " =~ " ${RAND} " ]]; then
                    continue
                else
                    while [ "$item" == "$RAND" ]
                    do
                        RAND=$(( $RANDOM % 8 ))
                    done
                fi

                done
                arrForInputValue+=($RAND)
                PLANSZA[$RAND]='0'
                sprawdzWygrana
                break

        done
        # wyswietl
    fi  
done

