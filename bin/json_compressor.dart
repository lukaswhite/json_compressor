import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import "package:path/path.dart" as p;
import 'package:cli_util/cli_logging.dart';
import 'package:interact/interact.dart';
import 'package:json_compress/json_compress.dart';

void main(List<String> arguments) async {

  bool verbose = arguments.contains('-v');
  var logger = verbose ? Logger.verbose() : Logger.standard();

  if(arguments.isEmpty){
    logger.stderr('❗ You need to provide a path to the file you want to compress.');
    logger.stderr('❗ Usage: json_compressor <filepath>.');
    exit(-1);
  }
  
  String filepath = arguments[0];
  final inputFile = File(filepath);
  if(!inputFile.existsSync()){
    logger.stderr('❗ The source file does not exist.');
    exit(-1);
  }

  String outputFilename = '${p.basenameWithoutExtension(filepath)}_compressed${p.extension(filepath)}';    
  String outputPath = p.join(p.dirname(filepath), outputFilename);

  File outputFile = File(outputPath);

  if(outputFile.existsSync()) {
    final answer = Confirm(
      prompt: 'The destination path already exists. Are you sure you want to overwrite it?',
      defaultValue: false,
    ).interact();
    if(!answer){
      logger.stdout('Exiting, leaving destination intact.');
      exit(0);
    }
  }

  int originalSize = inputFile.lengthSync();

  logger.trace('Reading source file...');

  String contents = await inputFile.readAsString();

  try{
    
    Map<String,dynamic> json = jsonDecode(contents);
  
    final spinner = Spinner(
      icon: '✅',      
      rightPrompt: (done) => done
          ? 'Compression complete'
          : 'Running compression',
    ).interact();
    
    Map<String, dynamic> compressed = await Isolate.run(() => compressJson(json, 
      forceEncode: false 
    ));

    spinner.done();

    logger.trace('Writing destination file...');
    
    var file = await File(outputPath).writeAsString(jsonEncode(compressed).toString());

    int compressedSize = file.lengthSync();
    int reductionPc = ((originalSize - compressedSize) / originalSize * 100).truncate();

    logger.trace('Saved file to $outputPath');
    logger.stdout('✅ All done. Reduced file size by ${logger.ansi.emphasized('$reductionPc%')}.');   

  } catch(e){
    logger.stderr('❗ Could not parse the JSON file');
    reset();
    exit(-1);
  }
   
}