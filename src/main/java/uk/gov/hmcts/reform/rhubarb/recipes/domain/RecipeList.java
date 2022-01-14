package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import com.fasterxml.jackson.annotation.JsonCreator;

import java.util.List;

public class RecipeList {

    private final List<Recipe> recipes;

    @JsonCreator
    public RecipeList(List<Recipe> recipes) {
        this.recipes = recipes;
    }

    public List<Recipe> getRecipes() {
        return recipes;
    }
}
