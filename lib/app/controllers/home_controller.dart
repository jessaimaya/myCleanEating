import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/recipes.dart';
import '../networking/api_service.dart';
import '../networking/queries.dart';
import '/resources/widgets/logo_widget.dart';
import 'controller.dart';

class HomeController extends Controller {
  @override
  construct(BuildContext context) {
    super.construct(context);
  }

  onTapGithub() async {
    await launchUrl(Uri.parse("https://github.com/nylo-core/nylo"));
  }

  onTapChangeLog() async {
    await launchUrl(Uri.parse(
        "https://github.com/nylo-core/framework/blob/5.x/CHANGELOG.md"));
  }

  onTapYouTube() async {
    await launchUrl(Uri.parse("https://m.youtube.com/@nylo_dev"));
  }

  Future<File?> getLocalFile(String filename) async {
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/$filename');
    bool fileExists = await file.exists();
    return fileExists ? file : null;
  }

  Future<void> downloadAndSaveImage(String url, String filename) async {
    Dio dio = Dio();
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/$filename');
    await dio.download(url, file.path);
  }

  void displayImage(String url, String filename) async {
    File? localFile = await getLocalFile(filename);
    if (localFile != null) {
      Image.file(localFile);
    } else {
      Image.network(url);
      downloadAndSaveImage(url, filename);
    }
  }

  Future<Recipes> handleRefresh() async {
    ApiService _apiService = ApiService();
    var recipes = Recipes(data: Data(recipes: []));
    int offset = 0;
    int limit = 100;

    while (true) {
      var newRecipes =
          await _apiService.fetchGraphQlData(recipesQuery, limit, offset);
      recipes.data.recipes.addAll(newRecipes.data.recipes);

      if (newRecipes.data.recipes.length < limit) {
        break;
      }

      offset += limit;
    }

    return recipes;
  }

  showAbout() {
    showAboutDialog(
      context: context!,
      applicationName: getEnv('APP_NAME'),
      applicationIcon: Logo(),
      applicationVersion: nyloVersion,
    );
  }
}
