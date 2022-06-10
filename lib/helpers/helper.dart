import 'dart:math';

const List<int> sign = [-1, 1];

double doubleInRange(Random source, num start, num end) =>
    source.nextDouble() * (end - start) + start;

int getRandomSign(Random source) =>
    sign[source.nextInt(2)];

double roundDouble(double value, int places){
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
