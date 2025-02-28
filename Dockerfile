 # renovate: datasource=github-releases depName=microsoft/ApplicationInsights-Java
ARG APP_INSIGHTS_AGENT_VERSION=3.7.1
ARG PLATFORM=""
FROM hmctspublic.azurecr.io/base/java:21-distroless

COPY build/libs/sds-toffee-recipes-service.jar /opt/app/

CMD ["sds-toffee-recipes-service.jar"]
