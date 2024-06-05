import 'package:thc/the_good_stuff.dart';
import 'package:thc/utils/widgets/placeholders.dart';

class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const FunPlaceholder('change livestream schedule!', color: ThcColors.dullBlue),
    );
  }
}
