// @file multithreaded_chat/server.d
//
// Start server first: rdmd server.d
import std.socket;
import std.stdio;
import core.thread.osthread;
import std.algorithm.mutation;

import packet;

/***********************************
     * TCPServer accepts multiple client connections and manages receiving/broadcasting data to clients.
     */
class TCPServer{
    string host;
    ushort port;
    ushort maxConnectionsBacklog;

    // The listening socket is responsible for handling new client connections.
    Socket mListeningSocket;
    // A SocketSet is equivalent to 'fd_set'
	// https://linux.die.net/man/3/fd_set
	// What SocketSet is used for, is to allow 
	// 'multiplexing' of sockets -- or put another
	// way, the ability for multiple clients
	// to connect a socket to this single server
	// socket.
    auto readSet = new SocketSet();
    // Stores the clients that are currently connected to the server.
    Socket[] mClientsConnectedToServer;
    // Stores all of the data on the server.
    // Ideally, we'll use this to broadcast out to clients connected.
    char[80][] mServerData;
    // Keeps track of the last message that was broadcast out to each client.
    uint[] mCurrentMessageToSend;
    // buffer will be large enough to send/receive Packet.sizeof
    byte[Packet.sizeof] buffer;
    // all the packets to send
    Packet[] mServerState;

    /// Constructor
    /// By default I have choosen localhost and a port that is likely to be free.
    /***********************************
     * Constructs a TCPServer on default host and port.
     */
    private this(){
        host = "localhost";
        port = 50001;
        maxConnectionsBacklog=4;
        writeln("Opening default server...");
        writeln("Server must be started before clients may join.");
        // Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
        // Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
        //       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
        mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        // Set the hostname and port for the socket
        // NOTE: It's possible the port number is in use if you are not able
        //  	 to connect. Try another one.
        // When we 'bind' we are assigning an address with a port to a socket.
        mListeningSocket.bind(new InternetAddress(host,port));
        // 'listen' means that a socket can 'accept' connections from another socket.
        // Allow 4 connections to be queued up in the 'backlog'
        mListeningSocket.listen(maxConnectionsBacklog);
        writeln("Awaiting client connections");
    }

    /***********************************
     * Constructs a TCPServer on a specified host and port.
     * Params:
	 * - `string host`: host name
	 * - `ushort port`: port number
     * - `ushort maxConnectionsBacklog`: max connections to allow to wait.
     */
    this(string host, ushort port, ushort maxConnectionsBacklog=4) {
        writeln("Opening server on host " ~ host ~ "...");
        writeln("Server must be started before clients may join.");
        mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        mListeningSocket.bind(new InternetAddress(host,port));
        mListeningSocket.listen(maxConnectionsBacklog);
        writeln("Awaiting client connections");
    }

    /// Destructor
    ~this(){
        // Close our server listening socket
        // If it was never opened, no need to call close
        mListeningSocket.close();
        writeln("server socket closed!");
    }

    /***********************************
     * Listens for new client connections and packets from clients.
     * Params: None
     */
    void next() {
        // Clear the readSet
        readSet.reset();
		// Add the server
        readSet.add(mListeningSocket);
        foreach(client ; mClientsConnectedToServer){
            // Check if the socket isAlive
            if(client.isAlive){
                readSet.add(client);
            }
        }
        // clear the server state
        mServerState = [];
        // Handle each clients message
        // Socket.select returns num clients in the readset that are
        // waiting and ready to read
        if(Socket.select(readSet, null, null)){
            foreach(clientSocket; mClientsConnectedToServer){
				// Check to ensure that the client
				// is in the readSet before receving
				// a message from the client.
                if(readSet.isSet(clientSocket)){
                    try {
                        // Server effectively is blocked
                        // until a message is received here.
                        // When the message is received, then
                        // we send that message from the 
                        // server to the client
                        auto got = clientSocket.receive(buffer);
                        
                        if (got > 0) {
                            // Setup a packet to echo back
                            // to the client
                            Packet p;
                            p.userName 	= cast(char[])buffer[0 .. 16].dup;
                            byte[4] field1 =  buffer[16 .. 20].dup;
                            byte[4] field2 =  buffer[20 .. 24].dup;
                            int f1 = *cast(int*)&field1;
                            int f2 = *cast(int*)&field2;
                            p.xPos = f1;
                            p.yPos = f2;
                            p.message = cast(char[])buffer[24 .. 88].dup;
                            p.spritePath = cast(char[])buffer[88 .. 120];
                            byte[4] e = buffer[120 .. got].dup;
                            p.emojiNum = *cast(int*)&e;
                            
                            mServerState ~= p;
                        }
                    } catch (SocketOSException e) {
                        // basically do nothing and exit the loop.
                        writeln("no client messages received yet.");
                    }
					
                }
            }
			// The listener is ready to read
			// Client wants to connect so we accept here.
			if(readSet.isSet(mListeningSocket)){
                // mListeningSocket.blocking = false;
                try {
                    auto newSocket = mListeningSocket.accept();
                    writeln("type of new Socket",typeid(newSocket));
                    // Add a new client to the list
                    mClientsConnectedToServer ~= newSocket;
                    // Tell client how many clients are now in the server
                    ulong numClients = mClientsConnectedToServer.length;
                    ubyte[] payload = (cast(ubyte*) &numClients)[0 .. numClients.sizeof];
                    writeln("numClients in server: ", numClients);
                    newSocket.send(payload);
                    writeln("> client",mClientsConnectedToServer.length," added to mClientsConnectedToServer");
                } catch (SocketOSException e) {
                    // basically do nothing and exit the loop.
                }
			}
            broadcastToAllClients();
    	}
    }

    /// The purpose of this function is to broadcast
    /// packets to all of the clients that are currently
    /// connected.
    /***********************************
     * Broadcasts packets to all the clients that are currently connected.
     */
    void broadcastToAllClients(){
        // writeln("Broadcasting to :", mClientsConnectedToServer.length);
        foreach(client; mClientsConnectedToServer) {
            foreach(p; mServerState) {
                client.send(p.GetPacketAsBytes());
            }
        }
    }
}