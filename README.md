# JSON Compressor

A command-line tool to compress - and effectively encrypt - JSON files, written in Dart.

Under the hood it uses the [json_compress](https://github.com/cyberpwnn/dart_json_compress) Dart package, so you should use that to decompress them.

## Usage

```bash
bin/json_compressor /path/to/your.json
```

Or on Windows:

```bash
bin/json_compressor.exe /path/to/your.json
```

This will create a file named `your_compressed.json` in the same folder.
