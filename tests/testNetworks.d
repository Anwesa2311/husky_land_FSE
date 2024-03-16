import sdl_app : SDLApp;
import player;
import server;
import client;


@("Test that server can accept new connections")
unittest{
    TCPServer server = new TCPServer;
    assert(server.mClientsConnectedToServer.length == 0, "should not have clients yet!");
    SDLApp app = new SDLApp(server, "default");
    TCPClient mClient = new TCPClient(&app);
    server.next();
    mClient.getWelcomedToServer();
    assert(server.mClientsConnectedToServer.length == 1, "failed to connect client!");
}