import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_validators.dart';
import '../controllers/leads_controller.dart';
import '../domain/models/lead_model.dart';

class LeadsScreen extends GetView<LeadsController> {
  const LeadsScreen({Key? key}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case "Hot Lead":
        return Colors.redAccent;
      case "Appointment":
        return Colors.cyanAccent;
      case "Follow Up":
        return Colors.orangeAccent;
      case "Done":
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Just Now";
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final dateToCompare = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final difference = today.difference(dateToCompare).inDays;

      if (difference == 0) {
        return "Today";
      } else if (difference == 1) {
        return "Yesterday";
      } else if (difference < 7 && difference > 0) {
        return "$difference days ago";
      } else {
        final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return "${dateTime.day} ${months[dateTime.month - 1]}";
      }
    } catch (e) {
      return "Just Now";
    }
  }

  void _showAddLeadBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String newStatus = "Hot Lead";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Lead",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AppValidators.validateEmpty(value, fieldName: "Full Name"),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF151821),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        final emptyCheck = AppValidators.validateEmpty(value, fieldName: "Phone Number");
                        if (emptyCheck != null) return emptyCheck;
                        
                        final trimmed = value!.trim();
                        if (trimmed.length != 10) {
                          return "Enter a valid 10 digit phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF151821),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Lead Status",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["Hot Lead", "Appointment", "Follow Up", "Done"].map((status) {
                        final isSelected = newStatus == status;
                        final statusColor = _getStatusColor(status);

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              newStatus = status;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? statusColor.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? statusColor : Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? statusColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(() {
                        final isCreating = controller.isCreating.value;
                        return ElevatedButton(
                          onPressed: isCreating
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    final response = await controller.createLead(
                                      nameController.text.trim(),
                                      phoneController.text.trim(),
                                      newStatus,
                                    );
                                    if (context.mounted) {
                                      if (response.isSuccess) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(response.message.isNotEmpty ? response.message : "Lead created successfully."),
                                            backgroundColor: AppColors.primaryColor,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(response.message.isNotEmpty ? response.message : "Failed to create lead."),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.5),
                          ),
                          child: isCreating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Save Lead",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangeStatusBottomSheet(BuildContext context, LeadModel lead, int index) {
    String selectedStatus = lead.uiStatus;
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Change Lead Status",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isUpdating)
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusOption(
                            context,
                            "Hot Lead",
                            isSelected: selectedStatus == "Hot Lead",
                            isUpdating: isUpdating,
                            onTap: () async {
                              setState(() {
                                selectedStatus = "Hot Lead";
                                isUpdating = true;
                              });
                              final response = await controller.updateStatus(lead, "Hot Lead");
                              if (context.mounted) {
                                if (response.isSuccess) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Status updated to Hot Lead"),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    selectedStatus = lead.uiStatus;
                                    isUpdating = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Failed to update status"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusOption(
                            context,
                            "Appointment",
                            isSelected: selectedStatus == "Appointment",
                            isUpdating: isUpdating,
                            onTap: () async {
                              setState(() {
                                selectedStatus = "Appointment";
                                isUpdating = true;
                              });
                              final response = await controller.updateStatus(lead, "Appointment");
                              if (context.mounted) {
                                if (response.isSuccess) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Status updated to Appointment"),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    selectedStatus = lead.uiStatus;
                                    isUpdating = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Failed to update status"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusOption(
                            context,
                            "Follow Up",
                            isSelected: selectedStatus == "Follow Up",
                            isUpdating: isUpdating,
                            onTap: () async {
                              setState(() {
                                selectedStatus = "Follow Up";
                                isUpdating = true;
                              });
                              final response = await controller.updateStatus(lead, "Follow Up");
                              if (context.mounted) {
                                if (response.isSuccess) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Status updated to Follow Up"),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    selectedStatus = lead.uiStatus;
                                    isUpdating = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Failed to update status"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatusOption(
                            context,
                            "Done",
                            isSelected: selectedStatus == "Done",
                            isUpdating: isUpdating,
                            onTap: () async {
                              setState(() {
                                selectedStatus = "Done";
                                isUpdating = true;
                              });
                              final response = await controller.updateStatus(lead, "Done");
                              if (context.mounted) {
                                if (response.isSuccess) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Status updated to Done"),
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    selectedStatus = lead.uiStatus;
                                    isUpdating = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response.message.isNotEmpty ? response.message : "Failed to update status"),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String status, {
    required bool isSelected,
    required bool isUpdating,
    required VoidCallback onTap,
  }) {
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? statusColor.withOpacity(0.08) : const Color(0xFF151821),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? statusColor : Colors.white.withOpacity(0.04),
            width: 1.5,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? statusColor : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showEditLeadBottomSheet(BuildContext context, LeadModel lead, int index) {
    final nameEditController = TextEditingController(text: lead.fullName);
    final phoneEditController = TextEditingController(text: lead.phoneNumber);
    final formKey = GlobalKey<FormState>();
    String editStatus = lead.uiStatus;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Lead Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: isSaving ? null : () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameEditController,
                      enabled: !isSaving,
                      style: const TextStyle(color: Colors.white),
                      validator: (value) => AppValidators.validateEmpty(value, fieldName: "Full Name"),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF151821),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneEditController,
                      enabled: !isSaving,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        final emptyCheck = AppValidators.validateEmpty(value, fieldName: "Phone Number");
                        if (emptyCheck != null) return emptyCheck;
                        
                        final trimmed = value!.trim();
                        if (trimmed.length != 10) {
                          return "Enter a valid 10 digit phone number";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF151821),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Lead Status",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["Hot Lead", "Appointment", "Follow Up", "Done"].map((status) {
                        final isSelected = editStatus == status;
                        final statusColor = _getStatusColor(status);

                        return GestureDetector(
                          onTap: isSaving ? null : () {
                            setModalState(() {
                              editStatus = status;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? statusColor.withOpacity(0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? statusColor : Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: isSelected ? statusColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() {
                              isSaving = true;
                            });
                            final response = await controller.updateLead(
                              index,
                              nameEditController.text.trim(),
                              phoneEditController.text.trim(),
                              editStatus,
                            );
                            if (context.mounted) {
                              if (response.isSuccess) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response.message.isNotEmpty ? response.message : "Lead updated successfully!"),
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                );
                              } else {
                                setModalState(() {
                                  isSaving = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response.message.isNotEmpty ? response.message : "Failed to update lead"),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteLead(BuildContext context, LeadModel lead, int index) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F121A),
              title: const Text("Delete Lead", style: TextStyle(color: Colors.white)),
              content: Text(
                isDeleting ? "Deleting lead..." : "Are you sure you want to delete ${lead.fullName}?",
                style: const TextStyle(color: Colors.grey),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setState(() {
                            isDeleting = true;
                          });
                          final response = await controller.deleteLead(lead);
                          if (context.mounted) {
                            Navigator.pop(context);
                            if (response.isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response.message.isNotEmpty ? response.message : "${lead.fullName} deleted successfully"),
                                  backgroundColor: AppColors.primaryColor,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response.message.isNotEmpty ? response.message : "Failed to delete lead"),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B11),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 65,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          "LEAD HUB",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0F121A),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.person_add_alt_1, color: AppColors.primaryColor, size: 16),
                onPressed: () => _showAddLeadBottomSheet(context),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final totalLeads = controller.totalCount.value;
        final totalHot = controller.hotLeadCount.value;
        final totalAppt = controller.appointmentCount.value;
        final totalFollow = controller.followUpCount.value;
        final totalDone = controller.doneCount.value;

        final filteredLeads = controller.leads;

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F121A), Color(0xFF151924)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.12), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(child: _buildStatItem("Total", totalLeads, AppColors.primaryColor)),
                          Expanded(child: _buildStatItem("Hot Lead", totalHot, Colors.redAccent)),
                          Expanded(child: _buildStatItem("Appointment", totalAppt, Colors.cyanAccent)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: Colors.white.withOpacity(0.05), height: 1, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: _buildStatItem("Follow Up", totalFollow, Colors.orangeAccent)),
                            Expanded(child: _buildStatItem("Done", totalDone, Colors.greenAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search leads by name or phone...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF0F121A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ["All", "Hot Lead", "Appointment", "Follow Up", "Done"].map((filter) {
                    final isSelected = controller.selectedFilter.value == filter;
                    return GestureDetector(
                      onTap: () => controller.selectedFilter.value = filter,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryColor : const Color(0xFF0F121A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              controller.isLoading.value
                  ? Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    )
                  : filteredLeads.isEmpty
                      ? Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                "No leads found",
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = filteredLeads[index];
                            final statusColor = _getStatusColor(lead.uiStatus);
                            final originalIndex = controller.leads.indexOf(lead);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F121A),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.03)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: statusColor.withOpacity(0.1),
                                          child: Text(
                                            lead.fullName.isNotEmpty ? lead.fullName[0].toUpperCase() : 'L',
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lead.fullName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                lead.phoneNumber,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                                            ),
                                            child: Text(
                                              lead.uiStatus,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatDate(lead.createdAt),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.3),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.4), size: 20),
                                        color: const Color(0xFF0F121A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side: BorderSide(color: Colors.white.withOpacity(0.05)),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onSelected: (value) {
                                          if (value == 'status') {
                                            _showChangeStatusBottomSheet(context, lead, originalIndex);
                                          } else if (value == 'edit') {
                                            _showEditLeadBottomSheet(context, lead, originalIndex);
                                          } else if (value == 'delete') {
                                            _confirmDeleteLead(context, lead, originalIndex);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'status',
                                            child: Row(
                                              children: [
                                                Icon(Icons.change_circle_rounded, color: AppColors.primaryColor, size: 18),
                                                SizedBox(width: 8),
                                                Text("Change Status", style: TextStyle(color: Colors.white, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded, color: Colors.cyanAccent, size: 18),
                                                SizedBox(width: 8),
                                                Text("Edit Details", style: TextStyle(color: Colors.white, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 18),
                                                SizedBox(width: 8),
                                                Text("Delete Lead", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}
