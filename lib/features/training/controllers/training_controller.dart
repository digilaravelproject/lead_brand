import 'package:get/get.dart';
import '../domain/models/training_model.dart';
import '../domain/usecases/get_trainings_usecase.dart';
import '../domain/usecases/get_training_details_usecase.dart';
import '../domain/usecases/search_trainings_usecase.dart';
import '../../../core/utils/custom_snackbar.dart';

class TrainingController extends GetxController {
  final GetTrainingsUseCase getTrainingsUseCase;
  final GetTrainingDetailsUseCase getTrainingDetailsUseCase;
  final SearchTrainingsUseCase searchTrainingsUseCase;

  TrainingController({
    required this.getTrainingsUseCase,
    required this.getTrainingDetailsUseCase,
    required this.searchTrainingsUseCase,
  });

  final pdfs = <TrainingModel>[].obs;
  final isPdfsLoading = false.obs;
  final videos = <TrainingModel>[].obs;
  final isVideosLoading = false.obs;
  final selectedTraining = Rxn<TrainingModel>();
  final isDetailsLoading = false.obs;

  Future<void> fetchPdfTrainings({String? categoryId}) async {
    isPdfsLoading.value = true;
    try {
      final response = await getTrainingsUseCase.execute(
        type: 'pdf',
        categoryId: categoryId,
      );
      if (response.isSuccess && response.body != null) {
        final bodyData = response.body;
        List<dynamic>? dataList;
        if (bodyData is List) {
          dataList = bodyData;
        } else if (bodyData is Map && bodyData['data'] is List) {
          dataList = bodyData['data'];
        }

        if (dataList != null) {
          pdfs.assignAll(
            dataList.map((json) => TrainingModel.fromJson(json)).toList(),
          );
        } else {
          pdfs.clear();
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load training documents.');
    } finally {
      isPdfsLoading.value = false;
    }
  }

  Future<void> fetchVideoTrainings({String? categoryId}) async {
    isVideosLoading.value = true;
    try {
      final response = await getTrainingsUseCase.execute(
        type: 'video',
        categoryId: categoryId,
      );
      if (response.isSuccess && response.body != null) {
        final bodyData = response.body;
        List<dynamic>? dataList;
        if (bodyData is List) {
          dataList = bodyData;
        } else if (bodyData is Map && bodyData['data'] is List) {
          dataList = bodyData['data'];
        }

        if (dataList != null) {
          videos.assignAll(
            dataList.map((json) => TrainingModel.fromJson(json)).toList(),
          );
        } else {
          videos.clear();
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load training videos.');
    } finally {
      isVideosLoading.value = false;
    }
  }

  Future<void> fetchTrainingDetails(int id) async {
    isDetailsLoading.value = true;
    selectedTraining.value = null;
    try {
      final response = await getTrainingDetailsUseCase.execute(id);
      if (response.isSuccess && response.body != null) {
        final data = response.body;
        if (data is Map<String, dynamic>) {
          selectedTraining.value = TrainingModel.fromJson(data);
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load training details.');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> searchPdfTrainings(String query) async {
    try {
      final response = await searchTrainingsUseCase.execute(query: query, type: 'pdf');
      if (response.isSuccess && response.body != null) {
        final bodyData = response.body;
        List<dynamic>? dataList;
        if (bodyData is List) {
          dataList = bodyData;
        } else if (bodyData is Map && bodyData['data'] is List) {
          dataList = bodyData['data'];
        }

        if (dataList != null) {
          pdfs.assignAll(
            dataList.map((json) => TrainingModel.fromJson(json)).toList(),
          );
        } else {
          pdfs.clear();
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Search failed.');
    }
  }

  Future<void> searchVideoTrainings(String query) async {
    try {
      final response = await searchTrainingsUseCase.execute(query: query, type: 'video');
      if (response.isSuccess && response.body != null) {
        final bodyData = response.body;
        List<dynamic>? dataList;
        if (bodyData is List) {
          dataList = bodyData;
        } else if (bodyData is Map && bodyData['data'] is List) {
          dataList = bodyData['data'];
        }

        if (dataList != null) {
          videos.assignAll(
            dataList.map((json) => TrainingModel.fromJson(json)).toList(),
          );
        } else {
          videos.clear();
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Search failed.');
    }
  }
}
