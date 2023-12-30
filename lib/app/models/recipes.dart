class Recipes {
  final Data data;

  Recipes({
    required this.data,
  });

  Recipes copyWith({
    Data? data,
  }) =>
      Recipes(
        data: data ?? this.data,
      );

  // from json
  factory Recipes.fromJson(Map<String, dynamic> json) => Recipes(
        data: Data.fromJson(json["data"]),
      );
}

class Data {
  final List<Recipe> recipes;

  Data({
    required this.recipes,
  });

  Data copyWith({
    List<Recipe>? recipes,
  }) =>
      Data(
        recipes: recipes ?? this.recipes,
      );

  // from json
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recipes:
            List<Recipe>.from(json["recipes"].map((x) => Recipe.fromJson(x))),
      );
}

class Recipe {
  final DateTime createdAt;
  final String id;
  final String name;
  final dynamic publishedAt;
  final String servings;
  final String time;
  final DateTime updatedAt;
  final List<Ingredient> ingredients;
  final List<Category> category;
  final bool? favorite;
  final List<String> preparation;
  final RecipeImage image;

  Recipe({
    required this.createdAt,
    required this.id,
    required this.name,
    required this.publishedAt,
    required this.servings,
    required this.time,
    required this.updatedAt,
    required this.ingredients,
    required this.category,
    required this.favorite,
    required this.preparation,
    required this.image,
  });

  Recipe copyWith({
    DateTime? createdAt,
    String? id,
    String? name,
    dynamic publishedAt,
    String? servings,
    String? time,
    DateTime? updatedAt,
    List<Ingredient>? ingredients,
    List<Category>? category,
    bool? favorite,
    List<String>? preparation,
    RecipeImage? image,
  }) =>
      Recipe(
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
        name: name ?? this.name,
        publishedAt: publishedAt ?? this.publishedAt,
        servings: servings ?? this.servings,
        time: time ?? this.time,
        updatedAt: updatedAt ?? this.updatedAt,
        ingredients: ingredients ?? this.ingredients,
        category: category ?? this.category,
        favorite: favorite ?? this.favorite,
        preparation: preparation ?? this.preparation,
        image: image ?? this.image,
      );

  // from json
  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        createdAt: DateTime.parse(json["createdAt"]),
        id: json["id"],
        name: json["name"],
        publishedAt: json["publishedAt"],
        servings: json["servings"],
        time: json["time"],
        updatedAt: DateTime.parse(json["updatedAt"]),
        ingredients: List<Ingredient>.from(
            json["ingredients"].map((x) => Ingredient.fromJson(x))),
        category: List<Category>.from(
            json["category"].map((x) => Category.fromJson(x))),
        favorite: json["favorite"],
        preparation: List<String>.from(json["preparation"].map((x) => x)),
        image: json["image"] == null
            ? RecipeImage(url: "")
            : RecipeImage.fromJson(json["image"]),
      );
}

class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  Category copyWith({
    String? id,
    String? name,
  }) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  // from json
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );
}

class RecipeImage {
  final String url;

  RecipeImage({
    required this.url,
  });

  RecipeImage copyWith({
    String? url,
  }) =>
      RecipeImage(
        url: url ?? this.url,
      );
  // from json
  factory RecipeImage.fromJson(Map<String, dynamic> json) => RecipeImage(
        url: json["url"] ?? "",
      );
}

class Ingredient {
  final String id;
  final String name;
  final List<String> ingredient;

  Ingredient({
    required this.id,
    required this.name,
    required this.ingredient,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    List<String>? ingredient,
  }) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        ingredient: ingredient ?? this.ingredient,
      );
  // from json
  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json["id"],
        name: json["name"],
        ingredient: List<String>.from(json["ingredient"].map((x) => x)),
      );
}
