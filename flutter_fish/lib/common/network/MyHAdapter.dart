import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_fish/common/core/HInterface.dart';
import 'package:flutter_fish/common/core/HttpUtils.dart';
import 'package:flutter_fish/common/core/RequestCtx.dart';

class MyAdapter implements HAdapter{

  Dio _dio;
  MyAdapter() {
    _dio = new Dio();
  }

  @override
  Future<Response<dynamic>> request(RequestCtx ctx) async {

    Future<Response<dynamic>> response;

    _dio.options = new BaseOptions(
        connectTimeout: ctx.timeout == null ? HConstants.timeout : ctx.timeout,
        receiveTimeout: ctx.timeout == null ? HConstants.timeout : ctx.timeout,
        headers: ctx.headerMap==null?{HttpHeaders.userAgentHeader: "HAdapter"}:ctx.headerMap,
        contentType: ctx.contentType == null ? ContentType.json : ctx.contentType,
        responseType: ctx.responseType == null ? ResponseType.json : ctx.responseType,
        validateStatus: (status) {
          return status >= 200 && status < 300 || status == 304;
        }
    );

    if (ctx.transformer != null) {
      _dio.transformer = ctx.transformer;
    }

    if (ctx.interceptors != null && ctx.interceptors.isNotEmpty) {
      for (var value in ctx.interceptors) {
        _dio.interceptors.add(value);
      }
    }

    String url = HttpUtils.get().getAssembleUrl(ctx.url, ctx.paramMap);

    switch (ctx.method) {
      case "get":
        response = _dio.get(url);
        break;
      case "post":
        response = _dio.post(url, data: ctx.bodyMap);
        break;
      default:
        response = _dio.get(url);
    }

    return response;
  }
}