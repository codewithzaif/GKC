import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../services/database_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  _MembersScreenState createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Member> _members = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    final members = await _databaseService.getMembers();
    
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  List<Member> get _filteredMembers {
    if (_searchQuery.isEmpty) {
      return _members;
    }
    
    return _members.where((member) {
      final name = member.name.toLowerCase();
      final houseNumber = member.houseNumber.toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || houseNumber.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or house number',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMembers,
                    child: _filteredMembers.isEmpty
                        ? _buildEmptyState()
                        : _buildMembersList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddMemberDialog(context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No members added yet'
                : 'No members match your search',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddMemberDialog(context),
              child: const Text('Add Member'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return ListView.builder(
      itemCount: _filteredMembers.length,
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: member.isOwner ? Colors.blue : Colors.orange,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(member.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('House: ${member.houseNumber}'),
                Row(
                  children: [
                    Text(member.isOwner ? 'Owner' : 'Tenant'),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: member.hasPaid ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        member.hasPaid ? 'Paid' : 'Unpaid',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    member.hasPaid ? Icons.check_circle : Icons.money_off,
                    color: member.hasPaid ? Colors.green : Colors.red,
                  ),
                  onPressed: () => _togglePaymentStatus(member),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditMemberDialog(context, member),
                ),
              ],
            ),
            onTap: () => _showMemberDetailsDialog(context, member),
            onLongPress: () => _showDeleteConfirmation(context, member),
          ),
        );
      },
    );
  }

  Future<void> _togglePaymentStatus(Member member) async {
    await _databaseService.updateMemberPaymentStatus(
      member.id,
      !member.hasPaid,
    );
    await _loadMembers();
  }

  Future<void> _showAddMemberDialog(BuildContext context) async {
    return _showMemberFormDialog(context, null);
  }

  Future<void> _showEditMemberDialog(BuildContext context, Member member) async {
    return _showMemberFormDialog(context, member);
  }

  Future<void> _showMemberFormDialog(BuildContext context, Member? existingMember) async {
    final _formKey = GlobalKey<FormState>();
    String name = existingMember?.name ?? '';
    String contactNumber = existingMember?.contactNumber ?? '';
    String email = existingMember?.email ?? '';
    String houseNumber = existingMember?.houseNumber ?? '';
    bool isOwner = existingMember?.isOwner ?? true;
    bool hasPaid = existingMember?.hasPaid ?? false;
    double latitude = existingMember?.latitude ?? 0.0;
    double longitude = existingMember?.longitude ?? 0.0;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingMember == null ? 'Add Member' : 'Edit Member'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: contactNumber,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      contactNumber = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: houseNumber,
                    decoration: const InputDecoration(
                      labelText: 'House Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter house number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      houseNumber = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: latitude.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter latitude';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      latitude = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: longitude.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter longitude';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      longitude = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Resident Type:'),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('Owner'),
                        selected: isOwner,
                        onSelected: (selected) {
                          setState(() {
                            isOwner = selected;
                          });
                        },
                        selectedColor: Colors.blue.shade200,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Tenant'),
                        selected: !isOwner,
                        onSelected: (selected) {
                          setState(() {
                            isOwner = !selected;
                          });
                        },
                        selectedColor: Colors.orange.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Payment Status:'),
                      const SizedBox(width: 16),
                      Switch(
                        value: hasPaid,
                        onChanged: (value) {
                          setState(() {
                            hasPaid = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      Text(
                        hasPaid ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                          color: hasPaid ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  final member = Member(
                    id: existingMember?.id ?? const Uuid().v4(),
                    name: name,
                    contactNumber: contactNumber,
                    email: email,
                    houseNumber: houseNumber,
                    isOwner: isOwner,
                    hasPaid: hasPaid,
                    latitude: latitude,
                    longitude: longitude,
                  );
                  
                  await _databaseService.saveMember(member);
                  await _loadMembers();
                  
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMemberDetailsDialog(BuildContext context, Member member) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(member.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('House Number: ${member.houseNumber}'),
              const SizedBox(height: 8),
              Text('Contact: ${member.contactNumber}'),
              const SizedBox(height: 8),
              Text('Email: ${member.email}'),
              const SizedBox(height: 8),
              Text('Type: ${member.isOwner ? 'Owner' : 'Tenant'}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Payment Status: '),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: member.hasPaid ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      member.hasPaid ? 'Paid' : 'Unpaid',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Location: ${member.latitude}, ${member.longitude}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(member.hasPaid ? 'Mark as Unpaid' : 'Mark as Paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: member.hasPaid ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await _databaseService.updateMemberPaymentStatus(
                  member.id,
                  !member.hasPaid,
                );
                await _loadMembers();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Member member) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Member'),
          content: Text('Are you sure you want to delete "${member.name}"?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                await _databaseService.deleteMember(member.id);
                await _loadMembers();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
} 