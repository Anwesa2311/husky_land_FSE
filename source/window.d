// Load the SDL2 library
import bindbc.sdl;
import loader = bindbc.loader.sharedlib;

/***********************************
     * Represents the SDL window
     *
     * Params:
     * - `SDL_Window* window`: Pointer to the SDL_Window that holds the project.
     * - `int w`: width of window
     * - `int h`: height of window
     */
struct Window{
    SDL_Window* window;
    int w;
    int h;

    ~this(){
        SDL_DestroyWindow(window);
    }
}