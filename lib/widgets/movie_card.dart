import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const MovieCard({
    Key? key,
    required this.movie,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affiche du film
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: movie.posterPath != null
                  ? Image.network(
                movie.posterPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderIcon();
                },
              )
                  : _buildPlaceholderIcon(),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('${movie.voteAverage.toStringAsFixed(1)}/10'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text('${movie.releaseDate.year}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (movie.isFromAdmin)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Admin',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.movie,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}