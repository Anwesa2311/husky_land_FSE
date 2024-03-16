import sdl_app : SDLApp;
import player: Player;
import sprite;
import bindbc.sdl;
import window;
@("testing player initialization")
unittest
{
    Window window;
    window.w = 768;
    window.h = 768;
    window.window = SDL_CreateWindow("D SDL Tilemap Example",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        window.w,
        window.h,
        SDL_WINDOW_SHOWN);

    SDL_Renderer* renderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
    Player player1 = Player(renderer, "./assets/images/cutie.bmp", 50, 50,"user1");
    Sprite sprite1 = player1.mSprite;
    assert(player1.username == "user1", "Username passed in correctly.");
    assert(sprite1.userName == "user1\0", "Username passed into sprite correctly.");

    destroy(window);
}