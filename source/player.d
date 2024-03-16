module player;

// Load the SDL2 library
import bindbc.sdl;
import sprite;
/***********************************
* This struct represents the player, encapsulating
* the player's state, its sprite, and movement control.
*/
struct Player{
    // Load our sprite
    Sprite mSprite;
    string username;
    int emojiNum = 0;


    /***********************************
     * Constructs a Player with the specified renderer and image file.
     * Params:
     *       renderer = The SDL renderer for rendering.
     *       filepath = The file path to the BMP image for the player's sprite.
     *       startX = The x position of the map where the player's sprite will be rendered.
     *       startY = The y position of the map where the player's sprite will be rendered.
     *       username = The username of the player.
     */
    this(SDL_Renderer* renderer, string filepath, int startX, int startY, string username_input){
        username = username_input;
        mSprite = Sprite(renderer,filepath, startX, startY, username);
    }


    /***********************************
     * Constructs a Player with the specified renderer and image file.
     * Params:
     *       renderer = The SDL renderer for rendering.
     *       filepath = The file path to the BMP image for the player's sprite.
     */
    this(SDL_Renderer* renderer, string filepath, int startX, int startY){
        mSprite = Sprite(renderer,filepath, startX, startY, username);
    }

    /***********************************
     * Gets the X-coordinate of the player's sprite.
     * Params: None.
     * Return: The X-coordinate of the player's sprite.
     */
    int GetX(){
        return mSprite.mXPos;
    }

    /***********************************
     * Gets the Y-coordinate of the player's sprite.
     * Params: None.
     * Return: The Y-coordinate of the player's sprite.
     */
    int GetY(){
        return mSprite.mYPos;
    }

    /***********************************
     * Gets the name of the player's sprite.
     * Params: None.
     * Return: The name of the player's sprite.
     */
    string getUsername() {
        return mSprite.userName;
    }

    /***********************************
     * Gets the filepath for the player's sprite.
     * Params: None.
     * Return: The name of the player's sprite.
     */
    string getSpritePath() {
        return mSprite.spritePath;
    }

    /***********************************
     * Moves the player's sprite up and sets the state to walking.
     * Params: None.
     * Return: None.
     */
    void MoveUp(){
        mSprite.mYPos -=16;
        mSprite.mState = STATE.WALK;
        mSprite.SetAnimationRow(3);
    }

    /***********************************
     * Moves the player's sprite down and sets the state to walking.
     * Params: None.
     * Return: None.
     */
    void MoveDown(){
        mSprite.mYPos +=16;
        mSprite.mState = STATE.WALK;
        mSprite.SetAnimationRow(0);
    }

    /***********************************
     * Moves the player's sprite left and sets the state to walking.
     * Params: None.
     * Return: None.
     */
    void MoveLeft(){
        mSprite.mXPos -=16;
        mSprite.mState = STATE.WALK;
        mSprite.SetAnimationRow(1);
    }

    /***********************************
     * Moves the player's sprite right and sets the state to walking.
     * Params: None.
     * Return: None.
     */
    void MoveRight(){
        mSprite.mXPos +=16;
        mSprite.mState = STATE.WALK;
        mSprite.SetAnimationRow(2);
    }

    /***********************************
     * Renders the player's sprite based on a specific renderer.
     * Params:
     *      renderer = The SDL renderer for rendering.
     * Return: None.
     */
    void Render(SDL_Renderer* renderer){
        mSprite.Render(renderer);
        mSprite.mState = STATE.IDLE;
    }

    /***********************************
     * Renders the emoji based on a specific renderer and a number.
     * Params:
     *      renderer = The SDL renderer for rendering.
     *      emoji_num = The number of the emoji in the emoji menu.
     * Return: None.
     */
    void RenderEmojiShared(SDL_Renderer* renderer){
        mSprite.RenderEmoji(renderer,emojiNum);
    }
}