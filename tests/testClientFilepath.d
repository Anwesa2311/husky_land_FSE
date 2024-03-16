import sdl_app : SDLApp;

@("testing filepath assignment accuracy")
unittest
{
    SDLApp app = new SDLApp();
    string[] playerFilePaths = app.playerFilePaths;
    string correctFilepath = playerFilePaths[1];
    string correctFilepath2 = playerFilePaths[0];
    int clientNum = 4;
    int clientNum2 = 6;
    assert(app.getClientToPlayerPath(clientNum, playerFilePaths) == correctFilepath, "Calculation is incorrect");
    assert(app.getClientToPlayerPath(clientNum2, playerFilePaths) == correctFilepath2, "Calculation is incorrect");
    assert(app.getClientToPlayerPath(2, playerFilePaths) != correctFilepath2, "Calculation is incorrect");
}
