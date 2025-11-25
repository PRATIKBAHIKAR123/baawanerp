import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final Color mlco_green = Color.fromRGBO(57, 71, 67, 1);
final Color baawan_yellow = Color.fromRGBO(254, 204, 0, 1);
final Color baawan_green = Color.fromRGBO(146, 192, 44, 1);

final Color baawan_blue = Color.fromRGBO(41, 153, 213, 1);
final Color baawan_red = Color.fromRGBO(228, 41, 36, 1);

Gradient mlcoGradient = LinearGradient(
  colors: [
    Color.fromRGBO(41, 153, 213, 1),
    baawan_green,
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

Gradient mlcoGradient2 = LinearGradient(
  colors: [baawan_green, Color.fromRGBO(41, 153, 213, 1)],
  begin: Alignment.topRight,
  end: Alignment.topLeft,
);

const Gradient mlcoGradient3 = LinearGradient(
  colors: [Color.fromRGBO(146, 192, 44, 1), Color.fromRGBO(41, 153, 213, 1)],
  begin: Alignment.topRight,
  end: Alignment.topLeft,
);

final Shader mlcoGradienttext = LinearGradient(
  colors: [Color.fromRGBO(146, 192, 44, 1), Color.fromRGBO(41, 153, 213, 1)],
  begin: Alignment.bottomRight,
  end: Alignment.topLeft,
).createShader(const Rect.fromLTWH(1, 2, 320.0, 80.0));

const Gradient announcementGradient = LinearGradient(
  colors: [
    Color.fromRGBO(131, 196, 76, 0.3),
    Color.fromRGBO(20, 156, 120, 0.2)
  ],
  begin: Alignment.bottomRight,
  end: Alignment.topLeft,
);

const Gradient inactivelinksgradient = LinearGradient(
  colors: [Color.fromRGBO(213, 213, 213, 1), Color.fromRGBO(213, 213, 213, 1)],
  begin: Alignment.bottomRight,
  end: Alignment.topLeft,
);

final TextStyle plus_jakarta24_w500 = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(0, 0, 0, 1),
  fontWeight: FontWeight.w500,
  fontSize: 24,
);

final TextStyle plus_jakarta18_w500 = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(255, 255, 255, 1),
  fontWeight: FontWeight.w500,
  fontSize: 18,
);

final TextStyle plus_jakarta14_w400 = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(255, 255, 255, 1),
  fontWeight: FontWeight.w400,
  fontSize: 14,
);

final TextStyle mlco_gradient_text2 = GoogleFonts.inter(
  fontWeight: FontWeight.w500,
  fontSize: 16,
  foreground: Paint()..shader = mlcoGradienttext,
);

final TextStyle mlco_gradient_text = GoogleFonts.plusJakartaSans(
  fontWeight: FontWeight.bold,
  fontSize: 16,
  foreground: Paint()..shader = mlcoGradienttext,
);

final TextStyle SpaceGrotesk14_w700 = GoogleFonts.spaceGrotesk(
  color: Color.fromRGBO(255, 255, 255, 1),
  fontWeight: FontWeight.w700,
  fontSize: 14,
);

final OutlineInputBorder inputBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(28),
    borderSide: BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));

final TextStyle plus_jakarta13_w600 = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(20, 156, 120, 1),
  fontWeight: FontWeight.w600,
  fontSize: 13,
);

final TextStyle announcementtextStyle = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(0, 0, 0, 1),
  fontWeight: FontWeight.w500,
  fontSize: 13,
);

final TextStyle inter400 = GoogleFonts.inter(
  color: Color.fromRGBO(129, 129, 129, 1),
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

final TextStyle inter600 = GoogleFonts.inter(
  color: Color.fromRGBO(35, 35, 35, 1),
  fontWeight: FontWeight.w600,
  fontSize: 13,
);

final TextStyle inter11400 = GoogleFonts.inter(
  color: Color.fromRGBO(129, 129, 129, 1),
  fontWeight: FontWeight.w400,
  fontSize: 11,
);

final TextStyle inter_13_500 = GoogleFonts.inter(
  color: Color.fromRGBO(0, 0, 0, 1),
  fontWeight: FontWeight.w500,
  fontSize: 13,
);

final TextStyle plus_jakarta12_w600 = GoogleFonts.plusJakartaSans(
  color: Color.fromRGBO(199, 199, 204, 1),
  fontWeight: FontWeight.w600,
  fontSize: 12,
);

final TextStyle plus_jakarta19_w600 = GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600,
    fontSize: 19,
    foreground: Paint()..shader = mlcoGradienttext);
