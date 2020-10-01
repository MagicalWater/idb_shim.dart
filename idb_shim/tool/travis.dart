import 'package:process_run/shell.dart';

Future main() async {
  var shell = Shell();

  await shell.run('''

  dartanalyzer --fatal-warnings --fatal-infos .
  dartfmt -n --set-exit-if-changed example lib test tool

  pub run test -p vm -j 1
  pub run test -p chrome -j 1
  pub run test -p firefox -j 1
  
  # Currently running as 2 commands
  pub run build_runner test -- -p chrome -j 1 test/web
  pub run build_runner test -- -p chrome -j 1 test/multiplatform
  
  # test dartdevc support
  pub run build_runner build example -o example:build/example_debug
  pub run build_runner build -r example -o example:build/example_release

  ''');
}
