module emoji;
// Load the SDL2 library
import bindbc.sdl;
import std.process;
import std.stdio;
import std.conv;
import std.string : toStringz;

/***********************************
* This struct represents a single emoji that will be rendered in the emoji menu.
*/
struct Emoji_Option{
    int mXPos;
    int mYPos;
    TTF_Font* font;
    SDL_Color text_color = {255, 255, 255};
    int emoji_number;
    SDL_Rect emoji_img_rect;
    SDL_Rect emoji_num_rect;
    SDL_Texture* num_texture;
    SDL_Texture* emoji_texture;

    /***********************************
     * Constructs an Emoji with the specified renderer, image file, number of the emoji, and location.
     * Params:
     *       renderer = The SDL renderer for rendering.
     *       filepath = The file path to the BMP image for the player's sprite.
     *       emoji_num = The number of the emoji in the menu
     *       XPos, YPos = The location of the emoji on screen.
     */
    this(SDL_Renderer* renderer, string filepath,int emoji_num,int XPos,int YPos){
        //load the font of the emoji number.
        font = TTF_OpenFont("./assets/fonts/Minecraft.ttf",24);

        if (font is null){
            writeln("Could not load font");
        }
        emoji_number = emoji_num;
        mXPos = XPos;
        mYPos = YPos;
        //Pixels from our text
        string textToRender = to!string(emoji_num);
        SDL_Surface* numberSurf = TTF_RenderText_Solid(font,textToRender.toStringz(),text_color);
        // Setup the emoji number as a texture
        num_texture = SDL_CreateTextureFromSurface(renderer,numberSurf);
        SDL_FreeSurface(numberSurf);

        // set up the rectangle on the top of the sprite to render the user name.
        emoji_num_rect.x = mXPos + 17;
        emoji_num_rect.y = mYPos - 30;
        emoji_num_rect.w = 25;
        emoji_num_rect.h = 28;

        // Load the bitmap surface
        SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
        // Create a texture from the surface
        emoji_texture = SDL_CreateTextureFromSurface(renderer,myTestImage);
        // Done with the bitmap surface pixels after we create the texture, we have
        // effectively updated memory to GPU texture.
        SDL_FreeSurface(myTestImage);
        // Rectangle is where we will represent the shape
        emoji_img_rect.x = mXPos;
        emoji_img_rect.y = mYPos;
        emoji_img_rect.w = 60;
        emoji_img_rect.h = 60;
    }

    /***********************************
     * Renders the emoji option based on a specific renderer.
     * Params:
     *      renderer = The SDL renderer for rendering.
     * Return: None.
     */
    void Render(SDL_Renderer* renderer){
        //Render our number on a rectangle
        SDL_RenderCopy(renderer,num_texture,null,&emoji_num_rect);

        // Render our emoji image on a rectangle.
        SDL_RenderCopy(renderer,emoji_texture,null,&emoji_img_rect);
    }
}

/***********************************
* This struct represents a emoji menu that will be rendered when the user enters the emoji
* sharing mode. There will be a total of five different emojis for each user to choose. A number
* that representing the code of the emoji will be rendered at the top of each emoji.
*/
struct Emoji_menu{
    // Use an array to store the emoji options .
    Emoji_Option[5] emojiArray;
    int window_width;
    int window_height;


    /***********************************
     * Constructs an Emoji menu with the specified renderer.
     * Params:
     *       renderer = The SDL renderer for rendering.
     *       w = the width of the emoji image.
     *       h = the height of the emoji image.
     */
    this(SDL_Renderer* renderer,int w, int h){
        // Set the width and height of the window.
        window_width = w;
        window_height = h;
        //Calculate the position to render the emoji options dynamically.
        int[5] emoji_x_pos;
        int offset = 100;
        int emoji_width = 60;
        int interval = to!int((window_width - 2 * offset - 5 * emoji_width)/4);
        int start = 100;
        for (int i = 0; i < 5; ++i) {
            emoji_x_pos[i] = start;
            start += interval + emoji_width;
        }
        int emoji_y_pos = window_height - emoji_width - 20;

        //init the emoji slots.
        emojiArray[0] = Emoji_Option(renderer,"./assets/images/emoji1.bmp",1,emoji_x_pos[0],emoji_y_pos);
        emojiArray[1] = Emoji_Option(renderer,"./assets/images/emoji2.bmp",2,emoji_x_pos[1],emoji_y_pos);
        emojiArray[2] = Emoji_Option(renderer,"./assets/images/emoji3.bmp",3,emoji_x_pos[2],emoji_y_pos);
        emojiArray[3] = Emoji_Option(renderer,"./assets/images/emoji4.bmp",4,emoji_x_pos[3],emoji_y_pos);
        emojiArray[4] = Emoji_Option(renderer,"./assets/images/emoji5.bmp",5,emoji_x_pos[4],emoji_y_pos);
    }

    /***********************************
     * Renders the emoji menu based on a specific renderer.
     * Params:
     *      renderer = The SDL renderer for rendering.
     * Return: None.
     */
    void Render(SDL_Renderer* renderer){
        // Rendering the background as a rectangle.
        SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND);
        SDL_Rect background_rect;
        background_rect.x = 0;
        background_rect.y = window_height - 120;
        background_rect.w = window_width;
        background_rect.h = window_height - background_rect.y - 10;
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 128);
        SDL_RenderFillRect(renderer, &background_rect);


        //Render each of the emoji slots on screen.
        // Loop through each Emoji in the emojiArray
        foreach (emoji; emojiArray) {
            emoji.Render(renderer);
        }
    }
}

