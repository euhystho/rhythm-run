import 'package:file_picker/file_picker.dart';
//import 'package:permission_handler/permission_handler.dart';
Future<List<String>> pickAudioFile() async{
  final List<String>audioAssetPaths=[];
  //filter the mp3 file from local file 
  //uncomment this to accept the request permission
  /**bool hasPermission = await _requestPermission();
    
    if (!hasPermission) {
      print('Storage permission denied');
      return;
    }
  **/
  FilePickerResult? results =await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['wav','mp3'],
    allowMultiple: true,
  );
  if(results!=null){
    //add the file paths to the list
    List<String> filePaths=results.paths
        .where((path)=>path!=null)
        .map((path)=>path!)
        .toList();
    audioAssetPaths.addAll(filePaths);
  }
  // print the asset path for debuging or testing:
  for(var path in audioAssetPaths){
    print('-$path');
  }
  return audioAssetPaths;
}
/**Future<bool> _requestPermission() async {
  if (Platform.isAndroid) {
    // For Android
    Permission permission;
    if (int.parse(Platform.operatingSystemVersion.split(' ').first) >= 13) {
      permission = Permission.audio;
    } else {
      permission = Permission.storage;
    }
    
    PermissionStatus status = await permission.status;
    
    if (status.isDenied) {
      status = await permission.request();
    }
    
    return status.isGranted;
  } else if (Platform.isIOS) {
    // iOS doesn't need explicit permission for file picker
    return true;
  }
  
  return false;
}
**/