#!/bin/bash

# Aguarda o PostgreSQL inicializar
until pg_isready -U postgres; do
    echo "Aguardando PostgreSQL inicializar..."
    sleep 2
done