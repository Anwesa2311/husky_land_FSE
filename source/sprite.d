module sprite;

// Load the SDL2 library
import bindbc.sdl;
import std.process;
import std.stdio;
import std.conv;

import bindbc.sdl.ttf;

/// Store state for sprites and very simple animation
enum STATE{
    IDLE,
    WALK}
;

/// Sprite that holds a texture and position
/***********************************
* This struct encapsulates the state of a sprite, including its position, texture,
* and frame for animation.
*/
struct Sprite{
    int mXPos=50;
    int mYPos=50;
    SDL_Rect mRectangle;
    SDL_Rect usrRectangle;
    SDL_Texture* mTexture;
    int mFrame;
    string userName;
    string spritePath;

    SDL_Rect emojiRectangle;
    SDL_Texture* emojiTexture;
    SDL_Color text_color = {255, 255, 255};

    STATE mState;

    int mAnimationRow;

    /***********************************
		* Constructs a Sprite with the specified renderer and image file.
		* Params:
		* 		renderer = The SDL renderer for rendering tiles.
		* 		filepath = The file path to the BMP image for the sprite.
		*/
    this(SDL_Renderer* renderer, string filepath, int startX, int startY, string username){
        // set the username to be rendered.
        userName = username~"\0";
        spritePath = filepath;

        // Load the bitmap surface
        SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
        // Create a texture from the surface
        mTexture = SDL_CreateTextureFromSurface(renderer,myTestImage);
        // Done with the bitmap surface pixels after we create the texture, we have
        // effectively updated memory to GPU texture.
        SDL_FreeSurface(myTestImage);

        //userName = "JasonJason";
        mXPos = startX;
        mYPos = startY;

        // Rectangle is where we will represent the shape
        mRectangle.x = mXPos;
        mRectangle.y = mYPos;
        mRectangle.w = 64;
        mRectangle.h = 64;
        mAnimationRow = 0;
    }

    /***********************************
     * Gets the width of the sprite.
     * Params:
     *      None
     * Returns: Width of the sprite.
     */
    int getRectangleWidth(){
        return mRectangle.w;
    }

    /***********************************
     * Gets the height of the sprite.
     * Params:
     *      None
     * Returns: Height of the sprite.
     */
    int getRectangleHeight(){
        return mRectangle.h;
    }

    /***********************************
     * Sets the animation row for the sprite.
     * Params:
     *      animationRow = The animation row to set.
     * Returns: None.
     */
    void SetAnimationRow(int animationRow) {
        mAnimationRow = animationRow;
    }

    /***********************************
    * Renders the sprite.
    * Params: 
    * 		renderer = The SDL renderer for rendering.
    * Returns: None.
    */
    void Render(SDL_Renderer* renderer){
        // load the font file(ttf format) for the username.
        TTF_Font* font = TTF_OpenFont("./assets/fonts/Minecraft.ttf",24);
        if (font is null){
            writeln("Could not load font");
        }
        userName~="\0";
        // Generate the pixels for the text to render
        SDL_Surface* textSurf = TTF_RenderText_Solid(font,userName.ptr,text_color);
        // Setup the surface as a texture
        SDL_Texture* textureText = SDL_CreateTextureFromSurface(renderer,textSurf);

        // set up the rectangle on the top of the sprite to render the user name.
        int sprite_width = 64;
        usrRectangle.x = (mXPos + sprite_width/2) - to!int(textSurf.w/2);
        usrRectangle.y = mYPos - 10;
        usrRectangle.w = textSurf.w;
        usrRectangle.h = textSurf.h;

        //Render our text on a rectangle
        SDL_RenderCopy(renderer,textureText,null,&usrRectangle);

        // Destroy our textured text
        SDL_DestroyTexture(textureText);
        SDL_FreeSurface(textSurf);


        // set up the rectangle to render the sprite.
        SDL_Rect selection;
        selection.x = 64 * mFrame;
        selection.y = 64 * mAnimationRow;;
        selection.w = 64;
        selection.h = 64;

        mRectangle.x = mXPos;
        mRectangle.y = mYPos;

        SDL_RenderCopy(renderer,mTexture,&selection,&mRectangle);

        if (mState == STATE.WALK){
            mFrame++;
            if (mFrame > 3){
                mFrame =0;
            }
        }
    }

    /***********************************
     * Renders an emoji on the screen at a specific position.This function loads an image corresponding to the provided emoji number
     * from the specified file path and renders it on the screen at a specific position.
     * It assumes the image format to be BMP.
     *
     * Params:
     * - `renderer`: Pointer to the SDL_Renderer used for rendering.
     * - `emoji_num`: Integer representing the emoji number to render.
     */
    void RenderEmoji(SDL_Renderer* renderer,int emoji_num){
        // Load the image corresponding to the emoji_num
        string filepath = "./assets/images/emoji" ~ to!string(emoji_num) ~ ".bmp";  // Assuming the image format is BMP.
        // Load the bitmap surface of emoji
        SDL_Surface* myEmojiImage   = SDL_LoadBMP(filepath.ptr);

        // set up the rectangle on the top of the sprite to render the emoji.
        emojiRectangle.x = mXPos + 15;
        emojiRectangle.y = mYPos - 50;
        emojiRectangle.w = 40;
        emojiRectangle.h = 40;

        // Create a texture from the surface
        emojiTexture = SDL_CreateTextureFromSurface(renderer,myEmojiImage);
        // Done with the bitmap surface pixels after we create the texture, we have
        // effectively updated memory to GPU texture.
        SDL_FreeSurface(myEmojiImage);

        // Render our emoji image on a rectangle.
        SDL_RenderCopy(renderer,emojiTexture,null,&emojiRectangle);

    }
}