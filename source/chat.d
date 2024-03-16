module chat;
// Load the SDL2 library
import bindbc.sdl;
import std.process;
import std.stdio;
import std.conv;
import std.string : toStringz;
import std.range;

/***********************************
 * Struct to manage chat history and rendering.
 */
struct Chat_history{
    int window_width;
    int window_height;
    // Array of arrays to store [username, message]
    string[][] chatData;
    TTF_Font* font;
    SDL_Color text_color = {255, 255, 255};
    SDL_Rect[5] messages;
    SDL_Rect[5] usrnames;
    SDL_Texture* text;
    SDL_Texture* usrname_texture;

    /***********************************
    * Appends the most recent chat to the end of the chatData array.
    *
    * Params:
    * - `username`: A string representing the username of the chat sender.
    * - `message`: A string representing the message sent by the user.
    */
    void updateChatData(string username, string message){
        chatData ~= [username,message];
    }

     /***********************************
     * Initializes the SDL_Renderer, sets window width and height, and initializes the font.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     * - `w`: Integer representing the window width.
     * - `h`: Integer representing the window height.
     */
    void Init(SDL_Renderer* renderer,int w,int h){
        //Initialize the font.
        font = TTF_OpenFont( "./assets/fonts/Minecraft.ttf", 28 );
        window_width = w;
        window_height = h;
        chatData =  [];
    }

    /***********************************
     * Renders the chat history.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     */
    void Render(SDL_Renderer* renderer){
        //only render the most recent 5 messages.
        if (chatData.length > 0) {
            int startIndex = to!int(chatData.length) - 5;
            if(startIndex < 0 ){
                startIndex = 0;
            }
            string[][] lastFiveMessages = chatData[startIndex .. $];

            //initialize the rectangle for background.
            SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
            SDL_Rect background_rect;
            background_rect.x = 0;
            background_rect.y = window_height - 95 - 28 * to!int(lastFiveMessages.length);
            background_rect.w = window_width;
            background_rect.h = window_height - background_rect.y - 70;
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 128);
            SDL_RenderFillRect(renderer, &background_rect);

            //loop through and render each entry.
            int y_pos = window_width - 64;
            int x_pos = 15;

            for (int i = 0; i < lastFiveMessages.length; ++i) {
                //initialize the rectangle for username
                string username = lastFiveMessages[i][0] ~ ":\0";
                SDL_Surface* usrname_surf = TTF_RenderText_Solid(font, username.ptr, text_color);
                usrname_texture = SDL_CreateTextureFromSurface(renderer, usrname_surf);
                SDL_Rect username_rect = usrnames[i];
                username_rect.x = x_pos;
                username_rect.y = to!int(y_pos - usrname_surf.h *(lastFiveMessages.length - i) - 15);

                username_rect.w = usrname_surf.w;
                username_rect.h = usrname_surf.h;
                SDL_RenderCopy(renderer, usrname_texture, null, &username_rect);

                SDL_DestroyTexture(usrname_texture);
                SDL_FreeSurface(usrname_surf);

                // initialize the rectangle for message
                SDL_Surface* text_surf = TTF_RenderText_Solid(font, lastFiveMessages[i][1].ptr, text_color);
                text = SDL_CreateTextureFromSurface(renderer, text_surf);
                SDL_Rect message_rect = messages[i];
                message_rect.x = username_rect.x + username_rect.w + 15;
                message_rect.y = username_rect.y;
                message_rect.w = text_surf.w;
                message_rect.h = text_surf.h;
                SDL_RenderCopy(renderer, text, null, &message_rect);

                SDL_DestroyTexture(text);
                SDL_FreeSurface(text_surf);
            }
        }
        
    }
}

/***********************************
 * Thid struct manages the chatbox. It allows the user to type his message and updates the string
 * typed on screen.
 */
struct Chatbox{
    int window_width;
    int window_height;

    TTF_Font* font;
    SDL_Color text_color = {255, 255, 255};
    string username;
    string text_input = "";
    SDL_Rect dest;
    SDL_Rect username_rect;
    SDL_Texture* text;
    SDL_Texture* usrname_texture;

    /***********************************
     * Updates the input text.
     *
     * Params:
     * - `newInput`: A string representing the new input text.
     */
    void updateInput(string newInput){
        text_input = newInput;
    }

    /***********************************
     * Initializes the chatbox.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     * - `w`: Integer representing the window width.
     * - `h`: Integer representing the window height.
     * - `username_input`: A string representing the username.
     */
    void initChat(SDL_Renderer* renderer,int w,int h,string username_input){
        //Initialize the font.
        font = TTF_OpenFont( "./assets/fonts/Minecraft.ttf", 28 );
        window_width = w;
        window_height = h;
        // Set the username.
        username = username_input[0 .. username_input.walkLength];
    }

    /***********************************
     * Renders the chatbox background.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     */
    void renderBackground(SDL_Renderer* renderer){
        // testing rendering the background as a rectangle.
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
        SDL_Rect rect;
        rect.x = 0;
        rect.y = window_height - 64;
        rect.w = window_width;
        rect.h = window_height - rect.y - 10;
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 128);
        SDL_RenderFillRect(renderer, &rect);
    }

    /***********************************
     * Renders the username in the chatbox.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     */
    void renderUsername(SDL_Renderer* renderer){
        string username_prompt = username ~ ">\0";
        SDL_Surface* usrname_surf = TTF_RenderText_Solid(font, username_prompt.ptr, text_color);
        usrname_texture = SDL_CreateTextureFromSurface(renderer, usrname_surf);
        username_rect.x = to!int(15);
        username_rect.y = to!int(window_height - usrname_surf.h - 20);
        username_rect.w = usrname_surf.w;
        username_rect.h = usrname_surf.h;
        SDL_RenderCopy(renderer, usrname_texture, null, &username_rect);

        SDL_DestroyTexture(usrname_texture);
        SDL_FreeSurface(usrname_surf);

    }


    /***********************************
     * Renders the chat text in the chatbox.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer.
     */
    void renderChat(SDL_Renderer* renderer){
        if ( text_input.length > 0 ) {
            SDL_Surface* text_surf = TTF_RenderText_Solid(font, text_input.toStringz(), text_color);
            text = SDL_CreateTextureFromSurface(renderer, text_surf);
            dest.x = username_rect.x + username_rect.w + 15;
            dest.y = to!int(window_width - text_surf.h - 20);
            dest.w = text_surf.w;
            dest.h = text_surf.h;
            SDL_RenderCopy(renderer, text, null, &dest);

            SDL_DestroyTexture(text);
            SDL_FreeSurface(text_surf);
        }
    }
}
