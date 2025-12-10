import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final double matchRate;
  final int commonMoviesCount;

  const UserCard({
    Key? key,
    required this.user,
    required this.matchRate,
    required this.commonMoviesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Photo de profil
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Icon(Icons.person, size: 30)
                  : null,
            ),
            SizedBox(width: 16),
            // Informations utilisateur
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${user.age} ans',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  // Barre de matching
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Matching: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${matchRate.toStringAsFixed(1)}%'),
                        ],
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: matchRate / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getMatchColor(matchRate),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '$commonMoviesCount films en commun',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Indicateur de matching
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getMatchColor(matchRate),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${matchRate.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.blue;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }
}