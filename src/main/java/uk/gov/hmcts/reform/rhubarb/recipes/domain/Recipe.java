package uk.gov.hmcts.reform.rhubarb.recipes.domain;

import com.fasterxml.jackson.annotation.JsonIgnore;

public record Recipe(String id, @JsonIgnore String userId, String name,
                     String ingredients, String method) {

}
