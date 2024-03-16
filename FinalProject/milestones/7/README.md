# Building Software

- [ ] Instructions on how to build your software should be written in this file
	- This is especially important if you have added additional dependencies.
	- Assume someone who has not taken this class (i.e. you on the first day) would have read, build, and run your software from scratch.
- You should have at a minimum in your project
	- [ ] A dub.json in a root directory
    	- [ ] This should generate a 'release' version of your software
  - [ ] Run your code with the latest version of d-scanner before commiting your code (could be a github action)
  - [ ] (Optional) Run your code with the latest version of clang-tidy  (could be a github action)

Please follow the steps below to build and run the huskyland software on your system. 
Ensure that you have** DUB — the D package manager** — and a **D compiler like DMD or LDC** installed on your system before proceeding.

### Step 1: Clone the Repository
Clone the repository using your preferred method:

**SSH:**  
`git clone git@github.com:Fall23FSE/finalproject-huskyland.git`

**HTTPS:**   
`git clone https://github.com/Fall23FSE/finalproject-huskyland.git`

### Step 2: Install Dependencies

This project depends on the following libraries:
1) `bindbc-sdl`
2) `bindbc-loader`
3) `unit-threaded`

They are listed in `dub.selections.json` and will be **automatically downloaded** by DUB during the build process.

This project also requires SDL TTF. To install on MacOS:   
`brew install sdl2_tff`

### Step 3: Build and run using DUB

Run this command from the root directory of the project:   
`dub`

### Step 4: Running the Application

After building successfully, the terminal will prompt you with some questions before running the application. It will ask you if you're the host (y/n), and if you are, you will enter a nickname and a port number.  The program will tell you what your host address is.  If you're not the host, then be sure to acquire the host address and port from the host, and type each in when prompted.

### Additional Notes
**Gameplay Hotkeys:**  
`t` &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;  Enter type mode   
`e` &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;  Enter emoji mode   
`w, UP` &emsp;&emsp;&emsp;&emsp; Move up   
`a, LEFT`&emsp;&emsp;&emsp;&nbsp; Move up   
`s, DOWN`&emsp;&emsp;&emsp;&nbsp; Move up   
`d, RIGHT` &emsp;&emsp;&nbsp; Move up   
`ESC` &emsp;&emsp;&emsp;&emsp;&emsp; Exit type mode or emoji mode   
`q` &emsp;&emsp;&emsp;&emsp;&emsp;&emsp; Quit the application   


**SDL2 libraries** must be installed on your system as these are required dependencies for bindbc-sdl. Visit https://wiki.libsdl.org/Installation for instructions specific to your operating system.
Ensure that you also have the SDL2_ttf library installed on your system. Visit https://www.libsdl.org/projects/SDL_ttf/ for more information.
Make sure your system paths are set correctly for the D compiler and DUB.
