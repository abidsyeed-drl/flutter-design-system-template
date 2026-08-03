import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedRadiusTokens {
  const GeneratedRadiusTokens();

  double md(context) {
    return ResponsiveValue<double>(
      mobile: 10,
      tablet: 12,
      desktop: 16,
    ).resolve(context).r;
  }


}
