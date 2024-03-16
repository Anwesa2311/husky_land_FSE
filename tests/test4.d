//module tests.test4;
import chat;
import std.stdio;
import sdl_app : SDLApp;
import bindbc.sdl;
import window;

@("Test Chat History")
unittest
{
    Window window;
    window.w = 768;
    window.h = 768;
    window.window = SDL_CreateWindow("D SDL Tilemap Example",
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOWPOS_UNDEFINED,
    window.w,
    window.h,
    SDL_WINDOW_SHOWN);

    SDL_Renderer* renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
    Chat_history chatHistory;
    chatHistory.Init(renderer, 768, 768); // Pass null for renderer since we're not actually rendering

    // Add some test data
    chatHistory.updateChatData("user1", "Test message 1");
    chatHistory.updateChatData("user2", "Hello!");

    // Ensure the chat history has been initialized correctly
    assert(chatHistory.chatData.length == 2);
    writeln(chatHistory.chatData[$ - 1][0]);
    assert(chatHistory.chatData[$ - 1][0] == "user2");
    assert(chatHistory.chatData[$ - 1][1] == "Hello!");
    assert(chatHistory.chatData[$ - 2][0] == "user1");
    assert(chatHistory.chatData[$ - 2][1] == "Test message 1");
}