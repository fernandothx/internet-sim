#!/bin/sh

# Variaveis globais
    DEV=eth3
    FILE=/users.txt
    LIMIT=512
    ECHOI=5
    ECHOF=3
    PERSIST=0
    WDIR=/tmp/masive-pppoe

# Pasta de trabalho
    mkdir -p $WDIR

# Ajuda
PROGNAME=$0
_usage(){
    echo $@

    echo "Use: $PROGNAME (ethX) (users-file) (limit)"
    echo
    echo "  ethX           : interface de rede (ou vlan)"
    echo "  users-file     : lista de usuario no formato CSV: user;pass;profilename"
    echo "  limit          : numero maximo de processos tentando conexoes"
    echo

    exit 1
}

# Funcao para criar conexao do usuario
pppoe_client(){
    user="$1"
    (
    (
	/usr/sbin/pppd \
		pty \
		"/usr/sbin/pppoe -p /var/run/pppoe.conf-pppoe.pid.pppoe -I $DEV -T 80 -U  -m 1412" \
		noipdefault noauth \
		default-asyncmap hide-password nodetach usepeerdns \
		mtu 1492 mru 1492 \
		noaccomp nodeflate nopcomp novj novjccomp \
		user "$user" \
		lcp-echo-interval $ECHOI lcp-echo-failure $ECHOF
    ) 2>/dev/null 1>/dev/null 
    ) &
}

# Registrar usuario na base PAP | CHAP
register_user(){
    user="$1" ; pass="$2"
    for f in pap-secrets chap-secrets; do
	e=$(grep "\"$user\"" /etc/ppp/$f 2>/dev/null)
	if [ "x$e" = "x" ]; then echo "\"$user\"  *   \"$pass\"" >> /etc/ppp/$f; fi
    done
}

# Contar numero de processos abertos
count_ps(){
    ps ax | grep 'pppd pty' | wc -l
}

for p in $@; do

    # Arquivo
    if [ -f "$p" ]; then FILE="$p"; continue; fi
    
    # Interface
    x=$(echo "$p" | egrep eth)
    if [ "x$x" != "x" ]; then DEV="$p"; continue; fi
    
    # LIMITE
    x=$(echo "$p" | egrep '$[0-9]+$')
    if [ "x$x" != "x" ]; then LIMIT="$p"; continue; fi

    # config magica
    if [ "$p" = "ubnt" ]; then ECHOI=10; ECHOF=2; continue; fi
    if [ "$p" = "normal" ]; then ECHOI=20; ECHOF=3; continue; fi
    if [ "$p" = "lento" ]; then ECHOI=30; ECHOF=6; continue; fi

    # persistente (gerar conexoes pra sempre)
    if [ "$p" = "persist" -o "$p" = "persistent" -o "$p" = "forever" ]; then PERSIST=1; continue; fi

done

# Critica
if [ "$LIMIT" -lt "1" ]; then LIMIT=1; fi
if [ "x$FILE" = "x" ]; then _usage "Informe o arquivo"; fi
if [ ! -f "$FILE" ]; then _usage "Informe o arquivo"; fi
if [ "$x$DEV" = "x" ]; then _usage "Informe a interface ether"; fi
if [ ! -d /sys/class/net/$DEV ]; then _usage "Interface '$DEV' nao existe"; fi

echo
echo "PPPoE Massive Simulator"
echo
echo "Interface...: $DEV"
echo "Limit.......: $LIMIT"
echo "File........: $FILE"
echo

# Preparar lista de usuarios
LIST=$(cat $FILE | egrep -v '^#' | egrep -v '^$' | egrep '^[a-z0-9.@-]+;.*$')

loops=0
while [ "$loops" = "0" -o "$PERSIT" = "1" ]; do

    for it in $LIST; do

	psc=$(count_ps)
	
	# exedeu numero de processos
	if [ "$psc" = "$LIMIT" ]; then break; fi
	if [ "$psc" -gt "$LIMIT" ]; then break; fi

	# gerar conexao
	usr=$(echo $it | cut -f1 -d';' -s)
	psw=$(echo $it | cut -f2 -d';' -s)
	prf=$(echo $it | cut -f3 -d';' -s)

	# anotar profile em arquivo tmp
	if [ "x$prf" != "x" ]; then
	    echo "$prf" > $WDIR/profile-$usr
	fi

	# registro invalido
	if [ "x$usr" = "x" -o "x$psw" = "x" ]; then continue; fi

	# registrar no PAP / CHAP
	register_user "$usr" "$psw"

	# Conectar no servidor
	pppoe_client "$usr"

    done

    loops=$(($loops+1))

done



