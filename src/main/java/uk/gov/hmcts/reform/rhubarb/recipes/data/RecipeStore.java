package uk.gov.hmcts.reform.rhubarb.recipes.data;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import uk.gov.hmcts.reform.rhubarb.recipes.domain.Recipe;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

public class RecipeStore {

    private final NamedParameterJdbcTemplate jdbcTemplate; // NOPMD no need for accessors here

    public RecipeStore(NamedParameterJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<Recipe> read(String recipeId) {
        try {
            Recipe recipe = jdbcTemplate.queryForObject("""
                    SELECT *
                    FROM recipe
                    WHERE id = :id
                    """, new MapSqlParameterSource("id", recipeId),
                    new RecipeMapper()
                );
            return Optional.of(recipe);
        } catch (EmptyResultDataAccessException ex) {
            return Optional.empty();
        }
    }

    public List<Recipe> readAll() {
        return jdbcTemplate.query("""
            SELECT *
            FROM recipe
            """, new RecipeMapper()
        );
    }

    private static final class RecipeMapper implements RowMapper<Recipe> {
        @Override
        public Recipe mapRow(ResultSet rs, int rowNumber) throws SQLException {
            return new Recipe(
                rs.getString("id"),
                rs.getString("user_id"),
                rs.getString("name"),
                rs.getString("ingredients"),
                rs.getString("method")
            );
        }
    }
}
