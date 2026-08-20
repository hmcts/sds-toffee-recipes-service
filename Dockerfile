ARG PLATFORM=""
FROM hmctsprod.azurecr.io/base/java:pr-25-distroless

COPY build/libs/sds-toffee-recipes-service.jar /opt/app/

CMD ["sds-toffee-recipes-service.jar"]
