import 'dart:developer';
import 'dart:io';
import 'package:chatbot/backend/saving_data.dart';
import 'package:chatbot/backend/send_message.dart';
import 'package:chatbot/bloc/bloc.dart';
import 'package:chatbot/component/chats_box.dart';
import 'package:chatbot/component/component.dart';
import 'package:chatbot/models/chat_model.dart';
import 'package:chatbot/models/user_model.dart';
import 'package:chatbot/pages/image_page.dart';
import 'package:chatbot/pages/login.dart';
import 'package:chatbot/pages/payment_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User user1;
  User Gemini = User(firstName: 'Gemini', userID: '2');
  bool isWriting = false;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  List<ChatModel> TextMessages = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // Optional: Handle scroll events if needed
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      backgroundColor: const Color.fromARGB(255, 31, 31, 31),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is InitialState) {
                    user1 = creatingUser();
                    TextMessages = deStructure(user1, Gemini);
                    log('!');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: TextMessages.length,
                      itemBuilder: (context, index) {
                        return ChatBox(
                          chatModel: TextMessages[index],
                          scrollController: _scroll,
                        );
                      },
                    );
                  } else if (state is SendingState) {
                    saveData(TextMessages);
                    log('!');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: TextMessages.length,
                      itemBuilder: (context, index) {
                        return ChatBox(
                          chatModel: TextMessages[index],
                          scrollController: _scroll,
                        );
                      },
                    );
                  } else if (state is RecievingState) {
                    log('@');
                    ChatModel chatModel = ChatModel(
                      text: 'text',
                      user: Gemini,
                      createAt: DateTime.now(),
                      isWaiting: true,
                      isSender: false,
                    );
                    TextMessages.add(chatModel);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: TextMessages.length,
                      itemBuilder: (context, index) {
                        return ChatBox(
                          chatModel: TextMessages[index],
                          scrollController: _scroll,
                        );
                      },
                    );
                  } else {
                    if (TextMessages.length > 2) {
                      TextMessages.removeAt(TextMessages.length - 2);
                      saveData(TextMessages);
                    }
                    log('#');
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: TextMessages.length,
                      itemBuilder: (context, index) {
                        return ChatBox(
                          chatModel: TextMessages[index],
                          scrollController: _scroll,
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _scrollToBottom();
                    },
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  Expanded(
                    child: MessageField(
                      buttonFunction: () async {
                        var contextLocal = Navigator.of(context);
                        FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                        if (result != null) {
                          File file = File(result.files.single.path!);
                          contextLocal.push(MaterialPageRoute(
                            builder: (context) => ImagePage(
                              file: file,
                              buttonFunction: () async {
                                final blocContext =
                                BlocProvider.of<MessageBloc>(context);
                                if (_controller.text.trim().isNotEmpty &&
                                    !isWriting) {
                                  Navigator.pop(context);
                                  isWriting = true;
                                  ChatModel message = ChatModel(
                                    createAt: DateTime.now(),
                                    text: _controller.text.trim(),
                                    user: user1,
                                    file: file,
                                  );
                                  _controller.clear();
                                  TextMessages.add(message);
                                  BlocProvider.of<MessageBloc>(context)
                                      .add(DataSent());

                                  log(TextMessages.toString());

                                  BlocProvider.of<MessageBloc>(context)
                                      .add(Pending());

                                  TextMessages.add(
                                      await sendImageData(message, Gemini));
                                  log(TextMessages.toString());

                                  blocContext.add(DataRecieving());
                                  WidgetsBinding.instance.addPostFrameCallback(
                                          (_) {
                                        _scrollToBottom();
                                      });
                                }
                                isWriting = false;
                              },
                              controller: _controller,
                            ),
                          ));
                        } else {
                          // User canceled the picker
                        }
                      },
                      text: "Enter Message...",
                      controller: _controller,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final blocContext =
                      BlocProvider.of<MessageBloc>(context);
                      if (_controller.text.trim().isNotEmpty && !isWriting) {
                        isWriting = true;
                        ChatModel message = ChatModel(
                          createAt: DateTime.now(),
                          text: _controller.text.trim(),
                          user: user1,
                        );
                        _controller.clear();
                        TextMessages.add(message);
                        BlocProvider.of<MessageBloc>(context)
                            .add(DataSent());

                        log(TextMessages.toString());

                        BlocProvider.of<MessageBloc>(context)
                            .add(Pending());

                        TextMessages.add(await getdata(message, Gemini));
                        log(TextMessages.toString());

                        blocContext.add(DataRecieving());
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      }
                      isWriting = false;
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          onPressed: () {
            var route = MaterialPageRoute(builder: (builder) => Login());
            boxUser.put('islogin', false);
            Navigator.pushAndRemoveUntil(
                context, route, (route) => false);
          },
          icon: const Icon(Icons.logout),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => PaymentPage()),
            );
          },
          icon: const Icon(Icons.monetization_on),
        ),
      ],
      title: const Text("Gemini"),
      foregroundColor: Colors.white,
      leading: Image.asset('./assets/gemini.png'),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    );
  }
}
