It is ActionScript3 (Flex SDK includes Adobe AIR library) library to analyze PDF file.


PDFファイルを解析し、文字列を取り出すライブラリです。ActionScript3(Flex SDK includes Adobe AIR library)で書いています。

現行バージョンでは、アウトライン(しおり)単位で文字列を取得する機能のみです。

文字列を取り出すのは TextExtractor を以下のように使います。

```
var extractor:TextExtractor = new TextExtractor();

extractor.addEventListener(PDFExtractorEvent.COMPLETE, _completeHandler);
extractor.addEventListener(PDFParserProgressEvent.PROGRESS, _progressHandler);
extractor.addEventListener(PDFParserFaultEvent.FAULT, _faultHandler);
extractor.addEventListener(PDFParserEvent.CANCELED, _canceledHandler);

extractor.filePath = "pdf file path";

extractor.asyncParse();
```

PDFExtractorEvent.COMPLETEイベントに、PDFファイル情報としおり単位の文字列が含まれて返ります。




※すべてのPDFファイルに対応している訳ではありません。