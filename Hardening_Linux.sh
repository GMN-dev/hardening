#!/bin/bash
# Script para realizar atualização do SO via central de ajuste do sistema
# Author: Genevy de Araujo Costa Souza
# 19/03/2024

if [ "$(id -u)" != "0" ]; then
   echo "Este script precisa ser executado com permissoes de superusuario (root)." 1>&2
   exit 1
fi

# Ativa o Firewall
ufw enable
echo "Firewall ativado com sucesso!"

# Instala o pacote unattended se ainda não estiver instalado
if apt list --installed 2>/dev/null | grep -q "^unattended-upgrades/"; then
   echo "O pacote 'unattended-upgrades' ja esta instalado."
else
   echo "O pacote 'unattended-upgrades' NAO esta instalado. Instalando..."
   apt update && apt install unattended-upgrades -y
fi

# Habilita as atualizações automaticas

echo 'APT::Periodic::Update-Package-Lists "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades

# Reinicia o serviço unattended-upgrades

systemctl restart unattended-upgrades

echo "Atualizacoes automaticas ativadas com sucesso!"

# Instala o pacote rsyslog se ainda não estiver instalado

if apt list --installed 2>/dev/null | grep -q "^rsyslog/"; then
   echo "O pacote 'rsyslog' ja esta instalado."
else
   echo "O pacote 'rsyslog' NAO esta instalado. Instalando..."
   apt update && apt install rsyslog -y
fi

# Habilita o monitoramento de logs

# Modifica as configurações do rsyslog para monitorar logs

sed -i 's/#module(load="imudp")/module(load="imudp")/' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/' /etc/rsyslog.conf
sed -i 's/#module(load=imtcp")/module(load="imtcp")/' /etc/rsyslog.conf
sed -i 's/#input(type="imtcp" port="514")/input(type="imtcp" port="514")/' /etc/rsyslog.conf

# Reinicia o serviço rsyslog para aplicar as alterações

systemctl restart rsyslog

# Exibe uma mensagem indicando que o monitoramento de logs foi ativado

echo "Monitoramento de logs ativado com sucesso!"

# Instala o pacote libpam-pwquality se ainda não estiver instalado

if apt list --installed 2>/dev/null | grep -q "^libpam-pwquality/"; then
   echo "O pacote 'libpam-pwquality' ja esta instalado."
else
   echo "O pacote 'libpam-pwquality' NAO esta instalado. Instalando..."
   apt update && apt install libpam-pwquality -y
fi

# Define as regras para a complexidade das senhas no arquivo de configuração pam_pwquality
# A senha deve ter pelo menos 12 caracteres - (variavel minlen=12)
# A senha não pode ser uma palavra comum - (variavel retry=3)
# A senha deve conter pelo menos um caractere maisculo  - (variavel ucredit=-1)
# A senha deve conter pelo menos um caractere minisculo - (variavel lcredit=-1)
# A senha deve conter pelo menos um digito - (variavel dcredit=-1)
# A senha deve conter pelo menos um caractere especial - (variavel ocredit=-1)

echo "password requisite pam_pwquality.so retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/common-password

# Exibe uma mensagem indicando que a politica de senha forte foi configurada

echo "Politica de senha forte configurada com sucesso!"
