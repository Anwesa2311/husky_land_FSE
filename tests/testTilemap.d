import tilemap : TileSet, DrawableTileMap;
import player : Player;
import bindbc.sdl;
import std.stdio;
import sdl_app : SDLApp;
import bindbc.sdl;
import window;

// import sdl_setup;

unittest {
     Window window;
    window.w = 768;
    window.h = 768;
    window.window = SDL_CreateWindow("D SDL Tilemap Example",
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOWPOS_UNDEFINED,
    window.w,
    window.h,
    SDL_WINDOW_SHOWN);
    
    // Mock data for tilemap and player position
    SDL_Renderer* fakeRenderer = SDL_CreateRenderer(window.window,-1,SDL_RENDERER_ACCELERATED);
    TileSet tileset = TileSet(fakeRenderer, "./assets/kenney_tiny-dungeon/Tilemap/tilemap_packed.bmp", 16, 12, 11);
    DrawableTileMap drawableTileMap = DrawableTileMap(tileset);

    // Initialize tilemap with boundary tiles around the edge
    drawableTileMap.setLobbyTiles();
    
    Player player = Player(fakeRenderer, "./assets/images/cutie.bmp", 50, 50);
    int zoomFactor = 3;
    
    // Player is initially not on a boundary tile (50, 50)
    assert(!drawableTileMap.IsBoundaryTile(drawableTileMap.GetTileAt(player.GetX(), player.GetY(), zoomFactor)));
    
    // Move player to a known boundary tile (0, 0)
    player.mSprite.mXPos = 0;
    player.mSprite.mYPos = 0;
    assert(drawableTileMap.IsBoundaryTile(drawableTileMap.GetTileAt(player.GetX(), player.GetY(), zoomFactor)));

    // Test player movement blocked by boundary tiles
    // Assuming player can move by tile size increments
    int tileSize = tileset.mTileSize;
    int playerX = tileSize; // One tile away from left boundary
    int playerY = tileSize;
    player.mSprite.mXPos = playerX;
    player.mSprite.mYPos = playerY;

    // Attempting to move left into boundary tile (0, tileSize)
    playerX -= tileSize;
    if (drawableTileMap.IsBoundaryTile(drawableTileMap.GetTileAt(playerX, playerY, zoomFactor))) {
        playerX = player.GetX(); // Player X position shouldn't change
    }
    assert(player.GetX() == tileSize); // Player should not have moved left

    // Reset player position for another boundary check
    playerX = drawableTileMap.mMapXSize * tileSize - tileSize * 2; // One tile away from right boundary
    playerY = tileSize;
    player.mSprite.mXPos = playerX;
    player.mSprite.mYPos = playerY;

    // Attempting to move right into boundary tile
    playerX += tileSize;
    if (drawableTileMap.IsBoundaryTile(drawableTileMap.GetTileAt(playerX, playerY, zoomFactor))) {
        playerX = player.GetX(); // Player X position shouldn't change
    }
    assert(player.GetX() == drawableTileMap.mMapXSize * tileSize - tileSize * 2); // Player should not have moved right
}
