import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class addFlower extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WizardForm(),
    );
  }
}

class WizardFormBloc extends FormBloc<String, String> {

  // File _image;
  final picker = ImagePicker();

  // Future getImage() async {
  //   final pickedFile = await picker.getImage(source: ImageSource.camera);
  //
  //   setState(() {
  //     if (pickedFile != null) {
  //       _image = File(pickedFile.path);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  // }


  final flowername = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  final flowerType = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final flowerColor = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final firstName = TextFieldBloc();

  final lastName = TextFieldBloc();

  final gender = SelectFieldBloc(
    items: ['Male', 'Female'],
  );

  final addedDate = InputFieldBloc<DateTime, Object>(
    validators: [FieldBlocValidators.required],
  );

  final github = TextFieldBloc();

  final twitter = TextFieldBloc();

  final facebook = TextFieldBloc();

  WizardFormBloc() {
    addFieldBlocs(
      step: 0,
      fieldBlocs: [flowername, flowerType, flowerColor],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [firstName, lastName, gender, addedDate],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [github, twitter, facebook],
    );
  }

  bool _showEmailTakenError = true;

  @override
  void onSubmitting() async {


    if (state.currentStep == 0) {
      await Future.delayed(Duration(milliseconds: 500));emitSuccess();
      // if (_showEmailTakenError) {
      //   _showEmailTakenError = false;
      //
      //   email.addFieldError('That email is already taken');
      //
      //   emitFailure();
      // } else {
      //   emitSuccess();
      // }
    } else if (state.currentStep == 1) {
      emitSuccess();
    } else if (state.currentStep == 2) {
      await Future.delayed(Duration(milliseconds: 500));


      emitSuccess();
    }
  }


}


class WizardForm extends StatefulWidget {
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm> {
  var _type = StepperType.horizontal;
  late File _imageFile;


  void _toggleType() {
    setState(() {
      if (_type == StepperType.horizontal) {
        _type = StepperType.vertical;
      } else {
        _type = StepperType.horizontal;
      }
    });
  }

  Future<void> pickImage(ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);
    setState(() {
      if (selected != null) {
        _imageFile = File(selected.path);
      } else {
        print('No image selected.');
      }
    });
  }



  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => WizardFormBloc(),
      child: Builder(
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text('Wizard'),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(_type == StepperType.horizontal
                          ? Icons.swap_vert
                          : Icons.swap_horiz),
                      onPressed: _toggleType)
                ],
              ),
              body: SafeArea(
                child: FormBlocListener<WizardFormBloc, String, String>(
                  onSubmitting: (context, state) => LoadingDialog.show(context),
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);

                    if (state.stepCompleted == state.lastStep) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => SuccessScreen()));
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    formBloc: context.read<WizardFormBloc>(),
                    type: _type,
                    physics: ClampingScrollPhysics(),
                    stepsBuilder: (formBloc) {
                      return [
                        _accountStep(formBloc!),
                        _personalStep(formBloc),
                        _socialStep(formBloc),
                      ];
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  FormBlocStep _accountStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Details'),
      content: Column(
        children: <Widget>[
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.flowername,
            keyboardType: TextInputType.emailAddress,
            enableOnlyWhenFormBlocCanSubmit: true,
            decoration: InputDecoration(
              labelText: 'Flower name',
              prefixIcon: Icon(Icons.sell_rounded),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.flowerType,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Flower type',
              prefixIcon: Icon(Icons.send_rounded),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.flowerColor,
            keyboardType: TextInputType.emailAddress,

            decoration: InputDecoration(
              labelText: 'Flower color',
              prefixIcon: Icon(Icons.details_outlined),
            ),
          ),
        ],
      ),
    );
  }

  FormBlocStep _personalStep(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Description'),
      content: Column(
        children: <Widget>[
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.firstName,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.lastName,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Last Name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          RadioButtonGroupFieldBlocBuilder<String>(
            selectFieldBloc: wizardFormBloc.gender,
            itemBuilder: (context, value) => value,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: SizedBox(),
            ),
          ),
          DateTimeFieldBlocBuilder(
            dateTimeFieldBloc: wizardFormBloc.addedDate,
            firstDate: DateTime(1900),
            initialDate: DateTime.now(),
            lastDate: DateTime.now(),
            format: DateFormat('yyyy-MM-dd'),
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.cake),
            ),
          ),
        ],
      ),
    );
  }

  FormBlocStep _socialStep(WizardFormBloc wizardFormBloc) {

    String fileName;
    String path;
    PlatformFile? pathsValue;
    List<String> extensions;
    bool isLoadingPath = false;
    bool isMultiPick = false;
    FileType fileType=FileType.any;

    File _imageFile=new File("");

    Future<void> pickImage(ImageSource source) async {
      final selected = await ImagePicker().getImage(source: ImageSource.camera);
      setState(() {
        if (selected != null) {
          _imageFile = File(selected.path);
        } else {
          print('No image selected.');
        }
      });
    }


    void _openFileExplorer() async {
      setState(() => isLoadingPath = true);
      try {
        path = "";
        FilePickerResult? paths = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'pdf', 'doc', 'png', 'jpeg'],);

        PlatformFile file = paths!.files.first;

print(paths!.files.first.bytes);
        List<int> imageBytes=paths!.files.first.bytes as List<int>;
String value=base64Encode(imageBytes);
print(value);
        setState(() {
          pathsValue = file;
        });
      }
      catch (e) {


      }
    }

    return FormBlocStep(
      title: Text('Image'),
      content: Column(
        children:  <Widget>[

          new Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
            child: new RaisedButton(
              onPressed: () => _openFileExplorer(),
              child: new Text("Open file picker"),
            ),
          ),
          // new Text(pathsValue!.name),
          new Builder(
            builder: (BuildContext context) => isLoadingPath ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: const CircularProgressIndicator()
            )
                : pathsValue!= null? new Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              height: MediaQuery.of(context).size.height * 0.50,
              child: new Scrollbar(
                  child: new ListView.separated(
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      final bool isMultiPath = pathsValue != null;
                      final int fileNo = index + 1;
                      final String name = 'File $fileNo : ' + pathsValue!.name.toString();
                      final filePath =  pathsValue!.path;
                      return new ListTile(title: new Text(name,),
                        subtitle: new Text(pathsValue!.path.toString()),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => new Divider(),
                  )),
            )
                : new Text('pathsValue!.name.toString()'),
          ),
        ]
      ),
    );
  }

}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(key: key),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => WizardForm())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}


class ImageCapture extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>
    // TODO: implement createState
   _ImageCaptureState();

}

class _ImageCaptureState extends State<ImageCapture>{
  late File _imageFile;

  Future<void> pickImage(ImageSource source) async {
    final selected = await ImagePicker().getImage(source: source);
    setState(() {
      if (selected != null) {
        _imageFile = File(selected.path);
      } else {
        print('No image selected.');
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }


}
