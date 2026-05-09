import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Abdialog {
  void showDialog(String content, bool type) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: (type ? Colors.green : Colors.red).withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Decorative Gradient Section
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: type ? Colors.green[50] : Colors.red[50],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (type ? Colors.green : Colors.red)
                              .withOpacity(0.2),
                          blurRadius: 15,
                        )
                      ],
                    ),
                    child: Icon(
                      type ? Icons.check_rounded : Icons.close_rounded,
                      size: 44,
                      color: type ? Colors.green : Colors.red,
                    )
                        .animate()
                        .scale(duration: 400.ms, curve: Curves.easeOutCirc)
                        .rotate(begin: -0.2, end: 0, duration: 400.ms),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  children: [
                    Text(
                      type ? 'Success' : 'Something went wrong',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Styled Button
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: type ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (type ? Colors.green : Colors.red)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack).fadeIn(),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}
