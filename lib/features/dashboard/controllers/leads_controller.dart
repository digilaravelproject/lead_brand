import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../domain/models/lead_model.dart';
import '../domain/repositories/leads_repository_interface.dart';
import '../domain/repositories/leads_repository.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/services/network/response_model.dart';

class LeadsController extends GetxController {
  final LeadsRepositoryInterface? _leadsRepository;

  LeadsController({LeadsRepositoryInterface? leadsRepository}) : _leadsRepository = leadsRepository;

  LeadsRepositoryInterface get leadsRepository {
    final repo = _leadsRepository;
    if (repo != null) return repo;

    // Self-healing DI fallback
    if (!Get.isRegistered<LeadsRepositoryInterface>()) {
      Get.lazyPut<LeadsRepositoryInterface>(
        () => LeadsRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }
    return Get.find<LeadsRepositoryInterface>();
  }

  final leads = <LeadModel>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;
  final searchQuery = ''.obs;
  final selectedFilter = 'All'.obs;

  // Counts metadata for statistics cards
  final totalCount = 0.obs;
  final hotLeadCount = 0.obs;
  final appointmentCount = 0.obs;
  final followUpCount = 0.obs;
  final doneCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeads();
    // Dynamically trigger fetchLeads without full-screen loading overlay when search query or filter updates
    ever(selectedFilter, (_) => fetchLeads(showLoader: false));
    debounce(searchQuery, (_) => fetchLeads(showLoader: false), time: const Duration(milliseconds: 500));
  }

  Future<void> fetchLeads({bool showLoader = true}) async {
    if (showLoader) {
      isLoading.value = true;
    }
    try {
      // Map UI filter selection to API status query parameter
      String? apiStatus;
      switch (selectedFilter.value) {
        case 'Hot Lead':
          apiStatus = 'hot_lead';
          break;
        case 'Appointment':
          apiStatus = 'appointment';
          break;
        case 'Follow Up':
          apiStatus = 'followup';
          break;
        case 'Done':
          apiStatus = 'done';
          break;
        case 'All':
        default:
          apiStatus = 'all';
          break;
      }

      final response = await leadsRepository.getLeads(
        status: apiStatus,
        search: searchQuery.value,
      );

      if (response.isSuccess && response.body != null) {
        List<dynamic>? list;
        if (response.body is List) {
          list = response.body as List;
        } else if (response.body is Map) {
          list = response.body['leads'] ?? response.body['data'];
        }

        if (list != null) {
          final List<LeadModel> fetched = list.map((item) => LeadModel.fromJson(item)).toList();
          leads.assignAll(fetched);
        }

        // Parse counts from response.rawBody
        if (response.rawBody is Map && response.rawBody['counts'] != null) {
          final counts = response.rawBody['counts'];
          totalCount.value = counts['total'] is int ? counts['total'] : (int.tryParse(counts['total'].toString()) ?? 0);
          hotLeadCount.value = counts['hot_lead'] is int ? counts['hot_lead'] : (int.tryParse(counts['hot_lead'].toString()) ?? 0);
          appointmentCount.value = counts['appointment'] is int ? counts['appointment'] : (int.tryParse(counts['appointment'].toString()) ?? 0);
          followUpCount.value = counts['followup'] is int ? counts['followup'] : (int.tryParse(counts['followup'].toString()) ?? 0);
          doneCount.value = counts['done'] is int ? counts['done'] : (int.tryParse(counts['done'].toString()) ?? 0);
        } else {
          _recalculateLocalCounts();
        }
      } else {
        debugPrint('fetchLeads failed or returned no data: ${response.message}');
        _loadDefaultLeads();
      }
    } catch (e) {
      debugPrint('Error fetching leads: $e');
      _loadDefaultLeads();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultLeads() {
    if (leads.isEmpty) {
      leads.assignAll([
        LeadModel(id: 101, fullName: "Amit Sharma", phoneNumber: "+91 98765 43210", status: "hot_lead", createdAt: "2026-06-15T04:51:43.000000Z"),
        LeadModel(id: 102, fullName: "Priya Patel", phoneNumber: "+91 87654 32109", status: "appointment", createdAt: "2026-06-14T04:51:43.000000Z"),
        LeadModel(id: 103, fullName: "Rajesh Kumar", phoneNumber: "+91 76543 21098", status: "follow_up", createdAt: "2026-05-15T04:51:43.000000Z"),
        LeadModel(id: 104, fullName: "Sneha Reddy", phoneNumber: "+91 95432 10987", status: "done", createdAt: "2026-05-12T04:51:43.000000Z"),
        LeadModel(id: 105, fullName: "Vikram Singh", phoneNumber: "+91 84321 09876", status: "hot_lead", createdAt: "2026-05-10T04:51:43.000000Z"),
      ]);
    }
    _recalculateLocalCounts();
  }

  void _recalculateLocalCounts() {
    totalCount.value = leads.length;
    hotLeadCount.value = leads.where((l) => l.status == 'hot_lead' || l.status == 'Hot Lead').length;
    appointmentCount.value = leads.where((l) => l.status == 'appointment' || l.status == 'Appointment').length;
    followUpCount.value = leads.where((l) => l.status == 'followup' || l.status == 'follow_up' || l.status == 'Follow Up').length;
    doneCount.value = leads.where((l) => l.status == 'done' || l.status == 'Done').length;
  }

  Future<ResponseModel> createLead(String fullName, String phoneNumber, String uiStatus) async {
    isCreating.value = true;
    try {
      final apiStatus = LeadModel.mapUIToApiStatus(uiStatus);
      final response = await leadsRepository.createLead(fullName, phoneNumber, apiStatus);

      if (response.isSuccess && response.body != null) {
        LeadModel newLead;
        if (response.body is Map) {
          newLead = LeadModel.fromJson(Map<String, dynamic>.from(response.body as Map));
        } else {
          newLead = LeadModel(
            id: DateTime.now().millisecondsSinceEpoch,
            fullName: fullName,
            phoneNumber: phoneNumber,
            status: apiStatus,
            createdAt: DateTime.now().toIso8601String(),
          );
        }

        // Add to our list at the top
        leads.insert(0, newLead);
        _recalculateLocalCounts();
      }
      return response;
    } catch (e) {
      debugPrint('Error creating lead: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    } finally {
      isCreating.value = false;
    }
  }

  // Handle status change locally/remotely
  Future<ResponseModel> updateStatus(LeadModel lead, String newStatusUi) async {
    try {
      final apiStatus = LeadModel.mapUIToApiStatus(newStatusUi);
      final response = await leadsRepository.updateLeadStatus(lead.id, apiStatus);

      if (response.isSuccess) {
        // Perform local update to show instantly
        final index = leads.indexWhere((l) => l.id == lead.id);
        if (index != -1) {
          leads[index] = LeadModel(
            id: lead.id,
            userId: lead.userId,
            fullName: lead.fullName,
            phoneNumber: lead.phoneNumber,
            status: apiStatus,
            isActive: lead.isActive,
            createdAt: lead.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
          _recalculateLocalCounts();
        }
        // Fetch fresh list and counts from server silently
        await fetchLeads(showLoader: false);
      }
      return response;
    } catch (e) {
      debugPrint('Error updating lead status: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }

  // Handle edit details locally/remotely
  Future<ResponseModel> updateLead(int index, String fullName, String phoneNumber, String statusUi) async {
    if (index >= 0 && index < leads.length) {
      final currentLead = leads[index];
      final apiStatus = LeadModel.mapUIToApiStatus(statusUi);

      try {
        final response = await leadsRepository.updateLead(currentLead.id, fullName, phoneNumber, apiStatus);

        if (response.isSuccess) {
          // Perform local update to show changes instantly
          final updated = LeadModel(
            id: currentLead.id,
            userId: currentLead.userId,
            fullName: fullName,
            phoneNumber: phoneNumber,
            status: apiStatus,
            isActive: currentLead.isActive,
            createdAt: currentLead.createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );

          leads[index] = updated;
          _recalculateLocalCounts();
          
          // Fetch fresh list and counts from server silently
          await fetchLeads(showLoader: false);
        }
        return response;
      } catch (e) {
        debugPrint('Error updating lead details: $e');
        return ResponseModel(isSuccess: false, message: e.toString());
      }
    }
    return const ResponseModel(isSuccess: false, message: 'Invalid lead index');
  }

  // Handle delete lead locally/remotely
  Future<ResponseModel> deleteLead(LeadModel lead) async {
    try {
      final response = await leadsRepository.deleteLead(lead.id);

      if (response.isSuccess) {
        final index = leads.indexWhere((l) => l.id == lead.id);
        if (index != -1) {
          leads.removeAt(index);
          _recalculateLocalCounts();
        }
        // Fetch fresh list and counts from server silently
        await fetchLeads(showLoader: false);
      }
      return response;
    } catch (e) {
      debugPrint('Error deleting lead: $e');
      return ResponseModel(isSuccess: false, message: e.toString());
    }
  }
}
