import 'package:ecommerce_app/common/widgets/loaders/loaders.dart';
import 'package:ecommerce_app/data/services/authenticated_http_client.dart'
    as http;
import 'package:ecommerce_app/features/quran_hadith/models/audio_url_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/hadith_books_chapters_hadiths_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/hadith_books_chapters_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/hadith_books_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/hadith_translation_languages_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/hadith_translation_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_audio_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_ayahs_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/juz_translation_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_audio_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_ayahs_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surah_translation_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/surahs_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/tafseer_model.dart';
import 'package:ecommerce_app/features/quran_hadith/models/translation_model.dart';
import 'package:ecommerce_app/utils/helpers/error_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class QuranHadithController extends GetxController {
  String? apisBaseUrl = dotenv.env['APIS_BASE_URL'];

  var juz = <Juz>[].obs;
  var surahs = <Surahs>[].obs;
  var juzzAyahs = <JuzAyah>[].obs;
  var surahAyahs = <SurahAyah>[].obs;
  var hadithBooks = <HadithBooks>[].obs;
  var hadithBooksChapters = <HadithBooksChapters>[].obs;
  var hadithBooksChaptersHadiths = <HadithBooksChaptersHadiths>[].obs;
  var hadithTranslations = <HadithTranslation>[].obs;
  var hadithTranslationLanguages = Rxn<HadithTranslationLanguages>();
  var translations = <Translation>[].obs;
  var tafseers = <Tafseer>[].obs;
  var audioUrls = <AudioUrl>[].obs;
  var juzTranslations = <JuzTranslation>[].obs;
  var juzTafseers = <JuzTafseer>[].obs;
  var juzAudios = <JuzAudio>[].obs;
  var surahTranslations = <SurahTranslation>[].obs;
  var surahTafseers = <SurahTafseer>[].obs;
  var surahAudios = <SurahAudio>[].obs;

  var isLoading = false.obs;
  var isSurahAyahsLoading = false.obs;
  var isJuzAyahsLoading = false.obs;
  var isBooksLoading = false.obs;
  var isChaptersLoading = false.obs;
  var isHadithsLoading = false.obs;
  var isHadithTranslationsLoading = false.obs;
  var isHadithTranslationLanguagesLoading = false.obs;
  var isJuzTranslationsLoading = false.obs;
  var isSurahTranslationsLoading = false.obs;
  var isJuzTafseersLoading = false.obs;
  var isSurahTafseersLoading = false.obs;

  final juzError = ''.obs;
  final surahError = ''.obs;
  final ayahError = ''.obs;
  final hadithBooksError = ''.obs;
  final hadithChaptersError = ''.obs;
  final hadithsError = ''.obs;
  final translationError = ''.obs;
  final tafseerError = ''.obs;
  final audioError = ''.obs;

  Future<void> fetchJuz() {
    return _fetchList<Juz>(
      path: '/quran/juz',
      loading: isLoading,
      errorState: juzError,
      target: juz,
      parser: (item) => Juz.fromJson(_asMap(item)),
      fallback: 'Unable to load Juz list. Please try again.',
    );
  }

  Future<void> fetchSurahs() {
    return _fetchList<Surahs>(
      path: '/quran/surah',
      loading: isLoading,
      errorState: surahError,
      target: surahs,
      parser: (item) => Surahs.fromJson(_asMap(item)),
      fallback: 'Unable to load Surah list. Please try again.',
    );
  }

  Future<void> fetchJuzAyahs(int juzNumber) {
    return _fetchList<JuzAyah>(
      path: '/quran/juz/$juzNumber',
      loading: isJuzAyahsLoading,
      errorState: ayahError,
      target: juzzAyahs,
      parser: (item) => JuzAyah.fromJson(_asMap(item)),
      fallback: 'Unable to load ayahs for this Juz. Please try again.',
    );
  }

  Future<void> fetchSurahAyahs(int surahNumber) {
    return _fetchList<SurahAyah>(
      path: '/quran/surah/$surahNumber',
      loading: isSurahAyahsLoading,
      errorState: ayahError,
      target: surahAyahs,
      parser: (item) => SurahAyah.fromJson(_asMap(item)),
      fallback: 'Unable to load ayahs for this Surah. Please try again.',
    );
  }

  Future<void> fetchHadithBooks() {
    return _fetchList<HadithBooks>(
      path: '/hadith/books',
      loading: isBooksLoading,
      errorState: hadithBooksError,
      target: hadithBooks,
      parser: (item) => HadithBooks.fromJson(_asMap(item)),
      fallback: 'Unable to load Hadith books. Please try again.',
    );
  }

  Future<void> fetchHadithBooksChapters(int bookId) {
    return _fetchList<HadithBooksChapters>(
      path: '/hadith/books/$bookId',
      loading: isChaptersLoading,
      errorState: hadithChaptersError,
      target: hadithBooksChapters,
      parser: (item) => HadithBooksChapters.fromJson(_asMap(item)),
      fallback: 'Unable to load Hadith chapters. Please try again.',
    );
  }

  Future<void> fetchHadithBooksChaptersHadiths(
    int bookId,
    int chapterId,
  ) {
    return _fetchList<HadithBooksChaptersHadiths>(
      path: '/hadith/books/$bookId/$chapterId',
      loading: isHadithsLoading,
      errorState: hadithsError,
      target: hadithBooksChaptersHadiths,
      parser: (item) => HadithBooksChaptersHadiths.fromJson(_asMap(item)),
      fallback: 'Unable to load Hadiths. Please try again.',
    );
  }

  Future<void> fetchHadithTranslations(
    int bookId,
    int chapterId,
    String language,
  ) {
    return _fetchList<HadithTranslation>(
      path: '/hadith/books/$bookId/$chapterId/translations/$language',
      loading: isHadithTranslationsLoading,
      errorState: translationError,
      target: hadithTranslations,
      parser: (item) => HadithTranslation.fromJson(_asMap(item)),
      fallback: 'Unable to load Hadith translations. Please try again.',
      showSnackBar: true,
    );
  }

  Future<void> fetchHadithTranslationLanguages() {
    return _fetchObject<HadithTranslationLanguages>(
      path: '/hadith/translations/languages',
      loading: isHadithTranslationLanguagesLoading,
      errorState: translationError,
      assign: (value) => hadithTranslationLanguages.value = value,
      parser: (item) => HadithTranslationLanguages.fromJson(_asMap(item)),
      fallback: 'Unable to load Hadith languages. Please try again.',
    );
  }

  Future<void> fetchTranslations() {
    return _fetchList<Translation>(
      path: '/quran/translations',
      loading: isLoading,
      errorState: translationError,
      target: translations,
      parser: (item) => Translation.fromJson(_asMap(item)),
      fallback: 'Unable to load Quran translations. Please try again.',
    );
  }

  Future<void> fetchTafseers() {
    return _fetchList<Tafseer>(
      path: '/quran/tafseers',
      loading: isLoading,
      errorState: tafseerError,
      target: tafseers,
      parser: (item) => Tafseer.fromJson(_asMap(item)),
      fallback: 'Unable to load Tafseer options. Please try again.',
    );
  }

  Future<void> fetchAudioUrls() {
    return _fetchList<AudioUrl>(
      path: '/quran/audio-urls',
      loading: isLoading,
      errorState: audioError,
      target: audioUrls,
      parser: (item) => AudioUrl.fromJson(_asMap(item)),
      fallback: 'Unable to load audio options. Please try again.',
    );
  }

  Future<void> fetchJuzTranslations(
    int juzNumber,
    String language,
    String translator,
  ) {
    return _fetchList<JuzTranslation>(
      path: '/quran/juz/$juzNumber/translations/$language/$translator',
      loading: isJuzTranslationsLoading,
      errorState: translationError,
      target: juzTranslations,
      parser: (item) => JuzTranslation.fromJson(_asMap(item)),
      fallback: 'Unable to load Juz translations. Please try again.',
      showSnackBar: true,
    );
  }

  Future<void> fetchJuzTafseers(
    int juzNumber,
    String language,
    String writer,
  ) {
    return _fetchList<JuzTafseer>(
      path: '/quran/juz/$juzNumber/tafseers/$language/$writer',
      loading: isJuzTafseersLoading,
      errorState: tafseerError,
      target: juzTafseers,
      parser: (item) => JuzTafseer.fromJson(_asMap(item)),
      fallback: 'Unable to load Juz tafseer. Please try again.',
      showSnackBar: true,
    );
  }

  Future<void> fetchJuzAudioUrls(
    int juzNumber,
    String language,
    String reciter,
  ) {
    return _fetchList<JuzAudio>(
      path: '/quran/juz/$juzNumber/audio-urls/$language/$reciter',
      loading: isLoading,
      errorState: audioError,
      target: juzAudios,
      parser: (item) => JuzAudio.fromJson(_asMap(item)),
      fallback: 'Audio unavailable. Try another reciter or retry.',
      showSnackBar: true,
    );
  }

  Future<void> fetchSurahTranslations(
    int surahNumber,
    String language,
    String translator,
  ) {
    return _fetchList<SurahTranslation>(
      path: '/quran/surah/$surahNumber/translations/$language/$translator',
      loading: isSurahTranslationsLoading,
      errorState: translationError,
      target: surahTranslations,
      parser: (item) => SurahTranslation.fromJson(_asMap(item)),
      fallback: 'Unable to load Surah translations. Please try again.',
      showSnackBar: true,
    );
  }

  Future<void> fetchSurahTafseers(
    int surahNumber,
    String language,
    String writer,
  ) {
    return _fetchList<SurahTafseer>(
      path: '/quran/surah/$surahNumber/tafseers/$language/$writer',
      loading: isSurahTafseersLoading,
      errorState: tafseerError,
      target: surahTafseers,
      parser: (item) => SurahTafseer.fromJson(_asMap(item)),
      fallback: 'Unable to load Surah tafseer. Please try again.',
      showSnackBar: true,
    );
  }

  Future<void> fetchSurahAudioUrls(
    int surahNumber,
    String language,
    String reciter,
  ) {
    return _fetchList<SurahAudio>(
      path: '/quran/surah/$surahNumber/audio-urls/$language/$reciter',
      loading: isLoading,
      errorState: audioError,
      target: surahAudios,
      parser: (item) => SurahAudio.fromJson(_asMap(item)),
      fallback: 'Audio unavailable. Try another reciter or retry.',
      showSnackBar: true,
    );
  }

  Future<void> _fetchList<T>({
    required String path,
    required RxBool loading,
    required RxString errorState,
    required RxList<T> target,
    required T Function(dynamic item) parser,
    required String fallback,
    bool clearBeforeFetch = true,
    bool showSnackBar = false,
  }) async {
    loading.value = true;
    errorState.value = '';
    if (clearBeforeFetch) target.clear();

    try {
      final response = await http.get(_uri(path));
      if (response.statusCode != 200) {
        _handleFailedResponse(response, errorState, fallback, showSnackBar);
        return;
      }

      final decoded = safeDecodeJson(response.body);
      final data = _asList(decoded);
      target.assignAll(data.map(parser).toList());
    } catch (error, stackTrace) {
      _handleCaughtError(
        error,
        stackTrace,
        errorState,
        fallback,
        showSnackBar,
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> _fetchObject<T>({
    required String path,
    required RxBool loading,
    required RxString errorState,
    required void Function(T value) assign,
    required T Function(dynamic item) parser,
    required String fallback,
    bool showSnackBar = false,
  }) async {
    loading.value = true;
    errorState.value = '';

    try {
      final response = await http.get(_uri(path));
      if (response.statusCode != 200) {
        _handleFailedResponse(response, errorState, fallback, showSnackBar);
        return;
      }

      final decoded = safeDecodeJson(response.body);
      assign(parser(decoded));
    } catch (error, stackTrace) {
      _handleCaughtError(
        error,
        stackTrace,
        errorState,
        fallback,
        showSnackBar,
      );
    } finally {
      loading.value = false;
    }
  }

  Uri _uri(String path) {
    final baseUrl = (apisBaseUrl ?? '').trim();
    if (baseUrl.isEmpty) {
      throw const AppConfigurationException(
        'Quran and Hadith service is unavailable.',
      );
    }
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  void _handleFailedResponse(
    http.Response response,
    RxString errorState,
    String fallback,
    bool showSnackBar,
  ) {
    final message = ApiErrorParser.parseResponse(response, fallback: fallback);
    errorState.value = message;
    if (showSnackBar) {
      PLoaders.errorSnackBar(title: 'Unable to Load', message: message);
    }
  }

  void _handleCaughtError(
    Object error,
    StackTrace stackTrace,
    RxString errorState,
    String fallback,
    bool showSnackBar,
  ) {
    if (kDebugMode) {
      debugPrint('[QuranHadithController] $error');
      debugPrint(stackTrace.toString());
    }
    final message = AppErrorMessage.fromException(error, fallback: fallback);
    errorState.value = message;
    if (showSnackBar) {
      PLoaders.errorSnackBar(title: 'Unable to Load', message: message);
    }
  }

  List<dynamic> _asList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final key in const ['data', 'results', 'items']) {
        final value = decoded[key];
        if (value is List) return value;
      }
    }
    throw const FormatException('Expected a list response.');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    throw const FormatException('Expected an object response.');
  }
}
