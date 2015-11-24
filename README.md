# internet-sim
Simulador de sites e serviços on-line para teste de desempenho de DNS, HTTP, PROXY e capacidade
<pre>

Uso esse projeto para gerar stress extremo em roteadores e servidores, assim consigo optimizar os
software para a maior performance, alta disponibilidade e detectacao de bugs em ambientes criticos.

Qualquer produto que sobreviva a esse laboratorio podera ser usado em solucoes sérias.

Compabilidade com Slackware e Ubuntu

linux/

    domains/
        Lista de dominios simulados

    dns/
        Scripts para gerar servidores DNS com BIND9 e Unbound

    http/
        Scripts para rodar web-sites simulados em Apache2, Apache3, Lighttpd e Nginx

    loopback/
        Scripts para associar IPs ao servidor (v4 e v6)

    routing/
        Scripts para gerar servidor zebra/quagga rodando RIP, RIP2, RIPng, OSPF, OSPFv3, mp-BGP
        Testes de BGP com full-routing simulado de 500 mil a 50 milhoes de rotas ipv4 e ipv6
        (claro que CCR nunca sobreviveu aos testes)




</pre>
