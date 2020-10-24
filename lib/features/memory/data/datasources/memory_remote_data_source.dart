import 'package:dartz/dartz.dart';
import 'package:mood_manager/core/error/exceptions.dart';
import 'package:mood_manager/features/memory/data/models/memory_parse.dart';
import 'package:mood_manager/features/memory/domain/entities/memory.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

abstract class MemoryRemoteDataSource {
  Future<Memory> saveMemory(Memory memory);
}

class MemoryParseDataSource extends MemoryRemoteDataSource {
  @override
  Future<Memory> saveMemory(Memory memory) async {
    final ParseResponse response =
        await cast<MemoryParse>(memory).toParse().save();
    if (response.success) {
      return MemoryParse.from(response.results.first);
    } else {
      throw ServerException();
    }
  }
}
