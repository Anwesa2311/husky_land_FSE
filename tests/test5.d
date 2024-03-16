//module tests.test5;
import sdl_app;
import tilemap;


@("Testing a boundary tile")
unittest{
    SDLApp app = new SDLApp();
    app.dt.mTiles[5][5] = 29;
    app.dt.mTiles[7][9] = 30;
    assert(app.dt.IsBoundaryTile(app.dt.mTiles[5][5]), "Not a boundary tile");
    assert(!app.dt.IsBoundaryTile(app.dt.mTiles[7][9]), "This is a boundary tile");

}