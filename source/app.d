/// Run with: 'dub'

module app;

// Import D standard libraries
import std.stdio;
import std.string;
import std.socket;
import std.concurrency: spawn;
import std.range;

import sprite;
import tilemap;
import player;
import window;
import sdl_app;
import server;
import client;

// Load the SDL2 library
import bindbc.sdl;

// Entry point to program
void main()
{
    writeln("Arrowkeys to move, hold 'space' key for tile map selector demo");
    bool isHostBool = false;

    // ask if they are the host!
    stdout.flush;
    write("Are you the host? (y/n): ");
    string isHostStr = readln;
    isHostStr = stripRight(isHostStr);
    isHostStr = stripLeft(isHostStr);
    import std.uni;
    isHostBool = (isHostStr.toLower == "y");

    // ask for nickname!
    stdout.flush;
    write("Enter nickname: ");
    bool hasUsername = false;
    string username;
    while (!hasUsername) {
        stdout.flush;
        username = readln;
        username = stripRight(username);
        username = stripLeft(username);
        if (username != "") { 
            hasUsername = true;
            break;
        }
        write("You must enter a username: ");
    }

    string host;
    ushort port;
    if (!isHostBool) {
        // ask for host address
        write("Enter host address: ");
        stdout.flush;
        host = readln;
        host = stripRight(host);
        host = stripLeft(host);

        // ask for host port number
        write("Enter host port number: ");
        stdout.flush;
        scanf("%d", &port);
    } else {
        writeln('='.repeat(30));
        host = GetIP();
        writeln("Share this address with your friends so they can join!");
        writeln("Host address: ", host);
        writeln('='.repeat(30));

        // ask for host port number
        write("Enter port number: ");
        stdout.flush;
        scanf("%d", &port);
        writeln("Share this port with your friends so they can join!");
        writeln("Host port number: ", port);
        writeln('='.repeat(30));
    }

    try {
        TCPServer server = new TCPServer(host,port);
        SDLApp app = new SDLApp(server,username,host,port);
        spawn(&runServer, cast(shared) server);
        app.LobbyLoop();
    } catch (SocketOSException e) {
        writeln("server is already open!");
        SDLApp app = new SDLApp(username,host,port);
        app.LobbyLoop();
    }

}

void runServer(shared TCPServer server) {
    TCPServer serv = cast(TCPServer)server;
    while (true) {
        serv.next();
    }
}

string GetIP(){
    // A bit of a hack, but we'll create a connection from google to
    // our current ip.
    // Use a well known port (i.e. google) to do this
    auto r = getAddress("8.8.8.8",53); // NOTE: This is effetively getAddressInfo
    // Create a socket
    auto sockfd = new Socket(AddressFamily.INET,  SocketType.STREAM);
    // Connect to the google server
    import std.conv;
    const char[] address = r[0].toAddrString().dup;
    ushort port = to!ushort(r[0].toPortString());
    sockfd.connect(new InternetAddress(address,port));
    // Obtain local sockets name and address
    writeln("Running on ", sockfd.hostName);
    string localHostName = sockfd.localAddress().toAddrString();

    // Close our socket
    sockfd.close();
    return localHostName;
}
