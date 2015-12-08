#!/bin/sh

# simular muitos clientes num provedor

alias fget="wget --timeout=1 --tries=1 -b -q --read-timeout=2 -O /dev/null"

killall http-loop 2>/dev/null
killall wget 2>/dev/null

while sleep 1; do

    # contar numero de processos
    n=$(ps ax | grep wget | grep -v grep | wc -l)
    limit=$(cat limit)
    if [ "$n" -gt "$limit" ]; then sleep 5; continue; fi

    listas=$(ls _*.txt)
    for f in $listas; do
    
	# baixar imediatamente
        #http-loop -d -f "$f"
	fget -i "$f"

    done

done

