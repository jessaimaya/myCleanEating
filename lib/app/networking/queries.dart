String recipesQuery = """
query Recipes {
  recipes(first:{limit}, skip:{offset}) {
    createdAt
    id
    name
    publishedAt
    servings
    time
    updatedAt
    ingredients {
      ... on Ingredient {
        id
        name
        ingredient
      }
    }
    category {
      ... on Category {
        id
        name
      }
    }
    favorite
    preparation
    image {
      url
    }
  }
}
""";
