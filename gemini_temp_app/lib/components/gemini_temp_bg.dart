class GeminiTempBg extends StatelessWidget {
  const GeminiTempBg({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.purple,
        Colors.deepPurple,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    );
  }
}