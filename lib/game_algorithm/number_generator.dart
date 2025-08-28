import 'dart:math';


class NumberGenerator {
  final int randomMin;
  final int randomMax;
  late int firstValue = 0;
  late int secondValue = 0;
  late int total = 0;
  final randomGen = Random();

  NumberGenerator({required this.randomMin, required this.randomMax});

  Future<int> numberGenerator({int min = 0, int max = 100}) async {
    return min + randomGen.nextInt((max + 1) - min);
    ;
  }

  Future<void> random() async {
    firstValue = await numberGenerator(min: randomMin, max: randomMax);
    secondValue = await numberGenerator(min: randomMin, max: randomMax);
  }

  Future<void> randomForSub() async {
    firstValue = await numberGenerator(min: randomMin, max: randomMax);
    secondValue = await numberGenerator(min: randomMin, max: randomMax);
    if (secondValue > firstValue) {
      int temp1 = secondValue;
      int temp2 = firstValue;
      firstValue = temp1;
      secondValue = temp2;
    }
  }

  Future<void> randomAddTotal() async {
    int rand =
        await numberGenerator(min: randomMin, max: randomMax) +
        await numberGenerator(min: randomMin, max: randomMax);
    int notRand = firstValue + secondValue;
    List<int> listNumbers = [rand, notRand];
    int randomIndex = randomGen.nextInt(listNumbers.length);
    total = listNumbers[randomIndex];
  }

  Future<void> randomSubTotal() async {
    int valueA = await numberGenerator(min: randomMin, max: randomMax);
    int valueB = await numberGenerator(min: randomMin, max: randomMax);
    if (valueB > valueA) {
      int temp1 = valueB;
      int temp2 = valueA;
      valueA = temp1;
      valueB = temp2;
    }
    int rand = valueA - valueB;
    int notRand = firstValue - secondValue;
    List<int> listNumbers = [rand, notRand];
    int randomIndex = randomGen.nextInt(listNumbers.length);
    total = listNumbers[randomIndex];
  }
}
