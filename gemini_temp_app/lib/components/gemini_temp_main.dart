class GeminiTempMain extends ConsumerWidget {
  const GeminiTempMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const GeminiTempBg(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CommunityMaterialIcons.leaf_maple,
                    size: 100, color: Colors.white.withOpacity(0.75)),
                const GeminiTempDisplay(),
                const SizedBox(height: 24),
                const GeminiTempInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}