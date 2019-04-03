

# Container para simular participacao em ponto de troca de trafego

# Baixe esse projeto para dentro do Linux Host onde o Docker foi instalado

# Preparacao:
# 0 - Crie uma maquina virtual ligada a port-group vlan 4095 (significa todas as vlans)
# 1 - Desative a seguranca de MAC da port-group, exemplo:
   # desativar seguranca
   esxcli network vswitch standard policy security set --vswitch-name=vSwitch0 --allow-mac-change yes
   esxcli network vswitch standard policy security set --vswitch-name=vSwitch0 --allow-promiscuous yes
   # criar pg trunk
   esxcli network vswitch standard portgroup add --portgroup-name=vPort0-Trunk --vswitch-name=vSwitch0
   esxcli network vswitch standard portgroup set -p vPort0-Trunk --vlan-id 4095

# 2 - Conecte a VM ou adicione uma nova interface de rede na PT vPort0-Trunk
# 3 - Dentro do Linux, apos instalar o Docker, crie uma rede MACVLAN:
   # supondo que a vPort0-Trunk foi associada a eth1 da VM
   LANDEV=eth1
   MACVDEV=mth1
   docker network create -d macvlan --ipv6 --subnet=198.18.0.0/24 --subnet=2001:db8:faca:fada::/64 -o parent=$LANDEV $MACVDEV

# 4 - Entre na pasta do projeto e crie a imagem do container:
   cd docker-ixbr-quarentena/
   docker  build  -t  ixbr-quarentena  .

# 5 - Edite o script run.sh e preencha com suas variaveis
# 6 - Rode o script run.sh
# 7 - Pronto!
