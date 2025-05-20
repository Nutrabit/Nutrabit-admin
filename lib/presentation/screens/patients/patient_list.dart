import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/widgets/logout.dart';
import '../../providers/user_provider.dart';
import '../../../core/models/app_users.dart';
import '../../../core/utils/utils.dart';

class PatientList extends ConsumerStatefulWidget {
  const PatientList({super.key});
  
  @override
  ConsumerState<PatientList> createState() => _PatientListState();
}

class _PatientListState extends ConsumerState<PatientList> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final usersAsyncValue = query.isEmpty ? ref.watch(usersProvider) : ref.watch(searchUsersProvider(query));


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pacientes'),
        leading: const BackButton(),
        actions: [Logout()],
      ),
      
      body:
      Column(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchField(
              controller: _searchController,
              hintText: 'Buscar paciente...',
              onChanged: (value) {
                ref.refresh(searchUsersProvider(value));
                setState(() {});
              },
              onClear: () {
                _searchController.clear();
                ref.refresh(searchUsersProvider(''));
                setState(() {});
              },
            ),
          ),
          Expanded(
          child: usersAsyncValue.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (List<AppUser> users) {
              if (users.isEmpty) {
                return const Center(child: Text('No se encontraron pacientes'));
              }
              return UserList( users: users );
            },
            
          ),
          
          ),
        ],
      ),
      floatingActionButton: AddPatientButton(
        onPressed: () {
          context.push('/pacientes/alta');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class UserList extends StatelessWidget {
  final List<AppUser> users;

  const UserList({required this.users, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListItem(user: user,
          onTap: () {
            context.push('/pacientes/${user.id}');
          },
        );
      },
    );
  }
}

class UserListItem extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;

  const UserListItem({required this.user, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return 
    
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:Colors.white,
            border: Border.all(color: Color(0xFFDC607A)),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    user.profilePic.isNotEmpty
                        ? NetworkImage(user.profilePic)
                        : null,
                child:
                    user.profilePic.isEmpty
                        ? Icon(Icons.person, size: 28, color: Colors.white)
                        : null,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  "${user.name.capitalize()} ${user.lastname.capitalize()}",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),),
    );
  }
}



class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Buscar...'
  });

  @override
  Widget build(BuildContext context) {
    final query = controller.text;
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: BorderSide(color: Color(0xFFDA958D), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: BorderSide(color: Color(0xFFDA958D), width: 2),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(27),
          borderSide: BorderSide(color: Color(0xFFDA958D)),
        ),
      ),
      onChanged: onChanged,
    );
  }
}


class AddPatientButton extends StatelessWidget {
  final VoidCallback onPressed;
  const AddPatientButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Color(0xFFD7F9DE),
        foregroundColor: Colors.black,
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(Icons.add),
      );
  }
}