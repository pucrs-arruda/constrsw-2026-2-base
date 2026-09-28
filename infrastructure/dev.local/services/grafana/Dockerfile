FROM grafana/grafana:13.2.2

# Datasource do Prometheus e dashboards versionados no repositório: o Grafana já
# sobe configurado, sem nenhum passo manual na UI.
COPY provisioning /etc/grafana/provisioning
COPY dashboards /etc/grafana/dashboards

# Expor porta do Grafana
EXPOSE 3000
