import 'dart:io';
import 'dart:isolate';

import 'package:biedronka_tests/algorithm_factory/unprocessed_algorithm.dart';

import '../model/recipe_full.dart';

Future<TimeAndMemoryResult> timeAndMemoryComplexity(UnprocessedAlgorithm unprocessedAlgorithm,  List<RecipeFull> history,Set<int> input, DateTime day) async {
  final receivePort = ReceivePort();
  try {
    await Isolate.spawn(
      _isolateEntryPoint,
      _IsolateMessage(unprocessedAlgorithm,history,input,day, receivePort.sendPort),
    );
    return await receivePort.first as TimeAndMemoryResult;
  } finally {
    receivePort.close();
  }
}

class _IsolateMessage {
  final UnprocessedAlgorithm unprocessedAlgorithm;
  final List<RecipeFull> history;
  final Set<int> input;
  final DateTime day;
  final SendPort sendPort;

  _IsolateMessage(this.unprocessedAlgorithm, this.history, this.input, this.day, this.sendPort);
}

class TimeAndMemoryResult {
  final int time;
  final int memory;
  TimeAndMemoryResult(this.time, this.memory);
}

void _isolateEntryPoint(_IsolateMessage message) {
  try {
    final stopwatch = Stopwatch()..start();
    int beforeMemory = ProcessInfo.currentRss;

    var processedAlgorithm = message.unprocessedAlgorithm.preprocess(message.history);
    processedAlgorithm.calculate(message.input, message.day);

    stopwatch.stop();
    int afterMemory = ProcessInfo.currentRss;
    message.sendPort.send(TimeAndMemoryResult(stopwatch.elapsedMilliseconds, afterMemory - beforeMemory));
  } catch (e) {
    message.sendPort.send(e);
  }
}
