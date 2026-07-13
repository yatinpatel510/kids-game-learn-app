import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Change font here — applies everywhere ────────────────────────────────────
// Options: GoogleFonts.nunito, GoogleFonts.baloo2, GoogleFonts.fredoka,
//          GoogleFonts.comicNeue, GoogleFonts.roundedMplus1c, GoogleFonts.poppins
TextStyle _base(TextStyle s) => GoogleFonts.nunito(textStyle: s);

// ─────────────────────────────────────────────────────────────────────────────

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // Named constructors for common styles
  const AppText.title(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 26, fontWeight = FontWeight.w900;

  const AppText.heading(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 20, fontWeight = FontWeight.w900;

  const AppText.subheading(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 17, fontWeight = FontWeight.w800;

  const AppText.body(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 14, fontWeight = FontWeight.w600;

  const AppText.caption(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 11, fontWeight = FontWeight.w600;

  const AppText.label(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontSize = 13, fontWeight = FontWeight.w700;

  const AppText.bold(this.text, {super.key, this.fontSize = 14, this.color, this.textAlign, this.maxLines, this.overflow})
      : fontWeight = FontWeight.w800;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: _base(TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      )),
    );
  }
}
