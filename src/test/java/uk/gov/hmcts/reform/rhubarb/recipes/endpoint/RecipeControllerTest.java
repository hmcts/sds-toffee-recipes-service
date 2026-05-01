package uk.gov.hmcts.reform.rhubarb.recipes.endpoint;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.Recipe;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.RecipeList;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = { "spring.flyway.enabled=true" })
@AutoConfigureMockMvc
@ExtendWith(SpringExtension.class)
@Sql(scripts = "/init.sql")
class RecipeControllerTest {

    @Autowired
    @SuppressWarnings("PMD.BeanMembersShouldSerialize")
    private MockMvc mvc;

    @Autowired
    @SuppressWarnings("PMD.BeanMembersShouldSerialize")
    private ObjectMapper objectMapper;

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
        assertEquals("Toffee", recipes.get(0).name(), "title is as expected");
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

        assertEquals("Toffee", recipe.name(), "title is as expected");
        assertEquals("200g sugar", recipe.ingredients(), "ingredients are as expected");
    }
}
