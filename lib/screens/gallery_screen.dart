import 'package:flutter/material.dart';
import 'package:buddyapp/services/google_auth_service.dart';
import 'package:buddyapp/services/google_drive_service.dart';
import 'package:buddyapp/screens/gallery_job_photos_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String?>(
            valueListenable:
                GoogleAuthService.instance.driveAccessTokenNotifier,
            builder: (context, token, _) {
              final isConnected = token != null && token.isNotEmpty;

              if (!isConnected) {
                return _buildConnectDriveCard(context);
              }

              final driveToken = token ?? '';

              return FutureBuilder<List<Map<String, String>>>(
                future: GoogleDriveService(accessToken: driveToken)
                    .listWorkorderFolders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Failed to load gallery. Please try again.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.red),
                      ),
                    );
                  }

                  final jobs = snapshot.data ?? <Map<String, String>>[];

                  if (jobs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        'No uploaded jobs found in Google Drive yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Previously uploaded jobs',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        itemCount: jobs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final job = jobs[index];
                          final name = job['name'] ?? 'Unknown';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                'Workorder #$name',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Tap to view uploaded photos',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GalleryJobPhotosScreen(
                                      workorderNumber: name,
                                      driveAccessToken: driveToken,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectDriveCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect Google Drive',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'To view your previously uploaded jobs and photos, connect Google Drive.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                await GoogleAuthService.instance.signInForDrive();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Connect Drive',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
