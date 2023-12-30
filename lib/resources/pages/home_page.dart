import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/json_dart_generator/json_def.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/models/recipes.dart';
import '/app/controllers/home_controller.dart';
import '/resources/widgets/safearea_widget.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static const path = '/home';

  HomePage() : super(path, child: _HomePageState());
}

class _HomePageState extends NyState<HomePage> {
  late Recipes recipes;
  TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredRecipes = [];
  Map<String, List<Recipe>> _groupedRecipes = {};

  @override
  init() async {
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });

    // catch error if NyStorage is not initialized
    try {
      String? data = await NyStorage.read('recipes');
      if (data != null && data.isNotEmpty) {
        recipes = Recipes.fromJson(jsonDecode(data));
      } else {
        recipes = await loadRecipesFromAssets();
      }
    } catch (e) {
      recipes = await loadRecipesFromAssets();
    }

    _filteredRecipes = await recipes.data.recipes;
    _groupedRecipes = groupBy(_filteredRecipes, (Recipe recipe) {
      return recipe.category[0].name;
    });

    _onSearchChanged('');
  }

  void updateRecipes(Recipes newRecipes) {
    setState(() {
      recipes = newRecipes;
    });
    _filteredRecipes = newRecipes.data.recipes;
    _groupedRecipes = groupBy(_filteredRecipes, (Recipe recipe) {
      return recipe.category[0].name;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _filteredRecipes = recipes.data.recipes.where((recipe) {
        var withName = recipe.name.toLowerCase().contains(value.toLowerCase());
        var withIngredients = recipe.ingredients.any((ingredient) =>
            ingredient.ingredient.any((element) =>
                element.toLowerCase().contains(value.toLowerCase())));
        var both = List.of([withName, withIngredients]);
        return both.any((element) => element == true);
      }).toList();
      _groupedRecipes = groupBy(_filteredRecipes, (Recipe recipe) {
        return recipe.category[0].name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeAreaWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // spacer
            SizedBox(height: 16),
            Text(
              getEnv("APP_NAME"),
            ).displayMedium(context),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
            // add a scrollable list of recipes
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  Recipes newRecipes = await widget.controller.handleRefresh();
                  updateRecipes(newRecipes);
                },
                child: ListView.builder(
                  itemCount: _groupedRecipes.keys.length,
                  itemBuilder: (context, index) {
                    String category = _groupedRecipes.keys.elementAt(index);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // spacing
                        SizedBox(height: 5),
                        Text(
                          category.upperCamel(),
                          style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ).displaySmall(context),
                        SizedBox(height: 5),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _groupedRecipes[category]!.length,
                          itemBuilder: (context, index) {
                            Recipe recipe = _groupedRecipes[category]![index];
                            Image currentImage =
                                Image.asset('/assets/images/nylo_logo.png');
                            return ListTile(
                              // include small thumbnail image
                              leading: FutureBuilder<File?>(
                                  future:
                                      widget.controller.getLocalFile(recipe.id),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<File?> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.data != null) {
                                        // set max width and height
                                        currentImage = Image.file(
                                          snapshot.data!,
                                          width: 50,
                                          height: 50,
                                        );
                                        return currentImage;
                                      } else {
                                        widget.controller.downloadAndSaveImage(
                                            recipe.image.url, recipe.id);
                                        currentImage = Image.network(
                                            recipe.image.url,
                                            width: 50,
                                            height: 50);
                                        return currentImage;
                                      }
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }),
                              title: Text(recipe.name),
                              subtitle: Text(recipe.time),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) {
                                      return Dialog(
                                          insetPadding: EdgeInsets.all(5),
                                          child: RecipeDetailsModal(
                                              recipe: recipe,
                                              currentImage: currentImage));
                                    });
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}

Future<Recipes> loadRecipesFromAssets() async {
  String jsonString =
      await rootBundle.loadString('public/assets/postman/recipes.json');
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  return Recipes.fromJson(jsonMap);
}

class RecipeDetailsModal extends StatefulWidget {
  final Recipe recipe;
  final Image currentImage;

  RecipeDetailsModal({required this.recipe, required this.currentImage});

  @override
  _RecipeDetailsModalState createState() => _RecipeDetailsModalState();
}

class _RecipeDetailsModalState extends State<RecipeDetailsModal> {
  List<bool> _checkedIngredients = [];

  @override
  void initState() {
    super.initState();

    widget.recipe.ingredients.forEach((ingredient) {
      ingredient.ingredient.forEach((element) {
        _checkedIngredients.add(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Recipe recipe = widget.recipe;
    // directory local storage
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // display full width image widget.currentImage,
            AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                    width: double.infinity,
                    child: FittedBox(
                        fit: BoxFit.cover, child: widget.currentImage))),
            //spacing
            SizedBox(height: 16),
            Text(recipe.name,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: ${recipe.time}'),
                Text('Servings: ${recipe.servings}'),
              ],
            ),
            SizedBox(height: 16),
            ...recipe.ingredients.map((ingredient) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ingredient.name,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ...ingredient.ingredient.asMap().entries.map((entry) {
                    int index = entry.key;
                    String ingredientItem = entry.value;
                    return Align(
                      alignment: Alignment.topLeft,
                      child: CheckboxListTile(
                        title: Text(
                          ingredientItem,
                        ),
                        value: _checkedIngredients[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _checkedIngredients[index] = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
            Text('Preparation', style: TextStyle(fontWeight: FontWeight.bold)),
            ...recipe.preparation.map((preparationItem) {
              List<String> preparationItemSplit = preparationItem.split('\n');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preparationItemSplit[0]),
                  ...preparationItemSplit.sublist(1).map((preparationItem) {
                    return Text(preparationItem);
                  }).toList(),
                ],
              );
            }).toList(),
            /*
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recipe.preparation.length,
              itemBuilder: (context, index) {
                String preparationItem = recipe.preparation[index];
                List<String> preparationItemSplit = preparationItem.split('\n');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preparationItemSplit[0]),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: preparationItemSplit.length,
                      itemBuilder: (context, index) {
                        String preparationItemSplitItem =
                            preparationItemSplit[index];
                        return Text(preparationItemSplitItem);
                      },
                    ),
                  ],
                );
              },
            ),

             */
          ],
        ),
      ),
    );
  }
}
