import 'dart:math';

generateRandomNumber() {
  var range = Random();
  for (var i = 0; i < 10; i++) {
    return range.nextInt(10000);
  }
}