// Copyright 2016 Google Inc.
// Licensed under the Apache License, Version 2.0 (the "License")
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

const _RELEASES_URL =
    'https://api.github.com/repos/l7ssha/dart-sqlite/releases';

Future main(List<String> args) async {
  final deps = loadYaml(new File('pubspec.yaml').readAsStringSync());
  final version = deps['version'];
  print('Setting up version $version');

  final releasesBody = await http.read(_RELEASES_URL).catchError((e, _) {
    print('Unable to list releases: $e');
    exit(314);
  });
  final releases = jsonDecode(releasesBody);

  final Map<String, dynamic> release = releases.firstWhere(
      (release) => release['tag_name'] == 'v$version',
      orElse: () => null);
  if (release == null) {
    print('Unknown release: $version');
    exit(314);
  }

  final assetNames = ['libdart_sqlite.so', 'libdart_sqlite.dylib'];
  await Future.forEach(assetNames, (assetName) async {
    final libUrl = release['assets'].firstWhere(
        (asset) => asset['name'] == assetName)['browser_download_url'];
    final libFile = path.join('lib', 'src', assetName);
    await http.readBytes(libUrl).catchError((e, _) {
      print('Could not download library file: $e');
      exit(314);
    }).then((bytes) => new File(libFile).writeAsBytesSync(bytes));
    print('Installed $assetName');
  });
  print('Library setup complete');
}
