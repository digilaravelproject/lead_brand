import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Lead {
  final String name;
  final String phone;
  final String status; // 'Hot Lead', 'Appointment', 'Follow Up', 'Done'
  final String date;

  Lead({
    required this.name,
    required this.phone,
    required this.status,
    required this.date,
  });
}

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({Key? key}) : super(key: key);

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final List<Lead> _leads = [
    Lead(name: "Amit Sharma", phone: "+91 98765 43210", status: "Hot Lead", date: "Today"),
    Lead(name: "Priya Patel", phone: "+91 87654 32109", status: "Appointment", date: "Yesterday"),
    Lead(name: "Rajesh Kumar", phone: "+91 76543 21098", status: "Follow Up", date: "15 May"),
    Lead(name: "Sneha Reddy", phone: "+91 95432 10987", status: "Done", date: "12 May"),
    Lead(name: "Vikram Singh", phone: "+91 84321 09876", status: "Hot Lead", date: "10 May"),
  ];

  String _searchQuery = "";
  String _selectedFilter = "All"; // 'All', 'Hot Lead', 'Appointment', 'Follow Up', 'Done'

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _newStatus = "Hot Lead";

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

  void _addLead() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _leads.insert(
        0,
        Lead(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          status: _newStatus,
          date: "Just Now",
        ),
      );
    });

    _nameController.clear();
    _phoneController.clear();
    _newStatus = "Hot Lead";
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Lead added successfully!"),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _showAddLeadBottomSheet() {
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
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF151821),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF151821),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                      final isSelected = _newStatus == status;
                      final statusColor = _getStatusColor(status);

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            _newStatus = status;
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
                      onPressed: _addLead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Lead",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangeStatusBottomSheet(Lead lead, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F121A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Change Lead Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildStatusOption(context, "Hot Lead", lead, index)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusOption(context, "Appointment", lead, index)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatusOption(context, "Follow Up", lead, index)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatusOption(context, "Done", lead, index)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(BuildContext context, String status, Lead lead, int index) {
    final isSelected = lead.status == status;
    final statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () {
        setState(() {
          final updatedLead = Lead(
            name: lead.name,
            phone: lead.phone,
            status: status,
            date: lead.date,
          );
          _leads[index] = updatedLead;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Status updated to $status"),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      },
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

  void _showEditLeadBottomSheet(Lead lead, int index) {
    final nameEditController = TextEditingController(text: lead.name);
    final phoneEditController = TextEditingController(text: lead.phone);
    String editStatus = lead.status;

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
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameEditController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF151821),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneEditController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF151821),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
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
                        onTap: () {
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
                      onPressed: () {
                        if (nameEditController.text.trim().isEmpty || phoneEditController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _leads[index] = Lead(
                            name: nameEditController.text.trim(),
                            phone: phoneEditController.text.trim(),
                            status: editStatus,
                            date: lead.date,
                          );
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Lead updated successfully!"),
                            backgroundColor: AppColors.primaryColor,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteLead(Lead lead, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F121A),
          title: const Text("Delete Lead", style: TextStyle(color: Colors.white)),
          content: Text("Are you sure you want to delete ${lead.name}?", style: const TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _leads.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${lead.name} deleted"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter and search leads
    final filteredLeads = _leads.where((lead) {
      final matchesSearch = lead.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lead.phone.contains(_searchQuery);
      final matchesFilter = _selectedFilter == "All" || lead.status == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    final totalHot = _leads.where((l) => l.status == "Hot Lead").length;
    final totalAppt = _leads.where((l) => l.status == "Appointment").length;
    final totalFollow = _leads.where((l) => l.status == "Follow Up").length;
    final totalDone = _leads.where((l) => l.status == "Done").length;

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
                onPressed: _showAddLeadBottomSheet,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Header Stats Card
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
                      Expanded(child: _buildStatItem("Total", _leads.length, AppColors.primaryColor)),
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

          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
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

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ["All", "Hot Lead", "Appointment", "Follow Up", "Done"].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
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

          // Leads List
          filteredLeads.isEmpty
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
                    final statusColor = _getStatusColor(lead.status);
                    final originalIndex = _leads.indexOf(lead);

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
                                    lead.name.isNotEmpty ? lead.name[0].toUpperCase() : 'L',
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
                                        lead.name,
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
                                        lead.phone,
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
                                      lead.status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lead.date,
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
                                     _showChangeStatusBottomSheet(lead, originalIndex);
                                   } else if (value == 'edit') {
                                     _showEditLeadBottomSheet(lead, originalIndex);
                                   } else if (value == 'delete') {
                                     _confirmDeleteLead(lead, originalIndex);
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
      ),
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
