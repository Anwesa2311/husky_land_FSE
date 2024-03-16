// @file chat/client.d
//
// After starting server (rdmd server.d)
// then start as many clients as you like with "rdmd client.d"
//
import std.socket;
import std.stdio;
import core.thread.osthread;
import core.exception;

import packet;
import sdl_app;
import player;

/// The purpose of the TCPClient class is to 
/// connect to a server and send messages.
/***********************************
     * Connects to the server send and receive updated data.
     */
class TCPClient {
    string host;
    ushort port;
	/// The client socket connected to a server
	Socket mSocket;
	SDLApp mApp;

	// Buffer of data to send out
	byte[Packet.sizeof] buffer;
	long received;

	/***********************************
     * Constructs a TCPClient given a pointer to the app.
     * Params:
     * - `SDLApp app`: Pointer its instance of SDLApp.
     */
	this(SDLApp app){
        host = "localhost";
        port = 50001;
		writeln("Starting client...attempt to create socket");
		// Create a socket for connecting to a server
		// Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
		// Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
		//       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
		mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
		// Socket needs an 'endpoint', so we determine where we
		// are going to connect to.
		// NOTE: It's possible the port number is in use if you are not
		//       able to connect. Try another one.
		mSocket.connect(new InternetAddress(host, port));
		writeln("Client connected to server");
		// Our client waits until we receive at least one message
		// confirming that we are connected
		// This will be something like "Hello friend\0"
		mApp = app;
	}

    /***********************************
     * Constructs a TCPClient given a pointer to the app and a specific host and port.
     * Params:
	 * - `string host`: hostname to connect to
	 * - `ushort port`: port number to connect to
     * - `SDLApp app`: Pointer its instance of SDLApp.
     */
    this(string host, ushort port, SDLApp app) {
        writeln("Starting client...attempt to create socket");
        mSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        mSocket.connect(new InternetAddress(host, port));
		writeln("Client connected to server");
		mApp = app;
    }

	/// Destructor 
	~this(){
		// Close the socket
		mSocket.close();
		writeln("client socket closed!");
	}

	/***********************************
     * Receives welcome message from server.
     * Params: None
     */
	ulong getWelcomedToServer() {
		mSocket.receive(buffer); // long
		ulong numClients = *cast(ulong*) buffer.ptr;
		writeln(">");
		return numClients;
	}

	/***********************************
     * Sends packet to server.
     * Params:
	 * - `string name`: player name
	 * - `int x`: x position of player
     * - `int y`: y position of player
	 * - `string msg`: message to send
     */
	void sendPacket(string name, int x, int y, string msg, string filePath, int e) {
		char[16] n;
		foreach (idx,c; name~"\0") {
			n[idx] = c;
		}
		char[32] f;
		foreach (idx,c; filePath~"\0") {
			f[idx] = c;
		}
		char[64] m;
		foreach(idx,c; msg~"\0") {
			m[idx] = c;
		}
		Packet data;
		// The 'with' statement allows us to access an object
		// (i.e. member variables and member functions)
		// in a slightly more convenient way
		with (data){
			userName = n;
			xPos = x;
			yPos = y;
			// TODO: convert msg to char[] and insert here
			message = m;
			// TODO: add spritePath as a parameter
			spritePath = f;
			emojiNum = e;
		}
		// Send the packet of information
        mSocket.send(data.GetPacketAsBytes());
	}

	/***********************************
     * Receives packet from server.
     * Params: None
     */
	void receiveData() {
		mSocket.blocking = false;
		byte[Packet.sizeof] buffer;
		try {
			auto got = mSocket.receive(buffer);
			auto fromServer = buffer[0 .. got];

			// Format the packet
			Packet formattedPacket;
			byte[16] name = fromServer[0 .. 16].dup;
			formattedPacket.userName = cast(char[])(name);

			// Get some of the fields
			byte[4] x = fromServer[16 .. 20].dup;
			byte[4] y = fromServer[20 .. 24].dup;
			formattedPacket.xPos = *cast(int*)&x;
			formattedPacket.yPos = *cast(int*)&y;

			byte[64] msg = fromServer[24 .. 88].dup;
			formattedPacket.message = cast(char[])(msg);

			byte[32] spath = fromServer[88 .. 120].dup;
			formattedPacket.spritePath = cast(char[])(spath);

			byte[4] e = fromServer[120 .. got].dup;
			formattedPacket.emojiNum = *cast(int*)&e;

			import std.conv;
			string nameFormatted = "";
			for(int i = 0; i < 16; i++) {
				char c = formattedPacket.userName[i];
				if (c != '\0') { 
					nameFormatted ~= c;
				} else if (c == '\0') {
					break;
				}
			}
			string msgFormatted = "";
			for(int j = 0; j < 64; j++) {
				char ch = formattedPacket.message[j];
				if (ch != '\0') { 
					msgFormatted ~= ch;
				} else if (ch == '\0') {
					break;
				}
			}
			import std.range;
			Player updatedPlayer;
			updatedPlayer = Player(mApp.getRenderer,
									to!string(formattedPacket.spritePath),
									formattedPacket.xPos,
									formattedPacket.yPos,
									nameFormatted[0 .. nameFormatted.walkLength]);
			updatedPlayer.emojiNum = formattedPacket.emojiNum;

			mApp.updatePlayerInConnectedList(updatedPlayer, msgFormatted);
		} catch (ArraySliceError e) {
			// nothing
		}
	}
}