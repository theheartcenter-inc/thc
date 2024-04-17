import 'dart:io' show File, Directory, FileSystemEntity;

/// ```sh
///
/// # cd into the root repository folder, then:
/// dart run lib/utils/svg_parsing/_svg_paths.dart
///
/// ```
void main() async {
  Future<String> svgPathVariable(FileSystemEntity file) async {
    // triple-nested functions 😎
    String match(RegExp pattern, String input) => pattern.firstMatch(input)!.group(1)!;
    String camelCase(Match match) => match.group(1)!.toUpperCase();

    final svg = await File(file.path).readAsString();
    final svgPath = match(RegExp('d="([^"]*)"'), svg);
    final filename = match(RegExp(r'/([^/]*)\.svg'), file.path);
    final variableName = filename.replaceAllMapped(RegExp('_(.)'), camelCase);
    return "  static const $variableName = '''\n$svgPath''';";
  }

  final filepaths = Directory('lib/utils/svg_parsing/svg_files/').listSync();
  final pathVariables = await Future.wait([for (final file in filepaths) svgPathVariable(file)]);
  final newFile = await File('lib/utils/svg_parsing/svg_paths.dart').create();
  final contents = '''
/// generated file!

abstract final class SvgPaths {
${pathVariables.join('\n')}
}
''';
  final sink = newFile.openWrite()..write(contents);
  await sink.flush();
  await sink.close();
}
