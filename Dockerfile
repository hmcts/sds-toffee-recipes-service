ARG APP_INSIGHTS_AGENT_VERSION=2.6.4
FROM hmctspublic.azurecr.io/base/java:17

COPY lib/AI-Agent.xml /opt/app/
COPY build/libs/sds-toffee-recipes-service.jar /opt/app/

CMD ["sds-toffee-recipes-service.jar"]
