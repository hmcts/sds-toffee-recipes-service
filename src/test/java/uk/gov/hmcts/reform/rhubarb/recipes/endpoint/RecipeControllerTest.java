package uk.gov.hmcts.reform.rhubarb.recipes.endpoint;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.ext.ScriptUtils;
import org.testcontainers.jdbc.JdbcDatabaseDelegate;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.Recipe;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.RecipeList;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@Testcontainers
@SpringBootTest(properties = { "spring.flyway.enabled=true" })
@AutoConfigureMockMvc
@ExtendWith(SpringExtension.class)
@ContextConfiguration(initializers = {RecipeControllerTest.Initializer.class})
class RecipeControllerTest {

    @Container
    public static final PostgreSQLContainer POSTGRES_CONTAINER = new PostgreSQLContainer("postgres:11-bullseye")
        .withDatabaseName("toffee")
        .withUsername("toffee")
        .withPassword("toffee");

    @Autowired
    @SuppressWarnings("PMD.BeanMembersShouldSerialize")
    private MockMvc mvc;

    @Autowired
    @SuppressWarnings("PMD.BeanMembersShouldSerialize")
    private ObjectMapper objectMapper;

    static class Initializer
        implements ApplicationContextInitializer<ConfigurableApplicationContext> {
        public void initialize(ConfigurableApplicationContext configurableApplicationContext) {
            TestPropertyValues.of(
                "spring.datasource.url=" + POSTGRES_CONTAINER.getJdbcUrl(),
                "spring.datasource.username=" + POSTGRES_CONTAINER.getUsername(),
                "spring.datasource.password=" + POSTGRES_CONTAINER.getPassword()
            ).applyTo(configurableApplicationContext.getEnvironment());
        }
    }

    @BeforeEach
    void before() {
        try (JdbcDatabaseDelegate jdbcDatabaseDelegate = new JdbcDatabaseDelegate(POSTGRES_CONTAINER, "")) {
            // script can only be run once
            // schema doesn't generate an ID automatically
            // shortcut to not fail when run more than one
            // BeforeAll runs before schema has been setup
            ScriptUtils.runInitScript(jdbcDatabaseDelegate, "init.sql");
        } catch (ScriptUtils.UncategorizedScriptException ignored) {
        }
    }

    @Test
    void retrieveAll() throws Exception {
        String result = mvc.perform(
                get("/recipes")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content()
                .contentTypeCompatibleWith(MediaType.APPLICATION_JSON)
            ).andReturn()
            .getResponse().getContentAsString();

        RecipeList recipeList = objectMapper.readValue(result, RecipeList.class);

        List<Recipe> recipes = recipeList.getRecipes();
        assertEquals(1, recipes.size(), "correct number of recipes");
        assertEquals("Toffee", recipes.get(0).getName(), "title is as expected");
    }

    @Test
    void retrieveOne() throws Exception {
        String result = mvc.perform(
                get("/recipes/1")
                    .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content()
                .contentTypeCompatibleWith(MediaType.APPLICATION_JSON)
            ).andReturn()
            .getResponse().getContentAsString();

        Recipe recipe = objectMapper.readValue(result, Recipe.class);

        assertEquals("Toffee", recipe.getName(), "title is as expected");
    }
}
