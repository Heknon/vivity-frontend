import 'dart:math';

const List<int> sign = [-1, 1];

double doubleInRange(Random source, num start, num end) =>
    source.nextDouble() * (end - start) + start;

int getRandomSign(Random source) =>
    sign[source.nextInt(2)];