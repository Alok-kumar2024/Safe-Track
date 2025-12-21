import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/profile_provider.dart';
import '../model/emergency_contact.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ProfileProvider>().contacts;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(context),

              Expanded(
                child: contacts.isEmpty
                    ? _EmptyContacts()
                    : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: contacts.length,
                  itemBuilder: (_, index) {
                    return _ContactCard(
                      contact: contacts[index],
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9333EA),
        onPressed: () => _openAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 12),
          const Text(
            'Emergency Contacts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static void _openAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ContactDialog(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final int index;

  const _ContactCard({
    required this.contact,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFF3E8FF),
            child: const Icon(Icons.person, color: Color(0xFF9333EA)),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  contact.phone,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => _ContactDialog(
                  index: index,
                  contact: contact,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => provider.deleteContact(index),
          ),
        ],
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final int? index;

  const _ContactDialog({this.contact, this.index});

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.contact?.name ?? '');
    phoneCtrl = TextEditingController(text: widget.contact?.phone ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final contact = EmergencyContact(
              name: nameCtrl.text.trim(),
              phone: phoneCtrl.text.trim(),
            );

            if (widget.index == null) {
              provider.addContact(contact);
            } else {
              provider.updateContact(widget.index!, contact);
            }

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
class _EmptyContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No emergency contacts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Add trusted contacts for emergencies',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

