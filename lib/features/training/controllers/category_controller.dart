import 'package:get/get.dart';
import '../domain/models/category_model.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../../../core/utils/custom_snackbar.dart';

class CategoryController extends GetxController {
  final GetCategoriesUseCase getCategoriesUseCase;

  CategoryController({required this.getCategoriesUseCase});

  final categories = <TrainingCategoryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final response = await getCategoriesUseCase.execute();
      if (response.isSuccess && response.body != null) {
        final bodyData = response.body;
        List<dynamic>? dataList;
        if (bodyData is List) {
          dataList = bodyData;
        } else if (bodyData is Map && bodyData['data'] is List) {
          dataList = bodyData['data'];
        }

        if (dataList != null) {
          categories.assignAll(
            dataList.map((json) => TrainingCategoryModel.fromJson(json)).toList(),
          );
        }
      } else {
        CustomSnackbar.showError(response.message);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load training categories.');
    } finally {
      isLoading.value = false;
    }
  }
}
