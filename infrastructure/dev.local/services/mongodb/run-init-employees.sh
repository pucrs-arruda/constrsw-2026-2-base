#!/bin/bash

# Script para executar a população da collection de funcionários
# Este script deve ser executado após o MongoDB estar rodando

echo "Aguardando MongoDB estar disponível..."
sleep 10

echo "Executando script de população de funcionários..."

# Executar o script de inicialização dos funcionários
mongosh --host ${MONGODB_HOST:-localhost} --port ${MONGODB_PORT:-27017} \
        --username ${MONGODB_USERNAME:-admin} \
        --password ${MONGODB_PASSWORD:-a12345678} \
        --authenticationDatabase admin \
        --file /docker-entrypoint-initdb.d/init-employees.js

echo "Script de população de funcionários executado com sucesso!"

