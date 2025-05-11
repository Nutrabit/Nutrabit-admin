import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/widgets/logout.dart';
import '../../providers/user_provider.dart';
import '../../../core/models/app_users.dart';

class PatientList extends ConsumerWidget {
  const PatientList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Pacientes'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              context.push('/pacientes/alta');
            },
          ),
          Logout(),
        ],
      ),
      body: usersAsyncValue.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (List<AppUser> users) {
          return UserList(users: users);
        },
      ),
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
        return UserListItem(user: user);
      },
    );
  }
}

class UserListItem extends StatelessWidget {
  final AppUser user;

  const UserListItem({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:Colors.white,
          border: Border.all(color: Color(0xFFDC607A)),
          borderRadius: BorderRadius.circular(8),
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
                "${user.name} ${user.lastname}",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
