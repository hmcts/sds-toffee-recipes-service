package uk.gov.hmcts.reform.rhubarb.functional;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static io.restassured.RestAssured.get;

public class HealthCheckTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(HealthCheckTest.class);

    @BeforeEach
    public void before() {
        String appUrl = System.getenv("TEST_URL");
        if (appUrl == null) {
            appUrl = "http://localhost:4550";
        }

        RestAssured.baseURI = appUrl;
        RestAssured.useRelaxedHTTPSValidation();
        LOGGER.info("Base Url set to: " + RestAssured.baseURI);
    }

    @Test
    @Tag("SmokeTest")
    public void healthcheck_returns_200() {
        get("/health").then().statusCode(200);
    }
}
