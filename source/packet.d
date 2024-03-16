// @file Packet.d
import core.stdc.string;

// NOTE: Consider the endianness of the target machine when you 
//       send packets. If you are sending packets to different
//       operating systems with different hardware, the
//       bytes may be flipped!
//       A test you can do is to when you send a packet to a
//       operating system is send a 'known' value to the operating system
//       i.e. some number. If that number is expected (e.g. 12345678), then
//       the byte order need not be flipped.
struct Packet {
	// NOTE: Packets usually consist of a 'header'
	//   	 that otherwise tells us some information
	//  	 about the packet. Maybe the first byte
	// 	 	 indicates the format of the information.
	// 		 Maybe the next byte(s) indicate the length
	// 		 of the message. This way the server and
	// 		 client know how much information to work
	// 		 with.
	// For this example, I have a 'fixed-size' Packet
	// for simplicity -- effectively cramming every
	// piece of information I can think of.

	char[16] userName; // Perhaps a unique identifier 
    int xPos;
    int yPos;
    char[64] message; // for debugging909
    char[32] spritePath;
	int emojiNum;
    // in the future we can add another int here for
    // which spriteNum to render for the client


	/// Purpose of this function is to pack a bunch of
    /// bytes into an array for 'serialization' or otherwise
	/// ability to send back and forth across a server, or for
	/// otherwise saving to disk.	
    char[Packet.sizeof] GetPacketAsBytes(){
		// user = "test user\0";
        // message = "test message\0";
        char[Packet.sizeof] payload;
		// Populate the payload with some bits
		// I used memmove for this to move the bits.
        // point start of user array address to the start of payload array addess
        // (a pointer points to the beginning of its address,
        // so automatically putting user at slot 0 of payload)
		memmove(&payload,&userName,userName.sizeof);
		// Populate the color with some bytes
		// import std.stdio;
		// writeln("xPos is:",xPos);
		// writeln("yPos is:",yPos);
        // put x at byte 16
		memmove(&payload[16],&xPos,xPos.sizeof);
        // put y at byte 0
		memmove(&payload[20],&yPos,yPos.sizeof);

        memmove(&payload[24],&message,message.sizeof);
        memmove(&payload[88],&spritePath,spritePath.sizeof);
		memmove(&payload[120],&emojiNum,emojiNum.sizeof);

        return payload;
    }

	
}
