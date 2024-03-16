//module tests.test6;
import player;
import sdl_app : SDLApp;

@("Get Player's (x, y) coordinates before and after movement")
unittest{
    SDLApp app = new SDLApp();
    assert(app.player.GetX() == 50, "Not originally set to x = 50");
    assert(app.player.GetY() == 50, "Not originally set to y = 50");
    app.player.MoveDown();
    assert(app.player.GetY() == 66, "Y not offset by +16");
    app.player.MoveRight();
    assert(app.player.GetX() == 66, "X not offset by +16");
    app.player.MoveUp();
    assert(app.player.GetY() == 50, "Y not offset by -16");
    app.player.MoveLeft();
    assert(app.player.GetX() == 50, "X not offset by -16");

}

