import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/library/src/all_videos.dart';
import 'package:thc/home/library/src/video_card.dart';
import 'package:thc/the_good_stuff.dart';

class VideoLibrary extends HookWidget {
  const VideoLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final category = useState('All');
    final search = useState('');

    final (:videos, :categories) = ThcVideos.of(context, category.value, search.value);

    if (videos == null) return const Center(child: CircularProgressIndicator());

    final bool isAdmin = user.isAdmin;

    const decoration = InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search');
    final dropdownButton = DropdownButton<String>(
      focusColor: Colors.transparent,
      value: category.value,
      onChanged: category.update,
      underline: const SizedBox.shrink(),
      padding: const EdgeInsets.only(left: 8, right: 4),
      items: [
        for (final String category in categories)
          DropdownMenuItem(value: category, child: Text(category)),
      ],
    );
    final bool oneField = MediaQuery.sizeOf(context).width > 600;
    Widget textField = TextField(
      decoration: decoration.copyWith(suffixIcon: oneField ? dropdownButton : null),
      onChanged: (text) => search.value = text.toLowerCase(),
    );
    if (isAdmin) {
      textField = Hero(
        tag: 'search box',
        child: Material(type: MaterialType.transparency, child: textField),
      );
    }

    final Widget searchBox = oneField
        ? Padding(padding: const EdgeInsets.only(bottom: 8), child: textField)
        : Column(mainAxisSize: MainAxisSize.min, children: [textField, dropdownButton]);

    Widget listView = ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) => videos[index],
      prototypeItem: VideoCard.blank,
    );

    if (isAdmin) {
      listView = Hero(tag: 'list view', child: listView);
    }

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [searchBox, Expanded(child: listView)]),
    );

    if (!isAdmin) return body;

    return Stack(
      children: [
        const _HeroBackground(),
        SizedBox.expand(child: body),
        _LibraryButton(
          icon: Icons.edit,
          onPressed: () => navigator.push(_LibraryEditor(body)),
        ),
        _AppBarHero.aboveScreen,
      ],
    );
  }
}

class _LibraryButton extends StatelessWidget {
  const _LibraryButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = Hero(
      tag: 'button',
      child: SizedBox.square(
        dimension: 48,
        child: IconButton.filled(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
    return Positioned(bottom: 16, right: 16, child: button);
  }
}

class _LibraryEditor extends StatelessWidget {
  const _LibraryEditor(this.body);

  final Widget body;

  static Future<void> uploadVideo() async {
    void cancelMessage() => navigator.snackbarMessage('Video upload cancelled.');

    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return cancelMessage();
    final PlatformFile file = result.files.first;
    try {
      final newVideo = await navigator.showDialog<VideoCard>(const _VideoUploadInfo());
      if (newVideo == null) return cancelMessage();

      final Cubit<bool> loading = navigator.context.read<Loading>();
      loading.value = true;
      final ref = FirebaseStorage.instance.ref(file.name);
      final TaskSnapshot task = await ref.putData(file.bytes!);
      if (task.state != TaskState.success) {
        return navigator.showDialog(const ErrorDialog('File upload failed.'));
      }
      await newVideo.upload();
      loading.value = false;
      navigator.context.read<ThcVideos>().data.add(newVideo);
    } catch (e) {
      return navigator.showDialog(ErrorDialog('Error uploading file.\n\n$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = Loading.of(context);
    final (text, opacity, duration, curve, icon) = loading
        ? (
            'saving...',
            1.0,
            Durations.medium1,
            Curves.ease,
            const _Spinny(),
          )
        : (
            'saved!',
            0.0,
            Durations.extralong4,
            Curves.easeIn,
            const Icon(Icons.done),
          );

    return PopScope(
      canPop: !loading,
      child: Scaffold(
        appBar: _AppBarHero(
          actions: [
            for (final item in [SizedBox(width: 66, child: Text(text)), icon])
              AnimatedOpacity(
                opacity: opacity,
                duration: duration,
                curve: curve,
                child: item,
              ),
            const SizedBox(width: 16),
          ],
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const _HeroBackground(),
            SizedBox.expand(
              child: BlocProvider(create: (_) => Editing(true), child: body),
            ),
            const _LibraryButton(icon: Icons.upload, onPressed: uploadVideo),
            const NavBar(belowPage: true),
          ],
        ),
      ),
    );
  }
}

class _VideoUploadInfo extends HookWidget {
  const _VideoUploadInfo();

  @override
  Widget build(BuildContext context) {
    final category = useState('');
    final director = useState('');
    final title = useState('');
    final items = <String, Cubit>{
      'Category': category,
      'Director': director,
      'Title': title,
    };

    return Dialog.confirm(
      titleText: 'Upload Details',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final MapEntry(key: label, value: cubit) in items.entries) ...[
            TextField(
              decoration: InputDecoration(labelText: label),
              onChanged: cubit.update,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
      actionText: ('cancel', 'upload'),
      onConfirm: () {
        final id = FirestoreID.create(Firestore.streams);
        final newVideo = VideoCard(
          id: id,
          title: title.value,
          timestamp: Timestamp.now(),
          director: director.value,
          category: category.value,
          path: 'gs://the-heart-center-app.appspot.com/${id.value}',
        );

        navigator.pop(newVideo);
      },
    );
  }
}

class _Spinny extends HookWidget {
  const _Spinny();

  static const duration = Durations.extralong1;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: duration, upperBound: math.pi);
    final rotation = useAnimation(controller);
    useOnce(controller.repeat);

    return Transform.rotate(angle: -rotation, child: const Icon(Icons.sync));
  }
}

class _AppBarHero extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarHero({this.actions});

  final List<Widget>? actions;

  static const aboveScreen = FractionalTranslation(
    translation: Offset(0, -1),
    child: _AppBarHero(),
  );

  @override
  final preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);
    final bool loading = Loading.of(context);

    return Hero(
      tag: 'app bar',
      child: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: loading ? null : navigator.pop,
        ),
        title: const Text('Editing Video Library'),
        actions: actions,
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    final color = ThcColors.of(context).surface;
    return Hero(
      tag: 'background',
      child: SizedBox.expand(child: ColoredBox(color: color)),
    );
  }
}
