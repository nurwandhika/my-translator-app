import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:my_translator_app/constants/word_lists.dart';

export 'language_translation.dart' show LanguageTranslationPage;

class LanguageTranslationPage extends StatefulWidget {
  const LanguageTranslationPage({super.key});

  @override
  State<LanguageTranslationPage> createState() =>
      _LanguageTranslationPageState();
}

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: items.contains(value) ? value : null,
        hint: Text(value, style: TextStyle(color: Colors.blue)),
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class TranslationInputField extends StatelessWidget {
  final TextEditingController controller;

  const TranslationInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(color: Colors.blue.shade700),
        decoration: InputDecoration(
          hintText: "Masukkan teks Anda di sini",
          hintStyle: TextStyle(color: Colors.blue.shade300),
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class TranslationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const TranslationButton({
    required this.onPressed,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TranslationHistoryCard extends StatelessWidget {
  final int index;
  final String text;

  const TranslationHistoryCard({
    required this.index,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            (index + 1).toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }
}

class _LanguageTranslationPageState extends State<LanguageTranslationPage> {
  var languages = ['Inggris', 'Indonesia', 'Jawa'];
  var originLanguage = "Dari";
  var destinationLanguage = "Ke";
  var output = "";
  TextEditingController languageController = TextEditingController();
  List<String> history = [];

  String getLanguageCode(String language) {
    if (language == "Inggris") {
      return "en";
    } else if (language == "Indonesia") {
      return "id";
    } else if (language == "Jawa") {
      return "jv";
    } else {
      return "--";
    }
  }

  String getLanguageName(String code) {
    if (code == "en") {
      return "Inggris";
    } else if (code == "id") {
      return "Indonesia";
    } else if (code == "jv") {
      return "Jawa";
    } else {
      return "Unknown";
    }
  }

  void translate(String src, String dest, String input) async {
    if (input.isEmpty) {
      showSnackBar('Silakan masukkan teks terlebih dahulu');
      return;
    }

    if (originLanguage == "Dari" || destinationLanguage == "Ke") {
      showSnackBar('Silakan pilih bahasa asal dan tujuan');
      return;
    }

    if (originLanguage == destinationLanguage) {
      showSnackBar('Bahasa asal dan tujuan tidak boleh sama');
      return;
    }

    // Improved language detection logic
    if (src == "en" && isIndonesianText(input)) {
      showSnackBar(
        'Teks yang Anda masukkan sepertinya dalam Bahasa Indonesia. Apakah Anda ingin menukar bahasa?',
        isError: false,
      );
      // Optional: Add a dialog to confirm language swap
      bool? shouldSwap = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi Bahasa'),
          content: Text('Apakah Anda ingin menukar bahasa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ya'),
            ),
          ],
        ),
      );

      if (shouldSwap == true) {
        swapLanguages();
        // Retry translation after swap
        translate(
          getLanguageCode(originLanguage),
          getLanguageCode(destinationLanguage),
          input,
        );
        return;
      }
    }

    if (src == "id" && isEnglishText(input)) {
      showSnackBar(
        'Teks yang Anda masukkan sepertinya dalam Bahasa Inggris. Apakah Anda ingin menukar bahasa?',
        isError: false,
      );
      // Optional: Add a dialog to confirm language swap
      bool? shouldSwap = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi Bahasa'),
          content: Text('Apakah Anda ingin menukar bahasa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ya'),
            ),
          ],
        ),
      );

      if (shouldSwap == true) {
        swapLanguages();
        // Retry translation after swap
        translate(
          getLanguageCode(originLanguage),
          getLanguageCode(destinationLanguage),
          input,
        );
        return;
      }
    }

    try {
      GoogleTranslator translator = GoogleTranslator();
      var translation = await translator.translate(input, from: src, to: dest);
      setState(() {
        output = translation.text.toString();
        history.add(
            "$input (${getLanguageName(src)}) -> $output (${getLanguageName(dest)})");
      });
    } catch (e) {
      showSnackBar('Terjadi kesalahan saat menerjemahkan: ${e.toString()}');
    }
  }

  void clearText() {
    if (languageController.text.isEmpty && output.isEmpty) {
      showSnackBar('Tidak ada teks yang perlu dibersihkan');
      return;
    }

    setState(() {
      languageController.clear();
      output = "";
    });
    showSnackBar('Teks berhasil dibersihkan', isError: false);
  }

  void clearHistory() {
    if (history.isEmpty) {
      showSnackBar('Riwayat sudah kosong');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Riwayat'),
        content: Text('Apakah Anda yakin ingin menghapus semua riwayat terjemahan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => history.clear());
              Navigator.pop(context);
              showSnackBar('Riwayat berhasil dihapus', isError: false);
            },
            child: Text('Hapus'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void swapLanguages() {
    if (originLanguage == "Dari" || destinationLanguage == "Ke") {
      showSnackBar('Silakan pilih bahasa terlebih dahulu');
      return;
    }

    setState(() {
      String temp = originLanguage;
      originLanguage = destinationLanguage;
      destinationLanguage = temp;
    });
    showSnackBar('Bahasa berhasil ditukar', isError: false);
  }

  void showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  bool isEnglishText(String text) {
    int matchCount = 0;
    List<String> words = text.toLowerCase().split(' ');

    for (String word in words) {
      if (WordLists.englishWords.contains(word)) {
        matchCount++;
      }
    }

    return matchCount > 0 && (matchCount / words.length) >= 0.2;
  }

  bool isIndonesianText(String text) {
    int matchCount = 0;
    List<String> words = text.toLowerCase().split(' ');

    for (String word in words) {
      if (WordLists.indonesianWords.contains(word)) {
        matchCount++;
      }
    }

    return matchCount > 0 && (matchCount / words.length) >= 0.2;
  }

  bool isJavaneseText(String text) {
    int matchCount = 0;
    List<String> words = text.toLowerCase().split(' ');

    for (String word in words) {
      if (WordLists.javaneseWords.contains(word)) {
        matchCount++;
      }
    }

    return matchCount > 0 && (matchCount / words.length) >= 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomDropdown(
                          value: originLanguage,
                          items: languages,
                          onChanged: (value) =>
                              setState(() => originLanguage = value!),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: IconButton(
                          icon: Icon(Icons.swap_horiz, color: Colors.blue),
                          onPressed: swapLanguages,
                        ),
                      ),
                      Expanded(
                        child: CustomDropdown(
                          value: destinationLanguage,
                          items: languages,
                          onChanged: (value) =>
                              setState(() => destinationLanguage = value!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TranslationInputField(controller: languageController),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TranslationButton(
                        onPressed: () => translate(
                          getLanguageCode(originLanguage),
                          getLanguageCode(destinationLanguage),
                          languageController.text,
                        ),
                        text: "Terjemahkan",
                        color: Colors.blue,
                      ),
                      TranslationButton(
                        onPressed: clearText,
                        text: "Bersihkan",
                        color: Colors.red,
                      ),
                    ],
                  ),
                  if (output.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        output,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (history.isNotEmpty) ...[
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Riwayat Terjemahan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: clearHistory,
                          tooltip: 'Hapus Riwayat',
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        return TranslationHistoryCard(
                          index: index,
                          text: history[index],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
