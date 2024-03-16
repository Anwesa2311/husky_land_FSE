module tilemap;

// Load the SDL2 library
import bindbc.sdl;
import player;
import std.stdio;

/***********************************
*    The following is a struct for a DrawableTileMap.
*    This is responsible for drawing the actual tiles for the tilemap data structure.
*
*/
struct DrawableTileMap{
    const int mMapXSize = 16;
    const int mMapYSize = 16;
 
    // Tile map with tiles
    TileSet mTileSet;

    // Static array for now for simplicity}
    int [mMapXSize][mMapYSize] mTiles;

    // Array of boundary tiles
    int[] mBoundaryTiles = [40,29,15,13,57,59,18,19,4,5,26];

    // Set the tileset
    /***********************************
    * Constructor for DrawableTileMap.
    * Params: t = TileSet used for loading and rendering tiles.
    */
    this(TileSet t){
        // Set our tilemap
        mTileSet = t;
        setLobbyTiles();
    }

    void setDefaultTiles() {
        // Set all tiles to 'default' tile
        int[][] initialTiles = [[29,40,40,40,40,40,40,40,40,40,40,40,40,40,40,29],
                                [40,48,48,48,48,48,48,48,15,0,0,0,0,24,0,40],
                                [40,48,42,48,48,48,48,48,0,0,0,0,0,0,0,40],
                                [40,48,48,48,4,26,5,48,0,12,0,0,0,0,0,40],
                                [40,48,48,48,15,0,13,48,16,3,0,1,2,6,2,40],
                                [40,26,26,26,27,12,13,48,57,15,0,13,40,18,40,40],
                                [40,0,0,0,0,0,13,48,48,48,48,48,48,30,48,40],
                                [40,0,12,1,2,2,17,48,49,48,48,48,48,48,48,40],
                                [40,0,0,13,22,23,40,48,48,48,48,48,48,48,48,40],
                                [40,0,0,13,48,48,48,48,48,48,48,4,26,26,26,40],
                                [40,2,2,17,49,48,48,48,48,48,48,15,0,0,0,40],
                                [40,19,40,59,48,48,48,48,48,48,48,15,0,0,0,40],
                                [40,50,51,52,53,48,48,48,48,48,48,0,0,24,0,40],
                                [40,48,48,48,48,48,48,48,48,48,48,0,0,0,0,40],
                                [40,48,48,48,48,48,48,48,48,48,48,15,12,0,0,40],
                                [29,40,40,40,40,40,40,40,40,40,40,40,40,40,40,29]];

        // Copy values from initialTiles to mTiles
        for (int y = 0; y < mMapYSize; y++) {
            for (int x = 0; x < mMapXSize; x++) {
                mTiles[x][y] = initialTiles[y][x];
            }
        }
    }

    void setLobbyTiles() {
        // Set all tiles to 'default' tile
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                if(y==0){
                   mTiles[x][y] = 40;
                } 
                else if(y==mMapYSize-1){
                    mTiles[x][y] =40;
                } 
                else if(x==0){
                    mTiles[x][y] =40;
                } 
                else if(x==mMapXSize-1){
                    mTiles[x][y] =40;
                } 
                else{
                    // Default tile
                    mTiles[x][y] =0;
                }
            }
        }

        // Adjust the corners
        mTiles[0][0] = 29;
        mTiles[mMapXSize-1][0] = 29;
        mTiles[0][mMapYSize-1] = 29;
        mTiles[mMapXSize-1][mMapYSize-1] = 29;
    }
 
    /***********************************
    * Renders the tiles of the tile map using the specified SDL renderer.
    * Params: 
    *       renderer = The SDL renderer for rendering tiles.
    *       zoomFactor = an optional input used for zooming in or out when rendering the tiles.
    * Return: None.
    */
    void Render(SDL_Renderer* renderer, int zoomFactor=1){
        for(int y=0; y < mMapYSize; y++){
            for(int x=0; x < mMapXSize; x++){
                mTileSet.RenderTile(renderer,mTiles[x][y],x,y,zoomFactor);
            }
        }
    }

    /***********************************
    * Gets the tile value at the specified local coordinates.
    * Params:
    *       localX = The local x-coordinate of the tile.
    *       localY = The local y-coordinate of the tile.
    *       zoomFactor = an optional input used for zooming in or out when rendering the tiles.
    * Return: The tile value at the specified local coordinates.
    */
    int GetTileAt(int localX, int localY, int zoomFactor=1){
        int x = localX / (mTileSet.mTileSize * zoomFactor);
        int y = localY / (mTileSet.mTileSize * zoomFactor);

        if(x < 0 || y < 0 || x> mMapXSize-1 || y > mMapYSize-1 ){
            // TODO: Perhaps log error?
            // Maybe throw an exception -- think if this is possible!
            // You decide the proper mechanism!
            return -1;
        }
        // writeln("we are at tile", mTiles[x][y], " AKA (", x, ", ", y, ")");
        return mTiles[x][y]; 
    }

    /***********************************
    * Checks if a given tile is a boundary tile.
    * Params:
    *       tile = The tile value to check.
    * Return: true if the tile is a boundary, false otherwise.
    */
    bool IsBoundaryTile(int tile) {
        foreach (boundaryTile; mBoundaryTiles) {
            if (tile == boundaryTile) {
                // writeln("this is a boundary tile");
                return true;
            }
        }
        
        return false;
    }

}




/***********************************
* Tilemap struct for loading a tilemap and rendering tiles
*/
struct TileSet{

        // Rectangle storing a specific tile at an index
		SDL_Rect[] mRectTiles;
        // The full texture loaded onto the GPU of the entire
        // tile map.
		SDL_Texture* mTexture;
        // Tile dimensions (assumed to be square)
        int mTileSize;
        // Number of tiles in the tilemap in the x-dimension
        int mXTiles;
        // Number of tiles in the tilemap in the y-dimension
        int mYTiles;

        /***********************************
        * Constructs a TileSet by loading a tile map texture from a file.
        * Params:
        *       renderer = The SDL renderer for rendering tiles
        *       filepath = The file path to the BMP image for the tile set.
        *       tileSize = The size of each tile.
        *       xTiles = The number of tiles in the x-dimension.
        *       yTiles = The number of tiles in the y-dimension.
        */
		this(SDL_Renderer* renderer, string filepath, int tileSize, int xTiles, int yTiles){
            mTileSize = tileSize;
            mXTiles   = xTiles;
            mYTiles   = yTiles;

			// Load the bitmap surface
			SDL_Surface* myTestImage   = SDL_LoadBMP(filepath.ptr);
			// Create a texture from the surface
			mTexture = SDL_CreateTextureFromSurface(renderer,myTestImage);
			// Done with the bitmap surface pixels after we create the texture, we have
			// effectively updated memory to GPU texture.
			SDL_FreeSurface(myTestImage);

            // Populate a series of rectangles with individual tiles
            for(int y = 0; y < yTiles; y++){
                for(int x =0; x < xTiles; x++){
                    SDL_Rect rect;
			        rect.x = x*tileSize;
        			rect.y = y*tileSize;
		        	rect.w = tileSize;
        			rect.h = tileSize;

                    mRectTiles ~= rect;
                }
            }
		}


        /***********************************
        * Helper function that displays all of the tiles
        * one after the other in an animation as a quick way to
        * preview the tile.
        * Params:
        *       renderer = The SDL renderer for rendering tiles.
        *       x = The x-coordinate for rendering the animation.
        *       y = The y-coordinate for rendering the animation.
        *       zoomFactor = An optional input used for zooming in or out when rendering the tiles.
        * Return: None.
        */
        void ViewTiles(SDL_Renderer* renderer, int x, int y, int zoomFactor=1){
            import std.stdio;

			static int tilenum =0;

            if(tilenum > mRectTiles.length-1){
				tilenum =0;
			}

            // Just a little helper for you to debug
            // You can omit this as necessary
            writeln("Showing tile number: ",tilenum);

            // Select a specific tile from our
            // tiemap texture, by offsetting correcting
            // into the tilemap
			SDL_Rect selection;
            selection = mRectTiles[tilenum];

            // Draw a preview of the actual tile
            SDL_Rect rect;
            rect.x = x;
            rect.y = y;
            rect.w = mTileSize * zoomFactor;
            rect.h = mTileSize * zoomFactor;

    	    SDL_RenderCopy(renderer,mTexture,&selection,&rect);
			tilenum++;
        }


        /***********************************
        * Helper function that tells you which tile your mouse is over.
        * Params:
        *       renderer = The SDL renderer for rendering tiles.
        * Return: None.
        */
        void TileSetSelector(SDL_Renderer* renderer){
            import std.stdio;
            
            int mouseX,mouseY;
            int mask = SDL_GetMouseState(&mouseX, &mouseY);

            int xTileSelected = mouseX / mTileSize;
            int yTileSelected = mouseY / mTileSize;
            int tilenum = yTileSelected * mXTiles + xTileSelected;
            if(tilenum > mRectTiles.length-1){
                return;
            }

            writeln("mouse  : ",mouseX,",",mouseY);
            writeln("tile   : ",xTileSelected,",",yTileSelected);
            writeln("tilenum: ",tilenum);

            SDL_SetRenderDrawColor(renderer, 255, 255, 255,255);

            // Tile to draw out on
            SDL_Rect rect = mRectTiles[tilenum];

            // Copy tile to our renderer
            // Note: We need a rectangle that's the exact dimensions of the
            //       image in order for it to render appropriately.
            SDL_Rect tilemap;
            tilemap.x = 0;
            tilemap.y = 0;
            tilemap.w = mXTiles * mTileSize;
            tilemap.h = mYTiles * mTileSize;
    	    SDL_RenderCopy(renderer,mTexture,null,&tilemap);
            // Draw a rectangle
            SDL_RenderDrawRect(renderer, &rect);
        }
        /// 
        /***********************************
        * Draw a specific tile from our tilemap
        * Params:
        *       renderer = The SDL renderer for rendering tiles.
        *       tile = The index of the tile to render.
        *       x = The x-coordinate for rendering the tile.
        *       y = The y-coordinate for rendering the tile.
        *       zoomFactor = An optional input used for zooming in or out when rendering the tiles.
        * Return: None.
        */
		void RenderTile(SDL_Renderer* renderer, int tile, int x, int y, int zoomFactor=1){
            if(tile > mRectTiles.length-1){
                // NOTE: Could use 'logger' here to log an error
                return;
            }

            // Select a specific tile from our
            // tiemap texture, by offsetting correcting
            // into the tilemap
			SDL_Rect selection = mRectTiles[tile];

            // Tile to draw out on
            SDL_Rect rect;
            rect.x = mTileSize * x * zoomFactor;
            rect.y = mTileSize * y * zoomFactor;
            rect.w = mTileSize * zoomFactor;
            rect.h = mTileSize * zoomFactor;
 
            // Copy tile to our renderer
    	    SDL_RenderCopy(renderer,mTexture,&selection,&rect);
		}
}
