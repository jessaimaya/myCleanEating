import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/recipes.dart';
import '/config/decoders.dart';

/*
|--------------------------------------------------------------------------
| ApiService
| -------------------------------------------------------------------------
| Define your API endpoints

| Learn more https://nylo.dev/docs/5.x/networking
|--------------------------------------------------------------------------
*/

class ApiService extends NyApiService {
  ApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  final interceptors = {
    if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger()
  };

  Future<Recipes> fetchGraphQlData(
      String gqlQuery, int limit, int offset) async {
    var response = await Dio().post(
      baseUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'query': gqlQuery
            .replaceAll("{limit}", limit.toString())
            .replaceAll("{offset}", offset.toString())
      },
    );
    await NyStorage.store('recipes', response);
    return Recipes.fromJson(response.data);
  }

  Future fetchTestData() async {
    return await network(
      request: (request) => request.get("/endpoint-path"),
    );
  }
}
