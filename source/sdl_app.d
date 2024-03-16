module sdl_app;
// Import D standard libraries
import std.stdio;
import std.string;
import std.array;
import std.conv;
import std.algorithm;
import std.ascii;
import std.string : toStringz;

//import setup_sdl;
import sprite;
import tilemap;
import player;
import window;
import client;
import server;
import chat;
import emoji;

// Load the SDL2 library
import bindbc.sdl;
import bindbc.sdl.ttf;

/***********************************
 * The main class that runs the program.
 */
class SDLApp {
    Window window;
    SDL_Renderer* renderer;
    TileSet tileset;
    DrawableTileMap dt;
    Player player;
    TCPServer mServer;
    TCPClient mClient;
    Player[string] connectedPlayers; // list of Player, index is the sprite's username
    string[] playerFilePaths = ["./assets/images/cutie.bmp",
                                "./assets/images/cutie2.bmp",
                                "./assets/images/kimono.bmp"];
    string mName;

    bool type_mode = false;
    bool emoji_sharing_mode = false;
    string text_input = "";
    Chatbox chatbox;
    Chat_history history;
    Emoji_menu emoji_menu;
    string mHost;
    ushort mPort;

    /***********************************
     * Constructs an SDLApp as a host, on a specified host and port, given a player username, host, and port.
     * Contains the server.
     * Params:
     * - `TCPServer serv`: server hosting the game
	 * - `string name`: player name
	 * - `string host`: host name
	 * - `ushort port`: port number
     */
    this(TCPServer serv, string name,string host,ushort port){
        mHost = host;
        mPort = port;
        window.w = 768;
        window.h = 768;
        window.window = SDL_CreateWindow("D SDL Tilemap Example",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        window.w,
        window.h,
        SDL_WINDOW_SHOWN);
        renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
        tileset = TileSet(renderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16,12,11);
        dt = DrawableTileMap(tileset);
        mName = name;
        connectedPlayers.clear();
        history.Init(renderer,window.w,window.h);
        chatbox.initChat(renderer,window.w,window.h,name);
        emoji_menu = Emoji_menu(renderer,window.w,window.h);
        mServer = serv;
        writeln(mServer.host, mServer.port);
    }

    /***********************************
     * Constructs an SDLApp on a specified host and port, given a player username, host, and port.
     * Params:
	 * - `string name`: player name
	 * - `string host`: host name
	 * - `ushort port`: port number
     */
    this(string name, string host, ushort port){
        mHost = host;
        mPort = port;
        // Create an SDL window
        window.w = 768;
        window.h = 768;
        window.window = SDL_CreateWindow("HuskyLand",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        window.w,
        window.h,
        SDL_WINDOW_SHOWN);
        // Create a hardware accelerated renderer
        renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
        // Load our tiles from an image
        tileset = TileSet(renderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16,12,11);
        dt = DrawableTileMap(tileset);
        // Create our player
        mName = name;
        connectedPlayers.clear();
        // Init chat history.
        history.Init(renderer,window.w,window.h);
        // Init our text chat
        chatbox.initChat(renderer,window.w,window.h,name);
        // Init our emoji menu
        emoji_menu = Emoji_menu(renderer,window.w,window.h);
    }



    
        /***********************************
        * Constructs an SDLApp for testing purposes
        * Params:
        *       None
        */
        this(){

        // Create an SDL window
        window.w = 768;
        window.h = 768;
        window.window = SDL_CreateWindow("HuskyLand",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        window.w,
                                        window.h,
                                        SDL_WINDOW_SHOWN);
        // Create a hardware accelerated renderer
        renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);

        // Load our tiles from an image
        tileset = TileSet(renderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16,12,11);
        dt = DrawableTileMap(tileset);
        // Create our player
        mName = "user1";
        connectedPlayers.clear();
        // Init chat history.
        history.Init(renderer,window.w,window.h);
        // Init our text chat
        chatbox.initChat(renderer,window.w,window.h,"user1");
        // Init our emoji menu
        emoji_menu = Emoji_menu(renderer,window.w,window.h);
    }


    /***********************************
     * Constructs an SDLApp on a default host and port, given a player username.
     * Params:
	 * - `string name`: player name
     */
    this(string name){

        // Create an SDL window
        window.w = 768;
        window.h = 768;
        window.window = SDL_CreateWindow("HuskyLand",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        window.w,
                                        window.h,
                                        SDL_WINDOW_SHOWN);
        // Create a hardware accelerated renderer
        renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);

        // Load our tiles from an image
        tileset = TileSet(renderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16,12,11);
        dt = DrawableTileMap(tileset);
        // Create our player
        mName = name;
        connectedPlayers.clear();
        // Init chat history.
        history.Init(renderer,window.w,window.h);
        // Init our text chat
        chatbox.initChat(renderer,window.w,window.h,name);
        // Init our emoji menu
        emoji_menu = Emoji_menu(renderer,window.w,window.h);
    }

     /***********************************
     * Constructs an SDLApp given a playername and a server to host it on.
     * Params:
	 * - `TCPServer serv`: server to host the app from
	 * - `string name`: player name
     */
    this(TCPServer serv, string name) {
        window.w = 768;
        window.h = 768;
        window.window = SDL_CreateWindow("D SDL Tilemap Example",
                                        SDL_WINDOWPOS_UNDEFINED,
                                        SDL_WINDOWPOS_UNDEFINED,
                                        window.w,
                                        window.h, 
                                        SDL_WINDOW_SHOWN);
        renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
        tileset = TileSet(renderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16,12,11);
        dt = DrawableTileMap(tileset);
        mName = name;
        connectedPlayers.clear();
        history.Init(renderer,window.w,window.h);
        chatbox.initChat(renderer,window.w,window.h,name);
        emoji_menu = Emoji_menu(renderer,window.w,window.h);
        mServer = serv;
        writeln(mServer.host, mServer.port);
    }

    /***********************************
    * This function calculates the index based on the client number
    * and returns the corresponding player file path from the array.
    *
    * Params:
    *       numClients = The number of clients.
    *       playerFilePaths = Array of player file paths.
    *
    * Returns: The file path for the specified client number.
    */
    string getClientToPlayerPath(int numClients, string[] playerFilePaths){
       int fileIndex = (numClients % cast(int)playerFilePaths.length).to!int;
       return playerFilePaths[fileIndex];
    }

    /***********************************
     * Game loop for the lobby area.
     * Params: None
     */
    void LobbyLoop(){
        bool lobbyIsRunning = true;
        bool gameIsRunning = false;
        int zoomFactor = 3;
        //main lobby loop
        while(lobbyIsRunning) {
            SDL_Event event;
            const ubyte* keyboard = SDL_GetKeyboardState(null);

            // (1) Handle Input
            // Start our event loop
            while(SDL_PollEvent(&event)){
                // Handle each specific event
                if(event.type == SDL_QUIT){
                    lobbyIsRunning = false;
                    destroy(window);
                }
            }

            if(keyboard[SDL_SCANCODE_Q]) {
                lobbyIsRunning = false;
            }

            if(keyboard[SDL_SCANCODE_KP_ENTER] || keyboard[SDL_SCANCODE_RETURN]){
                writeln("Entering Huskyland!");
                lobbyIsRunning = false;
                gameIsRunning = true;
            }

            // (3) Clear and Draw the Screen
            // Gives us a clear "canvas"
            SDL_SetRenderDrawColor(renderer,100,190,255,SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);
            dt.Render(renderer,zoomFactor);
            renderLobbyText(renderer);
            SDL_RenderPresent(renderer);

        }
        if (gameIsRunning) {
            this.MainApplicationLoop();
        }

        destroy(window);

    }

    /***********************************
     * Main game loop.
     * Params: None
     */
    void MainApplicationLoop(){
        mClient = new TCPClient(mHost,mPort,this);
        int curNumClients = cast(int)mClient.getWelcomedToServer();
        player = Player(renderer, getClientToPlayerPath(curNumClients, playerFilePaths), 50, 50, mName);

        // Infinite loop for our application
        bool gameIsRunning = true;
        // How 'zoomed' in are we
        int zoomFactor = 3;
        dt.setDefaultTiles();
        bool firstLoop = true;

        // Main application loop
        SDL_StartTextInput();
        while(gameIsRunning){
            SDL_Event event;
            bool moved;

            // (1) Handle Input
            // Start our event loop
            while(SDL_PollEvent(&event)){

                // Handle each specific event
                if(event.type == SDL_QUIT){
                    gameIsRunning = false;
                }
                // If text input is detected and the user is in type mode, handle the input.
                if(event.type == SDL_TEXTINPUT && type_mode){
                    text_input ~= event.text.text[0];
                    text_input.filter!(c => isPrintable(c));
                    chatbox.updateInput(text_input);
                }
                if(event.type == SDL_KEYDOWN && type_mode){
                    // Handle delete
                    if (event.key.keysym.sym == SDLK_BACKSPACE && text_input.length) {
                        text_input = text_input[0 .. $ - 1];
                        text_input.filter!(c => isPrintable(c));
                        chatbox.updateInput(text_input);
                    }
                    //Handle copy
                    else if( event.key.keysym.sym == SDLK_c && SDL_GetModState() & KMOD_CTRL ){
                        SDL_SetClipboardText( text_input.toStringz() );
                    }
                    //Handle paste
                    else if( event.key.keysym.sym == SDLK_v && SDL_GetModState() & KMOD_CTRL ){
                            const(char*) cString= SDL_GetClipboardText();
                            text_input = to!string(cString);
                            chatbox.updateInput(text_input);
                        }
                }
            }

            // Get Keyboard input
            const ubyte* keyboard = SDL_GetKeyboardState(null);

            if(!type_mode && keyboard[SDL_SCANCODE_Q]) {
                gameIsRunning = false;
            }

            // need to make a function adds players to array and gets their x and y coordinates

            int playerX = player.GetX();
            int playerY = player.GetY();

            // Check if it's legal to move a direction
            // TODO: Consider moving this into a function
            //       e.g. 'legal move' 

            // Check for movement
            if(keyboard[SDL_SCANCODE_LEFT] || (!type_mode && keyboard[SDL_SCANCODE_A])){
                if(!dt.IsBoundaryTile(dt.GetTileAt(playerX, playerY, zoomFactor))){
                    player.MoveLeft();
                    moved = true;
                }
            }
            if(keyboard[SDL_SCANCODE_RIGHT] || (!type_mode && keyboard[SDL_SCANCODE_D])){
                if (!dt.IsBoundaryTile(dt.GetTileAt(playerX + 48, playerY, zoomFactor))){
                    player.MoveRight();
                    moved = true;
                }
            }
            if(keyboard[SDL_SCANCODE_UP] || (!type_mode && keyboard[SDL_SCANCODE_W])){
                 if (!dt.IsBoundaryTile(dt.GetTileAt(playerX, playerY, zoomFactor))){
                     player.MoveUp();
                    moved = true;
                }
            }
            if(keyboard[SDL_SCANCODE_DOWN] || (!type_mode && keyboard[SDL_SCANCODE_S])){
                if (!dt.IsBoundaryTile(dt.GetTileAt(playerX, playerY + 64, zoomFactor))){
                    player.MoveDown();
                    moved = true;
                }
            }

            // Enter or quit the typing mode by pressing the T button or ESC.
            if(!emoji_sharing_mode && keyboard[SDL_SCANCODE_T]){
                type_mode = true;
            }
            if(type_mode && keyboard[SDL_SCANCODE_ESCAPE]){
                type_mode = false;
            }
            
            // add chat to chat history
            bool chatSent = false;
            string chatToBroadcast;
            if(text_input != "" && type_mode == true && (keyboard[SDL_SCANCODE_RETURN] || keyboard[SDL_SCANCODE_KP_ENTER])){
                import std.range;
                // history.updateChatData(player.username,text_input~"\0");
                chatToBroadcast = text_input.dup;
                chatSent = true;
                text_input = "";
                chatbox.updateInput("");
            }
            // Enter or quit the emoji sharing mode by pressing the E button or ESC.
            if(!type_mode && keyboard[SDL_SCANCODE_E]){
                emoji_sharing_mode = true;
                writeln("EMOJI:",emoji_sharing_mode);
            } else if(emoji_sharing_mode && keyboard[SDL_SCANCODE_ESCAPE]){
                emoji_sharing_mode = false;
                writeln("EMOJI:",emoji_sharing_mode);
            }

            //Check for emoji selection and change the emojiNum value
            bool emojiChanged = false;
            if (emoji_sharing_mode) {
                int e = player.emojiNum;
                if(keyboard[SDL_SCANCODE_1]){
                    if (e == 1){
                        e = 0;
                    } else {
                        e = 1;
                    }
                } else if(keyboard[SDL_SCANCODE_2]){
                    if (e == 2){
                        e = 0;
                    } else {
                        e = 2;
                    }
                } else if(keyboard[SDL_SCANCODE_3]){
                    if (e == 3){
                        e = 0;
                    } else {
                        e = 3;
                    }
                } else if(keyboard[SDL_SCANCODE_4]){
                    if (e == 4){
                        e = 0;
                    } else {
                        e = 4;
                    }
                } else if(keyboard[SDL_SCANCODE_5]){
                    if (e == 5){
                        e = 0;
                    } else {
                        e = 5;
                    }
                }
                if (e != player.emojiNum) {
                    writeln("setting player.emojiNum = ", e);
                    emojiChanged = true;
                    player.emojiNum = e;
                }
            }

            // (2) Handle Updates
            if (moved || firstLoop || emojiChanged || chatSent) {
                mClient.sendPacket(player.getUsername(), player.GetX(), player.GetY(), chatToBroadcast, player.getSpritePath(), player.emojiNum);
                firstLoop = false;
            }
            mClient.receiveData();


            // (3) Clear and Draw the Screen
            // Gives us a clear "canvas"
            SDL_SetRenderDrawColor(renderer,100,190,255,SDL_ALPHA_OPAQUE);
            SDL_RenderClear(renderer);

            // NOTE: The draw order here is very important
            //       We follow the 'painters algorithm' in 2D
            //       meaning that we draw the background first,
            //       and then our objects on top.


            // Render out DrawableTileMap
            dt.Render(renderer,zoomFactor);

            // Draw all players
            foreach(player; connectedPlayers) {
                player.Render(renderer);
                if (player.emojiNum != 0) {
                    player.RenderEmojiShared(renderer);
                }   
            }
                 
            // Draw the tile preview just so we can see all the different tiles in the tile map
            // ts.ViewTiles(renderer,480,400,8);

            if(!type_mode && keyboard[SDL_SCANCODE_SPACE]){
                tileset.TileSetSelector(renderer);
            }

            if(type_mode){
                history.Render(renderer);
                chatbox.renderBackground(renderer);
                chatbox.renderUsername(renderer);
                chatbox.renderChat(renderer);
            }

            if(emoji_sharing_mode){
                emoji_menu.Render(renderer);
            }
            
            // Little frame capping hack so we don't run too fast
            SDL_Delay(125);

            // Finally show what we've drawn
            // (i.e. anything where we have called SDL_RenderCopy will be in memory and presnted here)
            SDL_RenderPresent(renderer);
        }

        // Destroy everything
        destroy(mServer);
        mClient.sendPacket(player.getUsername(),0,0,"quitting","",0);
        destroy(mClient);
        destroy(window);
    }

    /***********************************
     * Renders the text in the lobby.
     * Params:
	 * - `SDL_Renderer* renderer`: a ponter to this SDLApp's renderer.
     */
    void renderLobbyText(SDL_Renderer* renderer) {
        renderLobbyWelcome(renderer);
        renderLobbyStartMessage(renderer);
    }

    /***********************************
     * Renders the welcome message in the lobby.
     * Params:
	 * - `SDL_Renderer* renderer`: a ponter to this SDLApp's renderer.
     */
    void renderLobbyWelcome(SDL_Renderer* renderer) {
        TTF_Font* font = TTF_OpenFont( "./assets/fonts/Minecraft.ttf", 45);
        
        SDL_Surface* welcomeSurface;
        SDL_Texture* welcomeTexture;
        welcomeSurface = TTF_RenderText_Solid(font, "WELCOME TO HUSKYLAND!", SDL_Color(255, 255, 255));
        welcomeTexture = SDL_CreateTextureFromSurface(renderer, welcomeSurface);
        SDL_Rect welcomeRect = SDL_Rect(window.w/2 - welcomeSurface.w/2,
                                        window.h/2 - welcomeSurface.h,
                                        welcomeSurface.w,
                                        welcomeSurface.h);

        SDL_RenderCopy(renderer, welcomeTexture, null, &welcomeRect);
        SDL_DestroyTexture(welcomeTexture);
        SDL_FreeSurface(welcomeSurface);
    }

    /***********************************
     * Renders the start message in the lobby.
     * Params:
	 * - `SDL_Renderer* renderer`: a ponter to this SDLApp's renderer.
     */
    void renderLobbyStartMessage(SDL_Renderer* renderer) {
        TTF_Font* font = TTF_OpenFont( "./assets/fonts/Minecraft.ttf", 30);

        SDL_Surface* msgSurface;
        SDL_Texture* msgTexture;
        msgSurface = TTF_RenderText_Solid(font, "Press Enter to Join", SDL_Color(255, 255, 255));
        msgTexture = SDL_CreateTextureFromSurface(renderer, msgSurface);
        SDL_Rect msgRect = SDL_Rect(window.w/2 - msgSurface.w/2,
                                        window.h/2,
                                        msgSurface.w,
                                        msgSurface.h);

        SDL_RenderCopy(renderer, msgTexture, null, &msgRect);
        SDL_DestroyTexture(msgTexture);
        SDL_FreeSurface(msgSurface);
    }

    /***********************************
     * Returns a pointer to this SDLApp's renderer.
     * Params: None
     */
    SDL_Renderer* getRenderer() {
        return renderer;
    }

    /***********************************
     * Finds and updates the given player in connectedPlayer list.
     * Params:
	 * - `Player p`: the player containing new information.
     */
    void updatePlayerInConnectedList(Player p, string msg) {
        auto playerptr = p.getUsername in connectedPlayers;
        Sprite* spriteptr = &playerptr.mSprite;
        if (playerptr !is null) {
            playerptr.emojiNum = p.emojiNum;
            bool moved = false;
            if (playerptr.GetX() < p.GetX()) {
                playerptr.MoveRight();
                moved = true;
            } else if (playerptr.GetX() > p.GetX()) {
                playerptr.MoveLeft();
                moved = true;
            }
            if (playerptr.GetY() < p.GetY()) {
                playerptr.MoveDown();
                moved = true;
            } else if (playerptr.GetY() > p.GetY()) {
                playerptr.MoveUp();
                moved = true;
            }
            if (moved) {
                spriteptr.mFrame++;
                if (spriteptr.mFrame > 3){
                    spriteptr.mFrame =0;
                }
            }
        } else {
            connectedPlayers[p.getUsername] = p;
            mClient.sendPacket(player.getUsername(), player.GetX(), player.GetY(), "", player.getSpritePath(), player.emojiNum);
        }
        if (msg != "") {
            if (msg == "quitting") {
                connectedPlayers.remove(p.getUsername);
            }
            history.updateChatData(p.username,msg~"\0");
            if (type_mode) {
                history.Render(renderer);
                chatbox.renderBackground(renderer);
                chatbox.renderUsername(renderer);
                chatbox.renderChat(renderer);
            }
        }
    }
}