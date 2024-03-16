//module tests.test3;
import chat;

@("Chatbox Test one message")
unittest
{
    Chatbox chatBox;
    chatBox.initChat(null, 768, 768, "user");
    chatBox.updateInput("New message");
    assert(chatBox.text_input == "New message");
    chatBox.updateInput("Hello, World!");
    assert(chatBox.text_input == "Hello, World!");

}




