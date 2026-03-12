import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pay_n_say/core/theme/app_theme.dart';

class OcrScanPage extends StatelessWidget {
  const OcrScanPage({super.key});

  Future<XFile?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return picker.pickImage(source: source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('영수증 스캔'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── 아이콘 영역 ────────────────────────────────
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: AppTheme.headerGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '영수증 스캔',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '카메라로 촬영하거나 갤러리에서\n이미지를 선택해 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),

            const Spacer(flex: 2),

            // ── 버튼 영역 ──────────────────────────────────
            _ScanButton(
              icon: Icons.camera_alt_rounded,
              label: '카메라로 촬영하기',
              isPrimary: true,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final image = await _pickImage(ImageSource.camera);
                if (image == null) return;
                messenger.showSnackBar(SnackBar(
                  content: Text('선택된 파일: ${image.name}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ));
              },
            ),
            const SizedBox(height: 12),
            _ScanButton(
              icon: Icons.photo_library_rounded,
              label: '갤러리에서 선택하기',
              isPrimary: false,
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final image = await _pickImage(ImageSource.gallery);
                if (image == null) return;
                messenger.showSnackBar(SnackBar(
                  content: Text('선택된 파일: ${image.name}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ));
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _ScanButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.accent, width: 1.5),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
