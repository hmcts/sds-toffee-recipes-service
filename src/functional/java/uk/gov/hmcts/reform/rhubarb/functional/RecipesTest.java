package uk.gov.hmcts.reform.rhubarb.functional;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static io.restassured.RestAssured.get;

public class RecipesTest {

    private static final Logger LOGGER = LoggerFactory.getLogger(RecipesTest.class);

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
    @SuppressWarnings("PMD.JUnitTestsShouldIncludeAssert")
    public void recipes_list_returns_200() {
        get("/recipes").then().statusCode(200);
    }
}
