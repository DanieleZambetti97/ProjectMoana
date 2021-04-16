# ProjectMoana

PorjectMoana is a Julia program for converting PFM images into HDR images such as JPEG and PNG formats.

## Requirements
1. Running this program requires an installed version of Julia Language (v1.5 or later, download [here](https://julialang.org/downloads/));
2. This program needs command-line inputs to run, then can only works on Linux/MacOS machines. If you are using a Windows machine we recommend to install a [WSL](https://docs.microsoft.com/it-it/windows/wsl/install-win10).

## Installation
1. Download the latest version tar.gz file from the ProjectMoana GitHub [repository](https://github.com/DanieleZambetti97/ProjectMoana/releases/tag/v0.1.0) or from the terminal:
```bash
wget https://github.com/DanieleZambetti97/ProjectMoana/archive/refs/tags/v0.1.0.tar.gz
```

> Note: check for the latest version on the repo and change to the current one in the above command.

2. Exctract the file in the directory you want to use the program:
```bash
tar -xf v0.1.0.tar.gz -C /path/to/your/directory
```
3. From the Julia REPL import Pkg and activate the ProjectMoana package with the following commands:
```bash
~$ julia
julia> using Pkg 		     # press ] to enter the package manager;
(@v1.5) pkg> activate .
(ProjectMoana) pkg>      # press backspace to exit;
julia> Pkg.instantiate() # this command will download and update the dependencies needed (it might take a while...);
julia> exit()			       # exiting the REPL.
```

## Usage

Now just type:
```bash
~$ julia main.jl [--help] [IN_FILE] [A_FACTOR] [γ] [OUT_FILE]
```
where $a$ is the tone mapping parameter and $\gamma$ is the monitor-response parameter. They both are set to a default value but can be changed. 
Just type `julia main.jl --help` for more detailed usage information.
The converted HDR image will be saved in the current directory.

## Contributing
[Pull requests](https://github.com/DanieleZambetti97/ProjectMoana/pulls) are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
This program is under a [MIT](https://github.com/DanieleZambetti97/ProjectMoana/blob/master/LICENSE) license.
<!--stackedit_data:
eyJoaXN0b3J5IjpbODMxMjkzNjQwLC0xNjM2ODY5NjI0LDE3Mz
czMTU1MTcsLTczMzAzMTczMCwtMTk3NjkwNTM3MywyMDIwODEx
NjAyXX0=
-->