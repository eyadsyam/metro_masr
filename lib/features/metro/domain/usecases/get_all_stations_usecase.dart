import '../../domain/entities/station.dart';
import '../../domain/repositories/metro_repository.dart';

class GetAllStationsUseCase {
  final IMetroRepository repository;

  GetAllStationsUseCase(this.repository);

  Future<List<Station>> call() async {
    return await repository.getAllStations();
  }
}
