#!/bin/bash

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root: sudo ./setup_tpm.sh"
  exit 1
fi

echo "Atualizando..."
apt update && apt upgrade -y

echo "Instalando..."
apt install -y tpm2-tools openssl

echo "Limpando TPM..."
tpm2_clear

tpm2_evictcontrol -C o -c 0x81010001 2>/dev/null

HEX_SEED=$(openssl rand -hex 16)
echo $HEX_SEED

tpm2_createprimary -p "$HEX_SEED" -C o -g sha256 -G rsa -c primary.ctx
tpm2_readpublic -c primary.ctx -f pem -o endorsement_pub.pem
tpm2_evictcontrol -C o -c primary.ctx 0x81010001

echo "Finalizado"
