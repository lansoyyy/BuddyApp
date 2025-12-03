import 'package:flutter/material.dart';
import 'package:buddyapp/services/google_drive_service.dart';

class GalleryJobPhotosScreen extends StatelessWidget {
  final String workorderNumber;
  final String driveAccessToken;

  const GalleryJobPhotosScreen({
    super.key,
    required this.workorderNumber,
    required this.driveAccessToken,
  });

  @override
  Widget build(BuildContext context) {
    final driveService = GoogleDriveService(accessToken: driveAccessToken);

    return Scaffold(
      appBar: AppBar(
        title: Text('Photos - $workorderNumber'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: driveService.listPhotosByWorkorderNumber(workorderNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to load photos for this workorder.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final photos = snapshot.data ?? <Map<String, dynamic>>[];

          if (photos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No photos found for this workorder yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final name = photo['name'] as String? ?? '';
              final thumb = photo['thumbnailLink'] as String?;
              final appProps =
                  photo['appProperties'] as Map<String, dynamic>? ?? {};
              final stage = appProps['processStage'] as String?;
              final component = appProps['component'] as String?;

              return InkWell(
                onTap: () {
                  if (thumb != null && thumb.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FullScreenPhotoScreen(
                          imageUrl: thumb,
                          title: name.isNotEmpty ? name : workorderNumber,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: thumb == null || thumb.isEmpty
                              ? Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                )
                              : Image.network(
                                  thumb,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (component != null && component.isNotEmpty)
                              Text(
                                component,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (stage != null && stage.isNotEmpty)
                              Text(
                                'Stage: $stage',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FullScreenPhotoScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _FullScreenPhotoScreen({
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
    );
  }
}
